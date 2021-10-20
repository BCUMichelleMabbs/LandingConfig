SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[Get_Therapies_Data_HealthMeasureOutcome]
as 
begin


select 
O.ID AS HealthMeasureCode, 
O.PATIENT_ID as PatientCode, 
O.REFERRAL_ID ReferralCode, 
O.USER_ID UserCode, 
O.SITE_ID SiteCodeHealthMeasure, 
O.TYPE HealthMeasureType,
O.DATE DateHealthMeasureTaken,
O.SIGNEDDATE DateHealthMeasureSigned,
O.VALUE HealthMeasureValue,
(CASE WHEN SI.MAINUNIT in ('POD_west','SaLT_Adult_West','SaLT_paeds_west','OT_Paeds_West') THEN 'West'
     WHEN SI.MAINUNIT in ('POD_East','OT_Paeds_East') THEN 'East'
     WHEN SI.MAINUNIT in ('POD_Central','SaLT_ygc','SaLT_paeds_rah','OT_Paeds_central') THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'D%' THEN 'West'
     WHEN P.HOSPITALNUMBER like 'G%' THEN 'Central'
     WHEN P.HOSPITALNUMBER like 'B%' THEN 'Central'
     ELSE 'East'
 END) as Area,
  'Therapies'  as Source,
  P.HospitalNumber as LocalPatientIdentifier
 FROM [SQL4\SQL4].[physio].[dbo].OUTCOME O 
 LEFT JOIN [SQL4\SQL4].[physio].[dbo].SITE_INFORMATION AS SI ON SI.ID = O.SITE_ID
 LEFT JOIN [SQL4\SQL4].[physio].[dbo].PATIENT AS P ON o.PATIENT_ID = P.ID


 end



 -- NOT using the outcome_score table since 31/1/2017 - only 307 lines in table
GO
