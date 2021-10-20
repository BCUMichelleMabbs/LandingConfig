SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [dbo].[Get_GPOH_Ref_Provider]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	P.ProviderRef,
	P.OrganisationGroupRef,
	P.Forename,
	P.Surname,
	P.[Lookup],
	P.ProviderType,
	P.AddressRef
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].[Provider] P

END
GO
