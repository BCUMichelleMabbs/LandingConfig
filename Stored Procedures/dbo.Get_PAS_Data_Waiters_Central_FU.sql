SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Heather Lewis 
-- Create date: 6/10/2020
-- Description:	Centre - Extract of all Waiters (FU / PP)  SPLIT FROM OTHERS - SLOW RUNNING
--              This version created to fix error "Unable to Execute an Execute"
--              Data succesfully loads into foundation   
--  Amend Date: 
--              
-- =============================================


CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Central_FU]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)



EXEC('

Select distinct

wl.LOS AS DaysWait,
wl.NHS AS NHSNumber,
wl.CaseNo as LocalPatientIdentifier,
wl.dat_ref as DateReferred,
wl.LinkID as SystemLinkID,
wl.INTENT_REFER AS ReferralIntent,
wl.GP_REF as Referrer,
wl.GP_PRAC AS OrganisationOfReferrer,
wl.Reg_GP as GPAtTimeOfActivity,
wl.Reg_Prac as GPPracticeAtTimeOfActivity,
wl.Postcode as PostcodeAtTimeOfActivity,
wl.DHA_CODE as Commissioner,
wl.Source_Refer as ReferralSource,
wl.LTTR_PRTY AS PriorityOnLetter,
wl.Ref_Outcome as Outcome,
wl.Datonsys as DateOnWaitingList,
wl.Loc as LocationCode,
wl.Category as PatientCategory,
wl.Cons_Prty as PriorityOfHCP,
wl.trt_type as TreatmentType,
wl.Date_Booked as DateBooked,
wl.Reason_Booked as ReasonBooked,
wl.GPREFNO as GpRefNo,
wl.Clinical_Condition as ClinicalCondition,
wl.Charged_To as CommissionerType,
wl.TRT_DATE as DateOfAppointment, 
wl.Deferred_Date as DateDeferred,
wl.Spec as Specialty,
wl.List_Outcome as ListStatus,    
wl.Contracts_Authorised as ContractsAuthorised,  
wl.origtext as Comments,
wl.AgeInDays as AgeAtAttendance,
wl.Suspended as Suspended, 
wl.Orig_Diag_description as OriginalDiagnosis,
wl.Exclude_PPO1W as ExcludeFromWLReporting,
wl.ACTNOTEKEY as ActNoteKey,
wl.RTT_UPI as UniquePathwayIdentifier,
wl.RTT_Start_Date as DateRTTStart,
wl.RTT_Stop_Date as DateRTTStop,
wl.RTT_LOW AS RTTLengthOfWait,
wl.RTT_Adjusted_LOW as RTTLengthOfWaitAdjusted,
wl.RTT_Spec AS RTTSpecialty,
wl.RTT_ACTNOTEKEY_Start as RTTActNotekeyAtStart,
wl.RTT_Exclude AS RTTExcludedSpecialtyFlag,
wl.Planned_OP_Date as DatePlanned,
wl.RTT_Start_Source as RTTSourceAtStart,
wl.RTT_Start_Type as RTTTypeAtStart,
wl.RTT_Target_Date as DateRTTTarget,
wl.RTT_TARGET AS RTTTargetDays,
wl.Pathway_Stage  as RTTStage,
NULL as DateOfLastDNAOrPatientCancelled,
NULL as CommentsFromWaitingList,
NULL as WaitingListRefNo,
NULL as ScheduleRefNo,
NULL as ReferralRefNo,
NULL as ProcedureIntended,
NULL as ProcedureProposed,
GP2.GP_CODE as HCP,
wl.TARGET_DATE as DateOfOriginalTarget,
cast(''Now'' as Date) as DateWaitingListCensus,
r.pref_ward as BookedWardOrClinicCode,
NULL as CommentsOfReferral,
NULL as TimeEstimatedInTheatre,
--wl.Anaesthetic_Type as AnaestheticType,
r.ref_anaes_type as AnaestheticType,
NULL as ServiceType,
''Centre'' as Area,
''Wpas'' as Source,
wl.HEALTH_RISK_FACTOR as HealthRiskFactor,
wl.WEIGHTED_PR_F as WeightedPRF,
wl.PERCENTAGE_OVERRUN as PercentageOverRun,  
wl.ARMED_SERVICES_KEYNOTE as ArmedServicesKeyNote,
padloc.provider_code as SiteCode,
--wl.Theatre_Type as TheatreType,  
r.thr_type as TheatreType,
r.datonsys as DateOnSystem,
c.THECODE as Coding,
wl.APPT_DIR_DESC as ApptDirDesc,
wl.Adjusted_Days as DaysAdjusted,
wl.Session_Key as ClinicSessionKey,
wl.NEXT_APPT_DATE as DateNextAppointment,
wl.LAST_EVENT_DATE as DateLastEvent,
wl.LAST_EVENT_CODE as LastEventCode,
wl.LAST_EVENT_CONS as HCPLastEvent,
wl.LAST_EVENT_SPEC as SpecialtyLastEvent,
--wl.LAST_ACT_OUTCOME as LastActOutcome,
O3.OUTCOME_CODE as LastActOutcome,
--wl.LAST_ACT_TYPE as LastActType,
CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as LastActType,
wl.LAST_EVENT_LOC as LastEventLoc,
wl.FU_ACTNOTEKEY as FUPActNotekey,
wl.FU_TO_COME_IN_DATE as DateFUToComeIn,
wl.PLANNED_ASA_GRADE as PlannedASAGrade,
--wl.INTENDED_ADMIT_METHOD as IntendedAdmitMethod,
m2.method as IntendedAdmitMethod,
--wl.wLIST AS WaitingListType,
''FU'' as WaitingListType, 
wl.DOC_REFERENCE_NO AS DocReferenceNo,
wl.VIRTUAL_TYPE as VirtualType,
wl.CONSULT_METHOD as ConsultMethod,
wl.PREVIOUS_VIRTUAL_TYPE as PreviousVirtualType,
wl.PREVIOUS_CONSULT_METHOD as PreviousConsultMethod,
wl.PREF_VIRTUAL_TYPE as PrefVirtualType,
wl.PREF_CONSULT_METHOD as PrefConsultMethod

/*
r.CLIN_REF_DATE as ClinicalReferralDate,
TT.TRT_TYPE as TRT_TYPE2, 
ou.OUTCOME_CODE AS outcome_code2,
*/

	from 
	
		REF_WAIT_LEN_VIEW_ENH (''FU'',''01/01/2999'','''','''','''','''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''4''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
		left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD




'


) at [WPAS_Central];
END

---EXEC(' Select * from REF_WAIT_LEN_VIEW_ENH (''21'', ''06 OCT 2020'' ,'''','''','''','''') ') AT [WPAS_Central] 
-- REF_WAIT_LEN_VIEW_ENH (''''21'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl


GO
