SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rule_Common_DateNotInCurrentMonth]
	@DatasetId AS INT,
	@FieldId AS INT

	
AS
DECLARE @SystemName AS VARCHAR(50)
DECLARE @DatasetName AS VARCHAR(50)
DECLARE @DatasetType AS VARCHAR(50)
DECLARE @FieldName AS VARCHAR(50)
DECLARE @SQL AS NVARCHAR(MAX)
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		@SystemName=S.Name, @DatasetName=D.Name, @DatasetType=DT.Name, @FieldName=F.Name 
	FROM
		Landing_Config.dbo.[System] S
		INNER JOIN Landing_Config.dbo.Dataset D ON S.Id = D.SystemId
		INNER JOIN Landing_Config.dbo.DatasetType DT ON D.DatasetTypeId=  DT.Id
		INNER JOIN Landing_Config.dbo.Field F ON D.Id = F.DatasetId
	WHERE
		D.Id = @DatasetId AND
		F.Id = @FieldId

    SET @SQL='SELECT * FROM Landing.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName+' WHERE CAST('+@FieldName+' AS DATE) 
	NOT BETWEEN 
	CAST(''1 '' + DATENAME(MONTH,GetDate()) + '' '' + DATENAME(YEAR,GETDATE()) AS DATE) AND
	CAST(DATEADD(SECOND,-1,DATEADD(MONTH, DATEDIFF(MONTH,0,GETDATE())+1,0)) AS DATE)'
	
	EXEC sp_executesql @SQL

END
GO
