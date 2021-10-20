SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE PROCEDURE [dbo].[Get_Radiology_Ref_ReferralType]
	
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
	1 AS LocalCode,
	'GP REFERRAL' AS LocalName,
	'Radis' AS Source,
	'Central' AS Area

	union all
	Select
	0 AS LocalCode,
	'HOSPITAL REFERRAL' AS LocalName,
	'Radis' AS Source,
	'Central' AS Area

INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	1 AS LocalCode,
	'GP REFERRAL' AS LocalName,
	'Radis' AS Source,
	'East' AS Area

	union all
	Select
	0 AS LocalCode,
	'HOSPITAL REFERRAL' AS LocalName,
	'Radis' AS Source,
	'East' AS Area


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	1 AS LocalCode,
	'GP REFERRAL' AS LocalName,
	'Radis' AS Source,
	'West' AS Area

	union all
	Select
	0 AS LocalCode,
	'HOSPITAL REFERRAL' AS LocalName,
	'Radis' AS Source,
	'West' AS Area

UPDATE 
	@Results
SET
	MainCode=LocalCode,
	Name=LocalName

SELECT * FROM @Results ORDER BY Area,LocalCode
END
GO
