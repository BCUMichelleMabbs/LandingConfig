SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_PathwayEvent]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(8),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		EVENT_TYPE AS LocalCode,
		EVENT_DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		PMANEVENTYPE
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		EVENT_TYPE AS LocalCode,
		EVENT_DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		PMANEVENTYPE
		')
INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
select distinct

MAIN_CODE as [LOCALCODE]
,DESCRIPTION as [LOCALNAME]
,'PIMS' as Source
,'West' as Area

from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
where RFVDM_CODE in ('SCOCM')






UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_PathwayEvent_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and r.area = amm.Area
	INNER JOIN Mapping.dbo.PAS_PathwayEvent AM ON AMM.MainCode=AM.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
order by LocalCode
END

GO
