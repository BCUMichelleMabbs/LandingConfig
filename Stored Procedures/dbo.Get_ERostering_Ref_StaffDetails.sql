SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- JOB MUST BE RUN AFTER 6:30 AM 

CREATE PROCEDURE [dbo].[Get_ERostering_Ref_StaffDetails]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(50),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(50),
	LocalName		VARCHAR(300),
	Source			VARCHAR(10),
	Area			VARCHAR(10)
)

INSERT INTO @Results(LocalCode,LocalName, Source, Area)
SELECT DISTINCT
		EnteredBy AS LocalCode,
		NULL AS LocalName,
		'ERostering' AS Source,
		'BCU' AS Area
	 FROM 
		[SSIS_Loading].[SafeCare].[dbo].[Landing]	
	---------------------------------------------------------------

UPDATE @Results SET
	R.MainCode = SD.MainCode,
	R.Name = SD.Name
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.ERostering_CensusPeriodCode_Map SDM ON (R.LocalCode=SDM.LocalCode AND R.Source=SDM.Source)
	INNER JOIN Mapping.dbo.ERostering_CensusPeriodCode SD ON SDM.MainCode=SD.MainCode
	
SELECT * FROM @Results

END
GO
