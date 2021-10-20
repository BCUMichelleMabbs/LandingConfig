SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Prep_Foundation_Tables]
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
	DECLARE @DatasetName AS VARCHAR(50)
	DECLARE @DatasetType AS VARCHAR(50)
	DECLARE @DatasetFullName AS VARCHAR(150)
	DECLARE @ReplacementPlanValue AS VARCHAR(10)
	DECLARE @ReplacementPlanUnit AS VARCHAR(50)
	DECLARE @ReplacementPlanField AS VARCHAR(50)
	DECLARE @ReplacementPlanType AS VARCHAR(50)

	DECLARE @ThisRowId AS INT
	DECLARE @MaxRowId AS INT

	DECLARE @SQL_Delete AS NVARCHAR(MAX)

	DECLARE @Datasets AS TABLE(
		RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		DatasetGroupName				VARCHAR(50),
		DatasetId				INT,
		DatasetName				VARCHAR(50),
		DatasetType				VARCHAR(50),
		ReplacementPlanValue	varchar(10),
		ReplacementPlanUnit		VARCHAR(50),
		ReplacementPlanField	VARCHAR(50),
		ReplacementPlanType		VARCHAR(50)
	)

	--EXECUTE AS USER = 'CYMRU\SVC192487'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--PRINT 'PREP FOUNDATION TABLES'
--PRINT '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
--RAISERROR('',0,1) WITH NOWAIT


	INSERT INTO @Datasets (DatasetGroupName, DatasetId, DatasetName, DatasetType, ReplacementPlanValue, ReplacementPlanUnit, ReplacementPlanField, ReplacementPlanType)
	SELECT 
		DG.Name, 
		D.Id,
		D.Name,
		DT.Name,
		ISNULL(RP.Value,'0'),
		RPU.Name,
		ISNULL(RPF.Name,'LoadDate'),
		RPT.Id
		--RPT.Name
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN ReplacementPlan RP ON D.ReplacementPlanId = RP.Id
		INNER JOIN ReplacementPlanUnit RPU ON RP.UnitId = RPU.Id
		INNER JOIN ReplacementPlanType RPT ON RP.TypeId = RPT.Id
		LEFT JOIN ReplacementPlanField RPF ON D.Id = RPF.DatasetId
	WHERE 
		DG.Active='Y' AND 
		D.Active='Y' AND 
		--RPT.Name='Delete and insert' AND  --Don't need the merges or insert only
		RPT.Id IN ('D','DN') AND
		D.ScheduleId=@ScheduleId
	
	INSERT INTO @Datasets (DatasetGroupName, DatasetId, DatasetName, DatasetType, ReplacementPlanValue, ReplacementPlanUnit, ReplacementPlanField, ReplacementPlanType)
	SELECT 
		DG.Name, 
		D.Id,
		D.Name,
		DT.Name,
		ISNULL(RP.Value,'0'),
		RPU.Name,
		ISNULL(RPF.Name,'LoadDate'),
		RPT.Id
		--RPT.Name
	FROM 
		DatasetGroup DG
		INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DependencyDatasetId =D.Id
		INNER JOIN DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN ReplacementPlan RP ON D.ReplacementPlanId = RP.Id
		INNER JOIN ReplacementPlanUnit RPU ON RP.UnitId = RPU.Id
		INNER JOIN ReplacementPlanType RPT ON RP.TypeId = RPT.Id
		LEFT JOIN ReplacementPlanField RPF ON D.Id = RPF.DatasetId
	WHERE 
		DG.Active='Y' AND 
		D.Active='Y' AND 
		--RPT.Name='Delete and insert' AND  --Don't need the merges or insert only
		RPT.Id IN ('D','DN') AND
		DD.DatasetId IN --(SELECT DatasetId FROM @Datasets)
		(SELECT D.Id FROM DatasetGroup DG INNER JOIN [Dataset] D ON DG.Id = D.GroupId
		WHERE
			DG.Active='Y' AND D.Active='Y' AND D.ScheduleId=@ScheduleId)

	--select * from @Datasets

	SELECT @ThisRowId = MIN(RowId), @MaxRowId = MAX(RowId) FROM @Datasets

	WHILE @ThisRowId <= @MaxRowId
	
	BEGIN
		SELECT 
			@DatasetGroupName = D.DatasetGroupName,
			@DatasetName= D.DatasetName,
			@DatasetType = D.DatasetType,
			@DatasetFullName=D.DatasetGroupName+'_'+D.DatasetType+'_'+D.DatasetName,
			@ReplacementPlanValue = D.ReplacementPlanValue,
			@ReplacementPlanUnit = D.ReplacementPlanUnit,
			@ReplacementPlanField = D.ReplacementPlanField,
			@ReplacementPlanType = D.ReplacementPlanType
		FROM
			@Datasets D
		WHERE
			D.RowId = @ThisRowId
	
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		IF @ReplacementPlanUnit='All'
			BEGIN
				SET @SQL_Delete = 'DELETE Foundation.dbo.'+@DatasetFullName
			END

		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		ELSE IF @ReplacementPlanUnit='Month'
			BEGIN
				SET @SQL_Delete = 'DELETE Foundation.dbo.'+@DatasetFullName + ' WHERE '
				IF @ReplacementPlanValue='0'  --Current month only
					BEGIN
						SET @SQL_Delete+='DATENAME(MONTH,'+@ReplacementPlanField+')=DATENAME(MONTH,'''+@RunDateString+''') AND DATEPART(YEAR,'+@ReplacementPlanField+')=DATEPART(YEAR,'''+@RunDateString+''')'
					END
				ELSE
					BEGIN
						SET @SQL_Delete+=@ReplacementPlanField+' > DATEADD(MONTH,-' + @ReplacementPlanValue + ','''+@RunDateString+''')'
					END
			END
		
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		ELSE IF @ReplacementPlanUnit='Day'
			BEGIN
				SET @SQL_Delete = 'DELETE Foundation.dbo.'+@DatasetFullName + ' WHERE '
				IF @ReplacementPlanValue='0'  --Current day only (Live data type stuff? - maybe you want to keep a live data thing going but keep the snapshot at the end of each day? - this would work for that)
					BEGIN
						SET @SQL_Delete+='DATENAME(DAY,'+@ReplacementPlanField+')=DATENAME(DAY,'''+@RunDateString+''') AND DATENAME(MONTH,'+@ReplacementPlanField+')=DATENAME(MONTH,'''+@RunDateString+''') AND DATENAME(YEAR,'+@ReplacementPlanField+')=DATENAME(YEAR,'''+@RunDateString+''')'
					END
				ELSE
					BEGIN
						SET @SQL_Delete+=@ReplacementPlanField+' > DATEADD(DAY,-' + @ReplacementPlanValue + ','''+@RunDateString+''')'
					END
			END
		
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		ELSE IF @ReplacementPlanUnit='Week'
			BEGIN
				SET @SQL_Delete = 'DELETE Foundation.dbo.'+@DatasetFullName + ' WHERE '
				IF @ReplacementPlanValue='0' --Current week only
					BEGIN
						DECLARE @CurrentDay AS VARCHAR(10)=DATENAME(WEEKDAY,@RunDateString)
						DECLARE @DaysToRemove AS INT=
							CASE @CurrentDay
								WHEN 'Sunday' THEN 0
								WHEN 'Monday' THEN 1
								WHEN 'Tuesday' THEN 2
								WHEN 'Wednesday' THEN 3
								WHEN 'Thursday' THEN 4
								WHEN 'Friday' THEN 5
								WHEN 'Saturday' THEN 6
							END
						SET @SQL_Delete+=@ReplacementPlanField+' > DATEADD(DAY,-' + @DaysToRemove + ','''+@RunDateString+''')'
					END
				ELSE
					BEGIN
						SET @SQL_Delete+=@ReplacementPlanField+' > DATEADD(WEEK,-' + @ReplacementPlanValue + ','''+@RunDateString+''')'
					END
			END

		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		ELSE IF @ReplacementPlanUnit='Year'
			BEGIN
			
				SET @SQL_Delete = 'DELETE Foundation.dbo.'+@DatasetFullName + ' WHERE '
				IF @ReplacementPlanValue='0'  --Current year only
					BEGIN
						SET @SQL_Delete+='DATENAME(YEAR,'+@ReplacementPlanField+')=DATENAME(YEAR,'''+@RunDateString+''')'
					END
				ELSE
					BEGIN
						SET @SQL_Delete+=@ReplacementPlanField+' > DATEADD(YEAR,-' + @ReplacementPlanValue + ','''+@RunDateString+''')'
					END
			END

	IF @ReplacementPlanType='DN'
		BEGIN 
			SET @SQL_Delete+=' OR '+@ReplacementPlanField+' IS NULL'
		END

--WE NEED TO REVISIT THE WHOLE CENSUSDATE/RUN DATE THING AT SOME POINT AS WE NEED TO BE SURE WE CAN RUN BEFORE MIDNIGHT, AFTER MIDNIGHT, OR
--EVEN RE-RUN DURING THE FOLLOWING DAY/RELOAD A WHOLE YEAR ETC ETC

		IF @SQL_Delete!=''
			BEGIN TRY
				--print @SQL_Delete
				DECLARE @ObjectName AS VARCHAR(MAX)='Foundation.dbo.' + @DatasetFullName
				EXEC sp_executesql @SQL_Delete
				DECLARE @RowCount AS VARCHAR(10)=CAST(@@ROWCOUNT AS VARCHAR(10))
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Delete',@ObjectName,@RowCount,@DatasetFullName
				--PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows from Foundation.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName
				--RAISERROR('',0,1) WITH NOWAIT
			END TRY
			BEGIN CATCH
				DECLARE @Err_Msg AS VARCHAR(MAX)=ERROR_MESSAGE()
				EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@ObjectName,@Err_Msg,@DatasetFullName
			END CATCH
	

	
	SET @SQL_Delete=''
	SET @ThisRowId+=1
END

DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
--SET @TimestampEnd = GetDate()
--SET @ProcessTime =  (SELECT FORMAT (CAST( CONVERT(VARCHAR,DATEADD(ms,DATEDIFF(SECOND,@TimestampStart,@TimestampEnd)*1000,0),114)AS DATETIME), 'HH:mm:ss', 'en-US'))
--PRINT 'Process time: ' + @ProcessTime
--RAISERROR('',0,1) WITH NOWAIT

END
GO
