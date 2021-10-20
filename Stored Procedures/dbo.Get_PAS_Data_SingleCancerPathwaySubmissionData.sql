SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_PAS_Data_SingleCancerPathwaySubmissionData]
	/*
	EXEC [dbo].[Get_PAS_Data_SingleCancerPathwaySubmissionData]
	*/
AS
BEGIN
	
	SET NOCOUNT ON;
	/*
	logic used to ensure we are only submitting new pathways
	
1.	 Tidy up current month’s data:
a.	Identify true duplicates (where UPI and reason pathway closed are the same) – delete duplicates so only one record of each remains
	
	*/

WITH cte 
AS
(
SELECT

CONVERT(DATE,DOB) AS BirthDate
,CASE WHEN [Cancer Treatment Type] = '' THEN NULL ELSE LEFT([Cancer Treatment Type],2) END AS CancerTreatmentModality
,CONVERT(DATE,'01 September 2021') AS CensusDate  --change censusdate
,[Code of Registered GP Practice] AS CodeofRegisteredGPPractice
,CONVERT(DATE,DDTT) AS DateOfDecisiontoTreatCWT_DDTT
,CONVERT(DATE,[Date of First Appointment Taken]) AS DateOfFirstAppointmentTaken
,CONVERT(DATE,[Date of First Diagnostic Test Reported]) AS DateOfFirstDiagnosticTestReported
,CONVERT(DATE,[Date of First Diagnostic Test]) AS DateOfFirstDiagnosticTestUndertaken
,CONVERT(DATE,[Date of Last Diagnostic Test Before DDTT Reported]) AS DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,CONVERT(DATE,[Date of Last Diagnostic Test Before DDTT Reported]) AS DateOfLastDiagnosticTestUndertakenbeforeDTT
,CONVERT(DATE,[Primary Cancer Diagnosis Date]) AS DateOfPrimaryDiagnosis_ClinicallyAgreed
,[CRD Date] AS DateOfReceiptOfCancerReferral
,CONVERT(DATE,[SCP Clock Stop Date]) AS DateOfSCPClockStop
,CONVERT(DATE,[Date Patient Informed of Diagnosis]) AS DatePatientInformedOfDiagnosis
,CONVERT(DATE,[Date referred to tertiary])AS DateReferredtoTertiaryCentre --cantfind
,CONVERT(DATE,[Date of death]) AS DeathDate
,CASE WHEN LEN(LEFT([Ethnic Group],2))=2 THEN LEFT([Ethnic Group],2) ELSE 'Z' END  AS EthnicGroup
,CRN AS LocalPatientIdentifier
,CONVERT(DATE,[MDT First Meeting Date]) AS MDTMeetingDate_FirstMeeting
,CONVERT(DATE,[MDT Last Meeting Date]) AS MDTMeetingDate_LastMeeting
,[NHS Number]  AS NHSNumber
,[NHS Number Status] AS NHSNumberStatusIndicator  ---cant find
,'7A1A1' AS Organisationcode
,CASE WHEN 	[Episode Type]	= 'Suspected Malignancy Episode' THEN 2
WHEN 	[Episode Type]	= 'Confirmed Malignant Episode' THEN 1
WHEN 	[Episode Type]	= 'Insitu Episode' THEN 1 ELSE 0 END AS	OutcomeOfInvestigations 
,CONVERT(DATE,[Date of Suspicion]) AS PathwayStartDate_PointOfSuspicionOfCancer
,[Patients Address] AS PatientsAddress
,[First Name] AS PatientsName_Forename
,[Last Name] AS PatientsName_Surname
,[Patients Postcode] AS PatientsPostcode
  ,CASE 
	  WHEN [Tumour site]='Head & Neck' THEN '01'
	  WHEN [Tumour site]='Upper Gastrointestinal' THEN '02'
	  WHEN [Tumour site]='Lower Gastrointestinal' THEN '03'
	  WHEN [Tumour site]='Lung' THEN '04'
	  WHEN [Tumour site]='Sarcoma' THEN '05'
	  	  WHEN [Tumour site]='Skin' THEN '06'
	  WHEN [Tumour site]='Brain/CNS' THEN '07'
	  	  WHEN [Tumour site]='Breast' THEN '08'
	  WHEN [Tumour site]='Gynaecological' THEN '09'
	  WHEN [Tumour site]='Urological' THEN '10'
	  	  WHEN [Tumour site]='Haematological' THEN '11'
	  WHEN [Tumour site]='Acute Leukaemia' THEN '12'
	  	  WHEN [Tumour site]='Childrens' THEN '13'
	  WHEN [Tumour site]='Other' THEN '98'
	  ELSE '98' END
	  AS	PrimaryCancerSiteDescription 
,CASE WHEN [Primary Cancer SubSite Description] ='' THEN NULL ELSE [Primary Cancer SubSite Description] END AS PrimaryCancerSiteDescription_SubSite
,CASE WHEN [USC/NUSC] ='USC' THEN 1 ELSE 2 END AS PriorityOfReferral
,LEFT([Reason Pathway Closed],2) AS ReasonforPathwayClose
,CASE WHEN [SCP Target Date] LIKE '%1900%' THEN NULL  ELSE REPLACE([SCP Target Date],'datetime;#','') END   AS SCPTargetDate
,CASE WHEN [Sex (At Birth)]='' THEN NULL ELSE LEFT([Sex (At Birth)],1) END AS Sex_Atbirth
,LEFT([Source Of Cancer Referral],2) AS SourceOfCancerReferral
,CASE WHEN [Source of Suspicion (select from drop-down list)]='' THEN NULL ELSE LEFT([Source of Suspicion (select from drop-down list)],2) END AS SourceOfSuspicion
,CASE WHEN [Tertiary Centre of Treatment] LIKE '%walton%' THEN 'W00' ELSE [Tertiary Centre of Treatment] END AS TertiaryCentreOfTreatment
--,CONVERT(VARCHAR, DateOfReceiptOfCancerReferral, 103) + '-'+ cast(PrimaryCancerSiteDescription as varchar) +'-'+ cast( LocalPatientIdentifier as varchar) as UniquePathwayIdentifier
,CASE WHEN [USC/NUSC BreachDate] LIKE '%1900%' THEN NULL ELSE REPLACE([USC/NUSC BreachDate],'datetime;#','') END AS USC_NUSCTargetDate_Adjusted


  FROM [SSIS_Loading].[CancerTracking].[dbo].[SCPQuarterlyRefreshDectoMar21v3]  --change to the table on ssisloading
  ), importResults
  AS
  (
SELECT 
BirthDate
,CASE WHEN CancerTreatmentModality ='n/' THEN  NULL ELSE CancerTreatmentModality END AS CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,CONVERT(DATE,DateOfReceiptOfCancerReferral) AS DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber  AS NHSNumber
,NHSNumberStatusIndicator
,Organisationcode
,OutcomeOfInvestigations
,PathwayStartDate_PointOfSuspicionOfCancer
,PatientsAddress
,PatientsName_Forename
,PatientsName_Surname
,PatientsPostcode
,PrimaryCancerSiteDescription
,PrimaryCancerSiteDescription_SubSite
,PriorityOfReferral
,ReasonforPathwayClose
,CONVERT(DATE,SCPTargetDate) AS SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,CASE WHEN TertiaryCentreOfTreatment ='' THEN NULL ELSE TertiaryCentreOfTreatment END AS TertiaryCentreOfTreatment
,REPLACE(CONVERT(VARCHAR(8),CAST(PathwayStartDate_PointOfSuspicionOfCancer AS DATE),112) +CAST(PrimaryCancerSiteDescription AS VARCHAR) +CAST( LocalPatientIdentifier AS VARCHAR),' ','') AS UniquePathwayIdentifier
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request#

,REPLACE(CONVERT(VARCHAR(8),CAST(DateOfReceiptOfCancerReferral AS DATE),112) +CAST(PrimaryCancerSiteDescription AS VARCHAR) +CAST( LocalPatientIdentifier AS VARCHAR),' ','') AS PreviousUniquePathwayIdentifier
,CONVERT(DATE,USC_NUSCTargetDate_Adjusted) AS USC_NUSCTargetDate_Adjusted
 FROM cte  
 ) 
 ,dupIDS
 AS
 (
 SELECT * 
 ,ROW_NUMBER()OVER(PARTITION BY importResults.UniquePathwayIdentifier,importResults.ReasonforPathwayClose ORDER BY  importResults.UniquePathwayIdentifier,importResults.ReasonforPathwayClose
 ) AS TrueDuplicate
 ,ROW_NUMBER()OVER(PARTITION BY importResults.PreviousUniquePathwayIdentifier,importResults.ReasonforPathwayClose ORDER BY  importResults.PreviousUniquePathwayIdentifier,importResults.ReasonforPathwayClose
 ) AS TrueDuplicateOldUPI
 ,ROW_NUMBER()OVER(PARTITION BY  importResults.UniquePathwayIdentifier ORDER BY importResults.UniquePathwayIdentifier) AS UniquePI
  ,ROW_NUMBER()OVER(PARTITION BY  importResults.PreviousUniquePathwayIdentifier 
  order BY importResults.PreviousUniquePathwayIdentifier) AS UniquePIold

 FROM importResults
 WHERE importResults.ReasonforPathwayClose <> 4 --remove all 4s as they are dead patients 
 )

 ,dupsRanges
 AS
 (

 SELECT 
 BirthDate
,CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber
,NHSNumberStatusIndicator
,Organisationcode
,OutcomeOfInvestigations
,PathwayStartDate_PointOfSuspicionOfCancer
,PatientsAddress
,PatientsName_Forename
,PatientsName_Surname
,PatientsPostcode
,PrimaryCancerSiteDescription
,PrimaryCancerSiteDescription_SubSite
,PriorityOfReferral
,ReasonforPathwayClose
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,a.PreviousUniquePathwayIdentifier
,USC_NUSCTargetDate_Adjusted
,a.TrueDuplicate
,a.TrueDuplicateOldUPI
,UniquePI
,a.UniquePIold
 ,MAX(TrueDuplicate) OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.TrueDuplicate DESC) AS TrueDupSamePathway  
 ,MAX(UniquePI)  OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.UniquePI DESC) AS Duplicate
 ,RANK() OVER(PARTITION BY UniquePathwayIdentifier ORDER BY ReasonforPathwayClose ASC)  AS PathwayRank
   ,LAG(a.ReasonforPathwayClose)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate ASC) AS PreviousRecordsPathway
    ,LEAD(a.ReasonforPathwayClose)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate ASC) AS LeadRecordsPathway

  ,ROW_NUMBER()OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate DESC) AS RecordVersion

   ,MAX(TrueDuplicateOldUPI) OVER(PARTITION BY PreviousUniquePathwayIdentifier ORDER BY a.TrueDuplicateOldUPI DESC) AS TrueDupSamePathwayOldUPI
 ,MAX(UniquePI)  OVER(PARTITION BY PreviousUniquePathwayIdentifier ORDER BY a.UniquePIold DESC) AS DuplicateOldUPI
 ,RANK() OVER(PARTITION BY PreviousUniquePathwayIdentifier ORDER BY ReasonforPathwayClose ASC)  AS PathwayRankOLDUPI
   ,LAG(a.ReasonforPathwayClose)OVER(PARTITION BY PreviousUniquePathwayIdentifier ORDER BY a.CensusDate ASC) AS PreviousRecordsPathwayOLDUPI
    ,LEAD(a.ReasonforPathwayClose)OVER(PARTITION BY PreviousUniquePathwayIdentifier ORDER BY a.CensusDate ASC) AS LeadRecordsPathwayOLDUPI

  ,ROW_NUMBER()OVER(PARTITION BY PreviousUniquePathwayIdentifier ORDER BY CensusDate DESC) AS RecordVersionOLDUPI
 FROM dupIDS a
 GROUP BY
  BirthDate
,CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber
,NHSNumberStatusIndicator
,Organisationcode
,OutcomeOfInvestigations
,PathwayStartDate_PointOfSuspicionOfCancer
,PatientsAddress
,PatientsName_Forename
,PatientsName_Surname
,PatientsPostcode
,PrimaryCancerSiteDescription
,PrimaryCancerSiteDescription_SubSite
,PriorityOfReferral
,ReasonforPathwayClose
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,a.PreviousUniquePathwayIdentifier
,USC_NUSCTargetDate_Adjusted
,TrueDuplicate
,a.TrueDuplicateOldUPI
,UniquePI
,a.UniquePIold

), finalsubmission
AS
(

SELECT 
 BirthDate
,CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber
,NHSNumberStatusIndicator
,Organisationcode
,OutcomeOfInvestigations
,PathwayStartDate_PointOfSuspicionOfCancer
,PatientsAddress
,PatientsName_Forename
,PatientsName_Surname
,PatientsPostcode
,PrimaryCancerSiteDescription
,PrimaryCancerSiteDescription_SubSite
,PriorityOfReferral
,ReasonforPathwayClose
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,dupsRanges.PreviousUniquePathwayIdentifier
,USC_NUSCTargetDate_Adjusted
,UniquePI
,TrueDupSamePathway  
,Duplicate
,PathwayRank
,PreviousRecordsPathway
,LeadRecordsPathway
,RecordVersion

 ,CASE 
 WHEN TrueDupSamePathway=2 AND RecordVersion=1 THEN 'DeleteRow'  --if pathway is the same delete 1 record
      --not required for the quarterly submission
	  ----if 1 and 2 keep 2 (this is based on the lag or lead)
	  -- WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
	  --   WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 2 THEN 'DeleteRow'


		 --	  --if 1 and 3 keep 3 (this is based on the lag or lead)

	  -- WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 3 THEN 'DeleteRow'
	  -- WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 3 THEN 'DeleteRow'

	  --       --if 2 and 3 keep 2 (this is based on the lag or lead)
	  --  WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
		 -- WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND LeadRecordsPathway = 2 THEN 'DeleteRow'
		ELSE 'KeepRow' END AS LogicToRemoveRecords

		
 ,CASE 
 WHEN dupsRanges.TrueDupSamePathwayOldUPI=2 AND RecordVersionOLDUPI=1 THEN 'DeleteRow'  --if pathway is the same delete 1 record
      --not required for the quarterly submission
	  ----if 1 and 2 keep 2 (this is based on the lag or lead)
	  -- WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
	  --   WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 2 THEN 'DeleteRow'


		 --	  --if 1 and 3 keep 3 (this is based on the lag or lead)

	  -- WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 3 THEN 'DeleteRow'
	  -- WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 3 THEN 'DeleteRow'

	  --       --if 2 and 3 keep 2 (this is based on the lag or lead)
	  --  WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
		 -- WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND LeadRecordsPathway = 2 THEN 'DeleteRow'
		ELSE 'KeepRow' END AS LogicToRemoveRecordsOld

 FROM dupsRanges
)

, currentQTRssubmission
AS
(

SELECT 

BirthDate
,CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber
,NHSNumberStatusIndicator
,Organisationcode
,OutcomeOfInvestigations
,PathwayStartDate_PointOfSuspicionOfCancer
,PatientsAddress
,PatientsName_Forename
,PatientsName_Surname
,PatientsPostcode
,PrimaryCancerSiteDescription
,PrimaryCancerSiteDescription_SubSite
,PriorityOfReferral
,ReasonforPathwayClose
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,PreviousUniquePathwayIdentifier 
,USC_NUSCTargetDate_Adjusted 


--,UniquePI
--,TrueDupSamePathway  
--,Duplicate
--,PathwayRank
--,PreviousRecordsPathway
--,LeadRecordsPathway
--,RecordVersion

 , LogicToRemoveRecords
  , LogicToRemoveRecordsOld


FROM finalsubmission
WHERE (finalsubmission.LogicToRemoveRecords='KeepRow'  --weed out the duplicates applying the logic
and finalsubmission.LogicToRemoveRecordsOld='KeepRow' ) --weed out the duplicates applying the logic
)
insert into [SSIS_LOADING].[CancerTracking].[dbo].[PAS_Data_SingleCancerPathwaySubmissionData](
[LoadDate]
      ,[BirthDate]
      ,[CancerTreatmentModality]
      ,[CensusDate]
      ,[CodeOfRegisteredGPPractice]
      ,[DateOfDecisiontoTreatCWT_DDTT]
      ,[DateOfFirstAppointmentTaken]
      ,[DateOfFirstDiagnosticTestReported]
      ,[DateOfFirstDiagnosticTestUndertaken]
      ,[DateOfLastDiagnosticTestReportedbeforeDTTOrTS]
      ,[DateOfLastDiagnosticTestUndertakenbeforeDTT]
      ,[DateOfPrimaryDiagnosis_ClinicallyAgreed]
      ,[DateOfReceiptOfCancerReferral]
      ,[DateOfSCPClockStop]
      ,[DatePatientInformedOfDiagnosis]
      ,[DateReferredtoTertiaryCentre]
      ,[DeathDate]
      ,[EthnicGroup]
      ,[LocalPatientIdentifier]
      ,[MDTMeetingDate_FirstMeeting]
      ,[MDTMeetingDate_LastMeeting]
      ,[NHSNumber]
      ,[NHSNumberStatusIndicator]
      ,[Organisationcode]
      ,[OutcomeOfInvestigations]
      ,[PathwayStartDate_PointOfSuspicionOfCancer]
      ,[PatientsAddress]
      ,[PatientsName_Forename]
      ,[PatientsName_Surname]
      ,[PatientsPostcode]
      ,[PrimaryCancerSiteDescription]
      ,[PrimaryCancerSiteDescription_SubSite]
      ,[PriorityOfReferral]
      ,[ReasonforPathwayClose]
      ,[SCPTargetDate]
      ,[Sex_Atbirth]
      ,[SourceOfCancerReferral]
      ,[SourceOfSuspicion]
      ,[TertiaryCentreOfTreatment]
      ,[UniquePathwayIdentifier]
      ,[PreviousUniquePathwayIdentifier]
      ,[USC_NUSCTargetDate_Adjusted]
	  )
SELECT 

convert(date,getdate()) as [LoadDate]
      ,[BirthDate]
      ,[CancerTreatmentModality]
      ,[CensusDate]
      ,[CodeOfRegisteredGPPractice]
      ,[DateOfDecisiontoTreatCWT_DDTT]
      ,[DateOfFirstAppointmentTaken]
      ,[DateOfFirstDiagnosticTestReported]
      ,[DateOfFirstDiagnosticTestUndertaken]
      ,[DateOfLastDiagnosticTestReportedbeforeDTTOrTS]
      ,[DateOfLastDiagnosticTestUndertakenbeforeDTT]
      ,[DateOfPrimaryDiagnosis_ClinicallyAgreed]
      ,[DateOfReceiptOfCancerReferral]
      ,[DateOfSCPClockStop]
      ,[DatePatientInformedOfDiagnosis]
      ,[DateReferredtoTertiaryCentre]
      ,[DeathDate]
      ,[EthnicGroup]
      ,[LocalPatientIdentifier]
      ,[MDTMeetingDate_FirstMeeting]
      ,[MDTMeetingDate_LastMeeting]
      ,[NHSNumber]
      ,[NHSNumberStatusIndicator]
      ,[Organisationcode]
      ,[OutcomeOfInvestigations]
      ,[PathwayStartDate_PointOfSuspicionOfCancer]
      ,[PatientsAddress]
      ,[PatientsName_Forename]
      ,[PatientsName_Surname]
      ,[PatientsPostcode]
      ,[PrimaryCancerSiteDescription]
      ,[PrimaryCancerSiteDescription_SubSite]
      ,[PriorityOfReferral]
      ,[ReasonforPathwayClose]
      ,[SCPTargetDate]
      ,[Sex_Atbirth]
      ,[SourceOfCancerReferral]
      ,[SourceOfSuspicion]
      ,[TertiaryCentreOfTreatment]
      ,[UniquePathwayIdentifier]
      ,[PreviousUniquePathwayIdentifier]
      ,[USC_NUSCTargetDate_Adjusted] FROM currentQTRssubmission
/*
--get the previous submissions and combine the two so we can apply the logic to ensure are submitting new pathways
,previoussubmissions
AS
(

SELECT
BirthDate
,CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber
,NHSNumberStatusIndicator
,Organisationcode
,OutcomeOfInvestigations
,PathwayStartDate_PointOfSuspicionOfCancer
,PatientsAddress
,PatientsName_Forename
,PatientsName_Surname
,PatientsPostcode
,PrimaryCancerSiteDescription
,PrimaryCancerSiteDescription_SubSite
,PriorityOfReferral
,ReasonforPathwayClose
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,USC_NUSCTargetDate_Adjusted 

FROM Foundation.dbo.PAS_Data_SingleCancerPathway a
),CombinedData --combine all the data to test if the pathway has only new pathways 
AS
(
SELECT
a.BirthDate
,a.CancerTreatmentModality
,a.CensusDate
,a.CodeOfRegisteredGPPractice
,a.DateOfDecisiontoTreatCWT_DDTT
,a.DateOfFirstAppointmentTaken
,a.DateOfFirstDiagnosticTestReported
,a.DateOfFirstDiagnosticTestUndertaken
,a.DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,a.DateOfLastDiagnosticTestUndertakenbeforeDTT
,a.DateOfPrimaryDiagnosis_ClinicallyAgreed
,a.DateOfReceiptOfCancerReferral
,a.DateOfSCPClockStop
,a.DatePatientInformedOfDiagnosis
,a.DateReferredtoTertiaryCentre
,a.DeathDate
,a.EthnicGroup
,a.LocalPatientIdentifier
,a.MDTMeetingDate_FirstMeeting
,a.MDTMeetingDate_LastMeeting
,a.NHSNumber
,a.NHSNumberStatusIndicator
,a.Organisationcode
,a.OutcomeOfInvestigations
,a.PathwayStartDate_PointOfSuspicionOfCancer
,a.PatientsAddress
,a.PatientsName_Forename
,a.PatientsName_Surname
,a.PatientsPostcode
,a.PrimaryCancerSiteDescription
,a.PrimaryCancerSiteDescription_SubSite
,a.PriorityOfReferral
,a.ReasonforPathwayClose
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.UniquePathwayIdentifier
,a.USC_NUSCTargetDate_Adjusted 

FROM previoussubmissions a

UNION ALL 
SELECT
a.BirthDate
,a.CancerTreatmentModality
,a.CensusDate
,a.CodeOfRegisteredGPPractice
,a.DateOfDecisiontoTreatCWT_DDTT
,a.DateOfFirstAppointmentTaken
,a.DateOfFirstDiagnosticTestReported
,a.DateOfFirstDiagnosticTestUndertaken
,a.DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,a.DateOfLastDiagnosticTestUndertakenbeforeDTT
,a.DateOfPrimaryDiagnosis_ClinicallyAgreed
,a.DateOfReceiptOfCancerReferral
,a.DateOfSCPClockStop
,a.DatePatientInformedOfDiagnosis
,a.DateReferredtoTertiaryCentre
,a.DeathDate
,a.EthnicGroup
,a.LocalPatientIdentifier
,a.MDTMeetingDate_FirstMeeting
,a.MDTMeetingDate_LastMeeting
,a.NHSNumber
,a.NHSNumberStatusIndicator
,a.Organisationcode
,a.OutcomeOfInvestigations
,a.PathwayStartDate_PointOfSuspicionOfCancer
,a.PatientsAddress
,a.PatientsName_Forename
,a.PatientsName_Surname
,a.PatientsPostcode
,a.PrimaryCancerSiteDescription
,a.PrimaryCancerSiteDescription_SubSite
,a.PriorityOfReferral
,a.ReasonforPathwayClose
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.UniquePathwayIdentifier
,a.USC_NUSCTargetDate_Adjusted 
FROM currentmonthssubmission a
),DupsIdCombined
AS
(

SELECT
a.BirthDate
,a.CancerTreatmentModality
,a.UniquePathwayIdentifier
,a.CensusDate

 ,ROW_NUMBER()OVER(PARTITION BY a.UniquePathwayIdentifier,a.ReasonforPathwayClose ORDER BY  a.UniquePathwayIdentifier,a.ReasonforPathwayClose
 ) AS TrueDuplicate
 ,ROW_NUMBER()OVER(PARTITION BY  a.UniquePathwayIdentifier ORDER BY a.UniquePathwayIdentifier) AS UniquePI

,a.CodeOfRegisteredGPPractice
,a.DateOfDecisiontoTreatCWT_DDTT
,a.DateOfFirstAppointmentTaken
,a.DateOfFirstDiagnosticTestReported
,a.DateOfFirstDiagnosticTestUndertaken
,a.DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,a.DateOfLastDiagnosticTestUndertakenbeforeDTT
,a.DateOfPrimaryDiagnosis_ClinicallyAgreed
,a.DateOfReceiptOfCancerReferral
,a.DateOfSCPClockStop
,a.DatePatientInformedOfDiagnosis
,a.DateReferredtoTertiaryCentre
,a.DeathDate
,a.EthnicGroup
,a.LocalPatientIdentifier
,a.MDTMeetingDate_FirstMeeting
,a.MDTMeetingDate_LastMeeting
,a.NHSNumber
,a.NHSNumberStatusIndicator
,a.Organisationcode
,a.OutcomeOfInvestigations
,a.PathwayStartDate_PointOfSuspicionOfCancer
,a.PatientsAddress
,a.PatientsName_Forename
,a.PatientsName_Surname
,a.PatientsPostcode
,a.PrimaryCancerSiteDescription
,a.PrimaryCancerSiteDescription_SubSite
,a.PriorityOfReferral
,a.ReasonforPathwayClose
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.USC_NUSCTargetDate_Adjusted 

FROM CombinedData a
),combinedDupsRanges
AS
(
SELECT

a.BirthDate
,a.CancerTreatmentModality
,a.UniquePathwayIdentifier
,a.CensusDate
,a.CodeOfRegisteredGPPractice
,a.DateOfDecisiontoTreatCWT_DDTT
,a.DateOfFirstAppointmentTaken
,a.DateOfFirstDiagnosticTestReported
,a.DateOfFirstDiagnosticTestUndertaken
,a.DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,a.DateOfLastDiagnosticTestUndertakenbeforeDTT
,a.DateOfPrimaryDiagnosis_ClinicallyAgreed
,a.DateOfReceiptOfCancerReferral
,a.DateOfSCPClockStop
,a.DatePatientInformedOfDiagnosis
,a.DateReferredtoTertiaryCentre
,a.DeathDate
,a.EthnicGroup
,a.LocalPatientIdentifier
,a.MDTMeetingDate_FirstMeeting
,a.MDTMeetingDate_LastMeeting
,a.NHSNumber
,a.NHSNumberStatusIndicator
,a.Organisationcode
,a.OutcomeOfInvestigations
,a.PathwayStartDate_PointOfSuspicionOfCancer
,a.PatientsAddress
,a.PatientsName_Forename
,a.PatientsName_Surname
,a.PatientsPostcode
,a.PrimaryCancerSiteDescription
,a.PrimaryCancerSiteDescription_SubSite
,a.PriorityOfReferral
,a.ReasonforPathwayClose
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.USC_NUSCTargetDate_Adjusted 
,a.TrueDuplicate
,UniquePI
 ,MAX(TrueDuplicate) OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.TrueDuplicate DESC) AS TrueDupSamePathway  
 ,MAX(UniquePI)  OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.UniquePI DESC) AS Duplicate
 ,RANK() OVER(PARTITION BY UniquePathwayIdentifier ORDER BY ReasonforPathwayClose ASC)  AS PathwayRank
  ,LAG(a.ReasonforPathwayClose)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate ASC) AS PreviousRecordsPathway
    ,LEAD(a.ReasonforPathwayClose)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate ASC) AS LeadRecordsPathway
  ,ROW_NUMBER()OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate DESC) AS RecordVersion
 FROM DupsIdCombined a

 ),finalCombined
 AS
 (

 SELECT 
 
a.BirthDate
,a.CancerTreatmentModality
,a.CensusDate
,a.CodeOfRegisteredGPPractice
,a.DateOfDecisiontoTreatCWT_DDTT
,a.DateOfFirstAppointmentTaken
,a.DateOfFirstDiagnosticTestReported
,a.DateOfFirstDiagnosticTestUndertaken
,a.DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,a.DateOfLastDiagnosticTestUndertakenbeforeDTT
,a.DateOfPrimaryDiagnosis_ClinicallyAgreed
,a.DateOfReceiptOfCancerReferral
,a.DateOfSCPClockStop
,a.DatePatientInformedOfDiagnosis
,a.DateReferredtoTertiaryCentre
,a.DeathDate
,a.EthnicGroup
,a.LocalPatientIdentifier
,a.MDTMeetingDate_FirstMeeting
,a.MDTMeetingDate_LastMeeting
,a.NHSNumber
,a.NHSNumberStatusIndicator
,a.Organisationcode
,a.OutcomeOfInvestigations
,a.PathwayStartDate_PointOfSuspicionOfCancer
,a.PatientsAddress
,a.PatientsName_Forename
,a.PatientsName_Surname
,a.PatientsPostcode
,a.PrimaryCancerSiteDescription
,a.PrimaryCancerSiteDescription_SubSite
,a.PriorityOfReferral
,a.ReasonforPathwayClose
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.UniquePathwayIdentifier
,a.USC_NUSCTargetDate_Adjusted 
,RecordVersion
,a.TrueDuplicate
,UniquePI
 , TrueDupSamePathway  
 ,Duplicate
 ,PathwayRank
 ,PreviousRecordsPathway
 ,LeadRecordsPathway
 ,CASE 
 WHEN a.TrueDupSamePathway=2 AND a.RecordVersion=1 THEN 'DeleteRow'  --if pathway is the same delete the most recent version as we would have submitted that data already
      
	  --if 1 and 2 keep 2 (this is based on the lag or lead)
	   WHEN Duplicate =2 AND a.ReasonforPathwayClose = 1 AND a.PreviousRecordsPathway = 2 THEN 'DeleteRow'
	     WHEN Duplicate =2 AND a.ReasonforPathwayClose = 1 AND a.LeadRecordsPathway = 2 THEN 'DeleteRow'


		 	  --if 1 and 3 keep 3 (this is based on the lag or lead)

	   WHEN Duplicate =2 AND a.ReasonforPathwayClose = 1 AND a.PreviousRecordsPathway = 3 THEN 'DeleteRow'
	   WHEN Duplicate =2 AND a.ReasonforPathwayClose = 1 AND a.LeadRecordsPathway = 3 THEN 'DeleteRow'

	         --if 2 and 3 keep 2 (this is based on the lag or lead)
	    WHEN Duplicate =2 AND a.ReasonforPathwayClose = 3 AND a.PreviousRecordsPathway = 2 THEN 'DeleteRow'
		  WHEN Duplicate =2 AND a.ReasonforPathwayClose = 3 AND a.LeadRecordsPathway = 2 THEN 'DeleteRow'
		ELSE 'KeepRow' END AS LogicToRemoveRecords
 FROM combinedDupsRanges a 
 )

 SELECT 
 
a.BirthDate
,a.CancerTreatmentModality
,a.CensusDate
,a.CodeOfRegisteredGPPractice
,a.DateOfDecisiontoTreatCWT_DDTT
,a.DateOfFirstAppointmentTaken
,a.DateOfFirstDiagnosticTestReported
,a.DateOfFirstDiagnosticTestUndertaken
,a.DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,a.DateOfLastDiagnosticTestUndertakenbeforeDTT
,a.DateOfPrimaryDiagnosis_ClinicallyAgreed
,a.DateOfReceiptOfCancerReferral
,a.DateOfSCPClockStop
,a.DatePatientInformedOfDiagnosis
,a.DateReferredtoTertiaryCentre
,a.DeathDate
,a.EthnicGroup
,a.LocalPatientIdentifier
,a.MDTMeetingDate_FirstMeeting
,a.MDTMeetingDate_LastMeeting
,a.NHSNumber
,a.NHSNumberStatusIndicator
,a.Organisationcode
,a.OutcomeOfInvestigations
,a.PathwayStartDate_PointOfSuspicionOfCancer
,a.PatientsAddress
,a.PatientsName_Forename
,a.PatientsName_Surname
,a.PatientsPostcode
,a.PrimaryCancerSiteDescription
,a.PrimaryCancerSiteDescription_SubSite
,a.PriorityOfReferral
,a.ReasonforPathwayClose
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.UniquePathwayIdentifier
,a.USC_NUSCTargetDate_Adjusted 

FROM finalCombined a
WHERE a.CensusDate ='01 July 2021'  --get the latest census date
AND a.LogicToRemoveRecords = 'KeepRow'  --dont import any that fall into the criteria above
ORDER BY a.CensusDate 
*/


END

	
GO
