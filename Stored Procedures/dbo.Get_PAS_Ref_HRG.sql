SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_HRG]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(5),	
	Name		VARCHAR(300),
	LocalCode	VARCHAR(5),
	LocalName	VARCHAR(300),
	Source		VARCHAR(8),
	Area			varchar(10)
)

--INSERT INTO @Results(LocalCode,LocalName,Source, area)
--SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
--	SELECT 
--		MICODE AS LocalCode,
--		DESCRIPT AS LocalName,
--		''WPAS'' AS Source,
--		''Central'' as Area
--	 FROM 
--		MGINTENT
--')


--INSERT INTO @Results(LocalCode,LocalName,Source, area)
--SELECT * FROM OPENQUERY(WPAS_EAST,'
--	SELECT 
--		MICODE AS LocalCode,
--		DESCRIPT AS LocalName,
--		''Myrddin'' AS Source,
--		''East'' as area
--	FROM
--		MGINTENT
--	')

--INSERT INTO @Results(LocalCode,LocalName,Source, area)
--SELECT
--	RI2.Identifier AS LocalCode,
--	R.Description AS LocalName,
--	'Pims' AS Source,
-- 'West' as area
--FROM 
--	[7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].reference_values R
--	JOIN [7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].reference_value_domains RD ON rd.rfvdm_code=r.rfvdm_code
--	LEFT JOIN [7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].reference_value_ids RI2 ON ri2.rfval_refno=r.rfval_refno AND RI2.rityp_code='NHS'
--	LEFT JOIN [7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].reference_value_ids RI3 ON ri3.rfval_refno=r.rfval_refno AND RI3.rityp_code='PIMS'
--WHERE
--	ISNULL(R.archv_flag,'N') = 'N' AND
--	ISNULL(RI2.archv_flag,'N') = 'N' AND
--	R.rfvdm_code IN ('INMGT') AND
--	RI2.Identifier IS NOT NULL

UPDATE @Results SET
	R.MainCode = HRG.MainCode,
	R.Name = HRG.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_HRG_Map HRGM ON R.LocalCode=HRGM.LocalCode AND R.Source=HRGM.Source and r.Area = hrgm.Area
	INNER JOIN Mapping.dbo.PAS_HRG HRG ON HRGM.MainCode=HRG.MainCode

SELECT * FROM @Results
END
GO
