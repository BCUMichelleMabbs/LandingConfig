SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [dbo].[Get_GPOH_Ref_Location]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	L.LocationRef,
	L.Name,
	L.AddressRef,
	L.OrganisationGroupRef
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].[Location] L

END
GO
