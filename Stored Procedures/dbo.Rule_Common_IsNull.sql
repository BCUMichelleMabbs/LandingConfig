SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rule_Common_IsNull]
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

    SET @SQL='SELECT * FROM Landing.dbo.'+@SystemName+'_'+@DatasetType+'_'+@DatasetName+' WHERE '+@FieldName+' IS NULL'
	EXEC sp_executesql @SQL

END
GO
