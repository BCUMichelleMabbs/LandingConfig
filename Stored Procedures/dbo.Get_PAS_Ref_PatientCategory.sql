SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Is this Legas Status in the data dictionary or Administrative or a bit of both


CREATE PROCEDURE [dbo].[Get_PAS_Ref_PatientCategory]
	
AS
BEGIN
	
	SET NOCOUNT ON;


DECLARE @Results AS TABLE(
	MainCode			VARCHAR(25),
	Name				VARCHAR(255),
	LocalCode			VARCHAR(25),
	LocalName			VARCHAR(300),
	Source				VARCHAR(8),
	area					varchar(10)
)


INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CATEGORY_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		PCATGY
	')


INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT DISTINCT
		CATEGORY_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		PCATGY
	')



INSERT INTO @Results(LocalCode,LocalName,Source, area)
	SELECT DISTINCT 
		MAIN_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		'PIMS' as Source,
		'West'
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
	WHERE
		RFVDM_CODE='ADCAT'
	

UPDATE @Results SET
	R.MainCode = PC.MainCode,
	R.Name = PC.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_PatientCategory_Map PCM ON R.LocalCode=PCM.LocalCode AND R.Source=PCM.Source and r.area = pcm.area
	INNER JOIN Mapping.dbo.PAS_PatientCategory PC ON PCM.MainCode=PC.MainCode


SELECT * FROM @Results 
--where MainCode is not null
order by Source,Name
END
GO
