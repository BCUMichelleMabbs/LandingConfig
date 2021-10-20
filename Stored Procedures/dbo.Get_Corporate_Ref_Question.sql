SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Corporate_Ref_Question]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	
	LocalName		VARCHAR(255),
	LocalCode		VARCHAR(5),
	Name			VARCHAR(255),
	MainCode		VARCHAR(5),
	Area			VARCHAR(10),
	Source			VARCHAR(20)
)

INSERT INTO @Results(LocalName,LocalCode, Area, Source)
SELECT DISTINCT
		CAST(QtnTxt AS VARCHAR(255)) AS LocalName,
		CAST(QtnNbr AS VARCHAR(10)) AS LocalCode,
		'BCU' AS Area,
		'Viewpoint' AS [Source]
		
	 FROM 
		[SSIS_Loading].[PatientExperience].[dbo].[AgeBand]
	
	---------------------------------------------------------------

UPDATE @Results SET
    R.Name = Q.Name,
	R.MainCode = Q.MainCode
	
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.Corporate_Question_Map QM ON (R.LocalCode=QM.LocalCode AND R.Source=QM.Source)
	INNER JOIN Mapping.dbo.Corporate_Question Q ON QM.MainCode=Q.MainCode
	
SELECT * FROM @Results
order by MainCode
END
GO
