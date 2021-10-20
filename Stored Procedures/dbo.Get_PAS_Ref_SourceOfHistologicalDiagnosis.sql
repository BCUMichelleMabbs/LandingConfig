SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_SourceOfHistologicalDiagnosis]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(2),
	LocalName			VARCHAR(100),
	Source				VARCHAR(7),
	Area					varchar(10)
)


INSERT INTO @Results(LocalCode,LocalName,Source, Area)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Source_Of_Hist AS LocalCode,
		'''' AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	FROM 
		Histol
		where  Source_Of_Hist <> '''' and Source_of_Hist is not null
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		Source_Of_Hist AS LocalCode,
		'''' AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	FROM 
		Histol
		where  Source_Of_Hist <> '''' and Source_of_Hist is not null
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
	select distinct 
	
	SUBSTRING(dgpro.code,9,1) as LocalCode
	,'' as LocalName
	,'Pims' as Source
	,'West' as Area

from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].diagnosis_procedures dgpro

     WHERE       dgpro.sorce_code = 'PRCAE'
        AND       dgpro.ccsxt_code = 'I10'
        AND       dgpro.code LIKE 'M%/%'
        AND       ISNULL(dgpro.archv_flag,'N') = 'N'
		and 
	SUBSTRING(dgpro.code,9,1) <> ' '
	

	



UPDATE @Results SET
	R.MainCode = SH.MainCode,
	R.Name = SH.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_SourceOfHistologicalDiagnosis_Map SHM ON R.LocalCode=SHM.LocalCode AND R.Source=SHM.Source and r.area = shm.Area
	INNER JOIN Mapping.dbo.PAS_SourceOfHistologicalDiagnosis SH ON SHM.MainCode=SH.MainCode


SELECT * FROM @Results 

order by MainCode
END
GO
