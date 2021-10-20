SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_FirstRegularDayOrNightAdmission]
	
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


--INSERT INTO @Results(LocalCode,LocalName,Source, Area)
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
--		''East'' as Area,
--	FROM 
--		COMMISSIONER
--	')
--)

UPDATE @Results SET
	R.MainCode = F.MainCode,
	R.Name = F.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_FirstRegularDayOrNightAdmission_Map FM ON R.LocalCode=FM.LocalCode AND R.Source=FM.Source and r.source = FM.Area
	INNER JOIN Mapping.dbo.PAS_FirstRegularDayOrNightAdmission F ON FM.MainCode=F.MainCode


SELECT * FROM @Results 
where MainCode is not null
order by Source,Name
END
GO
