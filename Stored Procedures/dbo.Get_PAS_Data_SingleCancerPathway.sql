SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Data_SingleCancerPathway]
	/*
	exec [dbo].[Get_PAS_Data_SingleCancerPathway]
	
 	*/
AS
BEGIN
	
	SET NOCOUNT ON;


	---dec-mar qte refresh code
	/*
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
, [NHS Number] as NHSNumber
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
 ,mergeupis
 as
 (
 select
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
, DateOfReceiptOfCancerReferral
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
, SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,case when UniquePathwayIdentifier is null then importResults.PreviousUniquePathwayIdentifier else importResults.UniquePathwayIdentifier end as UniquePathwayIdentifier 
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request#

,case when PreviousUniquePathwayIdentifier is null then UniquePathwayIdentifier else PreviousUniquePathwayIdentifier end as PreviousUniquePathwayIdentifier
, USC_NUSCTargetDate_Adjusted

 from importResults

 
 )

 ,dupIDS
 AS
 (
 SELECT * 
 ,ROW_NUMBER()OVER(PARTITION BY mergeupis.UniquePathwayIdentifier,mergeupis.ReasonforPathwayClose
 order BY mergeupis.ReasonforPathwayClose
 ) AS TrueDuplicate
 ,ROW_NUMBER()OVER(PARTITION BY mergeupis.PreviousUniquePathwayIdentifier,mergeupis.ReasonforPathwayClose
 order BY  mergeupis.PreviousUniquePathwayIdentifier,mergeupis.ReasonforPathwayClose
 ) AS TrueDuplicateOldUPI
 ,ROW_NUMBER()OVER(PARTITION BY  mergeupis.UniquePathwayIdentifier ORDER BY mergeupis.UniquePathwayIdentifier) AS UniquePI
  ,ROW_NUMBER()OVER(PARTITION BY  mergeupis.PreviousUniquePathwayIdentifier 
  order BY mergeupis.PreviousUniquePathwayIdentifier) AS UniquePIold

 FROM mergeupis
 WHERE mergeupis.ReasonforPathwayClose <> 4 --remove all 4s as they are dead patients 
 )
 --select * from mergeupis where mergeupis.UniquePathwayIdentifier='2020100109D646918'
 --where mergeupis.UniquePathwayIdentifier is null
 
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

)

, finalsubmission
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
,dupsRanges.TrueDuplicate
,TrueDupSamePathway  
,Duplicate
,PathwayRank
,PreviousRecordsPathway
,LeadRecordsPathway
,RecordVersion
,TrueDuplicateOldUPI
,UniquePIold
,dupsRanges.TrueDupSamePathwayOldUPI 
 ,CASE 
 WHEN TrueDupSamePathway>=2 AND RecordVersion>1 THEN 'DeleteRow'  --if pathway is the same delete 1 record
      --not required for the quarterly submission
	  ----if 1 and 2 keep 2 (this is based on the lag or lead)
	   WHEN Duplicate =2 and TrueDupSamePathway=1 and ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
	   --its a dup with diff pathways and the pathway is 1 but the next pathway is 2 delete it

	     WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 2 THEN 'DeleteRow'


		 --	  --if 1 and 3 keep 3 (this is based on the lag or lead)

	   WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 3 THEN 'DeleteRow'
	   WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 3 THEN 'DeleteRow'

	  --       --if 2 and 3 keep 2 (this is based on the lag or lead)
	    WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
		  WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND LeadRecordsPathway = 2 THEN 'DeleteRow'
		ELSE 'KeepRow' END AS LogicToRemoveRecords

		
 ,CASE 
 WHEN dupsRanges.TrueDupSamePathwayOldUPI>=2 AND RecordVersionOLDUPI>1 THEN 'DeleteRow'  --if pathway is the same delete 1 record
      --not required for the quarterly submission
	  ----if 1 and 2 keep 2 (this is based on the lag or lead)
	  WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
	    WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 2 THEN 'DeleteRow'


		 --	  --if 1 and 3 keep 3 (this is based on the lag or lead)

	   WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND PreviousRecordsPathway = 3 THEN 'DeleteRow'
	   WHEN Duplicate =2 AND ReasonforPathwayClose = 1 AND LeadRecordsPathway = 3 THEN 'DeleteRow'

	  --       --if 2 and 3 keep 2 (this is based on the lag or lead)
	    WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
		  WHEN Duplicate =2 AND ReasonforPathwayClose = 3 AND LeadRecordsPathway = 2 THEN 'DeleteRow'
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

,TrueDuplicate
,TrueDupSamePathway  
,Duplicate
,PathwayRank
,PreviousRecordsPathway
,LeadRecordsPathway
,RecordVersion
,TrueDuplicateOldUPI
,UniquePI
,UniquePIold
,TrueDupSamePathwayOldUPI 

 , LogicToRemoveRecords
  , LogicToRemoveRecordsOld


FROM finalsubmission
WHERE finalsubmission.LogicToRemoveRecords='KeepRow'  --weed out the duplicates applying the logic
--and finalsubmission.LogicToRemoveRecordsOld='KeepRow' ) --weed out the duplicates applying the logic
)
--select * from currentQTRssubmission 
--where LocalPatientIdentifier = 'G053463'
/*

in (
'2020100109D646918',
'2020102302401240',
'2020102901G534215',
'2020110302D138634',
'2020110402D934521',
'2020110902275520',
'2020110902D125204',
'2020111606G430826',
'2020111706G287471',
'2020112608G510028',
'2020120304664540',
'2020120502D1021904',
'2020120809G012434',
'2020121002D571335',
'2020121509G232648',
'2020121509G547712',
'2020121601G053463',
'2020121702G179293',
'2020121706G155054',
'2020121710D237549',
'2020122106G381075',
'2020122901G476619',
'2020123004567120',
'2021010908850050',
'2021011108D071145',
'2021011203D840095',
'2021011303D087516',
'2021011409G054262',
'2021011409G054262',
'2021011906D697459',
'2021012010D661785',
'2021012610G454530',
'2021021108G150918',
'2021021609G126751',
'2021022308317740',
'2021022406599870',
'2021022411341320',
'2021021008G051299',
'2021030206541280',
'2021030303D667542',
'2021030809G105810',
'2021031204490320',
'2021031206D075533',
'2021031809410620',
'2021032198G043923',
'2021032901G491994')
*/
--order by currentQTRssubmission.UniquePathwayIdentifier


, finalcheck
as
(
SELECT 

      [BirthDate]
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
      ,case when [UniquePathwayIdentifier] is null then [PreviousUniquePathwayIdentifier] else [UniquePathwayIdentifier] end as UniquePathwayIdentifier

      ,[USC_NUSCTargetDate_Adjusted] 

	   ,LogicToRemoveRecords
  , LogicToRemoveRecordsOld

	  ,TrueDuplicate
,TrueDupSamePathway  
,Duplicate
,PathwayRank
,PreviousRecordsPathway
,LeadRecordsPathway
,RecordVersion
,TrueDuplicateOldUPI
,UniquePI
,UniquePIold
,TrueDupSamePathwayOldUPI 
  
	  from currentQTRssubmission
	 -- where LocalPatientIdentifier='G054262'
	  )
	  , doublecheckrn
	  as
	  (
	  select
      [BirthDate]
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
      , UniquePathwayIdentifier
	  ,row_number()over(partition by UniquePathwayIdentifier order by UniquePathwayIdentifier) as rn
      ,[USC_NUSCTargetDate_Adjusted] 
	  
	   ,LogicToRemoveRecords
  , LogicToRemoveRecordsOld

	  ,TrueDuplicate
,TrueDupSamePathway  
,Duplicate
,PathwayRank
,PreviousRecordsPathway
,LeadRecordsPathway
,RecordVersion
,TrueDuplicateOldUPI
,UniquePI
,UniquePIold
,TrueDupSamePathwayOldUPI 

	  FROM finalcheck

	  )
	
select
	  [BirthDate]
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
      , UniquePathwayIdentifier
	 
      ,[USC_NUSCTargetDate_Adjusted] 
	  
	  from doublecheckrn 
	  where rn=1


	  END
	  */
	/*
	logic used to ensure we are only submitting new pathways
	
1.	 Tidy up current month’s data:
a.	Identify true duplicates (where UPI and reason pathway closed are the same) – delete duplicates so only one record of each remains
b.	If UPI occurs twice or more but with different pathway reason closed, delete records using the following logic:
i.	Delete any record with reason pathway closed is 4
ii.	For remaining duplicates, delete records by following logic based on reason pathway closed code:
1.	If 1 and 2 – keep 2, delete 1
2.	If 1 and 3 – keep 3, delete 1
3.	If 2 and 3 – keep 2, delete 3
2.	Compare current month’s data with previously submitted data.  Present only new or updated pathways using the following logic:
*if the UPI exists in the data that has already been submitted and the pathway reason closed is the SAME, exclude the most recent version based on census date
*if the UPI exists in the data that has already been submitted and the pathway reason closed is the different, delete records by following logic based on reason pathway closed code:
1.	If 1 and 2 – keep 2, delete 1
2.	If 1 and 3 – keep 3, delete 1
3.	If 2 and 3 – keep 2, delete 3
	
	*/
---actual monthly query


with cte 
as
(
SELECT

convert(date,DOB) as BirthDate
,case when [Cancer Treatment Type] = '' then null else left([Cancer Treatment Type],2) end as CancerTreatmentModality
,convert(date,'19 Oct 2021') AS CensusDate  --change censusdate
,[Code of Registered GP Practice] as CodeofRegisteredGPPractice
,CONVERT(DATE,DDTT) as DateOfDecisiontoTreatCWT_DDTT
,CONVERT(DATE,[Date of First Appointment Taken]) as DateOfFirstAppointmentTaken
,convert(date,[Date of First Diagnostic Test Reported]) as DateOfFirstDiagnosticTestReported
,convert(date,[Date of First Diagnostic Test]) as DateOfFirstDiagnosticTestUndertaken
,convert(date,[Date of Last Diagnostic Test Before DDTT Reported]) as DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,convert(date,[Date of Last Diagnostic Test Before DDTT Reported]) as DateOfLastDiagnosticTestUndertakenbeforeDTT
,convert(date,[Primary Cancer Diagnosis Date]) as DateOfPrimaryDiagnosis_ClinicallyAgreed
,[CRD Date] as DateOfReceiptOfCancerReferral
,convert(date,[SCP Clock Stop Date]) as DateOfSCPClockStop
,convert(date,[Date Patient Informed of Diagnosis]) as DatePatientInformedOfDiagnosis
,convert(date,[Date referred to tertiary])as DateReferredtoTertiaryCentre --cantfind
,convert(date,[Date of death]) as DeathDate
,case when LEN(LEFT([Ethnic Group],2))=2 then LEFT([Ethnic Group],2) else 'Z' end  AS EthnicGroup
,CRN as LocalPatientIdentifier
,convert(date,[MDT First Meeting Date]) as MDTMeetingDate_FirstMeeting
,convert(date,[MDT Last Meeting Date]) as MDTMeetingDate_LastMeeting
,[NHS Number]  as NHSNumber -- change back to NHS Number for next one
,[NHS Number Status] as NHSNumberStatusIndicator  ---cant find
,'7A1A1' as Organisationcode
,case when 	[Episode Type]	= 'Suspected Malignancy Episode' then 2
when 	[Episode Type]	= 'Confirmed Malignant Episode' then 1
when 	[Episode Type]	= 'Insitu Episode' then 1 else 0 end as	OutcomeOfInvestigations 
,convert(date,[Date of Suspicion]) AS PathwayStartDate_PointOfSuspicionOfCancer
,[Patients Address] as PatientsAddress
,[First Name] as PatientsName_Forename
,[Last Name] as PatientsName_Surname
,[Patients Postcode] as PatientsPostcode
  ,case 
	  when [Tumour site]='Head & Neck' then '01'
	  when [Tumour site]='Upper Gastrointestinal' then '02'
	  when [Tumour site]='Lower Gastrointestinal' then '03'
	  when [Tumour site]='Lung' then '04'
	  when [Tumour site]='Sarcoma' then '05'
	  	  when [Tumour site]='Skin' then '06'
	  when [Tumour site]='Brain/CNS' then '07'
	  	  when [Tumour site]='Breast' then '08'
	  when [Tumour site]='Gynaecological' then '09'
	  when [Tumour site]='Urological' then '10'
	  	  when [Tumour site]='Haematological' then '11'
	  when [Tumour site]='Acute Leukaemia' then '12'
	  	  when [Tumour site]='Childrens' then '13'
	  when [Tumour site]='Other' then '98'
	  else '98' end
	  as	PrimaryCancerSiteDescription 
,case when [Primary Cancer SubSite Description] ='' then null else [Primary Cancer SubSite Description] end as PrimaryCancerSiteDescription_SubSite
,case when [USC/NUSC] ='USC' then 1 else 2 end as PriorityOfReferral
,left([Reason Pathway Closed],2) as ReasonforPathwayClose
,case when [SCP Target Date] like '%1900%' then null  else Replace([SCP Target Date],'datetime;#','') end   as SCPTargetDate
,case when [Sex (At Birth)]='' then null else Left([Sex (At Birth)],1) end as Sex_Atbirth
,left([Source Of Cancer Referral],2) as SourceOfCancerReferral
,case when [Source of Suspicion (select from drop-down list)]='' then null else left([Source of Suspicion (select from drop-down list)],2) end as SourceOfSuspicion
,case when [Tertiary Centre of Treatment] like '%walton%' then 'W00' else [Tertiary Centre of Treatment] end as TertiaryCentreOfTreatment
--,REPLACE(convert(varchar(8),cast(PathwayStartDate_PointOfSuspicionOfCancer as date),112) +cast(PrimaryCancerSiteDescription as varchar) +cast( LocalPatientIdentifier as varchar),' ','') as UniquePathwayIdentifier

,case when [USC/NUSC BreachDate] like '%1900%' then null else Replace([USC/NUSC BreachDate],'datetime;#','') end as USC_NUSCTargetDate_Adjusted


  FROM [SSIS_Loading].[CancerTracking].[dbo].[SCPSep21_DRYRUN]  --change to the table on ssisloading
  ), importResults
  AS
  (
select 
BirthDate
,case when CancerTreatmentModality ='n/' then  NULL else CancerTreatmentModality end as CancerTreatmentModality
,CensusDate
,CodeOfRegisteredGPPractice
,DateOfDecisiontoTreatCWT_DDTT
,DateOfFirstAppointmentTaken
,DateOfFirstDiagnosticTestReported
,DateOfFirstDiagnosticTestUndertaken
,DateOfLastDiagnosticTestReportedbeforeDTTOrTS
,DateOfLastDiagnosticTestUndertakenbeforeDTT
,DateOfPrimaryDiagnosis_ClinicallyAgreed
,convert(date,DateOfReceiptOfCancerReferral) as DateOfReceiptOfCancerReferral
,DateOfSCPClockStop
,DatePatientInformedOfDiagnosis
,DateReferredtoTertiaryCentre
,DeathDate
,EthnicGroup
,LocalPatientIdentifier
,MDTMeetingDate_FirstMeeting
,MDTMeetingDate_LastMeeting
,NHSNumber  as NHSNumber
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
,convert(date,SCPTargetDate) as SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,case when TertiaryCentreOfTreatment ='' then null else TertiaryCentreOfTreatment end as TertiaryCentreOfTreatment
,REPLACE(convert(varchar(8),cast(isnull(PathwayStartDate_PointOfSuspicionOfCancer,DateOfReceiptOfCancerReferral) as date),112) 
+cast(PrimaryCancerSiteDescription as varchar) +cast( LocalPatientIdentifier as varchar),' ','') as UniquePathwayIdentifier
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request
,convert(date,USC_NUSCTargetDate_Adjusted) as USC_NUSCTargetDate_Adjusted
,cte.ReasonforPathwayClose as PathwayStatus -- new field 
 from cte  
 )
 

 
 ,dupIDS
 AS
 (
 SELECT * 
 ,ROW_NUMBER()OVER(PARTITION BY importResults.UniquePathwayIdentifier,importResults.PathwayStatus ORDER BY  importResults.UniquePathwayIdentifier,importResults.PathwayStatus
 ) AS TrueDuplicate
 ,Row_Number()OVER(PARTITION BY  importResults.UniquePathwayIdentifier ORDER BY importResults.UniquePathwayIdentifier) AS UniquePI
 
 FROM importResults
 WHERE importResults.PathwayStatus <> 4 --remove all 4s as they are dead patients 
 ),dupsRanges
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
,a.PathwayStatus
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,USC_NUSCTargetDate_Adjusted
,a.TrueDuplicate
,UniquePI
 ,MAX(TrueDuplicate) OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.TrueDuplicate desc) AS TrueDupSamePathway  
 ,MAX(UniquePI)  OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.UniquePI desc) AS Duplicate
 ,RANK() OVER(PARTITION BY UniquePathwayIdentifier ORDER BY PathwayStatus asc)  AS PathwayRank
   ,Lag(a.PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate asc) AS PreviousRecordsPathway
    ,Lead(a.PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate asc) AS LeadRecordsPathway

  ,Row_Number()OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate DESC) AS RecordVersion

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
,a.PathwayStatus
,SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
,UniquePathwayIdentifier
,USC_NUSCTargetDate_Adjusted
,TrueDuplicate
,a.TrueDuplicate
,UniquePI

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
,USC_NUSCTargetDate_Adjusted
,UniquePI
,TrueDupSamePathway  
,Duplicate
,PathwayRank
,PreviousRecordsPathway
,LeadRecordsPathway
,RecordVersion
,PathwayStatus
 ,CASE 
 WHEN TrueDupSamePathway=2 AND RecordVersion=1 THEN 'DeleteRow'  --if pathway is the same delete 1 record
      
	  --if 5 and 1 keep 1 (this is based on the lag or lead)
	   WHEN Duplicate =2 AND PathwayStatus = 5 AND PreviousRecordsPathway = 1 THEN 'DeleteRow'
	    WHEN Duplicate =2 AND PathwayStatus = 1 AND LeadRecordsPathway = 5 THEN 'DeleteRow'


		 	  --if 5 and 2 keep 2 (this is based on the lag or lead)

	   WHEN Duplicate =2 AND PathwayStatus = 5 AND PreviousRecordsPathway = 2 THEN 'DeleteRow'
	   WHEN Duplicate =2 AND PathwayStatus = 2 AND LeadRecordsPathway = 5 THEN 'DeleteRow'

	         --if 5 and 3 keep 3 (this is based on the lag or lead)
	    WHEN Duplicate =2 AND PathwayStatus = 5 AND PreviousRecordsPathway = 3 THEN 'DeleteRow'
		  WHEN Duplicate =2 AND PathwayStatus = 3 AND LeadRecordsPathway = 5 THEN 'DeleteRow'
		ELSE 'KeepRow' END AS LogicToRemoveRecords

 FROM dupsRanges
), currentmonthssubmission
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
,PathwayStatus


--,UniquePI
--,TrueDupSamePathway  
--,Duplicate
--,PathwayRank
--,PreviousRecordsPathway
--,LeadRecordsPathway
--,RecordVersion

-- , LogicToRemoveRecords


FROM finalsubmission
WHERE finalsubmission.LogicToRemoveRecords='KeepRow'  --weed out the duplicates the 4s applying the logic
)
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
,ReasonforPathwayClose as PathwayStatus

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
,PathwayStatus

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
,a.PathwayStatus
FROM currentmonthssubmission a
),DupsIdCombined
AS
(

select
a.BirthDate
,a.CancerTreatmentModality
,a.UniquePathwayIdentifier
,a.CensusDate

 ,ROW_NUMBER()OVER(PARTITION BY a.UniquePathwayIdentifier,a.PathwayStatus ORDER BY  a.UniquePathwayIdentifier,a.PathwayStatus
 ) AS TrueDuplicate
 ,Row_Number()OVER(PARTITION BY  a.UniquePathwayIdentifier ORDER BY a.UniquePathwayIdentifier) AS UniquePI

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
,a.PathwayStatus

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
,a.PathwayStatus
,a.SCPTargetDate
,a.Sex_Atbirth
,a.SourceOfCancerReferral
,a.SourceOfSuspicion
,a.TertiaryCentreOfTreatment
,a.USC_NUSCTargetDate_Adjusted 
,a.TrueDuplicate
,UniquePI
 ,MAX(TrueDuplicate) OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.TrueDuplicate desc) AS TrueDupSamePathway  
 ,MAX(UniquePI)  OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.UniquePI desc) AS Duplicate
 ,RANK() OVER(PARTITION BY UniquePathwayIdentifier ORDER BY PathwayStatus asc)  AS PathwayRank
  ,Lag(a.PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate asc) AS PreviousRecordsPathway
    ,Lead(a.PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY a.CensusDate asc) AS LeadRecordsPathway
  ,Row_Number()OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate DESC) AS RecordVersion
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
,a.PathwayStatus
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
      
	  --if 5 and 1 keep 1 (this is based on the lag or lead)
	   WHEN Duplicate =2 AND a.PathwayStatus = 5 AND a.PreviousRecordsPathway = 1 THEN 'DeleteRow'
	     WHEN Duplicate =2 AND a.PathwayStatus = 1 AND a.LeadRecordsPathway = 5 THEN 'DeleteRow'


		 	  --if 5 and 2 keep 2 (this is based on the lag or lead)

	   WHEN Duplicate =2 AND a.PathwayStatus = 5 AND a.PreviousRecordsPathway = 2 THEN 'DeleteRow'
	   WHEN Duplicate =2 AND a.PathwayStatus = 2 AND a.LeadRecordsPathway = 5 THEN 'DeleteRow'

	         --if 5 and 3 keep 3 (this is based on the lag or lead)
	    WHEN Duplicate =2 AND a.PathwayStatus = 5 AND a.PreviousRecordsPathway = 3 THEN 'DeleteRow'
		  WHEN Duplicate =2 AND a.PathwayStatus = 5 AND a.LeadRecordsPathway = 3 THEN 'DeleteRow'
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
,a.PathwayStatus

FROM finalCombined a
WHERE a.CensusDate ='19 Oct 2021'  --get the latest census date
and a.LogicToRemoveRecords = 'KeepRow'  --dont import any that fall into the criteria above
ORDER BY a.CensusDate 


end


	/*
	EXEC [dbo].[Get_PAS_Data_SingleCancerPathway]
	*/
	
GO
