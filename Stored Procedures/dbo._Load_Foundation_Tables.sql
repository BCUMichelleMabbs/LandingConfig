SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Load_Foundation_Tables]
	@Load_Guid AS VARCHAR(38),
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

	DECLARE @DatasetGroupName AS VARCHAR(50)
	DECLARE @DatasetId AS INT
	DECLARE @DatasetName AS VARCHAR(50)
	DECLARE @DatasetType AS VARCHAR(50)
	DECLARE @DatasetFullName AS VARCHAR(150)
	DECLARE @ReplacementPlanType AS VARCHAR(50)
	DECLARE @ReplacementPlanName AS VARCHAR(50)
	
	DECLARE @ThisRowId AS INT
	DECLARE @MinRowId AS INT
	--DECLARE @MaxRowId AS INT
	DECLARE @ThisFieldRowId AS INT
	DECLARE @MaxFieldRowId AS INT
	DECLARE @ThisRPFieldRowId AS INT
	DECLARE @MaxRPFieldRowId AS INT

	DECLARE @SQL_Insert AS NVARCHAR(MAX)
	DECLARE @SQL_Merge AS NVARCHAR(MAX)

	DECLARE @UpdateProcName AS VARCHAR(MAX)
	DECLARE @DependencyOrder AS INT
	
	DECLARE @Datasets AS TABLE(
		RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		DatasetGroupName				VARCHAR(50),
		DatasetId				INT,
		DatasetName				VARCHAR(50),
		DatasetType				VARCHAR(50),
		ReplacementPlanType		VARCHAR(50),
		ReplacementPlanName		VARCHAR(50),
		UpdateProc				VARCHAR(MAX),
		DependencyOrder			INT
	)
	DECLARE @Fields AS TABLE(
		RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		FieldName		VARCHAR(50)
	)
	DECLARE @ReplacementPlanFields AS TABLE(
		RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		FieldName		VARCHAR(50)
	)
	--DECLARE @MergeCount AS TABLE(
	--	MergeType	VARCHAR(20)
	--)
	--EXECUTE AS USER = 'CYMRU\SVC192487'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'LOAD FOUNDATION TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


	INSERT INTO @Datasets (DatasetGroupName, DatasetId, DatasetName, DatasetType, ReplacementPlanType, ReplacementPlanName, UpdateProc, DependencyOrder)
	SELECT 
		DG.Name, 
		D.Id,
		D.Name,
		DT.Name,
		RPT.Name, 
		RP.Name,
		D.PostFoundationProc,
		1
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN [Landing_Config].dbo.ReplacementPlan RP ON D.ReplacementPlanId=RP.Id
		LEFT JOIN Landing_Config.dbo.ReplacementPlanType RPT ON RP.TypeId = RPT.Id
	WHERE 
		DG.Active='Y' AND D.Active='Y' AND D.ScheduleId=@ScheduleId
	

	INSERT INTO @Datasets (DatasetGroupName, DatasetId, DatasetName, DatasetType, ReplacementPlanType, ReplacementPlanName, UpdateProc, DependencyOrder)
	SELECT 
		DG.Name, 
		D.Id,
		D.Name,
		DT.Name,
		RPT.Name, 
		RP.Name,
		D.PostFoundationProc,
		2
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN [Landing_Config].dbo.ReplacementPlan RP ON D.ReplacementPlanId=RP.Id
		LEFT JOIN Landing_Config.dbo.ReplacementPlanType RPT ON RP.TypeId = RPT.Id
	WHERE 
		DG.Active='Y' AND 
		D.Active='Y' AND 
		DD.DatasetId IN (SELECT DatasetId FROM @Datasets)


	--SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @Datasets
	SELECT @ThisRowId = MAX(RowId), @MinRowId = Min(RowId) FROM @Datasets

	--WHILE @ThisRowId <= @MaxRowId
	WHILE @ThisRowId >= @MinRowId

	BEGIN
		SELECT 
			@DatasetGroupName = D.DatasetGroupName,
			@DatasetId = D.DatasetId,
			@DatasetName= D.DatasetName,
			@DatasetType= D.DatasetType,
			@DatasetFullName=D.DatasetGroupName+'_'+D.DatasetType+'_'+D.DatasetName,
			@ReplacementPlanType=D.ReplacementPlanType,
			@ReplacementPlanName=D.ReplacementPlanName,
			@UpdateProcName=D.UpdateProc,
			@DependencyOrder=D.DependencyOrder
		FROM
			@Datasets D
		WHERE
			D.RowId = @ThisRowId
	
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		/* FIELDS */
		INSERT INTO @Fields (FieldName)
			SELECT 
				F.Name
			FROM 
				[Landing_Config].[dbo].[Field] F
			WHERE 
				DatasetId=@DatasetId AND
				InMainQuery='Y'

		SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields

		DECLARE @FieldName AS VARCHAR(50)
		DECLARE @FieldList AS VARCHAR(MAX)='Load_GUID,Row_GUID,LoadDate'

		WHILE @ThisFieldRowId <= @MaxFieldRowId
				BEGIN
					SET @FieldName = (SELECT F.FieldName FROM @Fields F WHERE RowId = @ThisFieldRowId)
					--SET @SQL_Merge+=',Target.'+@FieldName+'=Source.'+@FieldName
					--Build the FieldList at the same time
					SET @FieldList +=','+@FieldName 
					SET @ThisFieldRowId+=1
				END
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

	IF @ReplacementPlanType IN ('Merge','Merge and Delete')
		BEGIN
			--/* FIELDS */
			--INSERT INTO @Fields (FieldName)
			--	SELECT 
			--		F.Name
			--	FROM 
			--		[Landing_Config].[dbo].[Field] F
			--	WHERE 
			--		DatasetId=@DatasetId
			--SELECT @ThisFieldRowId = MIN(RowId), @MaxFieldRowId = MAX(RowId) FROM @Fields

			--DECLARE @FieldName AS VARCHAR(50)
			--DECLARE @FieldList AS VARCHAR(MAX)='Load_GUID,Row_GUID,LoadDate'
			
			/* REPLACEMENT PLAN FIELDS */
			INSERT INTO @ReplacementPlanFields (FieldName)
				SELECT 
					F.Name
				FROM 
					[Landing_Config].[dbo].ReplacementPlanField F
				WHERE 
					DatasetId=@DatasetId
			SELECT @ThisRPFieldRowId = MIN(RowId), @MaxRPFieldRowId = MAX(RowId) FROM @ReplacementPlanFields

			DECLARE @RPFieldName AS VARCHAR(50)

			/* CREATE THE MERGE STATEMENT */
			SET @SQL_Merge = 'DECLARE @MergeCount AS TABLE(MergeType VARCHAR(20)) '+
			'MERGE Foundation.dbo.'+@DatasetFullName+' AS Target ' +
			'USING Landing.dbo.'+@DatasetFullName+' AS Source '+
			'ON ('

			WHILE @ThisRPFieldRowId <= @MaxRPFieldRowId
				BEGIN
					SET @RPFieldName=(SELECT RPF.FieldName FROM @ReplacementPlanFields RPF WHERE RowId = @ThisRPFieldRowId)
					SET @SQL_Merge+='Target.'+@RPFieldName + ' = Source.'+@RPFieldName +' AND '
					SET @ThisRPFieldRowId+=1
				END
			SET @SQL_Merge=SUBSTRING(@SQL_Merge,0,LEN(@SQL_Merge)-3)
			SET @SQL_Merge+=') WHEN MATCHED THEN UPDATE SET ' +
				'Target.Load_GUID=Source.Load_GUID,Target.Row_GUID=Source.Row_GUID,Target.LoadDate=Source.LoadDate'
			SELECT @ThisFieldRowId = MIN(RowId) FROM @Fields
			WHILE @ThisFieldRowId <= @MaxFieldRowId
				BEGIN
					SET @FieldName = (SELECT F.FieldName FROM @Fields F WHERE RowId = @ThisFieldRowId)
					SET @SQL_Merge+=',Target.'+@FieldName+'=Source.'+@FieldName
					--Build the FieldList at the same time
					--SET @FieldList +=','+@FieldName 
					SET @ThisFieldRowId+=1
				END
			
			SET @SQL_Merge+=' WHEN NOT MATCHED BY Target THEN INSERT ('+@FieldList+') VALUES(Source.'+
			REPLACE(@FieldList,',',',Source.')+') '

			IF @ReplacementPlanName='Merge with delete'
				BEGIN
					SET @SQL_Merge+='WHEN NOT MATCHED BY SOURCE THEN DELETE '
				END
			
			SET @SQL_Merge+='OUTPUT $action INTO @MergeCount;SELECT @InsertCount=COUNT(*) FROM @MergeCount WHERE MergeType=''INSERT'';SELECT @UpdateCount=COUNT(*) FROM @MergeCount WHERE MergeType=''UPDATE'';SELECT @DeleteCount=COUNT(*) FROM @MergeCount WHERE MergeType=''DELETE'';'
			
			
			--SELECT @SQL_Merge



			BEGIN TRY
				DECLARE @MergeObjectName AS VARCHAR(MAX)='Foundation.dbo.' + @DatasetFullName
				DECLARE @InsertedCount AS INT
				DECLARE @UpdatedCount AS INT
				DECLARE @DeletedCount AS INT
				EXEC sp_executesql @SQL_Merge,N'@InsertCount int OUTPUT, @UpdateCount int OUTPUT, @DeleteCount int OUTPUT',@InsertCount=@InsertedCount OUTPUT,@UpdateCount=@UpdatedCount OUTPUT,@DeleteCount=@DeletedCount OUTPUT
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Merge-Insert',@MergeObjectName,@InsertedCount,@DatasetFullName
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Merge-Update',@MergeObjectName,@UpdatedCount,@DatasetFullName
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Merge-Delete',@MergeObjectName,@DeletedCount,@DatasetFullName
				--PRINT 'Merged ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows into Foundation.dbo.' + @SystemName+'_'+@DatasetType+'_'+@DatasetName
			END TRY
			BEGIN CATCH
				--PRINT @SQL_Merge
				DECLARE @Err_Msg_Merge AS VARCHAR(MAX)=ERROR_MESSAGE()+ ' ' + @SQL_Merge
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@MergeObjectName,@Err_Msg_Merge,@DatasetFullName
				--PRINT 'Error number: '+CAST(ERROR_NUMBER() AS VARCHAR(MAX))
				--PRINT 'Error severity: '+CAST(ERROR_SEVERITY() AS VARCHAR(MAX))
				--PRINT 'Error state: '+CAST(ERROR_STATE() AS VARCHAR(MAX))
				--PRINT 'Error procedure: '+ERROR_PROCEDURE()
				--PRINT 'Error line: '+CAST(ERROR_LINE() AS VARCHAR(MAX))
				--PRINT 'Error message: '+ERROR_MESSAGE()
				--RAISERROR('',0,1) WITH NOWAIT
			END CATCH
		END
	ELSE
		BEGIN
			SET @SQL_Insert = 'INSERT INTO Foundation.dbo.'+@DatasetFullName+' ('+@FieldList+
			') SELECT '+@FieldList+' FROM Landing.dbo.'+@DatasetFullName	
			
			BEGIN TRY
				DECLARE @InsertObjectName AS VARCHAR(MAX)='Foundation.dbo.' +@DatasetFullName
				EXEC sp_executesql @SQL_Insert
				DECLARE @InsertRowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Insert',@InsertObjectName,@InsertRowCount,@DatasetFullName
				--PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows into Foundation.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName
			END TRY
			BEGIN CATCH
				DECLARE @Err_Msg_Insert AS VARCHAR(MAX)=ERROR_MESSAGE()
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@InsertObjectName,@Err_Msg_Insert,@DatasetFullName  --@SQL_Insert
				--PRINT @SQL_Insert
				--PRINT 'Error number: '+CAST(ERROR_NUMBER() AS VARCHAR(MAX))
				--PRINT 'Error severity: '+CAST(ERROR_SEVERITY() AS VARCHAR(MAX))
				--PRINT 'Error state: '+CAST(ERROR_STATE() AS VARCHAR(MAX))
				--PRINT 'Error procedure: '+ERROR_PROCEDURE()
				--PRINT 'Error line: '+CAST(ERROR_LINE() AS VARCHAR(MAX))
				--PRINT 'Error message: '+ERROR_MESSAGE()
				--RAISERROR('',0,1) WITH NOWAIT
			END CATCH
		END


		--IF RTRIM(ISNULL(@UpdateProcName,''))!=''
		--	BEGIN TRY
		--		DECLARE @UpdateObjectName AS VARCHAR(MAX)='Foundation.dbo.' +@DatasetFullName
		--		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		--		DECLARE @UpdateProcStartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
		--		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Start time',@UpdateProcName,@UpdateProcStartTime,NULL
		--		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		--		EXEC (@UpdateProcName)
		--		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		--		DECLARE @UpdateProcEndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
		--		EXEC _Write_Audit_Item @Load_Guid,@ProcName,'End time',@UpdateProcName,@UpdateProcEndTime,NULL
		--		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		--	END TRY
		--	BEGIN CATCH
		--		DECLARE @Err_Msg_Update AS VARCHAR(MAX)=ERROR_MESSAGE()
		--		EXEC _Write_Audit_Item @Load_Guid,@UpdateProcName,'Error',@UpdateObjectName,@Err_Msg_Update,@DatasetFullName
		--	END CATCH


		DECLARE @PackageExists AS INT = (
		SELECT 1 WHERE EXISTS
			(
			SELECT * FROM
				[SSISDB].[internal].[folders] F
				INNER JOIN SSISDB.internal.projects PR ON F.folder_id = PR.folder_id
				INNER JOIN SSISDB.internal.packages PA ON PR.project_id = PA.project_id
			WHERE
				F.name=@DatasetGroupName AND
				PR.name=@DatasetName AND
				PA.name=@DatasetName+'.dtsx') 
			)
		DECLARE @SSISDBPackage AS VARCHAR(50)
		IF @PackageExists=1
			BEGIN TRY
				DECLARE @ExecutionId BIGINT
				SET @SSISDBPackage=@DatasetName+'.dtsx'
				EXEC [SSISDB].[catalog].[create_execution]
					@package_name= @SSISDBPackage,
					@execution_id=@ExecutionId OUTPUT,
					@folder_name=@DatasetGroupName,
					@project_name=@DatasetName,
					@use32bitruntime=False,
					@reference_id=Null
				EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionId,  @object_type=50, @parameter_name=N'SYNCHRONIZED',  @parameter_value= 1
				EXEC [SSISDB].[catalog].[start_execution] @ExecutionId
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Run SSIS package',@SSISDBPackage,'Run',@DatasetFullName
			END TRY
			BEGIN CATCH
				DECLARE @Err_Msg_Package AS VARCHAR(MAX)=@DatasetGroupName+'.'+@DatasetName+'.'+@SSISDBPackage
				DECLARE @Err_Msg_SSIS AS VARCHAR(MAX)=ERROR_MESSAGE()
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@Err_Msg_Package,@Err_Msg_SSIS,@DatasetFullName
			END CATCH


	--RAISERROR('',0,1) WITH NOWAIT
	SET @SQL_Insert=''
	SET @SQL_Merge=''
	DELETE @Fields
	DELETE @ReplacementPlanFields
	--SET @ThisRowId+=1
	SET @ThisRowId-=1
END

DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT

END
GO
