SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_OrganisationGroup]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	OG.OrganisationGroupRef,
	OG.Name,
	OG.Abbreviation
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].OrganisationGroup OG

END
GO
