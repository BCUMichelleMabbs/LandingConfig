SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_DischargeOutcome]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(100),
	Source			VARCHAR(8)
)

--INSERT INTO @Results(LocalCode,LocalName,Source)
--SELECT
--	Lkp_ID AS LocalCode,
--	Lkp_Name AS LocalName,
--	'Symphony' AS Source
--FROM 
--	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
--WHERE
--	Lkp_ParentID=5674


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5674


INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
		SELECT DISTINCT
			CODE AS LocalCodeCode,
			DESCRIPTION AS Name,
			''WPAS'' AS Source
		 FROM 
			AANDE_DISPOSAL
		')
	) 

INSERT INTO @Results(LocalCode,LocalName,Source)	(
	SELECT 
		RFVAL_REFNO AS LocalCode,
		DESCRIPTION AS Name,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
	WHERE
		RFVDM_CODE='ATDIS'
	) 


	INSERT INTO @Results(LocalCode,LocalName,Source)
(
Select Distinct
		a.DischargeOutcome as LocalCode,
		NULL as LocalName,
		a.Source as Source
From Foundation.dbo.UnscheduledCare_Data_EDAttendance a
left join mapping.dbo.UnscheduledCare_DischargeOutcome_Map as tc on rtrim(ltrim(upper(tc.LocalCode))) = ltrim(rtrim(upper(a.DischargeOutcome))) and a.source = 'OldWH' 
where a.DischargeOutcome is not null
)





--UPDATE @Results SET 
--	MainCode=
--		CASE 
--			WHEN LocalName IN ('Admitted') THEN '01'
--			WHEN LocalName IN ('Transfer GLAN CLWYD ') THEN '02'
--			WHEN LEFT(LocalName,8) = 'Transfer' AND LocalName!='Transfer GLAN CLWYD' THEN '03'
--			WHEN LocalName = '' THEN '04'
--			WHEN LocalName IN ('Home GP Follow Up','Home GP Remove Sut') THEN '05'
--			WHEN LocalName IN ('') THEN '06'
--			WHEN LocalName IN ('Home No Follow Up','Discharged - did not require any follow up treatment') THEN '07'
--			WHEN LocalName IN ('A&E Clinic','ED Clinic','Emergency Department') THEN '08'
--			WHEN LocalName = 'Did Not Wait' THEN '09'
--			WHEN LocalName = 'Died' THEN '10'
--			WHEN LocalName = 'DOA' THEN '11'
--		END,
--	Name = 
--		CASE 
--			WHEN LocalName IN ('Admitted','ADMIT','Admit to Ward (X)','Admitted') THEN 'Admitted to same Hospital within Local Health Board'
--			WHEN LocalName IN ('Transfer GLAN CLWYD ','Inpatient Other Hospital','Transferred to DGH') THEN 'Admitted to other Hospital within Local Health Board'
--			WHEN (LEFT(LocalName,8) = 'Transfer' AND LocalName!='Transfer GLAN CLWYD') OR LocalName IN ('Transferred to other Health Care Provider','Follow up at other Trust','Transferred to other hospital') THEN 'Transferred to different Local Health Board'
--			WHEN LocalName IN ('Referred to Fracture Clinic','Anticoagulation Clinic','ENT Clinic','Eye Clinic','Facio-Maxillary Clinic','Fracture Clinic',
--			'Other Clinic','Physiotherapy clinic (ED)','Scaphoid Clnic (ED Physio)','Referred to Fracture Clinic','Refer to Out-patient Clinic','Outpatient Department','Eye Clinic','Ent Clinic',
--			'Fracture Clinic','Physiotherapy') THEN 'Referred to Outpatient Department '
--			WHEN LocalName IN ('Home GP Follow Up','Home GP Remove Sut','Discharge to Care of GP','Home - GP  Follow up','GP Surgery') THEN 'Referred to GP'
--			WHEN LocalName IN ('Refd to CAMHS','Refd to EPU','Refd to Occupational Health','Return For XR/US','Referred to other health care professional''Refer to GP Out of Hours','Dental Referral','Psychiatric Referral','Opthalmic Opinion','Shropdoc','Green Suite (Out of hours GP)','Referred to GPOOH') THEN 'Referred to Other Healthcare Professional'
--			WHEN LocalName IN ('Home No Follow Up','Discharged - did not require any follow up treatment','Home - No Followup','Discharged') THEN 'No Planned Follow-up'
--			WHEN LocalName IN ('A&E Clinic','ED Clinic','Emergency Department','Referred to A&E Clinic','Reattend','A&E Waiting List for Minor OP') THEN 'Planned Follow-up at Accident and Emergency Department'
--			WHEN LocalName IN ('Did Not Wait','Left Department before being treated','Left Department having refused treatment','Own Discharge') THEN 'Patient Self Discharged without Clinical Consent'
--			WHEN LocalName IN ('Died','Patient Died','Died in Department') THEN 'Died in Department'
--			WHEN LocalName IN ('DOA','Dead on Arrival') THEN 'Patient Dead on Arrival'
--		END

UPDATE @Results SET
	R.MainCode = DO.MainCode,
	R.Name = DO.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_DischargeOutcome_Map DOM ON R.LocalCode=DOM.LocalCode AND R.Source=DOM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_DischargeOutcome DO ON DOM.MainCode=DO.MainCode

SELECT * FROM @Results
order by maincode
END
GO
