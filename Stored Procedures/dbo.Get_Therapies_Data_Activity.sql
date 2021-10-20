SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[Get_Therapies_Data_Activity]
as 
begin



SELECT 
A.ID as AppointmentCode,
P.HOSPITALNUMBER as LocalPatientIdentifier,
--P.DATEOFFBIRTH as DOB,
--P.POSTCODE PostCodeAtTimeOfActivity, -- Only Current held on TM
--PO.LHB,
A.RESOURCE_ID as ResourceCode,   -- HCP -TABLE RESOURCES ALSO GET SITE_ID TO GET SITE INFO
--RS.Name as RefKeyworkerName, - COMPARE DATA HERE WITH A.RESOURCE 
--R.NAME as ResourceTherapist, 
--R.DESCRIPTION, 
--R.TYPE,
--R.SITE_ID, 
--SI2.MAINUNIT, 
--SI2.DEPARTMENT,
A.STARTTIME as TimeAppointmentStart,
A.ENDTIME as TimeAppointmentEnd,
A.TEXT as AppointmentText,
A.DESCRIPTION as AppointmentDescription,
A.SYMBOL_ID as SymbolCode, -- TABLE SYMBOLS A.SYMBOL_ID = S.ID AND SYMB_GROUP=0 
--S.TYPE,  
--S.LABEL,
A.STATUS as Status,  --- TABLE  APPOINTMENT_STATUS
--APS.NAME,
A.PATIENT_ID as PatientCode,
A.REOCCUR_ID as ReoccurCode,
A.GROUP_ID as GroupCode,
A.REFERRAL_ID as ReferralCode, --TABLE REFERRAL
--REF.SOURCE_ID, 
--REF.TYPESOURCE_ID, REF.TYPESOURCE_ID = L1.ID AND L1.TYPE=6
--L1.TEXT, 
--RI.NAME,        -- TABLE REFFERINGINSTANCE RI ON RI.ID = REF.SOURCE_ID
--RI.ADDRESS, 
--RI.CODE, 
--REF.KEYWORKER AS REFKEYWORKER   TABLE REFERRAL TO TABLE RESOURCES
A.class_id as ClassCode,    --TABLE CLASS AS C ON C.ID = A.CLASS_ID
--C.NAME,
A.LOCATION_ID as LocationCode, --TABLE SITE_INFORMATION AS SI ON SI.ID = A.LOCATION_ID --- MAPPING NOT CORRECT -PAEDS FOR G171910??
--SI.MAINUNIT, 
--SI.DEPARTMENT,
A.REMINDER as Reminder ,
A.READONLY as Readonly,
A.PRIORITY as Priority,
A.CLINIC_ID as ClinicCode,
A.CBAPP as CBApp,
A.CREATE_DATE as DateAppointmentCreate ,
REF.INPATIENT_LOC BookedClinicOrWardCode,   --TABLE LISTS AS L3 ON REF.INPATIENT_LOC = L3.ID AND L3.TYPE=10 --TEST IPLOC_TEST - WORKS
--L3.TEXT AS INPATIENT_LOCATION,-- WORKS SOURCE DATA FROM REFERRAL REQUIRED INRODER TO WORK OUT IF IP/OP
      ---     REF.INPATIENT_LOC -- IF NOTNULL = INTPATIENT IF NULL = OUTPATIENT
p.NHSNUMBER as NhsNumber,
REF.SOURCE_ID HCPSourceOfReferralCode,
REF.DATE as DateReferral,
REF.DATE_RECIEVED as DateReferralRecieved,
REF.URGENT as ReferralUrgent,
REF.TYPESOURCE_ID as ReferralSourceTypeCode,
REF.URGENT_LEVEL as ReferralUrgentLevel,
REF.KEYWORKER as HCPReferredToCode,
REF.NEW_EPISODE ReferralNewEpisode,
REF.RESOURCE_GROUP_ID as ReferralResourceGroupCode ,
REF.PRIORITY as ReferralPriority,
REF.CODE as ReferralClockResetCode,
REF.GP_DATE as DateReferralGP,
REF.DIAGNOSIS as DiagnosisReferralFreeText,
REF.COMMENTS as ReferralCommentsFreeText,
REF.KEYWORD as ReferralReason,
REF.PATIENT_TYPE as ReferralTreatmentType,
(CASE WHEN SI2.MAINUNIT in ('POD_west','SaLT_Adult_West','SaLT_paeds_west','OT_Paeds_West') THEN 'West'
     WHEN SI2.MAINUNIT in ('POD_East','OT_Paeds_East') THEN 'East'
     WHEN SI2.MAINUNIT in ('POD_Central','SaLT_ygc','SaLT_paeds_rah','OT_Paeds_central') THEN 'Central'
	 WHEN P.HOSPITALNUMBER like 'D%' THEN 'West'
     WHEN P.HOSPITALNUMBER like 'G%' THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'B%' THEN 'Central'
     ELSE 'East'
 END) as Area,
 'Therapies'  as Source,
 REF.SITE_ID AS ReferralSiteCode,
 S.SYMB_GROUP AS ContactTypeCode, -- DIRECT /INDIRECT/OTHER
 S.PROCESS_INFO AS NewReviewCode,
   -- NEW / REVIEW 
(CASE WHEN SI2.MAINUNIT like 'PHYS%' THEN 'Physiotherapy'
 WHEN SI2.MAINUNIT like 'POD%' THEN 'Podiatry'
 WHEN SI2.MAINUNIT like 'DIET%' THEN 'Dietetics'
 WHEN SI2.MAINUNIT like 'OT%' THEN 'Occupational Therapy'
 WHEN SI2.MAINUNIT in ('MS_therapy team') THEN 'Occupational Therapy'
 WHEN SI2.MAINUNIT like 'OCCUP%' THEN 'Occupational Therapy'
 WHEN SI2.MAINUNIT like 'SaLT%' THEN 'Speech Language'
 WHEN SI2.MAINUNIT like 'Orthot%' THEN 'Orthotics'
 WHEN SI2.MAINUNIT like 'PULMON%' THEN 'Pulmonary Rehab'
 WHEN SI2.MAINUNIT IN ('COMM_OT WEST','COMM_OT CENTRAL','COMM_OT') THEN 'Occupational Therapy'
 WHEN SI2.MAINUNIT IN ('COMM_PHYS CENTRAL','COMM_PHYS WEST','COMM_PHYS') THEN 'Physiotherapy'
 ELSE SI2.MAINUNIT 
END) as Service, 
 --'' as Service,
 P.GP AS RegisteredGPCode,
 (select max(DATEADD(dd, DATEDIFF(dd, 0, ah.actiontime), 0))
  from [SQL4\SQL4].[physio].[dbo].appointment_history ah
   where ah.appointment_id = a.id) as DateAppointmentLastAction,
-- DateAppointmentLastAction = last action on appmnt  -  so if last action was cancell due to covid19 cancell date = max last action date
-- cancell date required for covid19 data - this is the closest/best solution available
APS.PATIENT_ATTENDING as PatientAttending,
 SI2.MAINUNIT 
  
FROM [SQL4\SQL4].[physio].[dbo].APPOINTMENTS A
--LEFT JOIN RESOURCES AS R ON A.RESOURCE_ID = R.ID
--LEFT JOIN SYMBOLS AS S ON A.SYMBOL_ID = S.ID AND SYMB_GROUP=0 
LEFT JOIN [SQL4\SQL4].[physio].[dbo].APPOINTMENT_STATUS  AS APS ON  A.STATUS = APS.ID 
--LEFT JOIN CLASS AS C ON C.ID = A.CLASS_ID
--LEFT JOIN SITE_INFORMATION AS SI ON SI.ID = A.LOCATION_ID --- MAPPING NOT CORRECT -PAEDS FOR G171910??
--LEFT JOIN SITE_INFORMATION AS SI2 ON SI2.ID = R.SITE_ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].PATIENT AS P ON A.PATIENT_ID = P.ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].REFERRAL AS REF ON A.REFERRAL_ID = REF.ID
LEFT JOIN [SQL4\SQL4].[physio].[dbo].SITE_INFORMATION AS SI2 ON SI2.ID = Ref.SITE_ID
--LEFT JOIN REFFERINGINSTANCE AS RI ON RI.ID = REF.SOURCE_ID
--LEFT JOIN LISTS AS L1 ON REF.TYPESOURCE_ID = L1.ID AND L1.TYPE=6
--LEFT JOIN LISTS AS L3 ON REF.INPATIENT_LOC = L3.ID AND L3.TYPE=10 --TEST IPLOC_TEST - WORKS
LEFT JOIN [SQL4\SQL4].[physio].[dbo].POSTCODES AS PO ON P.POSTCODE = PO.POSTCODE
--left JOIN RESOURCES AS RS ON RS.ID=REF.KEYWORKER
LEFT JOIN [SQL4\SQL4].[physio].[dbo].SYMBOLS AS S ON A.SYMBOL_ID = S.ID  
--WHERE  A.STARTTIME BETWEEN '2018-10-01 00:00:00' and  '2018-10-15 23:59:59'



end







GO
