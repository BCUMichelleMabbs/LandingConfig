SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_BedApp_Ref_ChangeReason]
*/
CREATE PROCEDURE [dbo].[Get_BedApp_Ref_ChangeReason]
	
AS
BEGIN
	
SET NOCOUNT ON;

	--SELECT DISTINCT
	--	NULLIF([Change_Reason], '') AS [Name]
	--	,'BedApp' AS [Source]
	--FROM [SSIS_LOADING].[Bed_Management_App].[Inpatients].[Live_BedNumbers]
	--WHERE NULLIF([Change_Reason], '') IS NOT NULL

	--UNION

	--SELECT DISTINCT
	--	NULLIF([Change_Reason], '') AS [Name]
	--	,'BedApp' AS [Source]
	--FROM [SSIS_LOADING].[Bed_Management_App].[Inpatients].[Historical_BedNumbers]
	--WHERE NULLIF([Change_Reason], '') IS NOT NULL

--SSIS responding very slow to pull back 7 rows of data that's hardly ever changed, manual entry for now until we can find out source of problem. DJ 8/2/21

	SELECT 
'Infection' as [Name]
,'BedApp' AS [Source]
UNION SELECT
'Staffing'
,'BedApp' AS [Source]
UNION SELECT
'Estates'
,'BedApp' AS [Source]
UNION SELECT
'Other'
,'BedApp' AS [Source]
UNION SELECT
'Escalation'
,'BedApp' AS [Source]
UNION SELECT
'De-escalation'
,'BedApp' AS [Source]
UNION SELECT
'Covid-19'
,'BedApp' AS [Source]


END
GO
