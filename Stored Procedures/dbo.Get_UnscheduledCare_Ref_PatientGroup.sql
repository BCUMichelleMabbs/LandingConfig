SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_PatientGroup]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(2),
	Name		VARCHAR(150),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(80),
	Source		VARCHAR(8)
)

--INSERT INTO @Results(LocalCode,LocalName,Source)
--SELECT
--	Lkp_ID AS LocalCode,
--	Lkp_Name AS LocalName,
--	'Symphony' AS Source
--FROM 
--	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
--WHERE
--	Lkp_ParentID=5687
INSERT INTO @Results(LocalCode,Source) VALUES
(11,'Symphony'),
(12,'Symphony'),
(13,'Symphony'),
(14,'Symphony'),
(15,'Symphony'),
(20,'Symphony'),
(30,'Symphony'),
(99,'Symphony')

INSERT INTO @Results(LocalCode,Source) VALUES
(11,'WEDS'),
(12,'WEDS'),
(13,'WEDS'),
(14,'WEDS'),
(15,'WEDS'),
(20,'WEDS'),
(30,'WEDS'),
(99,'WEDS')

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_REASON
')


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT 
	RFVAL_REFNO AS LocalCode,
	DESCRIPTION AS Name,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
WHERE
	RFVDM_CODE='AEPGR'



		INSERT INTO @Results(LocalCode,LocalName,Source)
(
Select Distinct
		a.PatientGroup as LocalCode,
		NULL as LocalName,
		a.Source as Source
From Foundation.dbo.UnscheduledCare_Data_EDAttendance a
left join mapping.dbo.UnscheduledCare_PatientGroup_Map as tc on rtrim(ltrim(upper(tc.LocalCode))) = ltrim(rtrim(upper(a.PatientGroup))) and a.source = 'OldWH' 
where a.PatientGroup is not null
)



--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Firework Related','Other Accident','RTC','Sports Related','Work Related','Road Traffic Accident','Sports Injury',
--				'Firework Injury','Accident or Emergency','RTA (Road Traffic Accident)','Firework Accident','Other Accident','Emergency','RTC (Road Traffic Collision)') THEN '11'
--			WHEN LocalName IN ('Assault') THEN '12'
--			WHEN LocalName IN ('Self Harm/OD','Deliberate Self Harm','Deliberate Self Harm (Trauma)','Deliberate Self-Harm (Non-Trauma)','Alcohol Abuse','Drug Abuse') THEN '13'
--			WHEN LocalName IN ('Not Specified') THEN '14'
--			WHEN LocalName IN ('') THEN '15'
--			WHEN LocalName IN ('Fall','Medical','Other Non-Trauma','Fall from height','Fall from standing height or less') THEN '20'
--			WHEN LocalName IN ('DOA','Brought in Dead') THEN '30'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Firework Related','Other Accident','RTC','Sports Related','Work Related','Road Traffic Accident','Sports Injury',
--				'Firework Injury','Accident or Emergency','RTA (Road Traffic Accident)','Firework Accident','Other Accident','Emergency','RTC (Road Traffic Collision)') THEN 'Accident'
--			WHEN LocalName IN ('Assault') THEN 'Assault'
--			WHEN LocalName IN ('Self Harm/OD','Deliberate Self Harm','Deliberate Self Harm (Trauma)','Deliberate Self-Harm (Non-Trauma)','Alcohol Abuse','Drug Abuse') THEN 'Deliberate Self-Harm'
--			WHEN LocalName IN ('Not Specified') THEN 'Not Known: Undetermined intent'
--			WHEN LocalName IN ('') THEN 'Not Given'
--			WHEN LocalName IN ('Fall','Medical','Other Non-Trauma','Fall from height','Fall from standing height or less') THEN 'Non-trauma'
--			WHEN LocalName IN ('DOA','Brought in Dead') THEN 'Dead on Arrival'
--		END


UPDATE @Results SET
	R.MainCode = PG.MainCode,
	R.Name = PG.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_PatientGroup_Map PGM ON R.LocalCode=PGM.LocalCode AND R.Source=PGM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_PatientGroup PG ON PGM.MainCode=PG.MainCode




SELECT * FROM @Results
order by maincode
END
GO
