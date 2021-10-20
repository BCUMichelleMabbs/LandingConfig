SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Eform_Ref_Location]
	
AS
BEGIN
	
SELECT DISTINCT 
	Area,
	Hospital,
	Ward_Name

FROM 
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_QuestionReturns]


End
GO
