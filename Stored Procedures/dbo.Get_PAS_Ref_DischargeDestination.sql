SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_DischargeDestination]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(3),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		DEST_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		DEST
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		DEST_CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		DEST
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT distinct
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source,
	'West' as area
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='DISDE'


UPDATE @Results SET
	R.MainCode = DD.MainCode,
	R.Name = DD.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_DischargeDestination_Map DDM ON R.LocalCode=DDM.LocalCode AND R.Source=DDM.Source and r.area = ddm.Area
	INNER JOIN Mapping.dbo.PAS_DischargeDestination DD ON DDM.MainCode=DD.MainCode

SELECT * FROM @Results
where MainCode is not null
END
GO
