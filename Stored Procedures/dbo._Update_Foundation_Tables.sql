SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Update_Foundation_Tables]
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
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @DatasetName AS VARCHAR(50)
DECLARE @DatasetFullName  AS VARCHAR(150)
DECLARE @UpdateProcName AS VARCHAR(MAX)
DECLARE @UpdateProcNameWithGuid AS VARCHAR(MAX)
DECLARE @Updated AS INT

DECLARE @Dataset AS TABLE(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Id					INT,
	Name				VARCHAR(50),
	DatasetGroupId		INT,
	DatasetGroupName	VARCHAR(50),
	DatasetType			VARCHAR(50),
	UpdateProc			VARCHAR(MAX),
	DependencyOrder		INT
)

INSERT INTO @Dataset (Id,Name,DatasetGroupId,DatasetGroupName,DatasetType,UpdateProc,DependencyOrder)
SELECT DISTINCT
	D.Id, D.Name,
	DG.Id, DG.Name,
	DT.Name,
	D.PostFoundationProc,
	1
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].Dataset D ON DG.Id = D.GroupId
	INNER JOIN [Landing_Config].dbo.DatasetType DT ON D.DatasetTypeId=DT.Id
WHERE
	DG.Active='Y' AND 
	D.Active='Y' AND 
	NULLIF(RTRIM(D.PostFoundationProc),'') IS NOT NULL AND
	D.ScheduleId=@ScheduleId

INSERT INTO @Dataset (Id,Name,DatasetGroupId,DatasetGroupName,DatasetType,UpdateProc,DependencyOrder)
SELECT DISTINCT
	DDD.Id, DDD.Name,
	DG.Id, DG.Name,
	DT.Name,
	DDD.PostFoundationProc,
	2
FROM
	[Landing_Config].[dbo].DatasetGroup DG
	INNER JOIN [Landing_Config].[dbo].Dataset D ON DG.Id = D.GroupId
	INNER JOIN [Landing_Config].[dbo].[DatasetDependency] DD ON DD.DatasetId =D.Id
	INNER JOIN [Landing_Config].[dbo].[Dataset] DDD ON DD.DependencyDatasetId=DDD.Id
	INNER JOIN [Landing_Config].dbo.DatasetType DT ON DDD.DatasetTypeId=DT.Id
WHERE
	DG.Active='Y' AND 
	D.Active='Y' AND 
	D.ScheduleId=@ScheduleId AND
	DDD.Active='Y' AND
	NULLIF(RTRIM(DDD.PostFoundationProc),'') IS NOT NULL

SELECT @ThisDatasetRowId=MAX(RowId), @MinDatasetRowId=Min(RowId) FROM @Dataset

WHILE @ThisDatasetRowId>=@MinDatasetRowId
	BEGIN	--2
		--SET @UpdateProcName=(SELECT UpdateProc FROM @Dataset WHERE RowId=@ThisDatasetRowId) +' '''+@Load_GUID+''''
		SELECT @UpdateProcName=UpdateProc,@DatasetName=Name,@DatasetFullName=DatasetGroupName+'_'+DatasetType+'_'+Name FROM @Dataset WHERE RowId=@ThisDatasetRowId
		SET @UpdateProcNameWithGuid=@UpdateProcName+' '''+@Load_GUID+''''
		--SET @UpdateProcName+=' '''+@Load_GUID+''''
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		--DECLARE @UpdateProcStartTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
		--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Start time',@UpdateProcName,@UpdateProcStartTime,NULL
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		BEGIN TRY
			EXEC (@UpdateProcNameWithGuid)--(@UpdateProcName)
			SET @Updated=@@ROWCOUNT
			EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Update',@UpdateProcName,@Updated,@DatasetFullName
		END TRY
		BEGIN CATCH
			DECLARE @Err_Msg_Update AS VARCHAR(MAX)=ERROR_MESSAGE()
			EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Error',@UpdateProcName,@Err_Msg_Update,@DatasetFullName
		END CATCH
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		--DECLARE @UpdateProcEndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
		--EXEC _Write_Audit_Item @Load_Guid,@ProcName,'End time',@UpdateProcName,@UpdateProcEndTime,NULL
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
		SET @ThisDatasetRowId-=1
	END		--2

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


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
DECLARE @EndTime AS CHAR(8)=((SELECT CAST(CAST(GETDATE() AS TIME(0)) AS CHAR(8))))
EXEC _Write_Audit_Item @Load_Guid,@ProcName,'Stage end',@ProcName,@EndTime,NULL
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

END		--1
GO
