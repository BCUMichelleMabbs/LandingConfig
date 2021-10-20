SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_ClinicalCondition]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(70),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(70),
	Source			VARCHAR(8),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		cast(Diag_Code as varchar(10)) AS LocalCode,
		cast(Diag_Description as varchar(70)) AS LocalName,
		''WPAS'' AS Source,
		''Central''
	 FROM 
		CLINCON
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		cast(Diag_Code as varchar(10)) AS LocalCode,
		cast(Diag_Description as varchar(70)) AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		CLINCON
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
	R.MainCode = rtrim(C.MainCode),
	R.Name = rtrim(C.Name)
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_ClinicalCondition_Map CCM ON R.LocalCode=CCM.LocalCode AND R.Source=CCM.Source and r.Area = ccm.Area
	INNER JOIN Mapping.dbo.PAS_ClinicalCondition C ON CCM.MainCode=C.MainCode
	
SELECT * FROM @Results
--where MainCode is not null

order by maincode
END

GO
