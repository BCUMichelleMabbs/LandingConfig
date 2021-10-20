SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_TriageComplaint]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(255),
	Name			VARCHAR(255),
	LocalCode	VARCHAR(255),
	LocalName	VARCHAR(255),
	Source		VARCHAR(8)

)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT DISTINCT 
	tri_complaint,
	tri_complaint,
	'Symphony' 
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Triage
WHERE 
	NULLIF(RTRIM(tri_complaint),'') IS NOT NULL


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT DISTINCT 
	tri_complaint,
	tri_complaint,
	'WEDS' 
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Triage
WHERE 
	NULLIF(RTRIM(tri_complaint),'') IS NOT NULL


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT 
	ODPCD_REFNO,
	Description,
	'Pims'
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[ODPCD_CODES]
WHERE
	CCSXT_CODE = 'AEPRC'



UPDATE @Results SET
	R.MainCode = TC.MainCode,
	R.Name = TC.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_TriageComplaint_Map TCM ON R.LocalCode=TCM.LocalCode AND R.Source=TCM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_TriageComplaint TC ON TCM.MainCode=TC.MainCode


SELECT * FROM @Results
END
GO
