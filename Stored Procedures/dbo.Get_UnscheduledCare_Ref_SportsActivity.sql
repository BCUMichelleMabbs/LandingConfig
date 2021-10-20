SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_SportsActivity]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		INT,
	LocalName		VARCHAR(255),
	Source			VARCHAR(8)
)


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5648


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5648


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT 
	ODPCD_REFNO AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[ODPCD_CODES]
WHERE
	CCSXT_CODE='AESP'

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
(6,'Contact sports','WPAS'),
(27,'Other sports','WPAS'),
(98,'Not applicable','WPAS')


--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Aero Sports') THEN '01'
--			WHEN LocalName IN ('Badminton') THEN '02'
--			WHEN LocalName IN ('Baseball') THEN '03'
--			WHEN LocalName IN ('Basketball') THEN '04'
--			WHEN LocalName IN ('Climbing') THEN '05'
--			WHEN LocalName IN ('Combat Sports','Martial Arts') THEN '06'
--			WHEN LocalName IN ('Cricket') THEN '07'
--			WHEN LocalName IN ('Cycling') THEN '08'
--			WHEN LocalName IN ('Golf') THEN '09'
--			WHEN LocalName IN ('Gymnastics') THEN '10'
--			WHEN LocalName IN ('Hockey') THEN '11'
--			WHEN LocalName IN ('Horse riding','Equestrian - Horse Riding') THEN '12'
--			WHEN LocalName IN ('Ice Skating') THEN '13'
--			WHEN LocalName IN ('Motor Sports','Car Racing','Motorcycle Racing') THEN '14'
--			WHEN LocalName IN ('Netball') THEN '15'
--			WHEN LocalName IN ('Rugby') THEN '16'
--			WHEN LocalName IN ('Running','Athletics') THEN '18'
--			WHEN LocalName IN ('Skate boarding') THEN '19'
--			WHEN LocalName IN ('Skiing') THEN '20'
--			WHEN LocalName IN ('Football','Football - Soccer') THEN '21'
--			WHEN LocalName IN ('Squash') THEN '22'
--			WHEN LocalName IN ('Swimming') THEN '23'
--			WHEN LocalName IN ('Tennis') THEN '24'
--			WHEN LocalName IN ('Water Sports','Boats - Fishing','Boats - Other','Boats - Speed','Boats - Yachts','Canoe','Diving - From Board','Diving - Scuba','Fishing','Jet Ski','Parasailing','Surfing','Swimming','Windsurfing') THEN '25'
--			WHEN LocalName IN ('Weight Lifting','Waight Training') THEN '26'
--			WHEN LocalName IN ('NOT APPLICABLE') THEN '98'
--			WHEN ISNULL(LocalName,'')='' THEN '99'
--			ELSE '27'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Aero Sports') THEN 'Aero sports'
--			WHEN LocalName IN ('Badminton') THEN 'Badminton'
--			WHEN LocalName IN ('Baseball') THEN 'Baseball'
--			WHEN LocalName IN ('Basketball') THEN 'Basketball'
--			WHEN LocalName IN ('Climbing') THEN 'Climbing'
--			WHEN LocalName IN ('Combat Sports','Martial Arts') THEN 'Combat sports'
--			WHEN LocalName IN ('Cricket') THEN 'Cricket'
--			WHEN LocalName IN ('Cycling') THEN 'Cycling'
--			WHEN LocalName IN ('Golf') THEN 'Golf'
--			WHEN LocalName IN ('Gymnastics') THEN 'Gymnastics'
--			WHEN LocalName IN ('Hockey') THEN 'Hockey'
--			WHEN LocalName IN ('Horse riding','Equestrian - Horse Riding') THEN 'Horse Riding'
--			WHEN LocalName IN ('Ice Skating') THEN 'Ice-skating'
--			WHEN LocalName IN ('Motor Sports','Car Racing','Motorcycle Racing') THEN 'Motor sports'
--			WHEN LocalName IN ('Netball') THEN 'Netball'
--			WHEN LocalName IN ('Rugby') THEN 'Rugby union'
--			WHEN LocalName IN ('Running','Athletics') THEN 'Running/jogging'
--			WHEN LocalName IN ('Skate boarding') THEN 'Skateboard/Roller Blades/skates'
--			WHEN LocalName IN ('Skiing') THEN 'Skiing'
--			WHEN LocalName IN ('Football','Football - Soccer') THEN 'Soccer'
--			WHEN LocalName IN ('Squash') THEN 'Squash'
--			WHEN LocalName IN ('Swimming') THEN 'Swimming'
--			WHEN LocalName IN ('Tennis') THEN 'Tennis'
--			WHEN LocalName IN ('Water Sports','Boats - Fishing','Boats - Other','Boats - Speed','Boats - Yachts','Canoe','Diving - From Board','Diving - Scuba','Fishing','Jet Ski','Parasailing','Surfing','Swimming','Windsurfing') THEN 'Water sports'
--			WHEN LocalName IN ('Weight Lifting','Waight Training') THEN 'Weightlifting'
--			WHEN LocalName IN ('NOT APPLICABLE') THEN 'Not Applicable – e.g. Non Injury / Non Sport Injury'
--			WHEN ISNULL(LocalName,'')='' THEN 'Sport Activity Unspecified'
--			ELSE 'Other sports'
--		END

UPDATE @Results SET
	R.MainCode = SA.MainCode,
	R.Name = SA.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_SportsActivity_Map SAM ON R.LocalCode=SAM.LocalCode AND R.Source=SAM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_SportsActivity SA ON SAM.MainCode=SA.MainCode


SELECT * FROM @Results
END
GO
