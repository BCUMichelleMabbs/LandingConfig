SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Init_Exception_Tables] 
	@Load_Guid AS VARCHAR(38),
	@ScheduleId AS INT
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ProcName AS VARCHAR(MAX)=(SELECT OBJECT_NAME(@@PROCID))
DECLARE @StartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage start',@ProcName,@StartTime,NULL
--DECLARE @TimestampStart AS DATETIME = GetDate() 
--DECLARE @TimestampEnd AS DATETIME
--DECLARE @ProcessTime AS VARCHAR(10)

DECLARE @ThisRowId AS INT = 0
DECLARE @MaxRowId AS INT = 0
DECLARE @ThisFieldRowId AS INT
DECLARE @MaxFieldRowId AS INT
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @DatasetName AS VARCHAR(50)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DatasetFullName AS VARCHAR(150)

--First, get the DatasetGroups, tables and fields that we need - cba splitting this into 3, easier to just grab everything - doesn't really matter about normalisation in here.....
DECLARE @ExceptionTables AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupId		INT,
	DatasetGroupName		VARCHAR(50),
	DatasetGroupActive	CHAR(1),
	DatasetId		INT,
	DatasetName		VARCHAR(50),
	DatasetType		VARCHAR(50),
	DatasetActive	CHAR(1),
	FieldId			INT,
	FieldName		VARCHAR(50),
	Active			CHAR(1)
)
DECLARE @ExceptionTables_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupName		VARCHAR(50),
	DatasetName		VARCHAR(50),
	DatasetType		VARCHAR(50)
)
DECLARE @ExceptionFields_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	FieldName		VARCHAR(50)
)


--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'INITIALISE EXCEPTION TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


INSERT INTO @ExceptionTables (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, Active)
SELECT 
	DG.Id, DG.Name, DG.Active,
	D.Id, D.Name, DT.Name, D.Active,
	F.Id, F.Name,
	CASE DG.Active
		WHEN 'N' THEN 'N'
		WHEN 'Y' THEN
			CASE D.Active
				WHEN 'N' THEN 'N'
				ELSE D.Active
			END
	END AS 'Active'
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].[Dataset] D ON DG.Id = D.GroupId
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId = DT.Id
	INNER JOIN [Landing_Config].[dbo].[Field] F ON D.Id = F.DatasetId
WHERE
	ScheduleId=@ScheduleId

INSERT INTO @ExceptionTables (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, Active)
SELECT 
	DG.Id, DG.Name, DG.Active,
	D.Id, D.Name, DT.Name, D.Active,
	F.Id, F.Name, 
	CASE DG.Active
		WHEN 'N' THEN 'N'
		WHEN 'Y' THEN
			CASE D.Active
				WHEN 'N' THEN 'N'
				ELSE D.Active
			END
	END AS 'Active'
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].[Dataset] D ON DG.Id = D.GroupId
	INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId = DT.Id
	INNER JOIN [Landing_Config].[dbo].[Field] F ON D.Id = F.DatasetId
WHERE
	DD.DatasetId IN (SELECT DatasetId FROM @ExceptionTables)



--AND NOW CREATE ANY TABLES THAT ARE ACTIVE
--DECLARE @SystemId AS INT
--DECLARE @TableId AS INT
DECLARE @FieldName AS VARCHAR(50)
DECLARE @SQL_CreateTable AS NVARCHAR(MAX)
DECLARE @SQL_AlterTable AS NVARCHAR(MAX)

INSERT INTO @ExceptionTables_TEMP
SELECT DISTINCT DatasetGroupName, DatasetName, DatasetType FROM @ExceptionTables WHERE Active='Y'

SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @ExceptionTables_TEMP

WHILE @ThisRowId <= @MaxRowId
	BEGIN
		DELETE @ExceptionFields_TEMP

		SELECT 
			@DatasetGroupName = ETT.DatasetGroupName,
			@DatasetName= ETT.DatasetName,
			@DatasetType= ETT.DatasetType,
			@DatasetFullName=ETT.DatasetGroupName+'_'+ETT.DatasetType+'_'+ETT.DatasetName
		FROM
			@ExceptionTables_TEMP ETT
		WHERE
			ETT.RowId = @ThisRowId

		INSERT INTO @ExceptionFields_TEMP (FieldName)
		SELECT DISTINCT FieldName FROM @ExceptionTables WHERE DatasetGroupName=@DatasetGroupName AND DatasetName=@DatasetName AND Active='Y' --SystemId=@SystemId AND TableId=@TableId
		
		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @ExceptionFields_TEMP


IF OBJECT_ID('Landing_Exception.dbo.'+@DatasetFullName,'U') IS NULL
	BEGIN TRY
		
		SET @SQL_CreateTable = 'CREATE TABLE Landing_Exception.dbo.'+@DatasetFullName+' (Load_GUID VARCHAR(38), Row_GUID uniqueidentifier NOT NULL, LoadDate DATE, FieldId INT NULL, RuleId INT NULL,'

		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT @FieldName = EFT.FieldName FROM @ExceptionFields_TEMP EFT WHERE RowId = @ThisFieldRowId
				SET @SQL_CreateTable += @FieldName + ' VARCHAR(MAX),'
				SET @ThisFieldRowId+=1
			END
		
			SET @SQL_CreateTable = SUBSTRING(@SQL_CreateTable,0,LEN(@SQL_CreateTable)) + ')'

			DECLARE @ObjectCreateFullName AS VARCHAR(MAX)='Landing_Exception.dbo.' + @DatasetFullName
			EXEC sp_executesql @SQL_CreateTable
			EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Create table',@ObjectCreateFullName,'Created',@DatasetFullName
			--PRINT 'TABLE CREATED: Landing_Exception.dbo.' + @SystemName + '_' + @DatasetType+'_'+@DatasetName
			--RAISERROR('',0,1) WITH NOWAIT
	END TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Create AS VARCHAR(MAX)=ERROR_MESSAGE()
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectCreateFullName,@Err_Msg_Create,@DatasetFullName
	END CATCH
ELSE IF OBJECT_ID('Landing_Exception.dbo.'+@DatasetFullName,'U') IS NOT NULL
	BEGIN
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN TRY
				SELECT @FieldName = EFT.FieldName FROM @ExceptionFields_TEMP EFT WHERE RowId = @ThisFieldRowId
				
				IF @FieldName NOT IN(
					SELECT
						C.name
					FROM
						Landing_Exception.sys.tables T
						INNER JOIN Landing_Exception.sys.columns C ON T.object_id=C.object_id
					WHERE
						T.is_ms_shipped=0 AND
						T.type_desc='USER_TABLE' AND
						T.name=@DatasetFullName)
					BEGIN
						SET @SQL_AlterTable='ALTER TABLE Landing_Exception.dbo.'+@DatasetFullName+
							' ADD '+@FieldName+' VARCHAR(MAX) NULL'
					DECLARE @ObjectAddFieldName AS VARCHAR(MAX)='Landing_Exception.dbo.' + @DatasetFullName+'.'+@FieldName
					EXEC sp_executesql @SQL_AlterTable
					EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Add field',@ObjectAddFieldName,'Added',@DatasetFullName
					--PRINT 'FIELD ADDED: Landing_Exception.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName+'.'+@FieldName
					--RAISERROR('',0,1) WITH NOWAIT
					END
					SET @ThisFieldRowId+=1
			END TRY
			BEGIN CATCH
				DECLARE @Err_Msg_Alter AS VARCHAR(MAX)=ERROR_MESSAGE()
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectAddFieldName,@Err_Msg_Alter,@DatasetFullName
			END CATCH
	END		

		
		SET @ThisRowId+=1
	END

DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime = (SELECT CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114))
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT


END
GO
