SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_ICNET_Ref_Organism]
	
AS
BEGIN
	

	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	Name				VARCHAR(100),
	Source				VARCHAR(8)
)

INSERT INTO @Results(Name,Source)
	(
	SELECT DISTINCT 
	Organism as [Name],
	'ICNET' as [Source]
  FROM [SSIS_LOADING].[ICNET].[dbo].[ICNET]

	)

SELECT * FROM @Results order by Source,Name

End

GO
