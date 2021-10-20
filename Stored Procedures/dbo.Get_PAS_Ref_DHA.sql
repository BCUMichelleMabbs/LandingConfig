SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_DHA]
	
AS
BEGIN
	
	SET NOCOUNT ON;


DECLARE @Results AS TABLE(
	MainCode			VARCHAR(20),
	Name				VARCHAR(255),
	LocalCode			VARCHAR(20),
	LocalName			VARCHAR(300),
	Source				VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		DHA AS LocalCode,
		DHA_NAME AS LocalName,
		''WPAS'' as Source
	 FROM 
		DHACODES
	')


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT DISTINCT
		DHA AS LocalCode,
		DHA_NAME AS LocalName,
		''Myrddin'' as Source
	 FROM 
		DHACODES
	')

INSERT INTO @Results(LocalCode,LocalName,Source)
	SELECT DISTINCT
			MAIN_IDENT AS LocalCode,
			DESCRIPTION AS LocalName,
			'PIMS' as source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].HEALTH_ORGANISATIONS
	WHERE
		HOTYP_REFNO=213983
	



UPDATE @Results SET
	R.MainCode = O.MainCode,
	R.Name = O.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_Commissioner_Map OM ON R.LocalCode=OM.LocalCode AND R.Source=OM.Source
	INNER JOIN Mapping.dbo.PAS_Commissioner O ON OM.MainCode=O.MainCode


SELECT * FROM @Results 
--where MainCode is not null
--order by Source,Name
END
GO
