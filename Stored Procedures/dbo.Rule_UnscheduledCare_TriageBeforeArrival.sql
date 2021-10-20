SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rule_UnscheduledCare_TriageBeforeArrival]
	@DatasetId AS INT,
	@FieldId AS INT
	
AS
DECLARE @DatasetGroupName AS VARCHAR(50)
DECLARE @DatasetName AS VARCHAR(50)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @SQL AS NVARCHAR(MAX)
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		@DatasetGroupName=DSG.Name, @DatasetName=D.Name, @DatasetType=DT.Name 
	FROM
		Landing_Config.dbo.DatasetGroup DSG
		INNER JOIN Landing_Config.dbo.Dataset D ON DSG.Id = D.GroupId
		INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId = DT.Id
		INNER JOIN Landing_Config.dbo.Field F ON D.Id = F.DatasetId
	WHERE
		D.Id = @DatasetId

    SET @SQL='SELECT * FROM Landing.dbo.'+@DatasetGroupName+'_'+@DatasetType+'_'+@DatasetName+' WHERE 
		CAST(DATEADD(DAY,DATEDIFF(DAY,''19000101'',ArrivalDate),CAST(ArrivalTime AS DATETIME2)) AS DATETIME2) > 
		CAST(DATEADD(DAY,DATEDIFF(DAY,''19000101'',TriageStartDate),CAST(TriageStartTime AS DATETIME2)) AS DATETIME2)'
	EXEC sp_executesql @SQL

END
GO
