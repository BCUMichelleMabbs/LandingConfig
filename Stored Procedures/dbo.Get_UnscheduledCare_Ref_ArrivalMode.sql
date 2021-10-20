SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_ArrivalMode]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(80),
	Source				VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5650
	and lkp_iD is not null


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5650
	and lkp_iD is not null


INSERT INTO @Results(LocalCode,LocalName,Source)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_ARRIVEDBY
		
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT 
		RFVAL_REFNO AS LocalCode,
		DESCRIPTION AS LocalName,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
	WHERE
		RFVDM_CODE='ARMOD'
	) 


UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_ArrivalMode_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_ArrivalMode AM ON AMM.MainCode=AM.MainCode


--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Ambulance','999 Ambulance','Ambulance Rapid Handover') THEN '01'
--			WHEN LocalName IN ('Foot','On foot','Self','Self Means') THEN '06'
--			WHEN LocalName IN ('Helicopter','Helimed','RAF Helicopter','SAR Helicopter') THEN '02'
--			WHEN LocalName = 'Police' THEN '07'
--			WHEN LocalName IN ('Private Transport','Car/Lorry/Van','Motorcycle') THEN '03'
--			WHEN LocalName IN ('Public transport','Taxi','Bus') THEN '05'
--			WHEN LocalName = 'Bicycle' THEN '04'
--			WHEN LocalName in ('Other','Trolley','Unknown','Other Means','Not Specified') THEN '20'
--			WHEN LocalName = 'Not Applicable (Planned Follow-up)' THEN '98'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Ambulance','999 Ambulance','Ambulance Rapid Handover') THEN 'Ambulance'
--			WHEN LocalName IN ('Foot','On foot','Self','Self Means') THEN 'Walked'
--			WHEN LocalName IN ('Helicopter','Helimed','RAF Helicopter','SAR Helicopter') THEN 'Helicopter/Air ambulance'
--			WHEN LocalName = 'Police' THEN 'Police car'
--			WHEN LocalName IN ('Private Transport','Car/Lorry/Van','Motorcycle') THEN 'Private motorised vehicle'
--			WHEN LocalName IN ('Public transport','Taxi','Bus') THEN 'Public transport'
--			WHEN LocalName = 'Bicycle' THEN 'Private non-motorised vehicle'
--			WHEN LocalName IN ('Other','Trolley','Unknown','Other Means','Not Specified') THEN 'Other'
--			WHEN LocalName = 'Not Applicable (Planned Follow-up)' THEN 'Not Applicable (Planned Follow-up)'
--		END

SELECT * FROM @Results order by Source,Name
END
GO
