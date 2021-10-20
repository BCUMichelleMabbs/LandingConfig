SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_ManagementIntent]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(1),	
	Name		VARCHAR(200),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(80),
	Source		VARCHAR(7),
	Area			varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT distinct
		MICODE AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source,
		''Central'' as area
	 FROM 
		MGINTENT
')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT distinct
		MICODE AS LocalCode,
		DESCRIPT AS LocalName,
		''Myrddin'' AS Source,
		''East'' as area
	FROM
		MGINTENT
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT distinct
	RI2.Identifier AS LocalCode,
	R.Description AS LocalName,
	'Pims' AS Source,
	'West' as area
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].reference_values R
	JOIN [7A1AUSRVIPMSQL].[iPMProduction].[dbo].reference_value_domains RD ON rd.rfvdm_code=r.rfvdm_code
	LEFT JOIN [7A1AUSRVIPMSQL].[iPMProduction].[dbo].reference_value_ids RI2 ON ri2.rfval_refno=r.rfval_refno AND RI2.rityp_code='NHS'
	LEFT JOIN [7A1AUSRVIPMSQL].[iPMProduction].[dbo].reference_value_ids RI3 ON ri3.rfval_refno=r.rfval_refno AND RI3.rityp_code='PIMS'
WHERE
	ISNULL(R.archv_flag,'N') = 'N' AND
	ISNULL(RI2.archv_flag,'N') = 'N' AND
	R.rfvdm_code IN ('INMGT') AND
	RI2.Identifier IS NOT NULL

UPDATE @Results SET
	R.MainCode = MI.MainCode,
	R.Name = MI.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_ManagementIntent_Map MIM ON R.LocalCode=MIM.LocalCode AND R.Source=MIM.Source and r.Area = mim.area
	INNER JOIN Mapping.dbo.PAS_ManagementIntent MI ON MIM.MainCode=MI.MainCode

SELECT * FROM @Results
where MainCode is not null
END
GO
