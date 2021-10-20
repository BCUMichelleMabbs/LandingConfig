SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Init_Landing_Tables] 
	@Load_Guid AS VARCHAR(38),
	@ScheduleId AS INT
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ProcName AS VARCHAR(MAX)=(SELECT OBJECT_NAME(@@PROCID))
DECLARE @StartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage start',@ProcName,@StartTime,NULL
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))

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

--First, get the system, tables and fields that we need - cba splitting this into 3, easier to just grab everything - doesn't really matter about normalisation in here.....
DECLARE @LandingTables AS TABLE(
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
DECLARE @LandingTables_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupName		VARCHAR(50),
	DatasetName		VARCHAR(50),
	DatasetType		VARCHAR(50)
)
DECLARE @LandingFields_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	FieldName		VARCHAR(50)
)


--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'INITIALISE LANDING TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


INSERT INTO @LandingTables (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, Active)
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
	D.ScheduleId=@ScheduleId

INSERT INTO @LandingTables (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, Active)
SELECT 
	DG.Id, DG.Name, DG.Active,
	D.Id, D.Name, DT.Name, D.Active,
	F.Id, F.Name, 
	CASE DG.Active
		WHEN 'N' THEN 'N'
		WHEN 'Y' THEN
			CASE D.Active
				WHEN 'N' THEN 'N'
				ELSE otherD.Active
			END
	END AS 'Active'
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].[Dataset] D ON DG.Id = D.GroupId
	INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
	INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId = DT.Id
	INNER JOIN [Landing_Config].[dbo].[Field] F ON D.Id = F.DatasetId
	INNER JOIN Landing_Config.dbo.Dataset otherD ON DD.DatasetId = otherD.Id
WHERE
	DD.DatasetId IN (SELECT DISTINCT DatasetId FROM @LandingTables)
	

--DROP THE TABLES
DECLARE @SQL_DropTable AS NVARCHAR(MAX)
INSERT INTO @LandingTables_TEMP (DatasetGroupName, DatasetName, DatasetType)
SELECT DISTINCT DatasetGroupName, DatasetName, DatasetType FROM @LandingTables
SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @LandingTables_TEMP

WHILE @ThisRowId <= @MaxRowId
	BEGIN TRY
	--Drop all the existing tables - this will have to include those which aren't active as well
		SELECT 
			@DatasetGroupName = LTT.DatasetGroupName,
			@DatasetName= LTT.DatasetName,
			@DatasetType = LTT.DatasetType,
			@DatasetFullName=LTT.DatasetGroupName+'_'+LTT.DatasetType+'_'+LTT.DatasetName
		FROM
			@LandingTables_TEMP LTT
		WHERE
			LTT.RowId = @ThisRowId

		IF OBJECT_ID('Landing.dbo.' + @DatasetFullName,'U') IS NOT NULL
		BEGIN
			SET @SQL_DropTable = 'DROP TABLE Landing.dbo.' + @DatasetFullName
			DECLARE @ObjectDropFullName AS VARCHAR(MAX)='Landing.dbo.' + @DatasetFullName
			EXEC sp_executesql @SQL_DropTable
			EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Drop table',@ObjectDropFullName,'Dropped',@DatasetFullName
			--PRINT 'TABLE DROPPED: Landing.dbo.' + @Systemname + '_' + @DatasetType+'_'+@DatasetName
			--RAISERROR('',0,1) WITH NOWAIT 
		END

		SET @ThisRowId+=1
	END TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Drop AS VARCHAR(MAX)=ERROR_MESSAGE()
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectDropFullName,@Err_Msg_Drop,@DatasetFullName
	END CATCH

DELETE @LandingTables_TEMP


--AND NOW CREATE ANY TABLES THAT ARE ACTIVE
--DECLARE @SystemId AS INT
--DECLARE @TableId AS INT
DECLARE @FieldName AS VARCHAR(50)
DECLARE @SQL_CreateTable AS NVARCHAR(MAX)

INSERT INTO @LandingTables_TEMP
SELECT DISTINCT DatasetGroupName, DatasetName, DatasetType FROM @LandingTables WHERE Active='Y'

SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @LandingTables_TEMP

WHILE @ThisRowId <= @MaxRowId
	BEGIN TRY
		DELETE @LandingFields_TEMP

		SELECT 
			@DatasetGroupName = LTT.DatasetGroupName,
			@DatasetName= LTT.DatasetName,
			@DatasetType= LTT.DatasetType,
			@DatasetFullName=LTT.DatasetGroupName+'_'+LTT.DatasetType+'_'+LTT.DatasetName
		FROM
			@LandingTables_TEMP LTT
		WHERE
			LTT.RowId = @ThisRowId

		INSERT INTO @LandingFields_TEMP (FieldName)
		SELECT DISTINCT FieldName FROM @LandingTables WHERE DatasetGroupName=@DatasetGroupName AND DatasetName=@DatasetName AND Active='Y' --SystemId=@SystemId AND TableId=@TableId
		
		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @LandingFields_TEMP



		SET @SQL_CreateTable = 'CREATE TABLE Landing.dbo.'+@DatasetFullName+' (Load_GUID VARCHAR(38), Row_GUID uniqueidentifier NOT NULL DEFAULT newid() PRIMARY KEY, LoadDate DATE, '
		
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT @FieldName = LFT.FieldName FROM @LandingFields_TEMP LFT WHERE RowId = @ThisFieldRowId
				SET @SQL_CreateTable += @FieldName + ' VARCHAR(MAX),'
				SET @ThisFieldRowId+=1
			END
		
		SET @SQL_CreateTable = SUBSTRING(@SQL_CreateTable,0,LEN(@SQL_CreateTable)) + ')'
		
		DECLARE @ObjectCreateFullName AS VARCHAR(MAX)='Landing.dbo.' + @DatasetFullName
		EXEC sp_executesql @SQL_CreateTable
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Create table',@ObjectCreateFullName,'Created',@DatasetFullName
		--PRINT 'TABLE CREATED: Landing.dbo.' + @SystemName + '_' + @DatasetType+'_'+@DatasetName
		--RAISERROR('',0,1) WITH NOWAIT
		
		SET @ThisRowId+=1
	END TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Create AS VARCHAR(MAX)=ERROR_MESSAGE()
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectCreateFullName,@Err_Msg_Create,@DatasetFullName 		--@SQL_CreateTable
	END CATCH

DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime = (SELECT CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114))
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT


END
GO
