SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Radiology_Ref_Abandoned]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(50),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(50),
	LocalName			VARCHAR(100),
	Source				VARCHAR(5),
	Area				VARCHAR(8)
)


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Code AS LocalCode,
	Description AS LocalName,
	'Radis' AS Source,
	'Central' AS Area
FROM 
	[RADIS_CENTRAL].RadisReporting.dbo.Abandoned


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Code AS LocalCode,
	Description AS LocalName,
	'Radis' AS Source,
	'East' AS Area
FROM
	[RADIS_EAST].RadisReporting.dbo.Abandoned


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Code AS LocalCode,
	Description AS LocalName,
	'Radis' AS Source,
	'West' AS Area
FROM
	[RADIS_WEST].RadisReporting.dbo.Abandoned

UPDATE 
	@Results
SET
	MainCode=LocalCode,
	Name=LocalName

SELECT * FROM @Results ORDER BY Area,LocalCode
END
GO
