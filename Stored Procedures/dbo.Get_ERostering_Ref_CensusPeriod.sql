SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- JOB MUST BE RUN AFTER 6:30 AM 

CREATE PROCEDURE [dbo].[Get_ERostering_Ref_CensusPeriod]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(1),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(1),
	LocalName		TIME(7),
	LocalDesription VARCHAR(100),
	Source			VARCHAR(10),
	Area			VARCHAR(10)
)

INSERT INTO @Results(LocalCode,LocalName,LocalDesription, Source, Area)
SELECT DISTINCT
		DefaultCensusPeriodID AS LocalCode,
		CensusPeriodStartTime AS LocalName,
		CensusPeriodName AS LocalDescription,
		'ERostering' AS Source,
		'BCU' AS Area
	 FROM 
		[SSIS_Loading].[SafeCare].[dbo].[Landing]
	
	---------------------------------------------------------------

UPDATE @Results SET
	R.MainCode = CP.MainCode,
	R.Name = CP.Name
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.ERostering_CensusPeriodCode_Map CPM ON (R.LocalCode=CPM.LocalCode AND R.Source=CPM.Source)
	INNER JOIN Mapping.dbo.ERostering_CensusPeriodCode CP ON CPM.MainCode=CP.MainCode
	
SELECT * FROM @Results

END
GO
