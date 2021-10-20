SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_BodySides]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(132),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCodeCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID = 5688 

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCodeCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID = 5688 


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODEDESC AS LocalCode,
		DESCRIPT AS Name,
		''WPAS'' AS Source
	FROM 
		AANDE_CODEDESC
	WHERE
		CODETYPE = ''SI''
')

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODEDESC AS LocalCode,
		DESCRIPT AS Name,
		''WPAS'' AS Source
	FROM 
		AANDE_CODEDESC
	WHERE
		CODETYPE = ''RS''
')


INSERT INTO @Results(LocalCode,LocalName,Source)	
	SELECT '01' AS LocalCode, 'Left' AS LocalName, 'Pims' AS Source
	UNION
	SELECT '02' AS LocalCode, 'Right' AS LocalName, 'Pims' AS Source
	UNION
	SELECT '03' AS LocalCode, 'Bilateral' AS LocalName, 'Pims' AS Source
	UNION
	SELECT '98' AS LocalCode, 'Not applicable' AS LocalName, 'Pims' AS Source
	UNION
	SELECT '99' AS LocalCode, 'Not known' AS LocalName, 'Pims' AS Source
	
UPDATE @Results SET
	R.MainCode = BS.MainCode,
	R.Name = BS.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_BodySide_Map BSM ON R.LocalCode=BSM.LocalCode AND R.Source=BSM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_BodySide BS ON BSM.MainCode=BS.MainCode


--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName = 'Left' THEN '01'
--			WHEN LocalName = 'Right' THEN '02'
--			WHEN LocalName = 'Bilateral' THEN '03'
--			WHEN LocalName IN ('Midline','Mid-Line') THEN '98'
--			WHEN LocalName = 'General' THEN '98'
--			WHEN LocalName = 'Not applicable' THEN '98'
--			WHEN LocalName = 'Not known' THEN '99'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName = 'Left' THEN 'Left'
--			WHEN LocalName = 'Right' THEN 'Right'
--			WHEN LocalName = 'Bilateral' THEN 'Bilateral'
--			WHEN LocalName IN ('Midline','Mid-Line') THEN 'Not Applicable – Anatomical Side Not Relevant'
--			WHEN LocalName = 'General' THEN 'Not Applicable – Anatomical Side Not Relevant'
--			WHEN LocalName = 'Not applicable' THEN 'Not Applicable – Anatomical Side Not Relevant'
--			WHEN LocalName = 'Not known' THEN 'Not Known'
--		END


SELECT * FROM @Results

END
GO
