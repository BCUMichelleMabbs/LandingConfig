SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_AnaestheticType]
	
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
		GROUP_CODE = ''12''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		ITEM_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''Area'' as Area
	 FROM 
		THR_LOOKUPS
	WHERE
		GROUP_CODE = ''12''
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
	R.MainCode = A.MainCode,
	R.Name = A.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_AnaestheticType_Map AM ON R.LocalCode=AM.LocalCode AND R.Source=AM.Source and R.Area = AM.Area
	INNER JOIN Mapping.dbo.PAS_AnaestheticType A ON AM.MainCode=A.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
END

GO
