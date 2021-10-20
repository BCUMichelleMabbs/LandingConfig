SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_ICNET_Ref_SpecimenType]
	
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
	SpecimenType as [Name],
	'ICNET' as [Source]
  FROM [Foundation].[dbo].[ICNET_Data_Infection]
  WHERE SpecimenType <> ''
 

	)

SELECT * FROM @Results order by Source,Name

End
GO
