SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_PsychiatricPatientStatus]
	
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


--INSERT INTO @Results(LocalCode,LocalName,Source, area)
--(
--SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
--	SELECT DISTINCT
--		'''' AS LocalCode,
--		'''' AS LocalName,
--		''WPAS'' AS Source,
--		''Central'' as Area
--	FROM 
--		COMMISSIONER
--	')
--)

--INSERT INTO @Results(LocalCode,LocalName,Source, Area)
--(
--SELECT * FROM OPENQUERY(WPAS_EAST,'
--	SELECT DISTINCT
--		'''' AS LocalCode,
--		'''' AS LocalName,
--		''Myrddin'' AS Source,
--		''East'' as Area
--	FROM 
--		COMMISSIONER
--	')
--)




UPDATE @Results SET
	R.MainCode = PP.MainCode,
	R.Name = PP.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_PsychiatricPatientStatus_Map PPM ON R.LocalCode=PPM.LocalCode AND R.Source=PPM.Source and r.Area = ppm.Area
	INNER JOIN Mapping.dbo.PAS_PsychiatricPatientStatus PP ON PPM.MainCode=PP.MainCode


SELECT * FROM @Results order by Source,Name
END
GO
