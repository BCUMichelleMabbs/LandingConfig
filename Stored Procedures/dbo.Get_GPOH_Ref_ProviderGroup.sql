SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [dbo].[Get_GPOH_Ref_ProviderGroup]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	PG.ProviderGroupRef,
	PG.OrganisationGroupRef,
	PG.ProviderType,
	PG.Name,
	PG.AddressRef,
	PG.NationalProviderGroupCode
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].[ProviderGroup] PG

END
GO
