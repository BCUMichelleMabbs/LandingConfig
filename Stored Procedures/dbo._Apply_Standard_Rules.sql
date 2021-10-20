SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Apply_Standard_Rules]
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
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @TableName AS VARCHAR(50)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DatasetFullName AS VARCHAR(150)
DECLARE @TableId AS INT
DECLARE @FieldId AS INT
DECLARE @FieldName AS VARCHAR(50)
DECLARE @DataType AS VARCHAR(50)
DECLARE @Length AS VARCHAR(20)
DECLARE @IncomingFormat AS VARCHAR(50)

--DECLARE @RuleName AS VARCHAR(50)
--DECLARE @RuleText AS NVARCHAR(MAX)
--DECLARE @RuleType AS VARCHAR(50)
--DECLARE @RuleSeverity AS VARCHAR(50)
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

--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'APPLY STANDARD RULES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT

/*TABLES*/
INSERT INTO @Tables (DatasetGroupId, DatasetGroupName, TableId, TableName, DatasetType)
SELECT 
	DG.Id, DG.Name, 
	D.Id, D.Name, DT.Name
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].Dataset D ON DG.Id = D.GroupId
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId=DT.Id
WHERE
	DG.Active='Y' AND D.Active='Y' AND D.ScheduleId=@ScheduleId

INSERT INTO @Tables (DatasetGroupId, DatasetGroupName, TableId, TableName, DatasetType)
SELECT 
	DG.Id, DG.Name, 
	D.Id, D.Name, DT.Name
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].Dataset D ON DG.Id = D.GroupId
	INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId=DT.Id
	INNER JOIN Landing_Config.dbo.Dataset otherD ON DD.DatasetId = otherD.Id
WHERE
	DG.Active='Y' AND 
	D.Active='Y' AND 
	otherD.Active='Y' AND
	DD.DatasetId IN (SELECT TableId FROM @Tables)

SELECT @ThisTableRowId = MIN(RowId), @MaxTableRowId = MAX(RowId) FROM @Tables
--select * from @Tables
WHILE @ThisTableRowId <= @MaxTableRowId
	BEGIN
		
		SELECT 
			@DatasetGroupName = T.DatasetGroupName,
			@TableName= T.TableName,
			@DatasetType=T.DatasetType,
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
--select * from @Fields
		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields

		--Need to build a field list first
		DECLARE @PrefixFieldList AS VARCHAR(50) = 'Load_GUID,Row_GUID,LoadDate,'
		DECLARE @FieldList AS VARCHAR(MAX)
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				--SELECT @ThisFieldName = F.FieldName FROM @Fields F WHERE RowId = @ThisFieldRowId
				--SELECT @ThisFieldName
				SET @FieldList += (SELECT F.FieldName FROM @Fields F WHERE RowId = @ThisFieldRowId) + ','
				--SELECT @FieldList
				SET @ThisFieldRowId+=1
			END
		SET @FieldList = SUBSTRING(@FieldList,0,LEN(@FieldList))
		
		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT 
					@FieldId = F.FieldId,
					@FieldName = F.FieldName,
					@DataType = F.DataType,
					@Length = F.Length,
					@IncomingFormat	= F.IncomingFormat
				FROM @Fields F WHERE F.RowId=@ThisFieldRowId

				/*RULES*/
				--Ensure that the datatype of the field is what we said it should be and check it's length etc
				--Doing this as another bonus for setting things up in the Dataset/Field tables - you get these rules/checks for free
				
				SET @SQL_ApplyRule=''

				IF @DataType = 'text'  
					BEGIN
						--Check length of the field
						IF @Length != '-1'
							BEGIN
								SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
								'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE '+@FieldName+' IS NOT NULL AND LEN(' + @FieldName + ') > ' + @Length + ') a'
							END
					END
				 ELSE IF @DataType = 'integer'  
					BEGIN
						--Check it's just numbers
						SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
						'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE '+@FieldName+' IS NOT NULL AND ' + @FieldName + ' LIKE ''%[^0-9]%'') a'
					END
				ELSE IF @DataType = 'big integer'  --Check it's just numbers
					BEGIN
						--Check it's just numbers
						SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
						'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE '+@FieldName+' IS NOT NULL AND ' + @FieldName + ' LIKE ''%[^0-9]%'') a'
					END
				ELSE IF @DataType = 'date'  
					BEGIN
						--Check it parses as a date (can ignore the nulls as that will be checked on a custom rule)
						SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
						'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE TRY_PARSE(' + @FieldName + ' AS DATE) IS NULL AND ' + @FieldName + ' IS NOT NULL) a'
					END
				ELSE IF @DataType = 'time as char'  --Check it parses as a time (depending on the 'length' it should have : as the 3rd character or it should just consist of numbers)
					BEGIN
						IF @Length = 5
							BEGIN
								SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
								'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE TRY_PARSE(' + @FieldName + 'AS TIME) IS NULL AND ' + @FieldName + ' IS NOT NULL) a'
							END
						ELSE IF @Length = 4
							BEGIN
								SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
								'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE TRY_PARSE(LEFT(' + @FieldName + ',2) + '':'' + RIGHT(' + @FieldName + ',2) AS TIME) IS NULL AND ' + @FieldName + ' IS NOT NULL) a'
							END
					END
				ELSE IF @DataType = 'datetime'
					BEGIN
						--Check it parses as a date (can ignore the nulls as that will be checked on a custom rule)
						SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
						'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE TRY_PARSE(' + @FieldName + ' AS DATETIME) IS NULL AND ' + @FieldName + ' IS NOT NULL) a'
					END
				ELSE IF @DataType = 'time'
					BEGIN
						--Check it parses as a time (can ignore the nulls as that will be checked on a custom rule)
						SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
						'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE TRY_PARSE(' + @FieldName + ' AS TIME) IS NULL AND ' + @FieldName + ' IS NOT NULL) a'
					END
				ELSE IF @DataType = 'decimal'
					BEGIN
						SET @SQL_ApplyRule = 'INSERT INTO Landing_Exception.dbo.'+@DatasetFullName+' SELECT '+@PrefixFieldList+CONVERT(VARCHAR(10),@FieldId) + ',-1,' + @FieldList + ' FROM (' +
						'SELECT * FROM Landing.dbo.'+@DatasetFullName+ ' WHERE ' + @FieldName + ' IS NOT NULL AND CHARINDEX(''.'',' + @FieldName + ')=0) a'
					END
				IF @SQL_ApplyRule != ''
					BEGIN TRY
						--PRINT @SQL_ApplyRule
						DECLARE @InsertObjectName AS VARCHAR(MAX)='Landing_Exception.dbo.' + @DatasetFullName
						EXEC sp_executesql @SQL_ApplyRule
						DECLARE @InsertRowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
						EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Insert',@InsertObjectName,@InsertRowCount,@DatasetFullName
						--IF @@ROWCOUNT > 0
							--BEGIN
								--PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows into Landing_Exception.dbo.'+@SystemName+'_'+@DatasetType+'_'+@TableName + ' for violation of standard rule'
								--RAISERROR('',0,1) WITH NOWAIT
							--END
					END TRY
					BEGIN CATCH
						DECLARE @Err_Msg_Insert AS VARCHAR(MAX)=ERROR_MESSAGE()
						EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@InsertObjectName,@Err_Msg_Insert,@DatasetFullName
					END CATCH
				SET @ThisFieldRowId+=1
			END

		DELETE @Fields
		
		BEGIN TRY
			DECLARE @SQL_Delete AS NVARCHAR(MAX) = 'DELETE Landing.dbo.'+@DatasetFullName+ ' WHERE Row_GUID IN (SELECT Row_GUID FROM Landing_Exception.dbo.'+@DatasetFullName+ ' WHERE Load_GUID=''' + @Load_GUID + ''')'
			DECLARE @DeleteObjectName AS VARCHAR(MAX)='Landing.dbo.' + @DatasetFullName
			EXEC sp_executesql @SQL_Delete
			DECLARE @DeleteRowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
			EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Delete',@DeleteObjectName,@DeleteRowCount,@DatasetFullName
		END TRY
		BEGIN CATCH
			DECLARE @Err_Msg_Delete AS VARCHAR(MAX)=ERROR_MESSAGE()
			EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@DeleteObjectName,@Err_Msg_Delete,@DatasetFullName
		END CATCH

		

		SET @ThisTableRowId+=1
	END

--And now remove any records from the landing table that are in the exception table
--Could have done this above for each statement but if we do it here we can do it once


DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime = (SELECT CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114))
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT

END
GO
