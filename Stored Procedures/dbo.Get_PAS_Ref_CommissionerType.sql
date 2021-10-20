SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_CommissionerType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(1),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(1),
	LocalName			VARCHAR(100),
	Source				VARCHAR(7),
	Area					varchar(10)
)


INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		COMMISSIONER AS LocalCode,
		COMMISSIONER_DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as area
	FROM 
		COMMISSIONER
	')


INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT DISTINCT
		Commissioner AS LocalCode,
		COMMISSIONER_DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	FROM 
		COMMISSIONER
	')


UPDATE @Results SET
	R.MainCode = CT.MainCode,
	R.Name = CT.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_CommissionerType_Map CTM ON R.LocalCode=CTM.LocalCode AND R.Source=CTM.Source and r.Area = ctm.Area
	INNER JOIN Mapping.dbo.PAS_CommissionerType CT ON CTM.MainCode=CT.MainCode


SELECT * FROM @Results 
--where MainCode is not null
order by MainCode
END
GO
