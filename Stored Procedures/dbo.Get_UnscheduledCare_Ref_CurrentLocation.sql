SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_CurrentLocation]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	Code			VARCHAR(10),
	Name			VARCHAR(80),
	Source				VARCHAR(8)
)

INSERT INTO @Results(Code,Name,Source)
SELECT 
    LEFT(loc_name,3) + ' ' + CONVERT(VARCHAR, ROW_NUMBER () OVER(PARTITION BY LEFT(loc_name,3) ORDER BY LEFT(loc_name,3))) AS [Code],
	loc_name as [DESCRIPTION],
	'MYRDDIN' as [SOURCE]

FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].cfg_locations

WHERE
	loc_name <> ''


INSERT INTO @Results(Code,Name,Source)
SELECT 
    LEFT(loc_name,3) + ' ' + CONVERT(VARCHAR, ROW_NUMBER () OVER(PARTITION BY LEFT(loc_name,3) ORDER BY LEFT(loc_name,3))) AS [Code],
	loc_name as [DESCRIPTION],
	'WEDS' as [SOURCE]
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.[dbo].cfg_locations
WHERE
	loc_name <> ''	


INSERT INTO @Results(Code,Name,Source)
(
SELECT [Left] + ' ' + CONVERT(VARCHAR, ROW_NUMBER () OVER(PARTITION BY [Left] ORDER BY [Left])) AS [Code], DESCRIPTION, SOURCE 
FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Left(DESCRIPTION, 3), 
		DESCRIPTION,
		''WPAS'' AS Source
	FROM 
		AANDE_LOCATION
		
	')
)

INSERT INTO @Results(Code,Name,Source)
	(
SELECT DISTINCT
	LEFT(REPLACE(DESCRIPTION, 'YG, ', ''), 3) + ' ' + CONVERT(VARCHAR, ROW_NUMBER () OVER(PARTITION BY LEFT(REPLACE(DESCRIPTION, 'YG, ', ''), 3)ORDER BY LEFT(REPLACE(DESCRIPTION, 'YG, ', ''), 3))),
	DESCRIPTION,
	'PIMS' as [SOURCE]

FROM 
	 [7A1AUSRVIPMSQL].iPMProduction.dbo.[SERVICE_POINTS]

WHERE
	sptyp_Refno = '205958'

	) 



SELECT * FROM @Results order by Source,Name
END
GO
