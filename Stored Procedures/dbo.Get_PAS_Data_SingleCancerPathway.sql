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

Create table #Ranks 
(Prev int, 
 next int,
 keep int
)

insert into #Ranks
values 
(5,1,1),
(5,2,2),
(5,3,3),
(5,4,5),

(4,1,1),
(4,2,2),
(4,3,3),
(4,5,5),

(3,1,3),
(3,2,2),
(3,4,3),
(3,5,3),


(2,1,2),
(2,3,2),
(2,4,2),
(2,5,2),

(1,2,2),
(1,3,1),
(1,4,1),
(1,5,1)
;



with SSISLoadingTbl
as
(
SELECT

convert(date,DOB) as BirthDate
,case when [Cancer Treatment Type] = '' then null else left([Cancer Treatment Type],2) end as CancerTreatmentModality
,convert(date,'01 Oct 2021') AS CensusDate  --change censusdate date of submission - one month behind
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
,cast([NHS Number] as varchar)  as NHSNumber -- change back to NHS Number for next one
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


  FROM [SSIS_LOADING].[CancerTracking].[dbo].[SCPSep21AllPathways2] --change to the table on ssisloading
  ), CurrentMonthSubmission
    --create the UPI and convert any data ready for the duplicates to be removed as well as the deaths
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
,ReasonforPathwayClose as PathwayStatus -- new field 
,ROW_NUMBER()OVER(PARTITION BY REPLACE(convert(varchar(8),cast(isnull(PathwayStartDate_PointOfSuspicionOfCancer,DateOfReceiptOfCancerReferral) as date),112) 
+cast(PrimaryCancerSiteDescription as varchar) +cast( LocalPatientIdentifier as varchar),' ',''),ReasonforPathwayClose ORDER BY  REPLACE(convert(varchar(8),cast(isnull(PathwayStartDate_PointOfSuspicionOfCancer,DateOfReceiptOfCancerReferral) as date),112) 
+cast(PrimaryCancerSiteDescription as varchar) +cast( LocalPatientIdentifier as varchar),' ',''),ReasonforPathwayClose) as RN
 from SSISLoadingTbl  
 ) 
 
 ,Flag4andDupPathways
 as
 (
select * 
,MAX(RN) OVER(PARTITION BY UniquePathwayIdentifier,PathwayStatus ORDER BY a.RN desc) AS TrueDupSamePathway  
---change to count
from CurrentMonthSubmission a
)
,Step1
as
(
select * 
,case when TrueDupSamePathway >1 and RN > 1 then 1
	  else 0 end as LogicATrueDupeSamePathway  --keep0
from Flag4andDupPathways
)
,Step2
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
, SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
, UniquePathwayIdentifier
,TrueDupSamePathway
,LogicATrueDupeSamePathway
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request
,USC_NUSCTargetDate_Adjusted
,ReasonforPathwayClose as PathwayStatus -- new field 
,Row_Number()Over(partition by UniquePathwayIdentifier order by UniquePathwayIdentifier) as RN
,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier ) AS DuplicateCnt
,Lag(PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate asc) AS PreviousRecordsPathway --previous
 ,Lead(PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate asc) AS NextRecordsPathway --next
from Step1
where LogicATrueDupeSamePathway =0 --keep0

)

, Step3
--duplicatelogic
as
(
select BirthDate
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
, SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
, UniquePathwayIdentifier
,TrueDupSamePathway
,LogicATrueDupeSamePathway
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request
,USC_NUSCTargetDate_Adjusted
,ReasonforPathwayClose as PathwayStatus -- new field 
,RN
, DuplicateCnt
--,PreviousRecordsPathway
--,NextRecordsPathway
,case when PreviousRecordsPathway is null then PathwayStatus else PreviousRecordsPathway end as PreviousRecordsPathway2 --previous or current
 ,case when NextRecordsPathway is null then PathwayStatus else NextRecordsPathway end as NextRecordsPathway2 --next or current

--,b.Prev,b.next,b.keep 
from Step2 a 
--inner join #Ranks b on a.PathwayStatus=b.Prev

where DuplicateCnt >1
),currentsubmission
as
(


select a.*, b.*, case when a.PathwayStatus=b.keep then 1 else 0 end as KeepDelete --keep =1
from Step3 a
inner join #Ranks b on a.PreviousRecordsPathway2=b.Prev
					and a.NextRecordsPathway2=b.next

					union all

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
, SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
, UniquePathwayIdentifier
,TrueDupSamePathway
,LogicATrueDupeSamePathway
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request
,USC_NUSCTargetDate_Adjusted
,ReasonforPathwayClose as PathwayStatus -- new field 
, RN
, DuplicateCnt
,PreviousRecordsPathway as PreviousRecordsPathway2 --previous
 ,NextRecordsPathway  as NextRecordsPathway2--next



    , null as Prev, null as next, null as keep, 1 as KeepDelete

from Step2 a
where DuplicateCnt = 1

)
,Step4
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
, SCPTargetDate
,Sex_Atbirth
,SourceOfCancerReferral
,SourceOfSuspicion
,TertiaryCentreOfTreatment
, UniquePathwayIdentifier
--mm changed from referral date to date of suspicion 12/05/21 caroline williams change request
,USC_NUSCTargetDate_Adjusted
, PathwayStatus -- new field 
--,ROW_NUMBER()OVER(PARTITION BY UniquePathwayIdentifier,ReasonforPathwayClose ORDER BY  UniquePathwayIdentifier,ReasonforPathwayClose) as RN
--,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier,ReasonforPathwayClose ) AS TrueDupSamePathway
,KeepDelete
from currentsubmission
where KeepDelete=1
)

,Submitted
as
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
,null as KeepDelete
FROM Foundation.dbo.PAS_Data_SingleCancerPathway a


),joined
as
(

select
* from Step4
union all
select
* from submitted
)


,Step5
as
(
select 

* 
,censusdate as CD
--,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier,ReasonforPathwayClose ) AS TrueDupSamePathway

from Joined
)
,Step6  --joined
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
,ROW_NUMBER()OVER(PARTITION BY UniquePathwayIdentifier ORDER BY  UniquePathwayIdentifier, CensusDate asc) as RN --ordered by census date as this is comparing new with old - we need to either keep the old record or if new record logic ranks higher then add new and remove old
,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier ) AS DuplicateCnt
,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier,PathwayStatus ) AS TrueDupSamePathway
,Lag(PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate asc) AS PreviousRecordsPathway --previous
 ,Lead(PathwayStatus)OVER(PARTITION BY UniquePathwayIdentifier ORDER BY CensusDate asc) AS NextRecordsPathway --next

from Step5
),Step7
as
(

select *, case when PreviousRecordsPathway is null then PathwayStatus else PreviousRecordsPathway end as PreviousRecordsPathway2
, case when NextRecordsPathway is null then PathwayStatus else NextRecordsPathway end as NextRecordsPathway2

from Step6
),Step8
as
(
--identify those that are true dups same pathway
select a.*
,case when TrueDupSamePathway >1 and RN > 1 then 1
	  else 0 end as LogicBTrueDupeSamePathway


 from Step7 a
 )
 
 ,Step9
 as
 (

 select a.*,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier ) AS DuplicateCnt2 --re count the dups as weve got rid of the true dups to old

from Step8 a
					 where a. LogicBTrueDupeSamePathway=0 --weed out the true dups from current to old
 )
,Step10
as
(
 select a.*
 ,b.*
 ,case when a.DuplicateCnt2 =1 then 1 
        when a.DuplicateCnt2>1 and a.PathwayStatus=b.keep then 1 else 0 end as KeepDelete --keep =1
 
 from Step9 a
  left join #Ranks b on a.PreviousRecordsPathway2=b.Prev
					and a.NextRecordsPathway2=b.next
				--	where a.DuplicateCnt2>1

)
,finalDupCheck

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
,Row_Number()Over(partition by UniquePathwayIdentifier order by UniquePathwayIdentifier) as RN
,COUNT(UniquePathwayIdentifier) OVER (PARTITION BY UniquePathwayIdentifier ) AS DuplicateCnt3
from Step10 a
where a.KeepDelete <>0  --removes all the pathways that should be removed
and CensusDate ='01 Oct 2021'

)

select BirthDate
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
,PathwayStatus from finalDupCheck a
where Rn =1
order by a.UniquePathwayIdentifier

drop table #Ranks


end


	/*
	EXEC [dbo].[Get_PAS_Data_SingleCancerPathway]
	*/
	
GO
