SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Heather Lewis                         
-- Create date: 6/10/2020
-- Description:	Centre - Extract of all Waiters (OP/DC/IP/FU/PP/TF/TO)
--              This version created to fix error "Unable to Execute an Execute"
--              Data succesfully loads into foundation   
--  Amend Date: 12/01/2021 x4 new fields added
--              22/06/2021 Risk Stratification fields not in Wpas SP
--              28/07/2021 Commented out nullif check for VirtualContactDetails - Issue identified for FU dataset
-- =============================================

CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Central_z1_TO]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)

DECLARE @LastDateWaitingListCensus AS DATE = (SELECT ISNULL(MAX(DateWaitingListCensus),'01 January 2018') FROM [Foundation].[dbo].[PAS_Data_WaitingList] where Area='Central')
DECLARE @LastDateWaitingListCensusString AS VARCHAR(30) = DATENAME(DAY,@LastDateWaitingListCensus) + ' ' + DATENAME(MONTH,@LastDateWaitingListCensus) + ' ' + DATENAME(YEAR,@LastDateWaitingListCensus)

EXEC('




Select distinct

nullif(rtrim(wl.LOS),'''') AS DaysWait,
nullif(rtrim(wl.NHS),'''')AS NHSNumber,
nullif(rtrim(wl.CaseNo),'''') as LocalPatientIdentifier,
nullif(rtrim(wl.dat_ref),'''')as DateReferred,
nullif(rtrim(wl.LinkID),'''') as SystemLinkID,
nullif(rtrim(wl.INTENT_REFER),'''')AS ReferralIntent,
nullif(rtrim(wl.GP_REF),'''')as Referrer,
nullif(rtrim(wl.GP_PRAC),'''')AS ReferringOrganisation,
nullif(rtrim(wl.Reg_GP),'''')as GPAtTimeOfActivity,
nullif(rtrim(wl.Reg_Prac),'''')as GPPracticeAtTimeOfActivity,
nullif(rtrim(wl.Postcode),'''')as PostcodeAtTimeOfActivity,
nullif(rtrim(wl.DHA_CODE),'''')as Commissioner,
nullif(rtrim(wl.Source_Refer),'''')as ReferralSource,
nullif(rtrim(wl.LTTR_PRTY),'''')AS PriorityOnLetter,
nullif(rtrim(wl.Ref_Outcome),'''')as Outcome,
nullif(rtrim(wl.Datonsys),'''')as DateOnWaitingList,
nullif(rtrim(wl.Loc),'''')as Location,
nullif(rtrim(wl.Category),'''')as PatientCategory,
nullif(rtrim(wl.Cons_Prty),'''')as PriorityOfHCP,
nullif(rtrim(wl.trt_type),'''')as TreatmentType,
nullif(rtrim(wl.Date_Booked),'''')as DateBooked,
nullif(rtrim(wl.Reason_Booked),'''')as ReasonBooked,
nullif(rtrim(wl.GPREFNO),'''')as GpRefNo,
nullif(rtrim(wl.Clinical_Condition),'''')as ClinicalCondition,
nullif(rtrim(wl.Charged_To),'''')as CommissionerType,
nullif(rtrim(wl.TRT_DATE),'''')as DateOfAppointment, 
nullif(rtrim(wl.Deferred_Date),'''')as DateDeferred,
nullif(rtrim(wl.Spec),'''')as Specialty,
nullif(rtrim(wl.List_Outcome),'''')as ListStatus,    
nullif(rtrim(wl.Contracts_Authorised),'''')as ContractsAuthorised,
wl.origtext as Comments,
nullif(rtrim(wl.AgeInDays),'''')as AgeInDays,
nullif(rtrim(wl.Suspended),'''')as Suspended, 
nullif(rtrim(wl.Orig_Diag_description),'''')as OriginalDiagnosis,
nullif(rtrim(wl.Exclude_PPO1W),'''')as ExcludeFromWLReporting,
nullif(rtrim(wl.ACTNOTEKEY),'''')as ActNoteKey,
nullif(rtrim(wl.RTT_UPI),'''')as UniquePathwayIdentifier,
nullif(rtrim(wl.RTT_Start_Date),'''')as DateRTTStart,
nullif(rtrim(wl.RTT_Stop_Date),'''')as DateRTTStop,
nullif(rtrim(wl.RTT_LOW),'''')AS RTTWait,
nullif(rtrim(wl.RTT_Adjusted_LOW),'''')as RTTWaitAdjusted,
nullif(rtrim(wl.RTT_Spec),'''')AS RTTSpecialty,
nullif(rtrim(wl.RTT_ACTNOTEKEY_Start),'''')as RTTActNotekeyAtStart,
nullif(rtrim(wl.RTT_Exclude),'''')AS RTTExcludedSpecialty,
nullif(rtrim(wl.Planned_OP_Date),'''')as DatePlanned,
nullif(rtrim(wl.RTT_Start_Source),'''')as RTTSourceAtStart,
nullif(rtrim(wl.RTT_Start_Type),'''')as RTTTypeAtStart,
nullif(rtrim(wl.RTT_Target_Date),'''')as DateRTTTarget,
nullif(rtrim(wl.RTT_TARGET),'''')AS RTTTargetDays,
nullif(rtrim(wl.Pathway_Stage),'''') as RTTStage,
NULL as DateOfLastDNAOrPatientCancelled,
NULL as CommentsFromWaitingList,
NULL as WaitingListRefNo,
NULL as ScheduleRefNo,
NULL as ReferralRefNo,
nullif(rtrim(C.THECODE),'''')as OPCS,
NULL as ProcedureProposed,
nullif(rtrim(GP2.GP_CODE),'''')as HCP,
nullif(rtrim(wl.TARGET_DATE),'''')as DateOfOriginalTarget,
cast(''Now'' as Date) as DateWaitingListCensus,
nullif(rtrim(r.pref_ward),'''')as BookedWardOrClinic,
NULL as CommentsOfReferral,
NULL as TimeEstimatedInTheatre,
--nullif(rtrim(wl.Anaesthetic_Type),'''')as AnaestheticType,
nullif(rtrim(r.ref_anaes_type),'''')as AnaestheticType,
''Central'' as Area,
''Wpas'' as Source,
nullif(rtrim(wl.HEALTH_RISK_FACTOR),'''')as HealthRiskFactor,
nullif(rtrim(wl.WEIGHTED_PR_F),'''')as WeightedPRF,
nullif(rtrim(wl.PERCENTAGE_OVERRUN),'''')as PercentageOverRun,  
nullif(rtrim(wl.ARMED_SERVICES_KEYNOTE),'''')as ArmedServicesKeyNote,
nullif(rtrim(padloc.provider_code),'''')as Site,
--nullif(rtrim(wl.Theatre_Type),'''')as TheatreType,  
nullif(rtrim(r.thr_type),'''')as TheatreType,
nullif(rtrim(r.datonsys),'''')as DateOnSystem,
--nullif(rtrim(wl.APPT_DIR_DESC),'''')as AppointmentDirective,
nullif(rtrim(D.APPT_DIRECTIVE),'''')as AppointmentDirective,
nullif(rtrim(wl.Adjusted_Days),'''')as DaysAdjusted,
nullif(rtrim(wl.Session_Key),'''')as ClinicSessionKey,
nullif(rtrim(wl.NEXT_APPT_DATE),'''')as DateNextAppointment,
nullif(rtrim(wl.LAST_EVENT_DATE),'''')as DateLastEvent,
nullif(rtrim(wl.LAST_EVENT_CODE),'''')as LastEvent,
nullif(rtrim(wl.LAST_EVENT_CONS),'''')as HCPLastEvent,
nullif(rtrim(wl.LAST_EVENT_SPEC),'''')as SpecialtyLastEvent,
--nullif(rtrim(wl.LAST_ACT_OUTCOME),'''')as LastActivityOutcome,
nullif(rtrim(O3.OUTCOME_CODE),'''')as LastActivityOutcome,
--nullif(rtrim(wl.LAST_ACT_TYPE ),'''')as LastActType,
CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as LastActivityType,
nullif(rtrim(wl.LAST_EVENT_LOC),'''')as LastEventLoc,
nullif(rtrim(wl.FU_ACTNOTEKEY),'''')as ActNotekeyFU,
nullif(rtrim(wl.FU_TO_COME_IN_DATE),'''')as DateFUToComeIn,
nullif(rtrim(wl.PLANNED_ASA_GRADE),'''')as PlannedASAGrade,
--nullif(rtrim(wl.INTENDED_ADMIT_METHOD),'''')as IntendedAdmitMethod,
nullif(rtrim(m2.method),'''')as AdmissionMethodIntended,
--nullif(rtrim(wl.wLIST),'''')AS WaitingListType,
''EN'' as WaitingListType,
nullif(rtrim(wl.DOC_REFERENCE_NO),'''')AS DocumentReference,
nullif(rtrim(wl.VIRTUAL_TYPE),'''')as VirtualType,
nullif(rtrim(wl.CONSULT_METHOD),'''')as ConsultMethod,
nullif(rtrim(wl.PREVIOUS_VIRTUAL_TYPE),'''')as PreviousVirtualType,
nullif(rtrim(wl.PREVIOUS_CONSULT_METHOD),'''')as PreviousConsultMethod,
nullif(rtrim(wl.PREF_VIRTUAL_TYPE),'''')as PreferredVirtualType,
nullif(rtrim(wl.PREF_CONSULT_METHOD),'''')as PreferredConsultMethod, 
wl.VIRTUAL_CONTACT_DETAILS as VirtualContactDetail,
--nullif(rtrim(wl.VIRTUAL_CONTACT_DETAILS),'''')as VirtualContactDetail,
nullif(rtrim(wl.ELECTIVE_PRIORITY_LEVEL),'''')as ElectivePriorityLevel,
nullif(rtrim(wl.REPRIORITISED_TAGET_DATE),'''')as DateReprioritisedTarget,
nullif(rtrim(wl.ADMIT_METHOD),'''')AS AdmissionMethodRePrioritised,
cast(pathway_notes as varchar (3000)) as PathwayNote,
Null as DaysSuspension,
Null as DaysDNASuspension,
Null as DateDNA,
Null as DateLastPreOp,
Null as LastPreOpAttendanceStatus,
Null as DateConsultantChangeRefused,
Null as ListReviewStatus,
Null as TotalAdmissionOffers,
Null as DateAppointmentRescheduled,
Null as IntendedManagement,
Null as DateReferralRequestReceived,
Null as DateReferralSent,
Null as ReferralReason,
Null as LocalReferralUrgnc,
Null as LocalReferralPrity,
Null as DateLastSuspensionStart,
Null as DateLastSuspensionEnd,
Null as LastSuspensionReason,
Null as DateLastWaitingListReview,
Null as LastWaitingListReviewStatus,
Null as LastWaitingListReviewBatchNumber,
Null as EisQueryId,
Null as ElectiveAdmissionType,
Null as LocalWLType,
nullif(rtrim(rep.priority_by),'''')as HCPRePrioritisedBy,
nullif(rtrim(rep.priority_date),'''')as DateRePrioritised,
Null as PriorityClinical,
nullif(rtrim(wl.DISCHARGE_DATE),'''')as DateDischargeOfLastAdmission,
nullif(rtrim(wl.NEXT_APPT_NEEDED),'''')as NextApptNeeded,
null as DateDDTA





	from 
	
		REF_WAIT_LEN_VIEW_ENH (''TO'','''+ @TodayDateText +''','''','''','''','''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''4'' and code_type =''OP''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
		left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD
		left join PATHWAYMGT pm ON pm.UPI = wl.RTT_UPI and (coalesce (pm.event_Source, ''PN'') = ''PN'' and pm.pwaykey = (select first 1 pm2.pwaykey from pathwaymgt pm2 where pm2.UPI = wl.RTT_UPI and coalesce(pm2.event_source, ''PN'') = ''PN''))
		left join REF_ELECTIVE_REPRIORITISED rep on rep.seqno = (select first 1 seqno from REF_ELECTIVE_REPRIORITISED r2 where r2.linkid = wl.linkid order by date_entered desc) 
		left join APPT_DIRECTIVE D ON D.DESCRIPTION = wl.APPT_DIR_DESC

'


) at [WPAS_Central];
END



GO
