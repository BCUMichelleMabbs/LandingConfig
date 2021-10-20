SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_DischargeDestination]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(80),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Reports].dbo.Lookups
WHERE
	Lkp_ParentID IN (5827,5828)


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID IN (SELECT lkp_id FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups WHERE lkp_parentid=9408)



INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
		SELECT DISTINCT
			DEST_CODE AS LocalCode,
			DESCRIPTION AS LocalName,
			''WPAS'' AS Source
		 FROM 
			DEST
		')
	) 


INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT 
		RFVAL_REFNO AS LocalCode,
		DESCRIPTION AS LocalName,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
	WHERE
		RFVDM_CODE='DISDE'
	) 


--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Usual place of residence') THEN '19'
--			WHEN LocalName IN ('Temporary place of residence') THEN '29'
--			WHEN LocalName IN ('Penal establishment') THEN '39'
--			WHEN LocalName = 'Special hospital' THEN '49'
--			WHEN LocalName IN ('Other NHS Trust - General Ward','Other NHS provider - general ward') THEN '51'
--			WHEN LocalName IN ('Other NHS Trust - Maternity Ward','Other NHS provider - maternity ward') THEN '52'
--			WHEN LocalName IN ('Other NHS Trust - MH/LDS Ward','Other NHS provider - mental health ward') THEN '53'
--			WHEN LocalName IN ('NHS nursing home','NHS nursing/group residential home') THEN '54'
--			WHEN LocalName IN ('Hospital this Trust/LHB- General Ward','Same HB-general/young phys.disabled') THEN '55'
--			WHEN LocalName IN ('Hospital this Trust/LHB - Maternity Ward','Same HB-maternity/neonates') THEN '56'
--			WHEN LocalName IN ('Hospital this Trust/LHB - MH/LDS Ward','Same HB-mentally ill/learning disabilities') THEN '57'
--			WHEN LocalName IN ('Local Authority Part 3 accomodation','L.A. Part3 res. acc. where care is provided') THEN '65'
--			WHEN LocalName IN ('Local Authority foster care','L.A. foster care not Part3 res. acc.') THEN '66'
--			WHEN LocalName IN ('Local authority care') THEN '69'
--			WHEN LocalName IN ('Not applicable - died or stillbirth','Deaths, including still births') THEN '79'
--			WHEN LocalName IN ('Non-NHS residential care home','Non NHS(other than L.A.) res. care home') THEN '85'
--			WHEN LocalName IN ('Non-NHS nursing home','Non NHS(other than L.A.) nursing home') THEN '86'
--			WHEN LocalName IN ('Non-NHS hospital','Non NHS run hospital') THEN '87'
--			WHEN LocalName IN ('Non NHS(other than L.A.) run Hospice') THEN '88'
--			WHEN LocalName IN ('Other, inc. non-NHS hospital, nursing home') THEN '89'
--			WHEN LocalName IN ('Not applicable (ie not discharged)') THEN '98'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Usual place of residence') THEN 'Usual place of residence'
--			WHEN LocalName IN ('Temporary place of residence') THEN 'Temporary place of residence'
--			WHEN LocalName IN ('Penal establishment') THEN 'Penal establishment, court or police station'
--			WHEN LocalName = 'Special hospital' THEN 'Special Hospital'
--			WHEN LocalName IN ('Other NHS Trust - General Ward','Other NHS provider - general ward') THEN 'Other Local Health Board/Trust - ward for general patients'
--			WHEN LocalName IN ('Other NHS Trust - Maternity Ward','Other NHS provider - maternity ward') THEN 'Other Local Health Board/Trust - ward for maternity patients'
--			WHEN LocalName IN ('Other NHS Trust - MH/LDS Ward','Other NHS provider - mental health ward') THEN 'Other Local Health Board/Trust - ward for patients who are mentally ill'
--			WHEN LocalName IN ('NHS nursing home','NHS nursing/group residential home') THEN 'NHS run nursing home, group home or residential care home'
--			WHEN LocalName IN ('Hospital this Trust/LHB- General Ward','Same HB-general/young phys.disabled') THEN 'Hospital site within the same Local Health Board/Trust - ward for general patients'
--			WHEN LocalName IN ('Hospital this Trust/LHB - Maternity Ward','Same HB-maternity/neonates') THEN 'Hospital site within the same Local Health Board/Trust - ward for maternity patients'
--			WHEN LocalName IN ('Hospital this Trust/LHB - MH/LDS Ward','Same HB-mentally ill/learning disabilities') THEN 'Hospital site within the same Local Health Board/Trust - ward for patients who are mentally ill'
--			WHEN LocalName IN ('Local Authority Part 3 accomodation','L.A. Part3 res. acc. where care is provided') THEN 'Local Authority Part 3 residential accommodation'
--			WHEN LocalName IN ('Local Authority foster care','L.A. foster care not Part3 res. acc.') THEN 'Local authority foster care but not in Part 3 residential accommodation'
--			WHEN LocalName IN ('Local authority care') THEN 'Under local authority care – residential or foster care'
--			WHEN LocalName IN ('Not applicable - died or stillbirth','Deaths, including still births') THEN 'Not Applicable - Patient died or stillbirth'
--			WHEN LocalName IN ('Non-NHS residential care home','Non NHS(other than L.A.) res. care home') THEN 'Non-NHS (other than local authority) run residential care home'
--			WHEN LocalName IN ('Non-NHS nursing home','Non NHS(other than L.A.) nursing home') THEN 'Non-NHS (other than local authority) run nursing home'
--			WHEN LocalName IN ('Non-NHS hospital','Non NHS run hospital') THEN 'Non-NHS run hospital'
--			WHEN LocalName IN ('Non NHS(other than L.A.) run Hospice') THEN 'Non-NHS (other than Local Authority) run Hospice'
--			WHEN LocalName IN ('Other, inc. non-NHS hospital, nursing home') THEN 'Other non NHS Hospital, Nursing Home or Residential institution'
--			WHEN LocalName IN ('Not applicable (ie not discharged)') THEN 'Not applicable - hospital provider spell not finished at episode end (i.e. not discharged, or current episode unfinished)'
--		END


UPDATE @Results SET
	R.MainCode = DD.MainCode,
	R.Name = DD.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_DischargeDestination_Map DDM ON R.LocalCode=DDM.LocalCode AND R.Source=DDM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_DischargeDestination DD ON DDM.MainCode=DD.MainCode

SELECT * FROM @Results


END
GO
