SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_PAS_Ref_AdmissionMethod]
AS
BEGIN
SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(300),
	LocalCode		VARCHAR(70),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	AdmissionGroup	VARCHAR(50),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		METHOD AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' AS Area
	 FROM 
		ADMITMTH
	')


INSERT INTO @Results(LocalCode,LocalName,Source,Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		METHOD AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' AS Area
	 FROM 
		ADMITMTH
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT distinct
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source,
	'West' AS Area
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADMET'
	
---------------------------------------------------------------
INSERT INTO @Results(LocalCode, LocalName, Source,Area)	
SELECT distinct
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([AdmissionMethod] , CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) AS LocalCode,
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([AdmissionMethod] , CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) AS LocalName,				--MTED admission methods are free text so require manual mapping. LocalCode and LocalName mapped to avoid duplication when getting admissionmethod
	'MTED' AS [Source],
	'BCU' AS Area
FROM 
	[SSIS_Loading].[MTED].[dbo].[DAL]
	---------------------------------------------------------------

UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name,
	R.AdmissionGroup = AM.AdmissionGroup
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_AdmissionMethod_Map AMM ON (R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and R.Area = AMM.Area) 
	INNER JOIN Mapping.dbo.PAS_AdmissionMethod AM ON AMM.MainCode=AM.MainCode
	
--SELECT MainCode,
--LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([Name], CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))),
--LocalCode,
--LocalName,
--Source,
--AdmissionGroup

Select * 
FROM @Results
where MainCode is not null

END
GO
