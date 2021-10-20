SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [dbo].[Get_GPOH_Ref_CancellationReason]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	CR.CancellationReasonRef,
	CR.Name,
	CR.Sort
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].CancellationReason CR

END
GO
