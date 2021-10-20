SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_Priority]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	P.PriorityRef,
	P.Name,
	P.PriorityType AS Type
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].[Priority] P

END
GO
