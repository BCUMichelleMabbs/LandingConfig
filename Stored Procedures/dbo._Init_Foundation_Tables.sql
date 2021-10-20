SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Init_Foundation_Tables] 
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
DECLARE @DatasetId AS INT
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DatasetFullName AS VARCHAR(150)

--First, get the system, tables and fields that we need - cba splitting this into 3, easier to just grab everything - doesn't really matter about normalisation in here.....
DECLARE @FoundationTables AS TABLE(
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
	FieldDatatype	VARCHAR(50),
	FieldLength		VARCHAR(10),
	Active			CHAR(1)
)
DECLARE @FoundationTables_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupName		VARCHAR(50),
	DatasetId		INT,
	DatasetName		VARCHAR(50),
	DatasetType		VARCHAR(50)
)
DECLARE @FoundationFields_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	FieldName		VARCHAR(50),
	Datatype		VARCHAR(50),
	Length			VARCHAR(10)
)


--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'INITIALISE FOUNDATION TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


INSERT INTO @FoundationTables (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, FieldDatatype, FieldLength, Active)
SELECT 
	DG.Id, DG.Name, DG.Active,
	D.Id, D.Name, DST.Name, D.Active,
	F.Id, F.Name, DT.SQLName, F.Length,
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
	INNER JOIN [Landing_Config].[dbo].[Field] F ON D.Id = F.DatasetId
	INNER JOIN [Landing_Config].dbo.Datatype DT ON F.DatatypeId=DT.Id  --ISNULL(F.FoundationDatatypeId,F.DatatypeId) = DT.Id
	INNER JOIN Landing_Config.dbo.DatasetType DST ON D.DatasetTypeId=DST.Id
WHERE
	ScheduleId=@ScheduleId


INSERT INTO @FoundationTables (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, FieldDatatype, FieldLength, Active)
SELECT 
	DG.Id, DG.Name, DG.Active,
	D.Id, D.Name, DST.Name, D.Active,
	F.Id, F.Name, DT.SQLName, F.Length,
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
	INNER JOIN [Landing_Config].[dbo].[Field] F ON D.Id = F.DatasetId
	INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
	INNER JOIN [Landing_Config].dbo.Datatype DT ON F.DatatypeId=DT.Id
	INNER JOIN Landing_Config.dbo.DatasetType DST ON D.DatasetTypeId = DST.Id
WHERE
	DD.DatasetId IN (SELECT DatasetId FROM @FoundationTables)


--AND NOW CREATE ANY TABLES THAT ARE ACTIVE
--DECLARE @SystemId AS INT
--DECLARE @TableId AS INT
DECLARE @FieldName AS VARCHAR(50)
DECLARE @Datatype AS VARCHAR(50)
DECLARE @Length AS VARCHAR(10)
DECLARE @SQL_CreateTable AS NVARCHAR(MAX)
DECLARE @SQL_AlterTable AS NVARCHAR(MAX)

INSERT INTO @FoundationTables_TEMP
SELECT DISTINCT DatasetGroupName, DatasetId, DatasetName, DatasetType FROM @FoundationTables WHERE Active='Y'

SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @FoundationTables_TEMP

WHILE @ThisRowId <= @MaxRowId
	BEGIN
		DELETE @FoundationFields_TEMP

		SELECT 
			@DatasetGroupName = FTT.DatasetGroupName,
			@DatasetName= FTT.DatasetName,
			@DatasetType=FTT.DatasetType,
			@DatasetFullName=FTT.DatasetGroupName+'_'+FTT.DatasetType+'_'+FTT.DatasetName
		FROM
			@FoundationTables_TEMP FTT
		WHERE
			FTT.RowId = @ThisRowId

		INSERT INTO @FoundationFields_TEMP (FieldName, Datatype, Length)
		SELECT DISTINCT
			FT.FieldName,
			FT.FieldDatatype,
			FT.FieldLength
		FROM 
			@FoundationTables FT
		WHERE DatasetGroupName=@DatasetGroupName AND DatasetName=@DatasetName And Active='Y' --SystemId=@SystemId AND TableId=@TableId

		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @FoundationFields_TEMP

IF OBJECT_ID('Foundation.dbo.'+@DatasetFullName,'U') IS NULL
	BEGIN TRY
		SET @SQL_CreateTable = 'CREATE TABLE Foundation.dbo.'+@DatasetFullName+' (Load_GUID VARCHAR(38), Row_GUID uniqueidentifier NOT NULL DEFAULT newid() PRIMARY KEY,LoadDate DATE, '
		
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT 
					@FieldName = FFT.FieldName,
					@Datatype = FFT.Datatype,
					@Length = FFT.Length
				FROM 
					@FoundationFields_TEMP FFT 
				WHERE 
					RowId = @ThisFieldRowId
	
				IF @Datatype IN ('varchar','decimal')
					BEGIN
						IF @Length='-1' 
							BEGIN
								SET @LENGTH='MAX'
							END						
						SET @SQL_CreateTable += @FieldName + ' ' + @Datatype + '(' + @Length + '),'
					END
				ELSE IF @Datatype='time'
					BEGIN
						IF @Length='' OR @Length IS NULL 
							BEGIN
								SET @Length='0'
							END
						SET @SQL_CreateTable += @FieldName + ' ' + @Datatype + '(' + @Length + '),'
					END
				ELSE
					BEGIN
						SET @SQL_CreateTable += @FieldName + ' ' + @Datatype + ','
					END
				SET @ThisFieldRowId+=1
			END

		SET @SQL_CreateTable = SUBSTRING(@SQL_CreateTable,0,LEN(@SQL_CreateTable)) + ')'
		
		DECLARE @ObjectCreateFullName AS VARCHAR(MAX)='Foundation.dbo.' + @DatasetFullName
		EXEC sp_executesql @SQL_CreateTable
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Create table',@ObjectCreateFullName,'Created',@DatasetFullName
		--PRINT 'TABLE CREATED: Foundation.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName
		--RAISERROR('',0,1) WITH NOWAIT
	END TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Create AS VARCHAR(MAX)=ERROR_MESSAGE()
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectCreateFullName,@Err_Msg_Create,@DatasetFullName
	END CATCH
ELSE IF OBJECT_ID('Foundation.dbo.'+@DatasetFullName,'U') IS NOT NULL
	BEGIN TRY
		--Get the fields that are in the table from sysobjects - the ordinal position should follow the order in the Field table

		--Get the fields from the Field table 

		--Compare them and add where necessary

		--Forget this stuff above
		--It should be enough to just go 'foreach field in the LandingConfig.Field table is it in the sysobjects', if not add it
		--this should be ok as we're not adding anything in a particular order so anything new 'should' just get tagged on the end
		--and if we do it this way then we don't need to bother about loadguid, rowguid and censusdate either

		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT 
					@FieldName = FFT.FieldName,
					@Datatype = FFT.Datatype,
					@Length = FFT.Length
				FROM 
					@FoundationFields_TEMP FFT 
				WHERE 
					RowId = @ThisFieldRowId
				
				IF @FieldName NOT IN(
					SELECT
						C.name
					FROM
						Foundation.sys.tables T
						INNER JOIN Foundation.sys.columns C ON T.object_id=C.object_id
					WHERE
						T.is_ms_shipped=0 AND
						T.type_desc='USER_TABLE' AND
						T.name=@DatasetFullName)
					BEGIN
						SET @SQL_AlterTable='ALTER TABLE Foundation.dbo.'+@DatasetFullName+
							' ADD '+@FieldName
						IF @Datatype IN ('varchar','decimal')
							BEGIN
								IF @Length='-1' 
									BEGIN
										SET @LENGTH='MAX'
									END						
								SET @SQL_AlterTable += ' ' + @Datatype + '(' + @Length + ') NULL'
							END	
						ELSE IF @Datatype='time'
					BEGIN
						IF @Length='' OR @Length IS NULL 
							BEGIN
								SET @Length='0'
							END
						SET @SQL_AlterTable += ' ' + @Datatype + '(' + @Length + ')'
					END
						ELSE
							BEGIN
								SET @SQL_AlterTable += ' ' + @Datatype + ' NULL'
							END
					DECLARE @ObjectAddFieldName AS VARCHAR(MAX)='Foundation.dbo.' + @DatasetFullName+'.'+@FieldName
					EXEC sp_executesql @SQL_AlterTable
					EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Add field',@ObjectAddFieldName,'Added',@DatasetFullName
					--PRINT 'FIELD ADDED: Foundation.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName+'.'+@FieldName
					--RAISERROR('',0,1) WITH NOWAIT
					END
					SET @ThisFieldRowId+=1
			END
			
		
	END	TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Alter AS VARCHAR(MAX)=ERROR_MESSAGE()
		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectAddFieldName,@Err_Msg_Alter,@DatasetFullName
	END CATCH
		
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
