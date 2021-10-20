SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================================================================
-- Author:		Heather Lewis
-- Create date: 21/01/2021
-- Description:	Extract of Component Waiting List
--            
-- 21/01/2021 : West Waiting List data extracted from exec SP dbo.nww_sp_eis_wlist_hwl
--					 Query 1 : IP/DC WLIST
--					 Query 2 : OP WLIST
--					 Query 3 : OP SCHDL
--					 Query 4 : IP/DC Planned/Check Repeat WLIST
--
-- Notes:
--                   Table produced=eis_wlist_hwl does not contain all the fields required for New Warehouse
--                   Table WestWaitingList_NewWH=eis_wlist_hwl plus additional fields
--                   If SP is amended - the extract going to New Warehouse is ok
--                   Need to keep altering the table WestWaitingList_NewWH when additional feilds added to SP
--                   Risk Stratification - local_wlrul_refno 
-- Amendments:
--
--
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_West]
	
AS
BEGIN
	
	SET NOCOUNT ON;

		   	 
	drop table WestWaitingList_NewWH
	select * into WestWaitingList_NewWH FROM eis_wlist_hwl

	alter table WestWaitingList_NewWH add PriorityOnLetter [varchar] (30)
	alter table WestWaitingList_NewWH add Outcome [varchar] (30) 
	alter table WestWaitingList_NewWH add ReferralIntent [varchar] (30)
	alter table WestWaitingList_NewWH add PostcodeAtTimeOfActivity [varchar] (12)
	alter table WestWaitingList_NewWH add DateBooked Date
	alter table WestWaitingList_NewWH add DatePlanned Date
	alter table WestWaitingList_NewWH add ProcedureIntended [varchar] (30)
	alter table WestWaitingList_NewWH add BookedWardOrClinicCode [varchar] (80)
	alter table WestWaitingList_NewWH add SiteCode [varchar] (6)
	alter table WestWaitingList_NewWH add ClinicalPriority [varchar] (10)
--
-- update fields not in original select
--

UPDATE	WestWaitingList_NewWH
SET PriorityOnLetter = refprity.main_code,
	         Outcome = refocm.main_code,
	  ReferralIntent = refocm.main_code
FROM    referrals as refrl			
join reference_values as refprity on refrl.prity_refno=refprity.rfval_refno	and isnull(refprity.archv_flag,'N')='N'
join reference_values as refocm on refrl.rfocm_refno =refocm.rfval_refno and isnull(refocm.archv_flag,'N')='N'
where refrl.patnt_refno = WestWaitingList_NewWH.patnt_refno
and refrl.refrl_refno = WestWaitingList_NewWH.refrl_refno 
and isnull(refrl.archv_flag,'N')='N'


UPDATE	WestWaitingList_NewWH
SET	PostcodeAtTimeOfActivity =  addss.pcode
from address_roles  
join addresses  addss on address_roles.addss_refno=addss.addss_refno
		                         and addss.adtyp_code='POSTL'
								 and isnull(addss.archv_flag,'N')='N'
								  
where WestWaitingList_NewWH.ddta between addss.start_dttm and isnull(addss.end_dttm,GETDATE()) 					 
and address_roles.rotyp_code='HOME' 
and isnull(address_roles.archv_flag,'N')='N'
and address_roles.end_dttm is null 
and address_roles.patnt_refno = WestWaitingList_NewWH.patnt_refno


--  Maximum accepted / NS TCI   ///  tci_dttm 
UPDATE	WestWaitingList_NewWH
SET	DateBooked = (SELECT 	MAX(admof.tci_dttm)
    			  FROM	admission_offers admof
			      WHERE	admof.wlist_refno = WestWaitingList_NewWH.refno
			      AND	admof.ofocm_refno = 11570
			      AND	admof.confm_refno IN (205078,202595)
			      AND	ISNULL(admof.archv_flag,'N') = 'N')


UPDATE	WestWaitingList_NewWH
SET DatePlanned = DateBooked where query = '4'


-- IntendedProcedure  ---- 
UPDATE	WestWaitingList_NewWH
SET	ProcedureIntended = odpcd.code
FROM	diagnosis_procedures dgpro
	JOIN odpcd_codes odpcd ON
	dgpro.odpcd_refno = odpcd.odpcd_refno
WHERE	dgpro.sorce_refno = WestWaitingList_NewWH.refno
AND	dgpro.sorce_code = 'WLIST'
AND	dgpro.ccsxt_code = 'OP4/3'
AND	dgpro.mplev_refno = 200723 
AND	ISNULL(dgpro.archv_flag,'N') = 'N'   


-- Ward or Clinic Code

UPDATE WestWaitingList_NewWH
   SET BookedWardOrClinicCode = spont.code
   from service_points spont
   where spont.spont_refno = (select spont_refno
    						   from waiting_list_entries wle
							   where wle.wlist_refno =  WestWaitingList_NewWH.refno
                               and WestWaitingList_NewWH.query in (1,2,4))
   and isnull(spont.archv_flag,'N')= 'N'
         

 UPDATE WestWaitingList_NewWH
   SET BookedWardOrClinicCode = spont.code
   from service_points spont
   where spont.spont_refno = (select spont_refno
						      from schedules sch
						      where sch.schdl_refno =  WestWaitingList_NewWH.refno
                              and WestWaitingList_NewWH.query in (3))
   and isnull(spont.archv_flag,'N')= 'N'
        




-- Update Site   heorg_code

UPDATE	WestWaitingList_NewWH
SET	 SiteCode= heoid.identifier
FROM	health_organisations heorg
       	JOIN health_organisation_ids heoid ON
	heorg.heorg_refno = heoid.heorg_refno
WHERE	heorg.heorg_refno = WestWaitingList_NewWH.heorg_refno
AND	heoid.hityp_refno = 4050
AND	ISNULL(heoid.end_dttm,GETDATE()) >= GETDATE()
AND	ISNULL(heorg.archv_flag,'N') = 'N'
AND	ISNULL(heoid.archv_flag,'N') = 'N'



UPDATE	WestWaitingList_NewWH
SET	ClinicalPriority = (select r.name
                        from waiting_list_rules r 
						where WestWaitingList_NewWH.local_wlrul_refno = r.wlrul_refno
						AND	ISNULL(r.archv_flag,'N') = 'N')




select 
CountOfDaysWaiting as DaysWait,
NHSNumber as NHSNumber,
pasid as LocalPatientIdentifier,
ddta as DateReferred,
patnt_refno as SystemLinkID,                           -- have set to patnt_refno - wlist & schdl used in waitinglist - wlist_refno & schdl_refno exist in dataset=30
ReferralIntent as ReferralIntent,
Referrer_code as Referrer,
ReferringOrganisationCode as OrganisationOfReferrer,
gp_code as GPAtTimeOfActivity,
pract_code as GPPracticeAtTimeOfActivity,
PostcodeAtTimeOfActivity as PostcodeAtTimeOfActivity,  -- rename feild?
Purch_Code as Commissioner,
SourceOfRefereralCode as ReferralSource,
PriorityOnLetter as PriorityOnLetter,
Outcome as Outcome,
wlist_dttm as DateOnWaitingList,
heorg_code as LocationCode,
AdminCategoryCode as PatientCategory,
Priority as PriorityOfHCP,
Null as TreatmentType,
DateBooked as DateBooked,
Null as ReasonBooked,
Null as GPRefNo,
Null as ClinicalCondition,
Null as CommissionerType,
tci_dttm as DateOfAppointment, 
Null as DateDeferred,
Specialty as Specialty,
Null as ListStatus,
Null as ContractsAuthorised,
ReferralComments as Comments,                                   ----- COMMENTS - from refrrals.comments - NULL APPART FROM Monthly Insert for missing referrals - 06-JAN-99 COMMENT - X2 RECORDS ONLY east/Center use more
Null as AgeAtAttendance,
Null as Suspended,
Null as OriginalDiagnosis,
Null as ExcludeFromWLReporting,
Null as ActNoteKey,
Null as UniquePathwayIdentifier,
NUll as DateRTTStart,
Null as DateRTTStop,
Null as RTTLengthOfWait,
Null as RTTLengthOfWaitAdjusted,
Null as RTTSpecialty,
NUll as RTTACTNOTEKEYatStart,
NUll as RTTExcludedSpecialtyFlag,
DatePlanned, 
Null as RTTSourceAtStart,
Null as RTTTypeAtStart,
Null as DateRTTTarget,
Null as RTTTargetDays,
Null as RTTStage,
ddna as DateOfLastDNAOrPatientCancelled,
Comments as CommentsFromWaitingList,                 --- COMMENTS
refno as WaitingListRefNo,
(case when query=3 then refno else '' end)  as ScheduleRefNo, 
refrl_refno as ReferralRefNo,
ProcedureIntended as ProcedureIntended,					
Null as ProcedureProposed,						
cons_code as HCP,
admit_notaf_dttm as DateOfOriginalTarget, 
WaitingListCensusDate as DateWaitingListCensus,
BookedWardOrClinicCode,
refcomments as CommentsOfReferral,                    -----COMMENTS
theat_time as TimeEstimatedInTheatre,
antyp_refno as AnaestheticType,
'West' as Area,
'Pims' as Source,
Null as HealthRiskFactor,
Null as WeightedPRF,
Null as PercentageOverRun,
Null as ArmedServicesKeyNote,
SiteCode,
TheatreType,          
Null DateOnSystem,                              --  todo wlist_dttm  or schdlcreate
op_code as Coding,
Null as ApptDirDesc,
Null as DaysAdjusted,
Null as ClinicSessionKey,
Null as DateNextAppointment,
Null as DateLastEvent,
Null as LastEventCode,
Null as HCPLastEvent,
Null as SpecialtyLastEvent,
Null as LastActivityOutcome,
Null as LastActivityType,
Null as LastEventLoc,
Null as UActNoteKey,
Null as DateFUToComeIn,
Null as PlannedASAGrade,
Null as IntendedAdmitMethod,
WaitingListTypeCode as WaitingListType,          ----- ip / op ... for this .... ef/en /fu /fb done separately
Null as DocReferenceNo,
Null as VirtualType,
Null as ConsultMethod,
Null as PreviousVirtualType,
Null as PreviousConsultMethod,
Null as PrefVirtualType,
Null as PrefConsultMethod,
Null as VirtualContactDetail,
Null as ElectivePriorityLevel,
Null as DateReprioritisedTarget,
Null as AdmitMethod,
Null as PathwayNote,
susper as DaysSuspension,
susper_dna as DaysDnaSuspension,
dna_date as  DateDna,
pread_date as DateLastPreOp,
pread_attnd as LastPreOpAttendanceStatus,
rev_date as DateConsultantChangeRefused,
rev_stat as ListReviewStatus,
offer_count as TotalAdmissionOffers,
dres as DateAppointmentRescheduled,
inmgt_refno as IntendedManagementCode,
ReferralRequestReceivedDate as DateReferralRequestReceived,
DateOfReferral as DateOfReferral,
ReferralReason as ReferralReason,
ReferralUrgnc as LocalReferralUrgncCode,
ReferralPrity as LocalReferralPrityCode,
SuspensionStartdate as DateLastSuspensionStart,
SuspensionEndDate as DateLastSuspensionEnd,
SuspensionReasn as LastSuspensionReason,
WaitingListEntryLastReviewDate as DateLastWaitingListReview,
WaitingListEntryLastReviewStatus as LastWaitingListReviewStatus,
ReviewBatchNumber as LastWaitingListReviewBatchNumber,
query as EisQueryId,
admet_main_code as ElectiveAdmissionTypeCode,
type as LocalWLTypeCode



from WestWaitingList_NewWH






	

END
GO
