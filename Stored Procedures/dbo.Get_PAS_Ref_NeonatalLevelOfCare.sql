SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_NeonatalLevelOfCare]
	
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

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
(
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT DISTINCT
		'''' AS LocalCode,
		'''' AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	FROM 
		COMMISSIONER
	')
)

UPDATE @Results SET
	R.MainCode = N.MainCode,
	R.Name = N.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_NeonatalLevelOfCare_Map NM ON R.LocalCode=NM.LocalCode AND R.Source=NM.Source and r.area = nm.area
	INNER JOIN Mapping.dbo.PAS_NeonatalLevelOfCare N ON NM.MainCode=N.MainCode


SELECT * FROM @Results order by Source,Name
END
GO
