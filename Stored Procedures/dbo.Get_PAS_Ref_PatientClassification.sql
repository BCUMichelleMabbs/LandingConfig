SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_PatientClassification]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(3),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				Varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		MICODE AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		MGINTENT
		where micode is not null
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		MICODE AS LocalCode,
		DESCRIPT AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		MGINTENT
		where micode is not null
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
select distinct

MAIN_CODE as [LOCALCODE]
,DESCRIPTION as [LOCALNAME]
,'PIMS' as Source
,'West' as Area

from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
where RFVDM_CODE in ('PATCL')


UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_PatientClassification_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and r.area = amm.Area
	INNER JOIN Mapping.dbo.PAS_PatientClassification AM ON AMM.MainCode=AM.MainCode
	
SELECT * FROM @Results

END
GO
