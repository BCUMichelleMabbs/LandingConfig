SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_OffList]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(3),
	Name			VARCHAR(30),
	LocalCode		VARCHAR(1),
	LocalName		VARCHAR(30),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Reason_Code AS LocalCode,
		Descript AS LocalName,
		''WPAS'' AS Source
	 FROM 
		ROFFLIST
	')


INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		Reason_Code AS LocalCode,
		Descript AS LocalName,
		''Myrddin'' AS Source
	 FROM 
		ROFFLIST
	')

/*
INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT 
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADMET'
*/

UPDATE @Results SET
	R.MainCode = O.MainCode,
	R.Name = O.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_OffList_Map OLM ON R.LocalCode=OLM.LocalCode AND R.Source=OLM.Source
	INNER JOIN Mapping.dbo.PAS_OffList O ON OLM.MainCode=O.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
END

GO
