SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_CaseType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	CT.CaseTypeRef,
	CT.Name,
	CT.Abbreviation,
	CT.Usage,
	CT.Sort
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].[CaseType] CT

END
GO
