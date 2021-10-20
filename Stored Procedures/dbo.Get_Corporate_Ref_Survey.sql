SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Corporate_Ref_Survey]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(

    LocalName		VARCHAR(60),
	LocalCode		VARCHAR(4),
	Name			VARCHAR(60),
	MainCode		VARCHAR(4),
	Area			VARCHAR(10),
	Source			VARCHAR(20)
	)

INSERT INTO @Results(LocalName,LocalCode, Area, Source)
SELECT DISTINCT
		
		CAST(SvyDsc AS VARCHAR(60)) AS LocalName,
		CAST(SvyNbr AS VARCHAR(10)) AS LocalCode,
		'BCU' AS Area,
		'Viewpoint' AS Source
		
	 FROM 
		[SSIS_Loading].[PatientExperience].[dbo].[AgeBand]
	
	---------------------------------------------------------------

UPDATE @Results SET
    R.Name = S.Name,
	R.MainCode = S.MainCode
	
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.Corporate_Survey_Map SM ON (R.LocalCode=SM.LocalCode AND R.Source=SM.Source)
	INNER JOIN Mapping.dbo.Corporate_Survey S ON SM.MainCode=S.MainCode
	
SELECT * FROM @Results
Order by MainCode
END
GO
