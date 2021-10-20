SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Init_Dimensions] 
	@Load_Guid AS VARCHAR(38),
	@ScheduleId AS INT--,
	--@DimensionServer AS VARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ProcName AS VARCHAR(MAX)=(SELECT OBJECT_NAME(@@PROCID))
DECLARE @StartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage start',@ProcName,@StartTime,NULL


DECLARE @ThisRowId AS INT = 0
DECLARE @MaxRowId AS INT = 0
DECLARE @ThisFieldRowId AS INT
DECLARE @MaxFieldRowId AS INT
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @DatasetName AS VARCHAR(50)
DECLARE @DatasetId AS INT
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DimensionName AS VARCHAR(150)
DECLARE @FQDimensionName AS VARCHAR(300)

DECLARE @DimensionServer  AS NVARCHAR(200)='[BCUINFO\BCUDATAWAREHOUSE]'

--First, get the system, tables and fields that we need - cba splitting this into 3, easier to just grab everything - doesn't really matter about normalisation in here.....
DECLARE @Dimension AS TABLE(
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
DECLARE @Dimension_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DatasetGroupName		VARCHAR(50),
	DatasetId		INT,
	DatasetName		VARCHAR(50),
	DatasetType		VARCHAR(50)
)
DECLARE @DimensionFields_TEMP AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	FieldName		VARCHAR(50),
	Datatype		VARCHAR(50),
	Length			VARCHAR(10)
)


--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'INITIALISE FOUNDATION TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


INSERT INTO @Dimension (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, FieldDatatype, FieldLength, Active)
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
	ScheduleId=9



INSERT INTO @Dimension (DatasetGroupId, DatasetGroupName, DatasetGroupActive, DatasetId, DatasetName, DatasetType, DatasetActive, FieldId, FieldName, FieldDatatype, FieldLength, Active)
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
	DD.DatasetId IN (SELECT DatasetId FROM @Dimension)

	select * from @Dimension
	
--AND NOW CREATE ANY TABLES THAT ARE ACTIVE
--DECLARE @SystemId AS INT
--DECLARE @TableId AS INT
DECLARE @FieldName AS VARCHAR(50)
DECLARE @Datatype AS VARCHAR(50)
DECLARE @Length AS VARCHAR(10)
DECLARE @SQL_CreateTable AS NVARCHAR(MAX)
DECLARE @SQL_AlterTable AS NVARCHAR(MAX)
DECLARE @FieldValueList AS NVARCHAR(MAX)

INSERT INTO @Dimension_TEMP
SELECT DISTINCT DatasetGroupName, DatasetId, DatasetName, DatasetType FROM @Dimension WHERE Active='Y' AND DatasetType='Ref'

SELECT * FROM @Dimension_TEMP

SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @Dimension_TEMP

WHILE @ThisRowId <= @MaxRowId
	BEGIN
		DELETE @DimensionFields_TEMP

		SELECT 
			@DatasetGroupName = FTT.DatasetGroupName,
			@DatasetName= FTT.DatasetName,
			@DatasetType=FTT.DatasetType,
			@DimensionName=FTT.DatasetGroupName+'_'+FTT.DatasetName,
			@FQDimensionName='[Dimension].dbo.'+@DimensionName
		FROM
			@Dimension_TEMP FTT
		WHERE
			FTT.RowId = @ThisRowId

		INSERT INTO @DimensionFields_TEMP (FieldName, Datatype, Length)
		SELECT DISTINCT
			FT.FieldName,
			FT.FieldDatatype,
			FT.FieldLength
		FROM 
			@Dimension FT
		WHERE DatasetGroupName=@DatasetGroupName AND DatasetName=@DatasetName And Active='Y' --SystemId=@SystemId AND TableId=@TableId

		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @DimensionFields_TEMP

IF OBJECT_ID(@FQDimensionName,'U') IS NULL  --Need to change this - think it's looking at Foundation for the fqdimension name - need to run it remotely
	BEGIN TRY
		--EXEC('
		--CREATE TABLE [Dimension].dbo.UnscheduledCare_TestDependency (TestDependencySKey INT NOT NULL, TD-Field1 varchar(1),TD-Field2 varchar(1))
		--')AT [BCUINFO\BCUDATAWAREHOUSE]
		
		SET @SQL_CreateTable =  'EXEC(''CREATE TABLE '+@FQDimensionName+' ('+@DatasetName+'SKey INT IDENTITY(1,1) NOT NULL, '
		
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT 
					@FieldName = FFT.FieldName,
					@Datatype = FFT.Datatype,
					@Length = FFT.Length
				FROM 
					@DimensionFields_TEMP FFT 
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

		SET @SQL_CreateTable = SUBSTRING(@SQL_CreateTable,0,LEN(@SQL_CreateTable)) + ')'')AT '+@DimensionServer

		DECLARE @ObjectCreateFullName AS VARCHAR(MAX)=@FQDimensionName
		--EXEC sp_executesql @SQL_CreateTable
		SELECT @SQL_CreateTable
		--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Create table',@ObjectCreateFullName,'Created',@DimensionName
	END TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Create AS VARCHAR(MAX)=ERROR_MESSAGE()
		--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectCreateFullName,@Err_Msg_Create,@DimensionName
	END CATCH
ELSE IF OBJECT_ID(@FQDimensionName,'U') IS NOT NULL
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
					@DimensionFields_TEMP FFT 
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
						T.name=@DimensionName)
					BEGIN
						SET @SQL_AlterTable='ALTER TABLE '+@FQDimensionName+
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
					DECLARE @ObjectAddFieldName AS VARCHAR(MAX)=@FQDimensionName+'.'+@FieldName
					--EXEC sp_executesql @SQL_AlterTable
					SELECT @SQL_AlterTable
					--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Add field',@ObjectAddFieldName,'Added',@DimensionName
					END
					SET @ThisFieldRowId+=1
			END
			
		
	END	TRY
	BEGIN CATCH
		DECLARE @Err_Msg_Alter AS VARCHAR(MAX)=ERROR_MESSAGE()
		--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectAddFieldName,@Err_Msg_Alter,@DimensionName
	END CATCH
		
		SET @ThisRowId+=1
	END


--CHECK WE'VE GOT ALL OF THE SOURCES AND AREAS IN THERE FOR THE UKNOWN DATA
--IT'S OVERKILL TO HAVE THEM ALL BUT ULTIMATELY MIGHT SAVE SOME HASSLE AS WE DON;T HAVE TO WORRY
--ABOUT KEEPING ALL THE DIMENSIONS UP TO DATE WHEN WE GET A NEW SOURCE
--MOST OF THEM WILL BE REDUNDANT MOST OF THE TIME BUT WE'RE NOT TALKING MANY ROWS SO THE BENEFITS FAAAAR OUTWEIGH
--THE DISC SPACE PENALTY....

--CHECK IF THERE ARE NEW -2'S TO BE INSERTED AND THAT THERE'S A -1 IN THERE AS WELL (NEW TABLES ARE THE ONES THAT WILL NEED THE -1)

--IF THERE ARE THEN SWITCH OFF IDENTITY INSERT (THERE WILL BE FOR NEW TABLES SO WOULD RATHER HAVE 
--INSERTED THEM ALL FIRST AND THEN PUT THS ON ETC BUT IT'S A BIT MORE A CONVOLUTED PROCES THAT WAY WITH SOME 
--REPEATING CODE, SO DOING IT THIS WAY INSTEAD
--SWITCH OFF IDENTITY (IF NEW TABLE IT WON'T YET BE ON BUT IF EXISTING TABLE IT WILL BE)
--DECLARE @IdentityChange AS NVARCHAR(MAX)

--SET @IdentityChange='EXEC(''SET IDENTITY_INSERT '+@FQDimensionName+' ON;'')AT'+@DimensionServerName+' GO; INSERT INTO '+@FQDimensionName+' (TestDependencySKey,TDField1,TDField2)VALUES (-2,''X'',''X'') GO; SET IDENTITY_INSERT '+@FQDimensionName+' OFF;'')AT'+@DimensionServerName 	 
--EXEC('SET IDENTITY_INSERT '+@FQDimensionName+' ON;
--INSERT INTO '+@FQDimensionName+' (TestDependencySKey,TDField1,TDField2)VALUES (-2,''Z'',''Z'');
--SET IDENTITY_INSERT '+@FQDimensionName+' OFF;
--')AT[BCUINFO\BCUDATAWAREHOUSE]; 

--SELECT @IdentityChange
--EXEC sp_executesql @IdentityChange



DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL


END
GO
