SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientPIMSLive]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	select *	
	,NULL AS [NursingHomeFlag]
	,NULL AS [NursingHomeType]
	,NULL AS [EMIFlag]
	,NULL AS [NursingHomeName] 
	
	from [7A1AUSRVIPMSQL].[iPMproduction].[dbo].[NWW_Get_Common_Ref_PatientPIMSLive] --view on production server

END
GO
