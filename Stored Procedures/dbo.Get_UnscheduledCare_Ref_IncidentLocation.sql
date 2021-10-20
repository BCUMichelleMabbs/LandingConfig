SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_IncidentLocation]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(2),
	Name		VARCHAR(100),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(80),
	Source		VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5654

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5654



INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_WHEREHAPPEN
')

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT 
	RFVAL_REFNO AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
WHERE
	RFVDM_CODE='INLOC'



--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Home') THEN '01'
--			WHEN LocalName IN ('Other Private Dwelling','Others Home') THEN '02'
--			WHEN LocalName IN ('Residential/Nursing Home','RESIDENTIAL HOME','Nursing Home','Residential Home') THEN '03'
--			WHEN LocalName IN ('Hospital') THEN '04'
--			WHEN LocalName IN ('Educational Establishment','School','Pre-School Establishment','School, Education Area','University') THEN '05'
--			WHEN LocalName IN ('Sports ground','Sports Field','Ski Slope','Sports, Athletics Area') THEN '06'
--			WHEN LocalName IN ('Street','Public Road','Street, Road') THEN '07'
--			WHEN LocalName IN ('Industrial Area') THEN '08'
--			WHEN LocalName IN ('Farm') THEN '09'
--			WHEN LocalName IN ('Recreational Area','Public Place','Park','Playground','Theatre') THEN '10'
--			WHEN LocalName IN ('Commercial Area','Work Place','Work','Workplace') THEN '11'
--			WHEN LocalName IN ('Water - Sea') THEN '12'
--			WHEN LocalName IN ('Licenced Premises','Public House','Town Centre Pub/Club') THEN '13'
--			WHEN LocalName IN ('') THEN '98'
--			WHEN LocalName IN ('Not Specified') THEN '99'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Home') THEN 'Own Home'
--			WHEN LocalName IN ('Other Private Dwelling','Others Home') THEN 'Other''s Home'
--			WHEN LocalName IN ('Residential/Nursing Home','RESIDENTIAL HOME','Nursing Home','Residential Home') THEN 'Residential Institution'
--			WHEN LocalName IN ('Hospital') THEN 'Medical service area'
--			WHEN LocalName IN ('Educational Establishment','School','Pre-School Establishment','School, Education Area','University') THEN 'School, educational area (including organised sports area)'
--			WHEN LocalName IN ('Sports ground','Sports Field','Ski Slope','Sports, Athletics Area') THEN 'Sports and Athletics area (public, not related to school)'
--			WHEN LocalName IN ('Street','Public Road','Street, Road') THEN 'Public highway, street, road, pavement'
--			WHEN LocalName IN ('Industrial Area') THEN 'Industrial or Construction area'
--			WHEN LocalName IN ('Farm') THEN 'Farm or other place of primary production'
--			WHEN LocalName IN ('Recreational Area','Public Place','Park','Playground','Theatre') THEN 'Recreational area, cultural area, or public building'
--			WHEN LocalName IN ('Commercial Area','Work Place','Work','Workplace') THEN 'Commercial area (non-recreational)'
--			WHEN LocalName IN ('Water - Sea') THEN 'Countryside/Beach'
--			WHEN LocalName IN ('Licenced Premises','Public House','Town Centre Pub/Club') THEN 'Licensed Premises'
--			WHEN LocalName IN ('') THEN 'Not Applicable – e.g. Non Injury'
--			WHEN LocalName IN ('Not Specified') THEN 'Unspecified place of occurrence'
--		END

UPDATE @Results SET
	R.MainCode = IL.MainCode,
	R.Name = IL.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_IncidentLocation_Map ILM ON R.LocalCode=ILM.LocalCode AND R.Source=ILM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_IncidentLocation IL ON ILM.MainCode=IL.MainCode

SELECT * FROM @Results
END
GO
