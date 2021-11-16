SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_TriageCategory]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(80),
	Source		VARCHAR(8),
	[Type]		VARCHAR(50),
	Colour		VARCHAR(50)
)

--INSERT INTO @Results(LocalCode,LocalName,Source)
--SELECT
--	--Lkp_ID AS LocalCode,
--	Lkp_Name AS LocalCode,
--	Lkp_Name AS LocalName,
--	'Symphony' AS Source
--FROM 
--	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
--WHERE
--	Lkp_ParentID=5660

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	--Lkp_ID AS LocalCode,
	Lkp_Name AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5660

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_TRIAGETREAT
	')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('1','Red','WPAS'),
('2','Orange','WPAS'),
('3','Yellow','WPAS'),
('4','Green','WPAS'),
('5','Blue','WPAS')


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT 
	RFVAL_REFNO AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
WHERE
	RFVDM_CODE='TRCAT'


INSERT INTO @Results(LocalCode,LocalName,Source)
(
Select Distinct
		a.TriageCategory as LocalCode,
		NULL as LocalName,
		a.Source as Source
From Foundation.dbo.UnscheduledCare_Data_EDAttendance a
left join mapping.dbo.UnscheduledCare_TriageCategory_Map as tc on rtrim(ltrim(upper(tc.LocalCode))) = ltrim(rtrim(upper(a.TriageCategory))) and a.source = 'OldWH' 
where a.TriageCategory is not null
)




UPDATE @Results SET
	R.MainCode = TC.MainCode,
	R.Name = TC.Name,
	R.[Type] = TC.[Type],
	R.Colour = TC.Colour
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_TriageCategory_Map TCM ON R.LocalCode=TCM.LocalCode AND R.Source=TCM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_TriageCategory TC ON TCM.MainCode=TC.MainCode


SELECT * FROM @Results
ORDER BY MainCode
END
GO
