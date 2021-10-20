SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_Treatment]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(3),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(255),
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
	Lkp_TableID=5668


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_TableID=9076


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODEDESC AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_CODEDESC
	WHERE
		CODETYPE = ''EA''
	')

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT 
	ODPCD_REFNO AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[ODPCD_CODES]
WHERE
	CCSXT_CODE='AETRE'


UPDATE @Results SET
	R.MainCode = T.MainCode,
	R.Name = T.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_Treatment_Map TM ON R.LocalCode=TM.LocalCode AND R.Source=TM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_Treatment T ON TM.MainCode=T.MainCode



SELECT * FROM @Results
END
GO
