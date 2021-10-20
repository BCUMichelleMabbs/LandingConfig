SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_Cover]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	C.CoverRef,
	C.Name,
	C.CoverDescription
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].Cover C

END
GO