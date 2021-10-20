SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_TheatreType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(8),
	Name			VARCHAR(50),
	LocalCode		VARCHAR(8),
	LocalName		VARCHAR(50),
	Source			VARCHAR(8),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		ITEM_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		THR_LOOKUPS
	WHERE
		GROUP_CODE = ''11''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		ITEM_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		THR_LOOKUPS
	WHERE
		GROUP_CODE = ''11''
	')

/*
INSERT INTO @Results(LocalCode,LocalName,Source, area)	
SELECT 
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source,
	'West' as Area
FROM 
	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADMET'
*/



UPDATE @Results SET
	R.MainCode = T.MainCode,
	R.Name = T.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_TheatreType_Map TM ON R.LocalCode=TM.LocalCode AND R.Source=TM.Source and r.Area = tm.Area
	INNER JOIN Mapping.dbo.PAS_TheatreType T ON TM.MainCode=T.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
END

GO
