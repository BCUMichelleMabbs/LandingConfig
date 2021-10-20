SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Load_Landing_Tables]
	@Load_GUID AS VARCHAR(38),
	@RunDate AS SMALLDATETIME,
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
	DECLARE @RunDateString AS VARCHAR(20) = DATENAME(DAY,@RunDate)+' '+DATENAME(MONTH,@RunDate)+' '+DATENAME(YEAR,@RunDate)
	--AND NOW IN THE SAME WAY THAT DID FOR CREATING THE LANDING TABLES - GO THROUGH THE ACTIVE SYSTEM/TABLES (FIELDS??)
	--AND RUN WHATEVER SQL/SP THE LOAD PROCEDURE IS
	DECLARE @SQL_LoadTables AS NVARCHAR(MAX)
	DECLARE @SQL_Exec AS NVARCHAR(MAX)
	DECLARE @LoadProc AS VARCHAR(MAX)
	DECLARE @ProcType AS VARCHAR(50)
	DECLARE @DatasetGroupName AS VARCHAR(50)
	DECLARE @DatasetName AS VARCHAR(50)
	DECLARE @DatasetType AS VARCHAR(50)
	DECLARE @DatasetFullName AS VARCHAR(150)
	DECLARE @DatasetId AS INT
	DECLARE @ThisRowId AS INT
	DECLARE @MinRowId AS INT
	DECLARE @ThisLoadProcRowId AS INT
	DECLARE @MaxLoadProcRowId AS INT
	DECLARE @ThisFieldRowId AS INT
	DECLARE @MaxFieldRowId AS INT
	DECLARE @FieldName AS VARCHAR(50)
	DECLARE @FieldDefinition AS VARCHAR(MAX)
	DECLARE @SQL_Select AS VARCHAR(MAX)
	DECLARE @FromDefinition AS VARCHAR(MAX)
	DECLARE @Datasets AS TABLE(
		RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		DatasetGroupId		INT,
		DatasetGroupName		VARCHAR(50),
		DatasetId		INT,
		DatasetName		VARCHAR(50),
		DatasetType		VARCHAR(50),
		--LoadProc		VARCHAR(MAX),
		ProcType		VARCHAR(50),
		FromDefinition	VARCHAR(MAX),
		DependencyOrder	INT
	)
	DECLARE @Fields AS TABLE(
		RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		FieldId			INT NOT NULL,
		FieldName		VARCHAR(50),
		FieldDefinition	VARCHAR(MAX),
		DatasetId		INT
	)
	DECLARE @LoadProcs AS TABLE(
		RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		LoadProcId		INT NOT NULL,
		LoadProcName	VARCHAR(MAX)
	)

	--EXECUTE AS USER = 'CYMRU\SVC192487'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'LOAD LANDING TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


	INSERT INTO @Datasets (DatasetGroupId, DatasetGroupName, DatasetId, DatasetName, DatasetType, ProcType, FromDefinition, DependencyOrder)
	SELECT 
		DG.Id, DG.Name, D.Id, D.Name, DT.Name, PT.Name, D.FromDefinition, 1 
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN [ProcType] PT ON D.ProcTypeId = PT.Id
	WHERE 
		DG.Active='Y' AND 
		D.Active='Y' AND 
		D.ScheduleId=@ScheduleId
	
	
	INSERT INTO @Datasets (DatasetGroupId, DatasetGroupName, DatasetId, DatasetName, DatasetType, ProcType, FromDefinition, DependencyOrder)
	SELECT 
		DG.Id, DG.Name, D.Id, D.Name, DT.Name, PT.Name, D.FromDefinition , 2
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN [ProcType] PT ON D.ProcTypeId = PT.Id
	WHERE 
		DG.Active='Y' AND 
		D.Active='Y' AND 
		DD.DatasetId IN (SELECT DatasetId FROM @Datasets)

	
	--SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @Tables
	SELECT @ThisRowId = Max(RowId), @MinRowId = Min(RowId) FROM @Datasets
	
	--WHILE @ThisRowId <= @MaxRowId
	WHILE @ThisRowId >= @MinRowId
	BEGIN
		SELECT 
			@DatasetGroupName = D.DatasetGroupName,
			@DatasetId = D.DatasetId,
			@DatasetName= D.DatasetName,
			@DatasetType=D.DatasetType,
			@DatasetFullName=D.DatasetGroupName+'_'+D.DatasetType+'_'+D.DatasetName,
			--@LoadProc = D.LoadProc,
			@ProcType = D.ProcType,
			@FromDefinition = D.FromDefinition
		FROM
			@Datasets D
		WHERE
			D.RowId = @ThisRowId


		
		/*FIELDS*/
		
		INSERT INTO @Fields (FieldId, FieldName, FieldDefinition)
		SELECT 
			F.Id, F.Name, f.Definition
		FROM 
			[Landing_Config].[dbo].[Field] F
		WHERE 
			DatasetId=@DatasetId AND
			InMainQuery='Y'

		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields

		--SET @SQL_LoadTables = 'INSERT INTO Dump_Landing.dbo.' + @SystemName + '_' + @DatasetName + ' (Load_GUID,'
		--SET @SQL_Select = 'SELECT ' + @Load_GUID + ','
		SET @SQL_LoadTables = 'INSERT INTO Landing.dbo.'+@DatasetFullName + ' ('
		SET @SQL_Select = 'SELECT '
		WHILE @ThisFieldRowId <= @MaxFieldRowId
			BEGIN
				SELECT 
					@FieldName = F.FieldName ,
					@FieldDefinition = F.FieldDefinition
				FROM @Fields F WHERE RowId = @ThisFieldRowId
				
				SET @SQL_LoadTables += @FieldName + ','
				SET @SQL_Select += @FieldDefinition + ','
				SET @ThisFieldRowId+=1		
			END
		
		SET @SQL_LoadTables = SUBSTRING(@SQL_LoadTables,0,LEN(@SQL_LoadTables))+') ' 
		SET @SQL_Select = SUBSTRING(@SQL_Select,0,LEN(@SQL_Select))+' '+ISNULL(@FromDefinition,'')
		
		INSERT INTO @LoadProcs(LoadProcId,LoadProcName)
		SELECT
			LP.Id,LP.Name
		FROM
			Landing_Config.dbo.DatasetLoadProc LP
		WHERE
			LP.DatasetId=@DatasetId

		SELECT @ThisLoadProcRowId=MIN(RowId),@MaxLoadProcRowId=MAX(RowId) FROM @LoadProcs
		
		WHILE @ThisLoadProcRowId<=@MaxLoadProcRowId
			BEGIN
				SELECT @LoadProc=LoadProcName FROM @LoadProcs LP WHERE LP.RowId=@ThisLoadProcRowId

				IF @ProcType = 'Stored procedure'
				BEGIN
					SET @SQL_Exec=@SQL_LoadTables + 'EXEC ' + @LoadProc
				END

				ELSE IF @ProcType = 'TSQL'
				BEGIN
					SET @SQL_Exec=@SQL_LoadTables + @LoadProc
				END

				ELSE IF @ProcType = 'SSIS package'
				BEGIN
			
					--SET @SQL_LoadTables += @SQL_Select
			
					DECLARE @ExecutionId BIGINT
					DECLARE @PackageName VARCHAR(MAX) = @LoadProc + '.dtsx'
					DECLARE @ParameterValue1 sql_variant =CONVERT(NVARCHAR(4000),LEFT(@SQL_LoadTables,8000))
					DECLARE @ParameterValue2 sql_variant =CONVERT(NVARCHAR(4000),LEFT(@SQL_Select,8000))
					EXEC [SSISDB].[catalog].[create_execution]
						@package_name= @PackageName,
						@execution_id=@ExecutionId OUTPUT,
						@folder_name='Load_Dev',
						@project_name=@LoadProc,
						@use32bitruntime=False,
						@reference_id=Null
					EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionId,  @object_type=50, @parameter_name=N'SYNCHRONIZED',  @parameter_value= 1
					--Select @ExecutionId
					--DECLARE @var0 smallint = 1
					--EXEC [SSISDB].[catalog].[set_execution_parameter_value]
					--	@ExecutionId,
					--	@object_type=50,
					--	@parameter_name=N'LOGGING_LEVEL',
					--	@parameter_value=@var0
					--EXEC [SSISDB].[catalog].[set_execution_parameter_value]
					--	@ExecutionId,
					--	@object_type = 30,
					--	@parameter_name='SQL_Insert',
					--	@parameter_value=@ParameterValue1
					--EXEC [SSISDB].[catalog].[set_execution_parameter_value]
					--	@ExecutionId,
					--	@object_type = 30,
					--	@parameter_name='SQL_Select',
					--	@parameter_value=@ParameterValue2
					--SET @SQL_LoadTables += 'EXEC [SSISDB].[catalog].[start_execution] ' + CONVERT(varchar(10), @ExecutionId)
					SET @SQL_LoadTables += 'EXEC [SSISDB].[catalog].[start_execution] ' + CONVERT(varchar(10), @ExecutionId)
					--EXEC [SSISDB].[catalog].[start_execution] @ExecutionId

				END

				ELSE IF @ProcType = 'OpenQuery'
				BEGIN
					SELECT 4
				END
		
				ELSE IF @ProcType = 'Job'
				BEGIN
					SELECT 5
				END
			
			
				--select @SQL_LoadTables
				--select @SQL_Select
				BEGIN TRY
					DECLARE @ObjectName AS VARCHAR(MAX)='Landing.dbo.' + @DatasetGroupName + '_' + @DatasetType+'_'+@DatasetName
					EXEC sp_executesql @SQL_Exec --@SQL_LoadTables
					DECLARE @RowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
					EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Insert',@LoadProc,@RowCount,@DatasetFullName
				END TRY
				BEGIN CATCH
					DECLARE @Err_Msg AS VARCHAR(MAX)=ERROR_MESSAGE()
					EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@LoadProc,@Err_Msg,@DatasetFullName --@SQL_Exec
				END CATCH
		
			--PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows into Landing.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName
			--RAISERROR('',0,1) WITH NOWAIT

			SET @ThisLoadProcRowId+=1
		END
		DELETE @LoadProcs

		DECLARE @SQL_Update AS VARCHAR(MAX) = 'UPDATE Landing.dbo.'+@DatasetFullName+' SET Load_GUID=''' + @Load_GUID + ''', LoadDate=''' + @RunDateString + ''''
		EXEC (@SQL_Update)
	
		DELETE @Fields



		
		
		
		--SET @ThisRowId+=1
		SET @ThisRowId-=1
	END

	--INSERT INTO WPAS_TREATMNT
	--EXEC(@LoadProc)

DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime = (SELECT CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114))
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT

END
GO
