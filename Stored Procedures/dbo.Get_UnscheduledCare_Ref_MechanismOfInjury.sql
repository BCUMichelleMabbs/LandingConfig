SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_MechanismOfInjury]
	
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
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Reports].dbo.Lookups
WHERE
	Lkp_ParentID=7274


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=7274


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_REASON
')



UPDATE @Results SET
	R.MainCode = MI.MainCode,
	R.Name = MI.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_MechanismOfInjury_Map MIM ON R.LocalCode=MIM.LocalCode AND R.Source=MIM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_MechanismOfInjury MI ON MIM.MainCode=MI.MainCode

SELECT * FROM @Results

END
GO
