SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Send_Notifications]
	@Load_GUID AS VARCHAR(38),
	@ScheduleId AS INT
AS
BEGIN	--1

SET NOCOUNT ON;

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
DECLARE @ProcName AS VARCHAR(MAX)=(SELECT OBJECT_NAME(@@PROCID))
DECLARE @StartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage start',@ProcName,@StartTime,NULL
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

DECLARE @ThisDatasetRowId AS INT
DECLARE @MinDatasetRowId AS INT
DECLARE @ThisRuleRowId AS INT
DECLARE @MaxRuleRowId AS INT
DECLARE @ThisContactRowId AS INT
DECLARE @MaxContactRowId AS INT
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @DatasetName AS VARCHAR(50)
DECLARE @DatasetDescription AS VARCHAR(100)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DatasetFullName AS VARCHAR(150)
DECLARE @DatasetId AS INT
DECLARE @ContactName AS VARCHAR(50)
DECLARE @ContactTypeName AS VARCHAR(50)
DECLARE @RuleId AS INT
DECLARE @RuleName AS VARCHAR(50)
DECLARE @ContentName AS VARCHAR(50)
DECLARE @Message AS NVARCHAR(MAX)=''
DECLARE @MessageItemCount AS INT
DECLARE @MessageRuleName AS VARCHAR(50)
DECLARE @MessageFieldName AS VARCHAR(50)

DECLARE @Datasets AS TABLE(
	RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupName				VARCHAR(50),
	DatasetId				INT,
	DatasetName				VARCHAR(50),
	DatasetDescription		VARCHAR(100),
	DatasetType				VARCHAR(50),
	DependencyOrder			INT		--technically we don't need this, but it's prolly better to receive the notification about errors in the dependency dataset first before the main one
)
DECLARE @Rules AS TABLE(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetId			INT,
	RuleId				INT,
	RuleName			VARCHAR(50),
	ItemCount			INT
)
DECLARE @Contacts AS TABLE(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ContactId			INT,
	ContactName			VARCHAR(50),
	ContactValue		VARCHAR(50),
	ContactTypeId		INT,
	ContactTypeName		VARCHAR(50),
	RuleId				INT,
	DatasetId			INT
)
DECLARE @DistinctContacts AS TABLE(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ContactId			INT,
	ContactValue		VARCHAR(50),
	ContactType			VARCHAR(50)
)

INSERT INTO @Datasets(DatasetGroupName,DatasetId,DatasetName,DatasetDescription,DatasetType,DependencyOrder)
SELECT DISTINCT
		DG.Name, 
		D.Id,
		D.Name,
		D.Description,
		DT.Name,
		1
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN Landing_Config.dbo.RuleContacts RC ON D.Id=RC.DatasetId
		INNER JOIN Landing_Config.dbo.DatasetRules DR ON D.Id=DR.DatasetId
	WHERE 
		DG.Active='Y' AND D.Active='Y' AND D.ScheduleId=@ScheduleId
INSERT INTO @Datasets(DatasetGroupName,DatasetId,DatasetName,DatasetDescription,DatasetType,DependencyOrder)
	SELECT 
		DG.Name, 
		D.Id,
		D.Name,
		D.Description,
		DT.Name,
		2
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
	WHERE 
		DG.Active='Y' AND D.Active='Y' AND DD.DatasetId IN (SELECT DatasetId FROM @Datasets)

--SELECT 'Datasets',SystemName, DatasetId, DatasetName, DatasetType, DependencyOrder FROM @Datasets

SELECT @ThisDatasetRowId = MAX(RowId), @MinDatasetRowId = Min(RowId) FROM @Datasets

WHILE @ThisDatasetRowId >= @MinDatasetRowId

	BEGIN	--2
		SELECT 
			@DatasetGroupName=D.DatasetGroupName,
			@DatasetId=D.DatasetId,
			@DatasetName=D.DatasetName,
			@DatasetDescription=D.DatasetDescription,
			@DatasetType=D.DatasetType,
			@DatasetFullName=D.DatasetGroupName+'_'+D.DatasetType+'_'+D.DatasetName
		FROM
			@Datasets D
		WHERE
			D.RowId=@ThisDatasetRowId

		INSERT INTO @Contacts(ContactId,ContactName,ContactValue,ContactTypeId,ContactTypeName,RuleId,DatasetId)
		SELECT
			C.Id,C.Name,C.Value,
			CT.Id,CT.Name,
			RC.RuleId,
			@DatasetId
		FROM
			Landing_Config.dbo.Contact C
			INNER JOIN Landing_Config.dbo.ContactType CT ON C.TypeId=CT.Id
			INNER JOIN Landing_Config.dbo.RuleContacts RC ON C.Id=RC.ContactId AND RC.DatasetId=@DatasetId
		WHERE
			C.Active='Y'
		
--SELECT * FROM @Contacts

		INSERT INTO @DistinctContacts(ContactId,ContactValue,ContactType)
		SELECT DISTINCT ContactId,ContactValue,ContactTypeName FROM @Contacts
		SELECT @ThisContactRowId=MIN(RowId),@MaxContactRowId=MAX(RowId) FROM @DistinctContacts

		SET @SQL='
			SELECT
				'+CAST(@DatasetId AS VARCHAR(10))+',
				E.RuleId,
				CASE 
					WHEN E.RuleId=-1 THEN ''Incorrect datatype''
					WHEN R.Name IS NULL THEN ''Unknown rule''
					ELSE R.Name
				END AS RuleName,
				COUNT(*)
			FROM
				Landing_Exception.dbo.'+@DatasetFullName+' E 
				LEFT JOIN Landing_Config.dbo.[Rule] R ON E.RuleId=R.Id
				
			WHERE
				E.Load_GUID='''+@Load_GUID+'''
			GROUP BY
				E.RuleId,
				CASE 
					WHEN E.RuleId=-1 THEN ''Incorrect datatype''
					WHEN R.Name IS NULL THEN ''Unknown rule''
					ELSE R.Name
				END
		'
		INSERT INTO @Rules(DatasetId,RuleId,RuleName,ItemCount)
		EXEC(@SQL)
		
		--SELECT @ThisRuleRowId=MIN(RowId),@MaxRuleRowId=MAX(RowId) FROM @Rules
--SELECT * FROM @Rules
		WHILE @ThisContactRowId<=@MaxContactRowId
			BEGIN
				DECLARE @RecipientValue AS VARCHAR(50)
				DECLARE @RecipientType AS VARCHAR(50)
				SELECT @RecipientValue=ContactValue,@RecipientType=ContactType FROM @DistinctContacts DC WHERE DC.RowId=@ThisContactRowId 

				IF @RecipientType='SMS'
					BEGIN
						--NEED TO DO THIS A ROW AT A TIME SO WE'RE NOT SENDING ALL THE STUFF IN ONE BLOCK
						--SO WE'LL HAVE TO GET THE ROWID FOR EACH RULE THAT THIS RECIPIENT IS INTERESTED IN
						--Nope, for now just send the whole lot, noone'll use this anyway
						DECLARE @ThisSMSRow AS INT
						DECLARE @MaxSMSRow AS INT
	
						SELECT 
							@ThisSMSRow=MIN(R.RowId),
							@MaxSMSRow=MAX(R.RowId) 
						FROM 
							@Rules R
							LEFT JOIN @Contacts C ON R.RuleId=C.RuleId
							LEFT JOIN @DistinctContacts DC ON C.ContactId=DC.ContactId
						WHERE
							DC.RowId=@ThisContactRowId OR R.RuleId IN (0,-1)

--SELECT @ThisSMSRow,@MaxSMSRow

						WHILE @ThisSMSRow<=@MaxSMSRow
							BEGIN
								SELECT
								@MessageItemCount=R.ItemCount,
								@MessageRuleName=R.RuleName
								FROM
									@Rules R
								WHERE
									R.RowId=@ThisSMSRow 
								
								SET @Message+=CAST(@MessageItemCount AS NVARCHAR(10))+' records broke rule '''+CAST(@MessageRuleName AS NVARCHAR(50))+''' in dataset '+CAST(@DatasetName AS NVARCHAR(50))+'    '
							
--SELECT @Message
								SET @ThisSMSRow+=1
							END
--SELECT @Message
						DECLARE @SMSResult AS NVARCHAR(MAX)
						EXEC Landing_Config.dbo.__SendSMS @Message,'07725258028',@SMSResult OUTPUT
					END
				ELSE IF @RecipientType='Email'
					BEGIN
						DECLARE @tableHTML VARCHAR(MAX)='
							<style type="text/css">
								#table-rules
								{
									width:100%;
									font-family: Trebuchet MS;
									font-size: 12px;
									text-align: Left;
									border-collapse: collapse;
								}
								#table-rules td
								{
									border-top: 1px solid #aabcfe;
									border-right: 1px solid #aabcfe;
									border-left: 1px solid #aabcfe;
									border-bottom: 1px solid #aabcfe;
									color: #669;
									padding:5px 20px 5px 20px;
								}
								tr:nth-child(odd) { background-color:#eee; }
								tr:nth-child(even) { background-color:#fff; }
							</style>
							<table>
								<tr>
									<td width=''75%'' align=''center'' style=''font-family:Trebuchet MS;font-size:x-large;color:MidnightBlue;font-weight:bold;padding-bottom:20px''>
										<div style=''display: table-cell;vertical-align: middle''>
											Data warehouse load exception notification
										</div>
									</td>
								</tr>
								<tr>
									<td width=''75%'' align=''center'' style=''font-family:Trebuchet MS;font-size:x-large;color:MidnightBlue;font-weight:bold''>
										<div style=''display: table-cell;vertical-align: middle''>
											'+
											@DatasetFullName
											+'
										</div>										
									</td>
								</tr>
								<tr>
									<td width=''75%'' align=''center'' style=''font-family:Trebuchet MS;font-size:x-large;color:MidnightBlue;font-weight:bold;padding-bottom:20px''>
										<div style=''display: table-cell;vertical-align: middle''>
											'+
											@DatasetDescription
											+'
										</div>
									</td>
								</tr>
								<tr>
									<td width=''75%'' align=''center'' style=''font-family:Trebuchet MS;font-size:x-large;color:MidnightBlue;font-weight:bold;padding-bottom:20px''>
										<hr width=''100%'' align=''center'' style=''color:#669''>
									</td>
								</tr>
								<tr>
									<td width=''75%'' align=''center''>
										<table id=''table-rules''>
											'+
											CAST
												(
													(
														SELECT
															td=R.RuleName,'',
															td=R.ItemCount,''
														FROM
															@Rules R 
															LEFT JOIN @Contacts C ON R.RuleId=C.RuleId
															LEFT JOIN @DistinctContacts DC ON C.ContactId=DC.ContactId

															--@DistinctContacts DC
															--INNER JOIN @Contacts C ON DC.ContactId=C.ContactId
															--INNER JOIN @Rules R ON C.RuleId=R.RuleId
														WHERE
															DC.RowId=@ThisContactRowId OR R.RuleId IN (0,-1)
														ORDER BY
															R.ItemCount DESC
														FOR XML PATH('tr'),TYPE
													) AS VARCHAR(MAX)
												)
											+'
										</table>
									</td>
								</tr>
							</table>							'
							
	
	--select @tableHTML

							exec msdb.dbo.sp_send_dbmail 
							@from_address='Iris <BCU.InformationDepartment@wales.nhs.uk>',
							@recipients=@RecipientValue,
							--@copy_recipients='martin.parry2@wales.nhs.uk',
							@subject = 'Data warehouse load exception notification', 
							@body = @tableHTML,
							@body_format = 'HTML';
					END
			SET @ThisContactRowId+=1
		END

		DELETE @DistinctContacts
		DELETE @Contacts
		DELETE @Rules
		
		--INSERT INTO @Contacts(ContactId,ContactName,ContactTypeId,ContactTypeName,DatasetId,RuleId,RuleName)--,ContentId,ContentName)
		--SELECT
		--	C.Id,C.Name,
		--	CT.Id,CT.Name,
		--	@DatasetId,
		--	R.Id,R.Name
		--	--CE.Id,CE.Name
		--FROM
		--	Landing_Config.dbo.Contact C
		--	INNER JOIN Landing_Config.dbo.ContactType CT ON C.TypeId=CT.Id
		--	INNER JOIN Landing_Config.dbo.RuleContacts RC ON C.Id=RC.ContactId AND RC.DatasetId=@DatasetId
		--	INNER JOIN Landing_Config.dbo.[Rule] R ON RC.RuleId=R.Id
		--WHERE
		--	C.Active='Y'
		
		--SELECT @ThisContactRowId=MIN(RowId),@MaxContactRowId=MAX(RowId) FROM @Contacts
		--SELECT * FROM @Contacts
		--DELETE @Contacts

		--WHILE @ThisContactRowId<=@MaxContactRowId
		--	BEGIN
				
				
		--	END
		--DELETE @Contacts
	--	INSERT INTO @ContactRules(RuleId,RuleName,ContactId)
	--	SELECT DISTINCT
	--		R.Id,R.Name,
	--		C.Id
	--	FROM
	--		Landing_Config.dbo.[Rule] R

			
	--SELECT 'Notifications',ContactId,ContactName,ContactTypeId,ContactTypeName,RuleId,RuleName FROM @Notifications	

	--	SELECT @ThisNotificationRowId = MIN(RowId), @MaxNotificationRowId = MAX(RowId) FROM @Notifications

	--	WHILE @ThisNotificationRowId<=@MaxNotificationRowId
	--		BEGIN	--3
	--			 SELECT
	--				@ContactName = N.ContactName,
	--				@ContactTypeName = N.ContactTypeName,
	--				@RuleId = N.RuleId,
	--				@RuleName = N.RuleName
	--				--@ContentName = N.ContentName
	--			FROM
	--				@Notifications N
	--			WHERE
	--				N.RowId=@ThisNotificationRowId
				
	--			SET @SQL='
	--						SELECT
	--							COUNT(*),
	--							CASE 
	--								WHEN E.RuleId=-1 THEN ''Incorrect datatype''
	--								WHEN R.Name IS NULL THEN ''Unknown rule''
	--								ELSE R.Name
	--							END AS RuleName,
	--							CASE
	--								WHEN E.FieldId=0 THEN ''Not available''
	--								WHEN F.Name IS NULL THEN ''Unknown field''
	--								ELSE F.Name
	--							END AS FieldName
	--						FROM
	--							Landing_Exception.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName+' E 
	--							LEFT JOIN Landing_Config.dbo.[Rule] R ON E.RuleId=R.Id
	--							LEFT JOIN Landing_Config.dbo.[Field] F ON E.FieldId=F.Id
	--						WHERE
	--							E.Load_GUID='''+@Load_GUID+''' AND
	--							E.RuleId='+CAST(@RuleId AS VARCHAR(10))+'
	--						GROUP BY
	--							CASE WHEN E.RuleId=-1 THEN ''Incorrect datatype''
	--								WHEN R.Name IS NULL THEN ''Unknown rule''
	--								ELSE R.Name
	--							END,
	--							CASE
	--								WHEN E.FieldId=0 THEN ''Not available''
	--								WHEN F.Name IS NULL THEN ''Unknown field''
	--								ELSE F.Name
	--							END'
	--							--SELECT @SQL

	--			INSERT INTO @NotificationData(ItemCount,RuleName,FieldName) EXEC(@SQL)
	--			SELECT 'NotificationData',ItemCount,RuleName,FieldName FROM @NotificationData
	--			SELECT @ThisNotificationDataRowId = MIN(RowId), @MaxNotificationDataRowId = MAX(RowId) FROM @NotificationData

	--			IF @ContactTypeName='SMS'  --Only allow summarised data for SMS and send them one at a time as we don't want to send massive list of rules and results in one go (SMS limit)
	--				BEGIN	--4
	--					WHILE @ThisNotificationDataRowId<=@MaxNotificationDataRowId	
	--						BEGIN	--5
	--							SELECT
	--								@MessageItemCount=ItemCount,
	--								@MessageRuleName=RuleName,
	--								@MessageFieldName=FieldName
	--							FROM
	--								@NotificationData ND
	--							WHERE
	--								RowId=@ThisNotificationDataRowId
								
	--							SET @Message=CAST(@MessageItemCount AS VARCHAR(10))+' records broke rule '''+@MessageRuleName+''' in dataset '+@DatasetName
	--							DECLARE @SMSResult AS NVARCHAR(MAX)
	--							--EXEC Landing_Config.dbo._Send_SMS @Message,'07725258028',@SMSResult OUTPUT

	--							SET @ThisNotificationDataRowId+=1
	--						END		--5
	--				END		--4
	--			ELSE IF @ContactTypeName='Email'
	--				BEGIN	--4
	--					--Send the whole NotificationData table as a html table

	--					--<tr>
	--					--	<td width=''75%'' align=''center'' style=''font-family:Trebuchet MS;font-size:large;color:#669;padding-bottom:10px''>
	--					--		<a href='+@ReportPath+' style=''font-family:Trebuchet MS;font-size:large;color:#669''
	--					--		<span>'+@ReportName+'</span>
	--					--		</a>
						
	--					--	</td>
	--					--</tr>
	--					--<tr>
	--					--	<td width=''75%'' align=''center'' style=''font-family:Trebuchet MS;font-size:medium;color:#669;padding-bottom:30px''>
	--					--		'+@ReportDescription+'
	--					--	</td>
	--					--</tr>

	--					DECLARE @tableHTML VARCHAR(MAX)=N'
	--						<style type="text/css">
	--						#box-table
	--						{
	--							font-family:Trebuchet MS;
	--							font-size: 12px;
	--							text-align: center;
	--							color:''Red'';
	--						}
	--							#box-table th
	--							{
	--								font-size: x-large;
	--								font-weight: bold;
	--								background: #b9c9fe;
	--							}
	--							#box-table td
	--							{
	--								width:75%;
	--								align:center;
	--								font-family:Trebuchet MS;
	--								font-size:large;
	--								color:#669;
	--								padding-bottom:10px;
	--							}
	--							tr:nth-child(odd) { background-color:#eee; }
	--							tr:nth-child(even) { background-color:#fff; }
	--						</style>
	--						<table>
	--							<tr>
	--								<td align=''center'' style=''font-family:Trebuchet MS;font-size:x-large;color:MidnightBlue;font-weight:bold;padding-bottom:20px''>
	--								<div style=''display: table-cell;vertical-align: middle''>
	--									Data warehouse load exception notification
	--								</div>
	--								</td>
	--							</tr>
	--						</table>
	--						<table id=''#box-table'' >
	--							<tr>
	--								<td  style=''padding-bottom:30px''>
	--									<hr width=''75%'' align=''center'' style=''color:#669''>
	--								</td>
	--							</tr>
	--							'+
	--							CAST
	--								(
	--									(
	--										SELECT
	--											td=ND.ItemCount,'',
	--											td=@DatasetName,'',
	--											td=ND.RuleName,'',
	--											td=ND.Fieldname
	--										FROM
	--											@NotificationData ND
	--										ORDER BY
	--											ND.ItemCount DESC
	--										FOR XML PATH('tr'),TYPE
	--									) AS VARCHAR(MAX)
	--								)
	--							+'
	--							<tr>
	--								<td  style=''padding-bottom:40px''>
	--									<hr width=''75%'' align=''center'' style=''color:#669''>
	--								</td>
	--							</tr>
				
	--						</table>'
	
	----SELECT @tableHTML

	--						exec msdb.dbo.sp_send_dbmail 
	--						@from_address='Iris <BCU.InformationDepartment@wales.nhs.uk>',
	--						--@recipients='martin.parry2@wales.nhs.uk;jacob.hammer@wales.nhs.uk',
	--						@recipients='martin.parry2@wales.nhs.uk',
	--						--@copy_recipients='martin.parry2@wales.nhs.uk',
	--						@subject = 'Data warehouse load exception notification', 
	--						@body = @tableHTML,
	--						@body_format = 'HTML';
	--				END		--4
				
	--			DELETE @NotificationData
	--			SET @SQL=''
	--			SET @ThisNotificationRowId+=1

	--		END	--3



		
		--DELETE @Notifications
		SET @ThisDatasetRowId-=1
	END	--2

/*
So basically what we want to do now is for each rule, go and get the records out of the exception table that match the load_guid and the current ruleid
That way we have all of the records in the current load that have broken that particular rule
I suppose the only question is do we want to do this by Dataset as well, we don't need this for custom rules but for Standard and Common rules we may need to....?
*/

--Ok, so actually we need to either get the scheduleId and ten the datasets and then for each dataset get the rules
--and then gets the exceptions (and there might not be exceptions for some datasets)
--or
--We have the load_guid so look in the exception table to get a distinct list of rules that are in there
--(cos these will be the rules that were broken) and then get the dataset from there


--Ok, actually forget all of the above, we have to do it the dataset first way because the 
--exception tables are split up into the datasets




--Standard rules
	--FieldId should be populated
	--RuleId will be -1

--Custom rules
	--Stored procedure (common)
	--FieldId should be populated if it's a 'common' stored procedure rule (cos you have to tell it what field to check) - although of course it's
	--possible to write the stored procedure so the rule is based on more than one field.....
	--RuleId will be populated

	--Stored procedure (dataset specific)
	--FieldId prolly won't be populated (because we're not passing a field in like we do with common ones)
	--RuleId will be populated

	--Query
	--FieldId won't be populated
	--RuleId will be populated

--It prolly doesn't matter too much about the field not being populated as long as we name the rules properly
--In fact, unless we alter the exception stuff to allow recording that a rule was based on more than one field then the name
--is prolly the best way to go (for instance, we could have a rule that is based on Treatment_Date in the future and Treatment_Type is OA - which field do
--we report as the one that the rule checked and broke?  Whereas if we name the rule 'Outpatient attendances with attendance date in future' then this 
--should be ok...).  So we're naming the rule based on what it's identifying as opposed to how it's identifying them.

--For now then we may as well ignore FieldId as part of this reporting process and rely on the name of the rule instead
--At some point maybe we look at adding multiple fieldids to the exception table but even if we do that we don't have the fieldids for some rules
--unless we start saying you have to associate a rule with a field (or fields) even if the query/sp doesn't make use of that fieldid (or fieldids)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */




/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Bit of an addition here as the request was for something that didn;t really match what notifications
were all about originally (which was the data quality stuff (rules, landing_exception, etc)
So, have put this here as an extra for now but will need to build this scenario in when
re-doing the framework
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
IF @ScheduleId=43
BEGIN
DECLARE @Result AS TABLE(
	Name			VARCHAR(100),
	ThisDateTime	DATETIME,
	ThisCount		INT,
	LastDateTime	DATETIME,
	LastCount		INT,
	Diff			INT
)
INSERT INTO @Result(Name,ThisDateTime,ThisCount)
SELECT Dataset,Logged, Value FROM AuditItem WHERE Load_Guid=(SELECT Load_Guid FROM LoadAudit WHERE ScheduleId=43 ORDER BY ProcessStart DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) AND 
Stage='_Load_Foundation_Tables' AND Action='INSERT' AND Object='Foundation.dbo.Covid_Data_WISVaccination'
UPDATE R SET LastDateTime=AI.Logged,LastCount=AI.Value
FROM @Result R
INNER JOIN AuditItem AI ON R.Name=AI.Dataset WHERE AI.Load_Guid=(SELECT Load_Guid FROM LoadAudit WHERE ScheduleId=43 ORDER BY ProcessStart DESC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY) AND 
Stage='_Load_Foundation_Tables' AND Action='INSERT' AND Object='Foundation.dbo.Covid_Data_WISVaccination'

INSERT INTO @Result(Name,ThisDateTime,ThisCount)
SELECT Dataset,Logged, Value FROM AuditItem WHERE Load_Guid=(SELECT Load_Guid FROM LoadAudit WHERE ScheduleId=43 ORDER BY ProcessStart DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) AND 
Stage='_Load_Foundation_Tables' AND Action='INSERT' AND Object='Foundation.dbo.Covid_Data_WISBooking'
UPDATE R SET LastDateTime=AI.Logged,LastCount=AI.Value
FROM @Result R
INNER JOIN AuditItem AI ON R.Name=AI.Dataset WHERE AI.Load_Guid=(SELECT Load_Guid FROM LoadAudit WHERE ScheduleId=43 ORDER BY ProcessStart DESC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY) AND 
Stage='_Load_Foundation_Tables' AND Action='INSERT' AND Object='Foundation.dbo.Covid_Data_WISBooking'

INSERT INTO @Result(Name,ThisDateTime,ThisCount)
SELECT Dataset,Logged, Value FROM AuditItem WHERE Load_Guid=(SELECT Load_Guid FROM LoadAudit WHERE ScheduleId=43 ORDER BY ProcessStart DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) AND 
Stage='_Load_Foundation_Tables' AND Action='INSERT' AND Object='Foundation.dbo.Covid_Data_WISCohort'
UPDATE R SET LastDateTime=AI.Logged,LastCount=AI.Value
FROM @Result R
INNER JOIN AuditItem AI ON R.Name=AI.Dataset WHERE AI.Load_Guid=(SELECT Load_Guid FROM LoadAudit WHERE ScheduleId=43 ORDER BY ProcessStart DESC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY) AND 
Stage='_Load_Foundation_Tables' AND Action='INSERT' AND Object='Foundation.dbo.Covid_Data_WISCohort'

UPDATE @RESULT SET Diff=ThisCount-LastCount
--SELECT * FROM @Result

--IF (SELECT COUNT(*) FROM @RESULT WHERE Diff<0)>0
--	BEGIN
		DECLARE @tableHTML1 VARCHAR(MAX)= 
			N'<style type="text/css">
			#box-table
			{
			width:1200px;
			font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
			font-size: 12px;
			text-align: center;
			border-collapse: collapse;
			border-top: 7px solid #9baff1;
			border-bottom: 7px solid #9baff1;
			}
			#box-table th
			{
			font-size: 13px;
			font-weight: normal;
			background: #b9c9fe;
			border-right: 2px solid #9baff1;
			border-left: 2px solid #9baff1;
			border-bottom: 2px solid #9baff1;
			color: #039;
			}
			#box-table td
			{
			text-align: left;
			border-right: 1px solid #aabcfe;
			border-left: 1px solid #aabcfe;
			border-bottom: 1px solid #aabcfe;
			color: #669;
			padding:5px 20px 5px 20px;
			}
			tr:nth-child(odd) { background-color:#eee; }
			tr:nth-child(even) { background-color:#fff; }
			</style>'+
			N'<div style="font-family:Verdana;width: 1200px">'+
				N'<H3><font color="Red">Covid dataset with value less than previous run</H3>' +
				
				N'<table>
					<tr>
						<td style="vertical-align: top; width: 1200px">' +
				N'<table id="box-table">' +
				N'	<tr>
						<th>Dataset</th>
						<th>This run datetime</th>
						<th>Count</th>
						<th>Last run datetime</th>
						<th>Count</th>
						<th>Difference</th>
					</tr>' +
				CAST
					(
						(
						SELECT 
							td=Name,'',
							td=FORMAT(ThisDateTime,'dd MMMM yyyy hh\:mm tt'),'',
							td=CAST(ThisCount AS VARCHAR(10)),'',
							td=FORMAT(LastDateTime,'dd MMMM yyyy hh\:mm tt'),'',
							td=CAST(LastCount AS VARCHAR(10)),'',
							td=CAST(Diff AS VARCHAR(10))
						FROM
							@Result R
						FOR XML PATH('tr'),TYPE
						) 
						AS varchar(max)
					) + 
				N'</table></td></tr></table>'
	
		exec msdb.dbo.sp_send_dbmail 
		@from_address='BCU data warehouse alert <BCU.InformationDepartment@wales.nhs.uk>',
		--@reply_to='BCU.noreply@wales.nhs.uk' ,
					
		@recipients='Josh.Williams2@wales.nhs.uk;Caitlin.Argument@wales.nhs.uk;Lavanya.Govindarajulu@wales.nhs.uk',
		--@recipients='martin.parry2@wales.nhs.uk',
		@copy_recipients='martin.parry2@wales.nhs.uk',
			@subject = 'WIS load count discrepancy', 
			@body = @tableHTML1,
			@body_format = 'HTML';
	--END
END

END		--1
GO
