SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_Investigation]
	
AS
BEGIN
	
	SET NOCOUNT ON;



DECLARE @Results AS TABLE(
	MainCode	VARCHAR(3),
	Name		VARCHAR(100),
	LocalCode	VARCHAR(10),
	LocalName		VARCHAR(132),
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
	Lkp_ParentID=5686


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5686


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODEDESC AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_CODEDESC
	WHERE
		CODETYPE = ''EI''
')


UPDATE @Results SET
	R.MainCode = I.MainCode,
	R.Name = I.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_Investigation_Map IM ON R.LocalCode=IM.LocalCode AND R.Source=IM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_Investigation I ON IM.MainCode=I.MainCode

SELECT * FROM @Results
END
GO
