SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Apply_Custom_Rules]
	@Load_GUID AS VARCHAR(38),
	@ScheduleId AS INT
AS
BEGIN

--DECLARE @TimestampStart AS DATETIME = GetDate() 
--DECLARE @TimestampEnd AS DATETIME
--DECLARE @ProcessTime AS VARCHAR(10)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProcName AS VARCHAR(MAX)=(SELECT OBJECT_NAME(@@PROCID))
	DECLARE @StartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
	EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage start',@ProcName,@StartTime,NULL
DECLARE @ThisTableRowId AS INT
DECLARE @MaxTableRowId AS INT
DECLARE @ThisFieldRowId AS INT
DECLARE @MaxFieldRowId AS INT
DECLARE @ThisRuleRowId AS INT
DECLARE @MaxRuleRowId AS INT
DECLARE @ThisSPFieldRowId AS INT
DECLARE @MaxSPFieldRowId AS INT
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @TableName AS VARCHAR(50)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DatasetFullName AS VARCHAR(150)
DECLARE @TableId AS INT
DECLARE @FieldId AS INT
DECLARE @RuleId AS INT
DECLARE @RuleName AS VARCHAR(50)
DECLARE @RuleText AS NVARCHAR(MAX)
DECLARE @RuleType AS VARCHAR(50)
DECLARE @RuleSeverity AS VARCHAR(50)
DECLARE @RuleRemove AS CHAR(1)
DECLARE @RuleFieldId AS INT
DECLARE @RuleFieldName AS VARCHAR(50)
DECLARE @SQL_ApplyRule AS NVARCHAR(MAX)


DECLARE @Tables AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupId		INT,
	DatasetGroupName		VARCHAR(50),
	TableId			INT,
	TableName		VARCHAR(50),
	DatasetType		VARCHAR(50)
)
DECLARE @Fields AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	FieldId			INT NOT NULL,
	FieldName		VARCHAR(50),
	DataType		VARCHAR(50),
	Length			VARCHAR(10),
	IncomingFormat	VARCHAR(50),
	TableId			INT
)
DECLARE @Rules AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	RuleId			INT NOT NULL,
	Name			VARCHAR(50),
	Text			VARCHAR(MAX),
	Type			VARCHAR(50),
	Severity		VARCHAR(50),
	Remove			CHAR(1),
	FieldId			INT,
	FieldName		VARCHAR(50)
)


--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'APPLY CUSTOM RULES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


/*TABLES*/
INSERT INTO @Tables (DatasetGroupId, DatasetGroupName, TableId, TableName, DatasetType)
SELECT DISTINCT
	DG.Id, DG.Name, 
	D.Id, D.Name, DT.Name
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].Dataset D ON DG.Id = D.GroupId
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId = DT.Id
	INNER JOIN Landing_Config.dbo.DatasetRules DR ON D.Id=DR.DatasetId
WHERE
	DG.Active='Y' AND D.Active='Y' AND D.ScheduleId=@ScheduleId
	

INSERT INTO @Tables (DatasetGroupId, DatasetGroupName, TableId, TableName, DatasetType)
SELECT DISTINCT
	DG.Id, DG.Name, 
	D.Id, D.Name, DT.Name
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].Dataset D ON DG.Id = D.GroupId
	INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId = DT.Id
	INNER JOIN Landing_Config.dbo.DatasetRules DR ON D.Id=DR.DatasetId
WHERE
	DG.Active='Y' AND 
	D.Active='Y' AND 
	DD.DatasetId IN (SELECT TableId FROM @Tables)


SELECT @ThisTableRowId = MIN(RowId), @MaxTableRowId = MAX(RowId) FROM @Tables

WHILE @ThisTableRowId <= @MaxTableRowId
	BEGIN
		SELECT 
			@DatasetGroupName = T.DatasetGroupName,
			@TableName= T.TableName,
			@DatasetType= T.DatasetType,
			@DatasetFullName=T.DatasetGroupName+'_'+T.DatasetType+'_'+T.TableName,
			@TableId = T.TableId
		FROM
			@Tables T
		WHERE
			T.RowId = @ThisTableRowId

		/*FIELDS*/
		INSERT INTO @Fields (FieldId, FieldName, DataType, Length, IncomingFormat, TableId)
		SELECT 
			F.Id, F.Name, D.Name, F.Length, F.IncomingFormat, F.DatasetId
		FROM 
			[Landing_Config].[dbo].[Field] F
			INNER JOIN [Landing_Config].[dbo].[Datatype] D ON F.DatatypeId=D.Id
		WHERE 
			DatasetId=@TableId
		
		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields

		--Need to build a field list first
		DECLARE @PrefixFieldList AS VARCHAR(50)='Load_GUID,Row_GUID,LoadDate,'
		DECLARE @FieldList AS VARCHAR(MAX)=''
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SET @FieldList += (SELECT F.FieldName FROM @Fields F WHERE RowId = @ThisFieldRowId) + ','
				SET @ThisFieldRowId+=1
			END
		SET @FieldList = SUBSTRING(@FieldList,0,LEN(@FieldList))

		--SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields
		--WHILE @ThisFieldRowId <= @MaxFieldRowId
			--BEGIN
				--SELECT @FieldId = F.FieldId FROM @Fields F WHERE F.RowId=@ThisFieldRowId

				/*RULES*/
				INSERT INTO @Rules (RuleId, Name, Text, Type, Severity, Remove, FieldId, FieldName)
				SELECT
					R.Id, R.Name, R.Text,
					T.Name, S.Name, S.Remove, DR.FieldId, F.Name
				FROM
					[Landing_Config].[dbo].[Rule] R
					INNER JOIN [Landing_Config].[dbo].[RuleType] T ON R.TypeId=T.Id
					INNER JOIN [Landing_Config].[dbo].[Severity] S ON R.SeverityId=S.Id
					INNER JOIN [Landing_Config].[dbo].[DatasetRules] DR ON R.Id = DR.RuleId
					LEFT JOIN Landing_Config.dbo.Field F ON DR.FieldId=F.Id
				WHERE
					DR.DatasetId=@TableId
				
				SELECT @ThisRuleRowId = MIN(RowId), @MaxRuleRowId = MAX(RowId) FROM @Rules
				--select * from @Rules
				WHILE @ThisRuleRowId <= @MaxRuleRowId
					BEGIN
						SELECT 
							@RuleId = R.RuleId,
							@RuleName= R.Name,
							@RuleText = R.Text,
							@RuleType = R.Type,
							@RuleSeverity = R.Severity,
							@RuleRemove = R.Remove,
							@RuleFieldId = R.FieldId,
							@RuleFieldName = R.FieldName
						FROM
							@Rules R
						WHERE
							R.RowId = @ThisRuleRowId
					
						
							IF @RuleType = 'stored_procedure'
								BEGIN
									--If having the 'type' is a problem then instead just grab the field list, create a table variable out of it,
									--populate it with all the relevant data from the landing table and add the rule id and fieldid

									/*****************************************************************/
									--TYPE METHOD
									--DECLARE @Results Row_GUID_Results;
									--INSERT INTO @Results(xRow_GUID) EXEC @RuleText
									--DECLARE @SQL_ApplyRule_SP NVARCHAR(MAX)='INSERT INTO Landing_Exception.dbo.' + @SystemName +'_'+ @TableName +
									--' SELECT ' + @FieldList + ' ' + CONVERT(VARCHAR(10),@FieldId) + ',' + CONVERT(VARCHAR(10),@RuleId) + 
									--' FROM @Results R' +
									--' INNER JOIN Landing.dbo.'+@SystemName+'_'+@TableName+' ON R.xRow_GUID=Landing.dbo.'+@SystemName+'_'+@TableName+'.Row_GUID'
									--EXEC sp_executesql @SQL_ApplyRule_SP,N'@Results Row_GUID_Results READONLY'
									--print @SQL_ApplyRule_SP
									--PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows into Landing_Exception.dbo.' + @SystemName + '_' + @TableName + ' for violation of custom rule: ' + @RuleName 
									--RAISERROR('',0,1) WITH NOWAIT
									/*****************************************************************/

									/*****************************************************************/
									--TABLE METHOD
									/*****************************************************************/
									
									SELECT @ThisSPFieldRowId = MIN(RowId), @MaxSPFieldRowId = MAX(RowId) FROM @Fields
									DECLARE @FieldName AS VARCHAR(50)
									DECLARE @CreateTable AS NVARCHAR(MAX)='DECLARE @Results AS TABLE(Load_GUID VARCHAR(38),Row_GUID uniqueidentifier,LoadDate Date,'
									WHILE @ThisSPFieldRowId <= @MaxSPFieldRowId
										BEGIN
											SELECT @FieldName = F.FieldName FROM @Fields F WHERE RowId = @ThisSPFieldRowId
											SET @CreateTable+= @FieldName+' VARCHAR(MAX) NULL,'
											SET @ThisSPFieldRowId+=1
										END
										SET @CreateTable=SUBSTRING(@CreateTable,0,LEN(@CreateTable))+')'
										
									SET @SQL_ApplyRule = @CreateTable +
										' INSERT INTO @Results (' + @PrefixFieldList+@FieldList + ') EXEC '+@RuleText
										
									IF @RuleFieldId IS NOT NULL
										BEGIN
											SET @SQL_ApplyRule+=' '+CAST(@TableId AS VARCHAR(10))+', '+CAST(@RuleFieldId AS VARCHAR(10))
										END
									SET @SQL_ApplyRule += ' INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+ CONVERT(VARCHAR(10),ISNULL(@RuleFieldId,0)) + ',' + CONVERT(VARCHAR(10),@RuleId) +','+ @FieldList + ' FROM @Results'
								END
								
							ELSE IF @RuleType = 'sql'
								BEGIN
									SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),ISNULL(@RuleFieldId,0)) + ',' + CONVERT(VARCHAR(10),@RuleId)+','+@FieldList+' FROM ('+@RuleText+')Results'
								END

							BEGIN TRY
								--print @SQL_ApplyRule	
								DECLARE @InsertObjectName AS VARCHAR(MAX)='Landing_Exception.dbo.' + @DatasetFullName
								EXEC sp_executesql @SQL_ApplyRule
								DECLARE @InsertRowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
								EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Insert',@RuleText,@InsertRowCount,@DatasetFullName
								--PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows into Landing_Exception.dbo.'+@SystemName+'_'+@DatasetType+'_'+@TableName + ' for violation of custom rule: ' + @RuleName 
								--RAISERROR('',0,1) WITH NOWAIT
							END TRY
							BEGIN CATCH
								DECLARE @Err_Msg_Insert AS VARCHAR(MAX)=ERROR_MESSAGE()
								EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@RuleText,@Err_Msg_Insert,@DatasetFullName
							END CATCH

							IF @RuleRemove='R'
								BEGIN TRY
									DECLARE @SQL_Delete AS NVARCHAR(MAX) = 'DELETE Landing.dbo.'+@DatasetFullName + 
									' WHERE Row_GUID IN (SELECT Row_GUID FROM Landing_Exception.dbo.'+@DatasetFullName + 
									' WHERE Load_GUID=''' + @Load_GUID + ''''+
									' AND RuleId = ' +CAST(@RuleId AS VARCHAR(10))+ ')'
									
									DECLARE @DeleteObjectName AS VARCHAR(MAX)='Landing.dbo.' +@DatasetFullName
									EXEC sp_executesql @SQL_Delete
									DECLARE @DeleteRowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
									EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Remove row',@RuleText,@DeleteRowCount,@DatasetFullName
								END TRY
								BEGIN CATCH
									DECLARE @Err_Msg_Delete AS VARCHAR(MAX)=ERROR_MESSAGE()
									EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@RuleText,@Err_Msg_Delete,@DatasetFullName
								END CATCH

							ELSE IF @RuleRemove='F'
								BEGIN TRY
									DECLARE @SQL_Field_Delete AS NVARCHAR(MAX) = 'UPDATE Landing.dbo.'+@DatasetFullName +
									' SET ' + @RuleFieldName +' = NULL WHERE Row_GUID IN (SELECT Row_GUID FROM Landing_Exception.dbo.'+@DatasetFullName + 
									' WHERE Load_GUID=''' + @Load_GUID + ''''+
									' AND RuleId = ' +CAST(@RuleId AS VARCHAR(10))+ ')'
									EXEC sp_executesql @SQL_Field_Delete
									DECLARE @DeleteFieldRowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
									EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Remove value',@RuleText,@DeleteFieldRowCount,@DatasetFullName
								END TRY
								BEGIN CATCH
									DECLARE @Err_Msg_Delete_Field AS VARCHAR(MAX)=ERROR_MESSAGE()
									EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@RuleText,@Err_Msg_Delete_Field,@DatasetFullName
								END CATCH
							
						SET @ThisRuleRowId+=1
					END

					DELETE @Rules

				--SET @ThisFieldRowId+=1
			--END

		DELETE @Fields
		
		SET @ThisTableRowId+=1
	END

DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT

END
GO
