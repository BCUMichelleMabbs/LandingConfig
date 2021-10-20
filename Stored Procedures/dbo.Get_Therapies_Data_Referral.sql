SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[Get_Therapies_Data_Referral]
as 
begin

-- Need to ensure data from Discharge Summary is max(id)
-- 3/1/2020 WrietUpp Helpdesk Ticket:26569 re:>1 discharge/referral - response doesn't explain 
-- 2/1/2020 see email from Daniel Grugel containing Screen shots of error 


CREATE TABLE #temp_Therapies_Referral
(
[ReferralCode] [varchar] (50) NULL,
[LocalPatientIdentifier] [varchar](20) NULL,
[PatientCode] [int] NULL,
[NHSNumber] [varchar](30) NULL,
[HCPSourceOfReferralCode] [int] NULL,
[DateReferralRegistered] [date] NULL,
[DateReceived] [date] NULL,
[DateDischarged] [date] NULL,
[DiagnosisReferral] [varchar](500) NULL,
[TransportRequired] [int] NULL,
[ReferralCommentsFreeText] [varchar](254) NULL,
[ReferralUrgent] [int] NULL,
[TitleOfEpisode] [varchar](16) NULL,
[Inappropriate] [int] NULL,
[ReferralSourceTypeCode] [int] NULL,
[ReferredToSiteCode] [int] NULL,
[ReferralReason] [varchar](128) NULL,
[UrgentLevel] [int] NULL,
[BudgetCode] [varchar](10) NULL,
[BookedWardCode] [int] NULL,
[ProtectionCode] [int] NULL,
[EnvironmentCode] [int] NULL,
[DateGP] [date] NULL,
[FinanceCode] [int] NULL,	
[OtherBodies] [varchar](254) NULL,
[ProgressInfo] [varchar](254) NULL,
[ForwardTo] [varchar](250) NULL,
[HCPReferredTo] [int] NULL,
[TreatmentType] [int] NULL,
[DateAction] [date] NULL,
[ClockResetCode] [int] NULL,
[NewEpisode] [varchar](1) NULL,
[ResourceGroupCode] [int] NULL,
[Priority] [int] NULL,
[DateTarget] [date] NULL,
[PCT] [int] NULL,
[Attachment] [varchar](50) NULL,
[Diagnosis1][varchar] (10),
[Diagnosis2][varchar] (10),
[Diagnosis3][varchar] (10),
[Diagnosis4][varchar] (10),
[Diagnosis5][varchar] (10),
[Diagnosis6][varchar] (10),
[Diagnosis7][varchar] (10),
[Diagnosis8][varchar] (10),
[Diagnosis9][varchar] (10),
[Diagnosis10][varchar] (10),
[Diagnosis11][varchar] (10),
[Diagnosis12][varchar] (10),
[Diagnosis13][varchar] (10),
[Diagnosis14][varchar] (10),
[Diagnosis15][varchar] (10),
[Diagnosis16][varchar] (10),
[Diagnosis17][varchar] (10),
[Diagnosis18][varchar] (10),
[Diagnosis19][varchar] (10),
[Diagnosis20][varchar] (10),
[Area][varchar] (20),
[Source][varchar] (20),
[DateDischargeSummary] [date] NULL,
[DischargeSummaryBETTER][int] NULL,
[DischargeSummaryMUCHIMPROVED][int] NULL,
[DischargeSummarySlightTImproved][int] NULL,
[DischargeSummaryNoChange][int] NULL,
[DischargeSummaryWorse][int] NULL,
[DischargeSummaryDNA][int] NULL,
[DischargeSummaryFailedToComplete][int] NULL,
[DischargeSummaryOther][int] NULL,
[DischargeSummarySelfDischarge][int] NULL,
[DischargeSummaryReviewList][int] NULL,
[DischargeSummaryReReferredToSource][int] NULL,
[DischargeSummaryComments] [VARCHAR](1000),
[DateSignedDate][date] NULL,
[DischargeSummaryBasedon][int] NULL,
[DischargeSummaryInappropriate][int] NULL,
[DischargeSummaryReturnToWork][int] NULL,
[DischargeSummarySiteID][int] NULL,
[TREATMENT01][int] NULL,
[TREATMENT02][int] NULL,
[TREATMENT03][int] NULL,
[TREATMENT04][int] NULL,
[TREATMENT05][int] NULL,
[TREATMENT06][int] NULL,
[TREATMENT07][int] NULL,
[TREATMENT08][int] NULL,
[TREATMENT09][int] NULL,
[TREATMENT10][int] NULL,
[TREATMENT11][int] NULL,
[TREATMENT12][int] NULL,
[TREATMENT13][int] NULL,
[TREATMENT14][int] NULL,
[TREATMENT15][int] NULL,
[TREATMENT16][int] NULL,
[TREATMENT17][int] NULL,
[TREATMENT18][int] NULL,
[TREATMENT19][int] NULL,
[TREATMENT20][int] NULL,
[TREATMENT21][int] NULL,
[TREATMENT22][int] NULL,
[TREATMENT23][int] NULL,
[TREATMENT24][int] NULL,
[TREATMENT25][int] NULL,
[TREATMENT26][int] NULL,
[TREATMENT27][int] NULL,
[TREATMENT28][int] NULL,
[DischargeSummaryCC][varchar](254),
[TREATMENT29][int] NULL,
[TREATMENT30][int] NULL,
[CONDITION01][int] NULL,
[CONDITION02][int] NULL,
[CONDITION03][int] NULL,
[CONDITION04][int] NULL,
[CONDITION05][int] NULL,
[CONDITION06][int] NULL,
[CONDITION07][int] NULL,
[CONDITION08][int] NULL,
[CONDITION09][int] NULL,
[CONDITION10][int] NULL,
[Service][varchar](100),
[RegisteredGPCode][int] null,
[MainUnit][varchar](128)
)

create table #temp_Therapies_DiagnosisLink
(
[REFERRAL_ID] [varchar](20),
[DIAGNOSIS_ID] [varchar](10),
[Rank] [int]
)

create table #temp_Therapies_DischargeSummary_Condition
(
[ID][varchar](20),
[PATIENT_ID][int] NULL,
[REFERRAL_ID] [varchar](10),
[DATE][date] NULL,
[TREATMENTS][varchar](100),
[CONDITION][varchar](100),
[L_ID][varchar](20),
[L_TEXT][varchar](128),
[CRank] [int]
)

create table #temp_Therapies_DischargeSummary_Treatment
(
[ID] [varchar](20),
[PATIENT_ID][int] NULL,
[REFERRAL_ID] [varchar](10),
[DDATE][date] NULL,
[TREATMENTS][varchar](100),
[CONDITION][varchar](100),
[L_ID][varchar](20),
[L_TEXT][varchar](128),
[TRank] [int]
)

--Condition
insert into #temp_Therapies_DischargeSummary_Condition
select 
d.id as id,
d.patient_id as Patient_Id,
d.referral_id as Referral_Id,
d.date AS DDATE,
d.treatments AS TREATMENTS,
d.condition AS CONDITION,
lm.id AS L_ID,
lm.text AS L_TEXT,
RANK() OVER (PARTITION BY D.ID ORDER BY lm.ID) AS CRank
from [SQL4\SQL4].[physio].[dbo].lists lm 
join [SQL4\SQL4].[physio].[dbo].site_information s on s.id=lm.site_id 
join [SQL4\SQL4].[physio].[dbo].Discharge_summary d on ',' + d.CONDITION + ',' like '%,' + CONVERT(VARCHAR, lm.id) + ',%' 
join [SQL4\SQL4].[physio].[dbo].Referral r on r.ID = d.REFERRAL_ID 
where lm.type = 8 
order by d.referral_id

--Treatment
insert into #temp_Therapies_DischargeSummary_Treatment
select 
d9.id as id,
d9.patient_id as Patient_Id,
d9.referral_id as Referral_Id,
d9.date AS DDATE,
d9.treatments AS TREATMENTS, 
d9.condition AS CONDITION,
lm.id AS L_ID,
lm.text AS L_TEXT,
RANK() OVER (PARTITION BY D9.ID ORDER BY lm.ID) AS TRank
from [SQL4\SQL4].[physio].[dbo].lists lm 
join [SQL4\SQL4].[physio].[dbo].site_information s on s.id=lm.site_id 
join [SQL4\SQL4].[physio].[dbo].Discharge_summary d9 on ',' + d9.Treatments + ',' like '%,' + CONVERT(VARCHAR, lm.id) + ',%' 
join [SQL4\SQL4].[physio].[dbo].Referral r on r.ID = d9.REFERRAL_ID 
join [SQL4\SQL4].[physio].[dbo].PATIENT p on p.ID = r.PATIENT_ID 
where lm.type = 1
order by r.id



insert into  #temp_Therapies_Referral

SELECT 
R.ID as ReferralCode,
P.HOSPITALNUMBER as LocalPatientIdentifier,
R.PATIENT_ID as PatientCode,
p.NHSNUMBER as NhsNumber,
--P.DATEOFFBIRTH as DOB,
R.SOURCE_ID as HCPSourceOfReferralCode,     -- local code for Referrer
--RI.CODE as SourceReferrerCode,  -- national code for Referrer - all entries do not have a national code!
--RI.NAME as ReferrerName, -- leave in for now - dataq !!- SourceReferrerCode is blank
R.DATE as DateReferralRegistered,
R.DATE_RECIEVED as DateReceived,
R.DATE_DISCHARGED as DateDischarged,
R.DIAGNOSIS as DiagnosisReferral,
R.TRANSPORT_REQUIRED as TransportRequired,
R.COMMENTS as ReferralCommentsFreeText,
R.URGENT as ReferralUrgent,
R.TITLE as TitleOfEpisode,
R.INAPPROPIATE as Inappropriate,
R.TYPESOURCE_ID as ReferralSourceTypeCode,
--L1.TEXT AS TYPESOURCE_ID_TEXT,
R.SITE_ID as ReferredToSiteCode,
--SI.MAINUNIT,
--SI.DEPARTMENT,
R.KEYWORD as ReferralReason,
R.URGENT_LEVEL as UrgentLevel,
R.BUDGET_ID as BudgetCode,
R.INPATIENT_LOC as BookedWardCode,
--L2.TEXT AS INPATIENT_LOC_TEXT, -- MUST BE being RESTRICTED IN THE VIEW 
R.PROTECTION as ProtectionCode,
R.ENVIRONMENT_ID as EnvironmentCode,
R.GP_DATE as DateGP,
R.FINANCE_CODE as FinanceCode,
R.OTHER_BODIES as OtherBodies,
R.PROGRES_INFO as ProgressInfo,
R.FORWARD as ForwardTo,
R.KEYWORKER as HCPReferredTo,
--RS.Name as RefKeyworkerName, 
R.PATIENT_TYPE as TreatmentType,
R.ACTION_DATE as DateAction,
R.CODE as ClockResetCode,
--l3.text,
R.NEW_EPISODE as NewEpisode,
R.RESOURCE_GROUP_ID as ResourceGroupCode,
R.PRIORITY as Priority,
R.TARGET_DATE as DateTarget,
R.PCT as PCT,
R.ATTACHMENT as Attachment,
'' as Diagnosis1,
'' as Diagnosis2,
'' as Diagnosis3,
'' as Diagnosis4,
'' as Diagnosis5,
'' as Diagnosis6,
'' as Diagnosis7,
'' as Diagnosis8,
'' as Diagnosis9,
'' as Diagnosis10,
'' as Diagnosis11,
'' as Diagnosis12,
'' as Diagnosis13,
'' as Diagnosis14,
'' as Diagnosis15,
'' as Diagnosis16,
'' as Diagnosis17,
'' as Diagnosis18,
'' as Diagnosis19,
'' as Diagnosis20,
(CASE WHEN SI.MAINUNIT in ('POD_west','SaLT_Adult_West','SaLT_paeds_west','OT_Paeds_West') THEN 'West'
     WHEN SI.MAINUNIT in ('POD_East','OT_Paeds_East') THEN 'East'
     WHEN SI.MAINUNIT in ('POD_Central','SaLT_ygc','SaLT_paeds_rah','OT_Paeds_central') THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'D%' THEN 'West'
     WHEN P.HOSPITALNUMBER like 'G%' THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'B%' THEN 'Central'
     ELSE 'East'
 END) as Area,
 'Therapies' as Source,
D33.DATE AS DATEDISCHARGESUMMARYDATE,
D33.BETTER AS DISCHARGESUMMARYBETTER,
D33.MUCHIMPROVED AS DISCHARGESUMMARYMUCHIMPROVED,
D33.SLIGHTIMPROVED AS DISCHARGESUMMARYSLIGHTIMPROVED,
D33.NOCHANGE AS DISCHARGESUMMARYNOCHANGE,
D33.WORSE AS DISCHARGESUMMARYWORSE,
D33.DNA AS DISCHARGESUMMARYDNA,
D33.FAILEDTOCOMPLETE AS DISCHARGESUMMARYFAILEDTOCOMPLETE,
D33.OTHER AS DISCHARGESUMMARYOTHER,
D33.SELFDISCHARGE AS DISCHARGESUMMARYSELFDISCHARGE,
D33.REVIEWLIST AS DISCHARGESUMMARYREVIEWLIST,
D33.REREFERREDTOSOURCE AS DISCHARGESUMMARYREREFERREDTOSOURCE,
D33.COMMENTS AS DISCHARGESUMMARYCOMMENTS,
D33.SIGNEDDATE AS DISCHARGESUMMARYSIGNEDDATE,
D33.BASEDON AS DISCHARGESUMMARYBASEDON,
D33.INAPPROPIATE AS DISCHARGESUMMARYINAPPROPRIATE,
D33.RETURNTOWORK AS DISCHARGESUMMARYRETURNTOWORK,
D33.SITE_ID AS DISCHARGESUMMARYSITEID,
'' AS TREATMENT01,
'' AS TREATMENT02,
'' AS TREATMENT03,
'' AS TREATMENT04,
'' AS TREATMENT05,
'' AS TREATMENT06,
'' AS TREATMENT07,
'' AS TREATMENT08,
'' AS TREATMENT09,
'' AS TREATMENT10,
'' AS TREATMENT11,
'' AS TREATMENT12,
'' AS TREATMENT13,
'' AS TREATMENT14,
'' AS TREATMENT15,
'' AS TREATMENT16,
'' AS TREATMENT17,
'' AS TREATMENT18,
'' AS TREATMENT19,
'' AS TREATMENT20,
'' AS TREATMENT21,
'' AS TREATMENT22,
'' AS TREATMENT23,
'' AS TREATMENT24,
'' AS TREATMENT25,
'' AS TREATMENT26,
'' AS TREATMENT27,
'' AS TREATMENT28,
D33.CC AS DischargeSummaryCC,
'' AS TREATMENT29,
'' AS TREATMENT30,
'' AS CONDITION01,
'' AS CONDITION02,
'' AS CONDITION03,
'' AS CONDITION04,
'' AS CONDITION05,
'' AS CONDITION06,
'' AS CONDITION07,
'' AS CONDITION08,
'' AS CONDITION09,
'' AS CONDITION10,
CASE WHEN SI.MAINUNIT like 'PHYS%' THEN 'Physiotherapy'
WHEN SI.MAINUNIT like 'POD%' THEN 'Podiatry'
WHEN SI.MAINUNIT like 'DIET%' THEN 'Dietetics'
WHEN SI.MAINUNIT like 'OT%' THEN 'Occupational Therapy'
WHEN SI.MAINUNIT in ('MS_therapy team','COMM_OT WEST','COMM_OT CENTRAL','COMM_OT') THEN 'Occupational Therapy'
WHEN SI.MAINUNIT like 'OCCUP%' THEN 'Occupational Therapy'
WHEN SI.MAINUNIT like 'SaLT%' THEN 'Speech Language'
WHEN SI.MAINUNIT like 'Orthot%' THEN 'Orthotics'
WHEN SI.MAINUNIT like 'PULMON%' THEN 'Pulmonary Rehab'
WHEN SI.MAINUNIT IN ('COMM_PHYS CENTRAL','COMM_PHYS WEST','COMM_PHYS') THEN 'Physiotherapy'
ELSE SI.MAINUNIT
END as Service,
 P.GP AS RegisteredGPCode,
 SI.MAINUNIT
 


FROM [SQL4\SQL4].[physio].[dbo].REFERRAL R 
LEFT JOIN [SQL4\SQL4].[physio].[dbo].PATIENT AS P ON R.PATIENT_ID = P.ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].REFFERINGINSTANCE AS RI ON R.SOURCE_ID = RI.ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].SITE_INFORMATION AS SI ON SI.ID = R.SITE_ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].DISCHARGE_SUMMARY  AS D33 ON D33.REFERRAL_ID = R.ID and D33.id =(select max(d2.id)
                                                                                       	  from [SQL4\SQL4].[physio].[dbo].discharge_summary d2
																					      where d2.referral_id= D33.referral_id
																						  and d2.patient_id= D33.patient_id)



--LEFT JOIN LISTS AS L1 ON R.TYPESOURCE_ID = L1.ID AND L1.TYPE=6  -- HEALTHCARE PROFESSIONAL
--LEFT JOIN LISTS AS L2 ON R.INPATIENT_LOC = L2.ID AND L2.TYPE=10 -- REF DATA SEEM TO BE WARDS - WORKS
--LEFT JOIN LISTS AS L3 ON R.Code = L3.ID AND L3.TYPE=17--
--LEFT JOIN RESOURCES AS RS ON RS.ID = R.KEYWORKER
--where NEW_EPISODE=1
--AND R.DATE_RECIEVED BETWEEN '2017-04-01 00:00:00' and  '2018-03-31 23:59:59'
--AND restriction criteria in IMT_REFERRAL_VIEW 
--AND P.HOSPITALNUMBER NOT IN (SELECT HOSPITALNUMBER FROM IMT_REFERRAL_VIEW)-- TRY WORK OUT WHATS EXCLUDED

-----------------------------------------------------------------------------------------------------------------------------------
-- DIAGNOSIS TABLE Includes : ICD, Bespoke Diagnosis and Data Capture Fields.
-----------------------------------------------------------------------------------------------------------------------------------

---- EXTRACT ICD DIAGNOSIS_LINK DATA 
INSERT INTO #temp_Therapies_DiagnosisLink
SELECT 
DL.REFERRAL_ID AS REFERRAL_ID,
DL.DIAGNOSIS_ID AS DIAGNOSIS_ID,
RANK() OVER (PARTITION BY DL.REFERRAL_ID ORDER BY Dl.DIAGNOSIS_ID) AS Rank
FROM [SQL4\SQL4].[physio].[dbo].DIAGNOSIS_LINK DL


----- Mappings -Diagnosis 
Update #temp_Therapies_Referral
set Diagnosis1 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =1

Update #temp_Therapies_Referral
set Diagnosis2 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =2

Update #temp_Therapies_Referral
set Diagnosis3 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =3

Update #temp_Therapies_Referral
set Diagnosis4 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t 
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =4

Update #temp_Therapies_Referral
set Diagnosis5 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t  
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =5

Update #temp_Therapies_Referral
set Diagnosis6 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =6

Update #temp_Therapies_Referral
set Diagnosis7 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =7

Update #temp_Therapies_Referral
set Diagnosis8 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =8

Update #temp_Therapies_Referral
set Diagnosis9 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =9

Update #temp_Therapies_Referral
set Diagnosis10 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =10

Update #temp_Therapies_Referral
set Diagnosis11 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =11

Update #temp_Therapies_Referral 
set Diagnosis12 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =12

Update #temp_Therapies_Referral
set Diagnosis13 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =13

Update #temp_Therapies_Referral
set Diagnosis14 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =14

Update #temp_Therapies_Referral
set Diagnosis15 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =15

Update #temp_Therapies_Referral
set Diagnosis16 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =16

Update #temp_Therapies_Referral
set Diagnosis17 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =17

Update #temp_Therapies_Referral
set Diagnosis18 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =18

Update #temp_Therapies_Referral
set Diagnosis19 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =19

Update #temp_Therapies_Referral
set Diagnosis20 = t.DIAGNOSIS_ID
from #temp_Therapies_DiagnosisLink t
where  #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and t.Rank =20

--Mapping Condition & Treatment Fields

Update  #temp_Therapies_Referral
set Condition01 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=1

Update  #temp_Therapies_Referral
set Condition02 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=2

Update  #temp_Therapies_Referral
set Condition03 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=3

Update  #temp_Therapies_Referral
set Condition04 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=4

Update  #temp_Therapies_Referral
set Condition05 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=5

Update  #temp_Therapies_Referral
set Condition06 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=6

Update  #temp_Therapies_Referral
set Condition07 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode= c.PATIENT_ID
and CRank=7

Update  #temp_Therapies_Referral
set Condition08 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=8

Update  #temp_Therapies_Referral
set Condition09 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=9

Update  #temp_Therapies_Referral
set Condition10 = L_ID
from #temp_Therapies_DischargeSummary_Condition c
where #temp_Therapies_Referral.ReferralCode = c.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = c.PATIENT_ID
and CRank=10

Update  #temp_Therapies_Referral
set Treatment01 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=1

Update  #temp_Therapies_Referral
set Treatment02 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=2

Update  #temp_Therapies_Referral
set Treatment03 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=3

Update  #temp_Therapies_Referral
set Treatment04 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=4

Update  #temp_Therapies_Referral
set Treatment05 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=5

Update  #temp_Therapies_Referral
set Treatment06 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=6

Update  #temp_Therapies_Referral
set Treatment07 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=7

Update  #temp_Therapies_Referral
set Treatment08 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=8

Update  #temp_Therapies_Referral
set Treatment09 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=9

Update  #temp_Therapies_Referral
set Treatment10 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=10

Update  #temp_Therapies_Referral
set Treatment11 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=11

Update  #temp_Therapies_Referral
set Treatment12 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=12

Update  #temp_Therapies_Referral
set Treatment13 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=13

Update  #temp_Therapies_Referral
set Treatment14 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=14

Update  #temp_Therapies_Referral
set Treatment15 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=15

Update  #temp_Therapies_Referral
set Treatment16 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=16

Update  #temp_Therapies_Referral
set Treatment17 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=17

Update  #temp_Therapies_Referral
set Treatment18 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=18

Update  #temp_Therapies_Referral
set Treatment19 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=19

Update  #temp_Therapies_Referral
set Treatment20 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=20

Update  #temp_Therapies_Referral
set Treatment21 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=21

Update  #temp_Therapies_Referral
set Treatment22 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=22

Update  #temp_Therapies_Referral
set Treatment23 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=23

Update  #temp_Therapies_Referral
set Treatment24 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=24

Update  #temp_Therapies_Referral
set Treatment25 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=25

Update  #temp_Therapies_Referral
set Treatment26 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=26

Update  #temp_Therapies_Referral
set Treatment27 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=27

Update  #temp_Therapies_Referral
set Treatment28 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=28

Update  #temp_Therapies_Referral
set Treatment29 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=29

Update  #temp_Therapies_Referral
set Treatment30 = L_ID
from #temp_Therapies_DischargeSummary_Treatment t
where #temp_Therapies_Referral.ReferralCode = t.REFERRAL_ID
and #temp_Therapies_Referral.PatientCode = t.PATIENT_ID
and TRank=30


end
-------------------------------------------------------------------------------------------------------------------------------
select * from #temp_Therapies_Referral
GO
