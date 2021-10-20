SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_RegistrationType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	RT.RegistrationTypeRef,
	RT.Name,
	RT.Abbreviation,
	RT.Usage
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].RegistrationType RT

END
GO
