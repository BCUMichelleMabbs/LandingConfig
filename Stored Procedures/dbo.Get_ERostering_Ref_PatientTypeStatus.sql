SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- JOB MUST BE RUN AFTER 6:30 AM 

CREATE PROCEDURE [dbo].[Get_ERostering_Ref_PatientTypeStatus]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(1),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(3),
	LocalName		VARCHAR(100),
	Source			VARCHAR(10),
	Area			VARCHAR(10) )

INSERT INTO @Results(LocalCode,LocalName, Source, Area)
SELECT DISTINCT
		PatientTypeStatus AS LocalCode,
		NULL AS LocalName,
		'ERostering' AS Source,
		'BCU' AS Area
	 FROM 
		[SSIS_Loading].[SafeCare].[dbo].[Landing]
	
	---------------------------------------------------------------

UPDATE @Results SET
	R.MainCode = PTS.MainCode,
	R.Name = PTS.Name
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.ERostering_PatientTypeStatus_Map PTSM ON (R.LocalCode=PTSM.LocalCode AND R.Source=PTSM.Source)
	INNER JOIN Mapping.dbo.ERostering_PatientTypeStatus PTS ON PTSM.MainCode=PTS.MainCode
	
SELECT * FROM @Results

END
GO
