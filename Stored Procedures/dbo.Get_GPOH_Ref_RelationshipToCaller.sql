SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create PROCEDURE [dbo].[Get_GPOH_Ref_RelationshipToCaller]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	R.RelationshipRef,
	R.Name,
	R.Sort
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].RelationshipToCaller R

END
GO
