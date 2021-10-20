SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_TriageDiscriminator]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(255),
	Name			VARCHAR(255),
	LocalCode	VARCHAR(255),
	LocalName	VARCHAR(255),
	Source		VARCHAR(8)
)

INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
SELECT DISTINCT 
	RTRIM(tri_discriminator),
	RTRIM(tri_discriminator),
	RTRIM(tri_discriminator),
	RTRIM(tri_discriminator),
	'Symphony'
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.triage
WHERE
	NULLIF(RTRIM(tri_discriminator),'') IS NOT NULL AND
	tri_date>'1 January 2010'


INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
SELECT DISTINCT 
	RTRIM(tri_discriminator),
	RTRIM(tri_discriminator),
	RTRIM(tri_discriminator),
	RTRIM(tri_discriminator),
	'WEDS'
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.triage
WHERE
	NULLIF(RTRIM(tri_discriminator),'') IS NOT NULL AND
	tri_date>'1 January 2010'

INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		DISCRIMINATOR_ID AS MainCode,
		DISCRIMINATOR_NAME AS Name,
		DISCRIMINATOR_ID AS LocalCode,
		DISCRIMINATOR_NAME AS LocalName,
		''WPAS'' AS Source
	FROM 
		TRIAGEDI
	WHERE
		NOT(
			DISCRIMINATOR_ID=5423 AND
			TRIAGE_ID=1016
		)
	')



INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
SELECT
	TD.ODPCD_REFNO,
	TD.DESCRIPTION,
	TD.ODPCD_REFNO,
	TD.DESCRIPTION,
	'Pims'
FROM
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].ODPCD_CODES TD 
WHERE
	TD.CCSXT_CODE='AEDIG'



--UPDATE @Results SET
--	R.MainCode = TD.MainCode,
--	R.Name = TD.Name

--FROM
--	@Results R
--	INNER JOIN Mapping.dbo.UnscheduledCare_TriageDiscriminator_Map TDM ON R.LocalCode=TDM.LocalCode AND R.Source=TDM.Source
--	INNER JOIN Mapping.dbo.UnscheduledCare_TriageDiscriminator TD ON TDM.MainCode=TD.MainCode


SELECT * FROM @Results 
END
GO
