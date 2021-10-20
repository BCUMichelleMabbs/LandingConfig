SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_Gender]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(80),
	Source				VARCHAR(10),
	Area				VARCHAR(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
(
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT Distinct
		Sex_Code AS LocalCode,
		Description AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	FROM 
		Sex
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Sex_CODE AS LocalCode,
		DESCRIPTion AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	FROM 
		Sex
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)    (
    SELECT
        Main_Code AS LocalCode,
        DESCRIPTION AS LocalName,
        'Pims' AS Source,
        'West' as Area
    FROM
        [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES
    WHERE
        RFVDM_CODE='sexxx'
        AND ISNULL(ARCHV_FLAG,'N')='N'
    )

INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source,
	'East' AS Area
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=258
	and lkp_iD is not null


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source,
	'East' AS Area
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=258
	and lkp_iD is not null
	
INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source,
	'West' AS Area
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=258
	and lkp_iD is not null


UPDATE @Results SET
	R.MainCode = P.MainCode,
	R.Name = P.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.Common_Gender_Map PM ON R.LocalCode=pm.LocalCode AND R.Source=PM.Source
	INNER JOIN Mapping.dbo.Common_Gender P ON PM.MainCode=P.MainCode

	

SELECT * FROM @Results order by Source,Name
END
GO
