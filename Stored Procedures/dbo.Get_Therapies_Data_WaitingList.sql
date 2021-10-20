SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[Get_Therapies_Data_WaitingList]
as 
begin

DECLARE @LastDateWaitingListCensus AS DATE = (SELECT ISNULL(MAX(DateWaitingListCensus),'01 January 2018') FROM [Foundation].[dbo].[Therapies_Data_WaitingList] )
DECLARE @LastDateWaitingListCensusString AS VARCHAR(30) = DATENAME(DAY,@LastDateWaitingListCensus) + ' ' + DATENAME(MONTH,@LastDateWaitingListCensus) + ' ' + DATENAME(YEAR,@LastDateWaitingListCensus)


create table #temp_TherapyManager_Wlist
(
[Area][varchar] (20), 
[Category][varchar] (20), 
[Service][varchar] (100), 
[ServiceSubHeading][varchar] (100),
[DateWaitingListCensus][datetime],
[Source][varchar] (20),
[ReportableFlag][varchar] (1),
[LocalPatientIdentifier][varchar] (20),
--P.DATEOFFBIRTH as DOB,
--P.Surname +', '+ P.FirstName as PatientName,
--P.Title as PatientTitle,
--P.Address as PatientAddress, 
--P.Postcode as PatientPostCode,
--P.Gender as Sex,
--P.GP as RegGP,   -- TM ID ... GP CODE EXTRACTED ... NEXT FIELD
[RegisteredGP][varchar] (10), 
--P.ETHNIC_ORIGIN AS EthnicOrigin,
--RI2.NAME as RegisteredGPName,
--(CASE when (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 <18 THEN 'Paed'
--     when (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 >=18 THEN 'Adult'
-- else ''
-- END ) as Paed_Adult,
[WaitingListCode][varchar] (50), 
[PatientCode][varchar] (50), 
[ReferralCode][varchar] (50),
[DateWaitingList][datetime],
[WlistMaxWaitTime][varchar] (20),
[WlistInfoFreeText][varchar] (255),
[WListSiteCode][varchar] (10),
[NhsNumber][varchar] (20),
[DateWlistLClockReset][datetime],
[WListLastLetter][varchar] (255),
[DateReferral][datetime],
[DateReferralReceived][datetime],
[HCPSourceOfReferralCode][varchar] (50),     -- local code for Referrer
--RI.CODE as SourceReferrerCode,  -- national code for Referrer - all entries do not have a national code!
--RI.NAME as SourceReferrerName, 
[DateGPReferral][datetime],
[ReferralDiagnosisFreeText][varchar] (500),
[ReferralCommentsFreeText][varchar] (255),
[ReferralUrgent][varchar] (1),
[Priority][varchar] (1) , 
[ReferralSourceTypeCode][varchar] (10),        -----(Map to Lists)
[ReferralReason][varchar] (128),
[HCPReferredToCode][varchar] (20),              ------(Map to Resources)
--RS.Name as ReferralHCPId,                     ------(Resources Table does not include National Codes)
[ClockResetCode][varchar] (10),                 ------(Map to LISTS 4890=ClockRunning/4891=ClockStop/6807=Other)
[ReferralResourceGroupCode][int], 
[PriorityReferral][varchar] (10), 
[ReferralTreatmentType][int],
[ReferralNewEpisode][varchar] (10),
[DateAppointment][datetime], 
[WaitDays][int], 
--(Datediff(d ,ISNULL(W.[CLOCK_RESET] ,R.[GP_DATE]),GetDate())-2)/7 as  WaitWeeks,
--(CASE WHEN R.PATIENT_TYPE=2 THEN 'Inpatient' ELSE 'Outpatient' END) as TypeX,                ----- from IMT_WAITINGLIST view 
--'' as Specialty,
[WaitingListType][varchar] (10),                      ----- (Map to LISTS
--p.city as LHB,
[BookedWardCode][int],
MainUnit [varchar] (128)

)






insert into #temp_TherapyManager_Wlist

SELECT 
(CASE WHEN L.text in ('C - Llandudno Community Hospital','CENTRAL - OTHER','YGC ORTHOPAEDICS','YGC PALLIATIVE CARE','YGC ONCOLOGY') THEN 'Central'
     WHEN L.text in ('YG ARTHROPLASTY') THEN 'West'
     WHEN S.MAINUNIT in ('POD_west','SaLT_Adult_West','SaLT_paeds_west','OT_Paeds_West') THEN 'West'
     WHEN S.MAINUNIT in ('POD_East','OT_Paeds_East') THEN 'East'
     WHEN S.MAINUNIT in ('POD_Central','SaLT_ygc','SaLT_paeds_rah','OT_Paeds_central') THEN 'Central'
	 WHEN w.site_id in (52) THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'D%' THEN 'West'
     WHEN P.HOSPITALNUMBER like 'G%' THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'B%' THEN 'Central'
     ELSE 'East'
 END) as Area, 
 'Therapy' as Category, 
(CASE WHEN S.MAINUNIT like 'PHYS%' THEN 'Physiotherapy'
      WHEN S.MAINUNIT like 'POD%' THEN 'Podiatry'
      WHEN S.MAINUNIT like 'DIET%' THEN 'Dietetics'
      WHEN S.MAINUNIT like 'OT%' THEN 'Occupational Therapy'
      WHEN S.MAINUNIT in ('MS_therapy team') THEN 'Occupational Therapy'
      WHEN S.MAINUNIT like 'OCCUP%' THEN 'Occupational Therapy'
      WHEN S.MAINUNIT like 'SaLT%' THEN 'Speech Language'
      WHEN S.MAINUNIT like 'Orthot%' THEN 'Orthotics'
      WHEN S.MAINUNIT like 'PULMON%' THEN 'Pulmonary Rehab'
	  WHEN S.MAINUNIT IN ('COMM_OT WEST','COMM_OT CENTRAL','COMM_OT') THEN 'Occupational Therapy'
	  WHEN S.MAINUNIT IN ('COMM_PHYS CENTRAL','COMM_PHYS WEST','COMM_PHYS') THEN 'Physiotherapy'
      ELSE S.MAINUNIT 
 END) as Service,
 (CASE WHEN S.MAINUNIT = 'OCCUPATIONAL THERAPY' AND (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 <18 THEN 'Paediatrics'
      WHEN S.MAINUNIT = 'OCCUPATIONAL THERAPY' AND (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 >=18  THEN 'Adults'
      WHEN S.MAINUNIT like 'POD%' THEN (CASE WHEN R.URGENT = 1 THEN '2' ELSE '1' END)
      WHEN L.text in ('ALD','Adult Learning Disability - Conwy' ,'Adult Learning Disability - Denbigh') THEN 'Learning Disabilities' 
      ELSE 
	  (CASE WHEN (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 >=18 THEN 'Adults' 
	        WHEN (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 <18 THEN 'Paediatrics'
			ELSE '' 
		END) 
 END) as ServiceSubHeading,
CONVERT(Datetime,(Convert(varchar(8),getdate()-1,112))) as DateWaitingListCensus,
'Therapies' as Source,
(CASE WHEN  S.MAINUNIT in ('COMM _Therapy Services','PHYS_spinal_cbay','MDT_rehab serv.','POD_Di screening/Central/West','POD_Di Screening/East','POD_Di Ulcer Team','PULMONARY REHAB BCUHB','ORTHOTICS_Central','ORTHOTICS_West','ORTHOTICS_East','LIFESTYLE PROGRAMME EAST','LIFESTYLE PROGRAMME CENTRAL','LIFESTYLE PROGRAMME WEST','OT Mental Health East') THEN 'N' 
      WHEN  S.MAINUNIT like 'z%' THEN 'N'
      ELSE 'Y' 
  END) as ReportableFlag,
P.HOSPITALNUMBER  as LocalPatientIdentifier,
--P.DATEOFFBIRTH as DOB,
--P.Surname +', '+ P.FirstName as PatientName,
--P.Title as PatientTitle,
--P.Address as PatientAddress, 
--P.Postcode as PatientPostCode,
--P.Gender as Sex,
--P.GP as RegGP,   -- TM ID ... GP CODE EXTRACTED ... NEXT FIELD
RI2.CODE as RegisteredGP,
--P.ETHNIC_ORIGIN AS EthnicOrigin,
--RI2.NAME as RegisteredGPName,
--(CASE when (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 <18 THEN 'Paed'
--     when (Datediff(D ,(P.DATEOFFBIRTH),GetDate()))/365 >=18 THEN 'Adult'
-- else ''
-- END ) as Paed_Adult,
W.ID AS WaitingListCode,
W.PATIENT_ID as PatientCode,
W.REFERRAL_ID as ReferralCode,
W.DATE as DateWaitingList,
W.MAX_WAITTIME as WlistMaxWaitTime,
W.INFORMATION as WlistInfoFreeText,
W.SITE_ID as WListSiteCode,
P.NHSNUMBER as NhsNumber,
W.CLOCK_RESET as DateWlistLClockReset,
W.LAST_LETTER as WListLastLetter,
R.DATE as DateReferral,
R.DATE_RECIEVED as DateReferralReceived,
R.SOURCE_ID as HCPSourceOfReferralCode,     -- local code for Referrer
--RI.CODE as SourceReferrerCode,  -- national code for Referrer - all entries do not have a national code!
--RI.NAME as SourceReferrerName, 
R.GP_DATE as DateGPReferral,
R.DIAGNOSIS as ReferralDiagnosisFreeText,
R.COMMENTS as ReferralCommentsFreeText,
R.URGENT as ReferralUrgent,
(CASE WHEN R.URGENT=1 THEN '2' ELSE '1' END) as Priority, 
R.TYPESOURCE_ID as ReferralSourceTypeCode,        -----(Map to Lists)
R.KEYWORD as ReferralReason,
R.KEYWORKER as HCPReferredToCode,               ------(Map to Resources)
--RS.Name as ReferralHCPId,                  ------(Resources Table does not include National Codes)
R.CODE as ClockResetCode,                         ------(Map to LISTS 4890=ClockRunning/4891=ClockStop/6807=Other)
R.RESOURCE_GROUP_ID as ReferralResourceGroupCode,
R.PRIORITY as PriorityReferral,
R.PATIENT_TYPE as ReferralTreatmentType,
R.NEW_EPISODE as ReferralNewEpisode,
A.STARTTIME as DateAppointment,
Datediff(d ,ISNULL(W.[CLOCK_RESET] ,R.[GP_DATE]),GetDate())-1 as WaitDays,
--(Datediff(d ,ISNULL(W.[CLOCK_RESET] ,R.[GP_DATE]),GetDate())-2)/7 as  WaitWeeks,
--(CASE WHEN R.PATIENT_TYPE=2 THEN 'Inpatient' ELSE 'Outpatient' END) as TypeX,                ----- from IMT_WAITINGLIST view 
--'' as Specialty,
W.TYPE as WaitingListType,                      ----- (Map to LISTS
--p.city as LHB,
R.INPATIENT_LOC as BookedWardCode,
S.MAINUNIT

FROM [SQL4\SQL4].[physio].[dbo].WAITINGLIST AS W 
LEFT JOIN [SQL4\SQL4].[physio].[dbo].Referral AS R ON W.REFERRAL_ID = R.ID 
LEFT JOIN [SQL4\SQL4].[physio].[dbo].PATIENT AS P ON W.PATIENT_ID = P.ID
lEFT JOIN [SQL4\SQL4].[physio].[dbo].LISTS AS L ON W.TYPE = L.ID AND L.TYPE=3
--LEFT JOIN [SQL4\SQL4].[physio].[dbo].LISTS AS L2 ON R.TYPESOURCE_ID = L2.ID AND L2.TYPE=6
--LEFT JOIN [SQL4\SQL4].[physio].[dbo].LISTS AS L3 ON R.CODE = L3.ID AND L3.TYPE=17
--left JOIN [SQL4\SQL4].[physio].[dbo].LISTS AS L4 ON P.ETHNIC_ORIGIN = L4.ID AND L4.TYPE=12
LEFT JOIN [SQL4\SQL4].[physio].[dbo].SITE_INFORMATION AS S ON S.ID = W.SITE_ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].REFFERINGINSTANCE AS RI ON R.SOURCE_ID = RI.ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].REFFERINGINSTANCE AS RI2 ON P.GP = RI2.ID
left JOIN [SQL4\SQL4].[physio].[dbo].RESOURCES AS RS ON RS.ID=R.KEYWORKER
left JOIN [SQL4\SQL4].[physio].[dbo].APPOINTMENTS AS A ON W.REFERRAL_ID = A.REFERRAL_ID AND A.ID = ( SELECT MIN(A2.ID)
                                                                          FROM [SQL4\SQL4].[physio].[dbo].APPOINTMENTS A2
																		  WHERE A2.REFERRAL_ID = W.REFERRAL_ID
																		  AND A2.STARTTIME > GETDATE()
																		  AND A2.STATUS NOT IN (21,28))																  																		  																	  
--where R.new_episode =1 
--and p.DATEOFDEATH IS NULL

-----------------------------------------------------------------------------------------------------------------------------------

-- DIAGNOSIS TABLE Includes : ICD, Bespoke Diagnosis and Data Capture Fields.

-----------------------------------------------------------------------------------------------------------------------------------


end

------------------------------------------------------------------------------------------------------------------------------------------

select *
from #temp_TherapyManager_Wlist


drop table #temp_TherapyManager_Wlist

GO
