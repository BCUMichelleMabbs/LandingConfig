SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- JOB MUST BE RUN AFTER 6:30 AM 

CREATE PROCEDURE [dbo].[Get_ERostering_Ref_PatientType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(3),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(3),
	LocalName		VARCHAR(100),
	Source			VARCHAR(10),
	Area			VARCHAR(10) )

INSERT INTO @Results(LocalCode,LocalName, Source, Area)
SELECT DISTINCT
		PatientTypeID AS LocalCode,
		PatientTypeName AS LocalName,
		'ERostering' AS Source,
		'BCU' AS Area
	 FROM 
		[SSIS_Loading].[SafeCare].[dbo].[Landing]
	
	---------------------------------------------------------------

UPDATE @Results SET
	R.MainCode = PT.MainCode,
	R.Name = PT.Name
FROM
	@Results R																																																		
	INNER JOIN Mapping.dbo.ERostering_PatientType_Map PTM ON (R.LocalCode=PTM.LocalCode AND R.Source=PTM.Source)
	INNER JOIN Mapping.dbo.ERostering_PatientType PT ON PTM.MainCode=PT.MainCode
	
SELECT * FROM @Results

END
GO
