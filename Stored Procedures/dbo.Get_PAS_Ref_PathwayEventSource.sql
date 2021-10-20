SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_PathwayEventSource]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Event_Source AS LocalCode,
		SOURCE_DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as area
	 FROM 
		PMANEVENTSOURCE
		where Event_Source is not null
		and Event_Source <> ''''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		Event_Source AS LocalCode,
		SOURCE_DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		PMANEVENTSOURCE
		where Event_Source is not null
		and Event_Source <> ''''
	')

/*
INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT 
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADMET'
*/

UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_PathwayEventSource_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and r.area = amm.Area
	INNER JOIN Mapping.dbo.PAS_PathwayEventSource AM ON AMM.MainCode=AM.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
order by MainCode
END
GO
