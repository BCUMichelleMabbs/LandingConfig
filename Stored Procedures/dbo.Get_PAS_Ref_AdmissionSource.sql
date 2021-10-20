SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_AdmissionSource]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(300),
	LocalCode		VARCHAR(5),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		SOURCE_CODE AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Name
	 FROM 
		SADMIT
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		SOURCE_CODE AS LocalCode,
		DESCRIPT AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		SADMIT
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT  distinct
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source,
	'West' as Area
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADSOR'


UPDATE @Results SET
	R.MainCode = ADS.MainCode,
	R.Name = ADS.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_AdmissionSource_Map ASM ON R.LocalCode=ASM.LocalCode AND R.Source=ASM.Source and R.Area = ASM.Area
	INNER JOIN Mapping.dbo.PAS_AdmissionSource ADS ON ASM.MainCode=ADS.MainCode


SELECT * FROM @Results
--where MainCode is not null
END
GO
