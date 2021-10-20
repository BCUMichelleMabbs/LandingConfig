SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_OutcomeOfActivity]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(300),
	Source			VARCHAR(8),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		OUTCOME_CODE AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source,
		''Central'' as area
	 FROM 
		OUTCOME
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		OUTCOME_CODE AS LocalCode,
		DESCRIPT AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		OUTCOME
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
select distinct

MAIN_CODE as [LOCALCODE]
,DESCRIPTION as [LOCALNAME]
,'PIMS' as Source
,'West' as area

from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
where RFVDM_CODE in ('SCOCM')




INSERT INTO @Results(LocalCode,LocalName,Source) Select '8' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = '8' and source = 'pims')


UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_Outcome_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and r.area = amm.Area
	INNER JOIN Mapping.dbo.PAS_Outcome AM ON AMM.MainCode=AM.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
order by MainCode
END
GO
