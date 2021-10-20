SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_ASAGrade]
	
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

INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		ITEM_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		THR_LOOKUPS
	WHERE
		GROUP_CODE = ''18''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		ITEM_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		THR_LOOKUPS
	WHERE
		GROUP_CODE = ''18''
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
	R.MainCode = O.MainCode,
	R.Name = O.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_ASAGrade_Map ORM ON R.LocalCode=ORM.LocalCode AND R.Source=ORM.Source and r.area = orm.area
	INNER JOIN Mapping.dbo.PAS_ASAGrade O ON ORM.MainCode=O.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
END

GO
