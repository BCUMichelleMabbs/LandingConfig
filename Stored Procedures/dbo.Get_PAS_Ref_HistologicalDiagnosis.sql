SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_HistologicalDiagnosis]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(7),
	Name				VARCHAR(255),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(300),
	Source				VARCHAR(7),
	Area					varchar(10)
)


INSERT INTO @Results(LocalCode,LocalName,Source, area)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		upper(CODEDESC) AS LocalCode,
		--SHORTDESC AS LocalName,
		NULL as LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	FROM 
		CODEDESC
		where CodeType = ''HI''
		and CodeDesc is not null
		and Shortdesc not like ''MALIGNANT LYMPHOMA, NON-HODGKIN%''
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		upper(CODEDESC) AS LocalCode,
		--SHORTDESC AS LocalName,
		NULL as LocalName,
		''Myrddin'' AS Source,
		''East'' as area
	FROM 
		CODEDESC
		where CodeType = ''HI''
		and codedesc is not null
		and Shortdesc not like ''MALIGNANT LYMPHOMA, NON-HODGKIN%''
	')
)


INSERT INTO @Results(LocalCode,LocalName,Source, area)



select 
		
distinct LEFT(dgpro.code,5)+SUBSTRING(dgpro.code,7,1) as LocalCode
,null as LocalName
,'Pims' as Source
,'West' as area

FROM       
    [7A1AUSRVIPMSQL].[iPMProduction].[dbo].diagnosis_procedures dgpro
           
WHERE       dgpro.sorce_code = 'PRCAE'
AND       dgpro.ccsxt_code = 'I10'
AND       dgpro.code LIKE 'M%/%'
AND       ISNULL(dgpro.archv_flag,'N') = 'N'





UPDATE @Results SET
	R.MainCode = HD.MainCode,
	R.Name = HD.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_HistologicalDiagnosis_Map HDM ON R.LocalCode=HDM.LocalCode AND R.Source=HDM.Source and r.area = hdm.Area
	INNER JOIN Mapping.dbo.PAS_HistologicalDiagnosis HD ON HDM.MainCode=HD.MainCode


SELECT * FROM @Results 

order by mainCode
END
GO
