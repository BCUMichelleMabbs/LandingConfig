SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_Xray]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(132),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5685


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5685


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODEDESC AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_CODEDESC
	WHERE
		CODETYPE = ''RT''
')

--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('MR Scan','MRI scan') THEN '6887'
--			WHEN LocalName IN ('Angiogram','Angiograms') THEN '6994'
--			WHEN LocalName IN ('Echo') THEN '6997'
--			WHEN LocalName IN ('Isotope Scan','Radioistope Scan') THEN '6998'
--			WHEN LocalName IN ('CT','CT Scan') THEN '6886'
--			WHEN LocalName IN ('Doppler Scan') THEN '6996'
--			WHEN LocalName IN ('US Scan','Ultrasound') THEN '6888'
--			WHEN LocalName IN ('IVU','I.V.U') THEN '6999'
--			WHEN LocalName IN ('X-Ray','XRay') THEN '6885'
--			WHEN LocalName IN ('Contrast Study') THEN '6995'
--			WHEN LocalName IN ('Venogram') THEN 'E1999'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('MR Scan','MRI scan') THEN 'MR Scan'
--			WHEN LocalName IN ('Angiogram','Angiograms') THEN 'Angiogram'
--			WHEN LocalName IN ('Echo') THEN 'Echo'
--			WHEN LocalName IN ('Isotope Scan','Radioistope Scan') THEN 'Isotope Scan'
--			WHEN LocalName IN ('CT','CT Scan') THEN 'CT'
--			WHEN LocalName IN ('Doppler Scan') THEN 'Doppler Scan'
--			WHEN LocalName IN ('US Scan','Ultrasound') THEN 'US Scan'
--			WHEN LocalName IN ('IVU','I.V.U') THEN 'IVU'
--			WHEN LocalName IN ('X-Ray','XRay') THEN 'X-Ray'
--			WHEN LocalName IN ('Contrast Study') THEN 'Contrast Study'
--			WHEN LocalName IN ('Venogram') THEN 'Venogram'
--		END


UPDATE @Results SET
	R.MainCode = X.MainCode,
	R.Name = X.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_XRay_Map XM ON R.LocalCode=XM.LocalCode AND R.Source=XM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_XRay X ON XM.MainCode=X.MainCode

SELECT * FROM @Results
END
GO
