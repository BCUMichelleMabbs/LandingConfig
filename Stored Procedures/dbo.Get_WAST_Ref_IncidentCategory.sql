SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Ref_IncidentCategory]
AS
BEGIN
SET NOCOUNT ON;

SELECT DISTINCT 
		IncidentCategory
		,CASE IncidentCategory 
				WHEN 'RED' THEN 'Immediate - Life Threatening'
				WHEN 'AMBER' THEN 'Serious - Not Immediately Life Threatening'
				WHEN 'GREEN' THEN 'Non-Urgent - Neither Serious or Life Threatening'
				WHEN 'Cat A' THEN 'Old Response Model'
				WHEN 'Cat C' THEN 'Old Response Model'
		END

	FROM 
		[SSIS_LOADING].[WAST].[dbo].[WAST_Data_Historic]

	WHERE 
		IncidentCategory IS NOT NULL

END
GO
