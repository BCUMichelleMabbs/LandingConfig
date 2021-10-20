SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_AdministrativeCategory]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(4),
	LocalName		VARCHAR(300),
	Source			VARCHAR(7),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CATEGORY_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		PCATGY
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		CATEGORY_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		PCATGY
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT distinct
	rtrim(MAIN_CODE) AS LocalCode,
	rtrim(DESCRIPTION) AS LocalName,
	'Pims' AS Source,
	'West' as Area
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADCAT'


UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_AdministrativeCategory_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and r.area = amm.area
	INNER JOIN Mapping.dbo.PAS_AdministrativeCategory AM ON AMM.MainCode=AM.MainCode
	

SELECT * FROM @Results
--where MainCode is not null
END


GO
