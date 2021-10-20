SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_IncidentActivity]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(20),
	LocalName		VARCHAR(50),
	Source			VARCHAR(8)
)


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT MainCode,Name,'Symphony' FROM Mapping.dbo.UnscheduledCare_IncidentActivity

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT MainCode,Name,'WEDS' FROM Mapping.dbo.UnscheduledCare_IncidentActivity

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
		SELECT DISTINCT
			CODE AS LocalCode,
			DESCRIPTION AS LocalName,
			''WPAS'' AS Source
		 FROM 
			AANDE_DOINGWHAT
	')




--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Paid Work') THEN '01'
--			WHEN LocalName IN ('Contact Sports','Non-Contact Sport') THEN '03'
--			WHEN LocalName = 'Other Leisure Pursuits' THEN '04'
--			WHEN LocalName IN ('Gardening','DIY (Home Improvement)') THEN '05'
--			WHEN LocalName = 'Other' THEN '08'
--			WHEN LocalName = 'Not applicable' THEN '98'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Paid Work') THEN 'Work'
--			WHEN LocalName IN ('Contact Sports','Non-Contact Sport') THEN 'Sports (including during education)'
--			WHEN LocalName = 'Other Leisure Pursuits' THEN 'Leisure or Play'
--			WHEN LocalName IN ('Gardening','DIY (Home Improvement)') THEN 'Home, Do It Yourself, Gardening Activities'
--			WHEN LocalName = 'Other' THEN 'Other'
--			WHEN LocalName = 'Not applicable' THEN 'Not Applicable – e.g. Non injury'
--		END

UPDATE @Results SET
	R.MainCode = IA.MainCode,
	R.Name = IA.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_IncidentActivity_Map IAM ON R.LocalCode=IAM.LocalCode AND R.Source=IAM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_IncidentActivity IA ON IAM.MainCode=IA.MainCode

SELECT * FROM @Results
END
GO
