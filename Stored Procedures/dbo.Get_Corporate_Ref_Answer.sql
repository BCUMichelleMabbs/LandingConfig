SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Corporate_Ref_Answer]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	LocalName		VARCHAR(255),
	LocalCode		VARCHAR(4),
	Name			VARCHAR(255),
	MainCode		VARCHAR(4),
	Area			VARCHAR(10),
	Source			VARCHAR(20)
)

INSERT INTO @Results(LocalName,LocalCode, Area, Source)
SELECT DISTINCT
		CAST(AwrTxt AS VARCHAR(255)) AS LocalName,
		CAST(AwrNbr AS VARCHAR(10)) AS LocalCode,
		'BCU' AS Area,
		'Viewpoint' AS [Source]
	 FROM 
		[SSIS_Loading].[PatientExperience].[dbo].[AgeBand]

	where CAST(AwrNbr AS VARCHAR(10)) != '0'
	
	---------------------------------------------------------------

UPDATE @Results SET
	R.Name = A.Name,
	R.MainCode = A.MainCode
	
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.Corporate_Answer_Map AM ON (R.LocalCode=AM.LocalCode AND R.Source=AM.Source)
	INNER JOIN Mapping.dbo.Corporate_Answer A ON AM.MainCode=A.MainCode
	
SELECT * FROM @Results

order by MainCode
END
GO
