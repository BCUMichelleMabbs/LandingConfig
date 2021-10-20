SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_TimeSinceIncident]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(10),
	Name		VARCHAR(80),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(80),
	Source		VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5659

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_HOWLONG
	')


UPDATE @Results SET 
	MainCode=
		CASE 
			WHEN LocalName IN ('< 6 hours','0 to 6 Hours Ago') THEN '6067'
			WHEN LocalName IN ('6 - 24 hours','06 to 12 Hours Ago','12 to 18 Hours Ago') THEN '6068'
			WHEN LocalName IN ('1 - 2 Days','24 to 48 Hours Ago') THEN '6069'
			WHEN LocalName IN ('2 - 7 days','Over 48 Hours Ago') THEN '6070'
			WHEN LocalName IN ('> 1 week','Over A Week Ago') THEN '6071'
			WHEN LocalName IN ('> 1 month') THEN '6072'
			WHEN LocalName='Unknown' THEN '6073'
		END,
	Name = 
		CASE 
			WHEN LocalName IN ('< 6 hours','0 to 6 Hours Ago') THEN '< 6 hours'
			WHEN LocalName IN ('6 - 24 hours','06 to 12 Hours Ago','12 to 18 Hours Ago') THEN '6 - 24 hours'
			WHEN LocalName IN ('1 - 2 Days','24 to 48 Hours Ago') THEN '1 - 2 Days'
			WHEN LocalName IN ('2 - 7 days','Over 48 Hours Ago') THEN '2 - 7 days'
			WHEN LocalName IN ('> 1 week','Over A Week Ago') THEN '> 1 week'
			WHEN LocalName IN ('> 1 month') THEN '> 1 month'
			WHEN LocalName='Unknown' THEN 'Unknown'
		END

SELECT * FROM @Results

END
GO
