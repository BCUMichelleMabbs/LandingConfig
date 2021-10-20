SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_ActivePerformanceManagement]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT 
	APM.ActivePerformanceManagementRef,
	APM.Id,
	APM.RedTime,
	APM.AmberTime
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].ActivePerformanceManagement APM

END
GO
