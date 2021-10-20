SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_DischargeMethod]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(2),
	Name		VARCHAR(300),
	LocalCode	VARCHAR(3),
	LocalName	VARCHAR(100),
	Source		VARCHAR(7),
	Area			varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		MTHD AS LocalCode,
		DISCH_METHOD AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		DISCMTH
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		MTHD AS LocalCode,
		DISCH_METHOD AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		DISCMTH
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
		RFVDM_CODE='DISMT'


UPDATE @Results SET
	R.MainCode = DM.MainCode,
	R.Name = DM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_DischargeMethod_Map DMM ON R.LocalCode=DMM.LocalCode AND R.Source=DMM.Source and r.area = dmm.Area
	INNER JOIN Mapping.dbo.PAS_DischargeMethod DM ON DMM.MainCode=DM.MainCode

SELECT * FROM @Results
where MainCode is not null
END
GO
