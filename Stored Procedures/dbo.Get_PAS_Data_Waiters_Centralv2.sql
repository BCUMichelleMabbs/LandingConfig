SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: July 2017
-- Description:	Extract of all Waiters
-- Amend Date:  15/4/2020  - HWL :Ensure extract loads into New WH
-- =============================================


CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Centralv2]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)


--Assign the openquery to the string
--set @sql = 'SELECT * FROM OPENQUERY(WPAS_Central,   
--'' Select 

EXEC('
Select distinct
wl.DaysWait,
wl.NHSNumber,
wl.CaseNumber as LocalPatientIdentifier,
wl.ReferralDate as DateReferred,
wl.LinkID as SystemLinkID,
wl.ReferralIntent,
wl.ReferrerCode as Referrer,
wl.ReferringOrganisationCode as OrganisationOfReferrer,
wl.RegisteredGPCode as GPAtTimeOfActivity,
wl.RegisteredGPPractice as GPPracticeAtTimeOfActivity,
wl.PostcodeAtTimeOfReferral as PostcodeAtTimeOfActivity,
wl.LHBofResidence as Commissioner,
wl.SourceOfReferral as ReferralSource,
wl.PriorityOnLetter,
wl.OutcomeOfReferral as Outcome,
wl.WaitingListDate as DateOnWaitingList,
wl.LocationCode as ActivityLocation,
wl.CategoryOfPatient as PatientCategory,
wl.PrioritySetByConsultant as PriorityOfHCP,
wl.WhichListIsPatientOn as TreatmentType,
wl.BookedDate as DateBooked,
wl.ReasonBooked,
wl.FreeTextField_GPREFNO as GpRefNo,
wl.ClinicalCondition,
wl.ChargedTo as CommissionerType,
wl.AttendanceDate as DateOfAppointment,      --same as booked date
wl.DateDeferred as DateDeferred,
wl.WaitingListSpecialty as Specialty,
wl.WaitingListStatus as ListStatus,     
wl.ContractsAuthorised,  
wl.FreeTextField as Comments,
wl.AgeInDays as AgeAtAttendance,
wl.Suspended,  
wl.OriginalDiagnosisTEXT as OriginalDiagnosis,
wl.ExcludeFromPPO1W as ExcludeFromWLReporting,
wl.ACTNOTEKEY as ActNoteKey,
wl.UniquePatientIdendifier as UniquePathwayIdentifier,
wl.RTTStartDate as DateRTTStart,
wl.RTTStopDate as DateRTTStop,
wl.RTTLengthOfWait,
wl.RTTLengthOfWait_Adjusted as RTTLengthOfWaitAdjusted,
wl.RTTSpecialty,
wl.RTTACTNOTEKEYatStart as RTTActNotekeyAtStart,
wl.RTTExcludedSpecialtyFlag,
wl.PlannedDate as DatePlanned,
wl.RTTSourceAtStart,
wl.RTTTypeAtStart,
wl.RTTTargetDate as DateRTTTarget,
wl.RTTTargetDays,
wl.RTT_Stage as RTTStage,
''''''as DateOfLastDNAOrPatientCancelled,
''''''as CommentsFromWaitingList,
''''''as WaitingListRefNo,
''''''as ScheduleRefNo,
''''''as ReferralRefNo,
wl.Coding as ProcedureIntended,
''''''as ProcedureProposed,
wl.HealthCareProfessional as HCP,        ---LOCAL CODE IN CONS FIELD - LOCAL REQUIRED NOT THIS ONE?
wl.TARGET_DATE as DateOfOriginalTarget,
wl.CensusDate as DateWaitingListCensus,
wl.BookedWard as BookedWardOrClinicCode,
''''''as CommentsOfReferral,
''''''as TimeEstimatedInTheatre,
wl.AnaesType as AnaestheticType,
''''''as serviceType,
''''Centre''''as Area,
''''Wpas''''as Source,
wl.HEALTH_RISK_FACTOR as HealthRiskFactor,
wl.WEIGHTED_PR_F as WeightedPRF,
wl.PERCENTAGE_OVERRUN as PercentageOverRun,
wl.ARMED_SERVICES_KEYNOTE ArmedServicesKeyNote,
wl.SiteCode,
wl.TheatreType,
wl.DateOnSystem as DateOnSystem,
wl.Coding,
wl.APPT_DIR_DESC as ApptDirDesc,				-- for Outpatients leave in
wl.AdjustedDays as DaysAdjusted, 
wl.ClinicSessionKey,
wl.NEXT_APPT_DATE as DateNextAppointment,
wl.LAST_EVENT_DATE as DateLastEvent,
wl.LAST_EVENT_CODE as LastEventCode,
wl.LAST_EVENT_CONS as HCPLastEvent,
wl.LAST_EVENT_SPEC as SpecialtyLastEvent,
wl.OUTCOME_CODE3 as LastActivityOutcome,
wl.LAST_ACT_TYPE2 as LastActivityType,
wl.LAST_EVENT_LOC as LastEventLocation,
wl.FU_ACTNOTEKEY as FollowUPActNotekey,
wl.FU_TO_COME_IN_DATE as DateFollowUpTCI,
wl.PLANNED_ASA_GRADE as PlannedASAGrade,
wl.INTENDED_ADMIT_METHOD2 as IntendedAdmitMethod,
wl.WaitingListType,				 -- ListType also in data
wl.DOC_REFERENCE_NO,
GP2.GP_CODE as HealthCareProfessional,
padloc.provider_code as SiteCode,
r.thr_type as TheatreType,
r.ref_anaes_type as AnaesType,
r.pref_ward as BookedWard,
r.datonsys as dateonsystem,
r.CLIN_REF_DATE as ClinicalReferralDate,
c.THECODE as Coding,
''''OP'''' as WLTYPE,
cast(''''Now'''' as Date),
TT.TRT_TYPE as TRT_TYPE2, 
ou.OUTCOME_CODE AS outcome_code2,
CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as Last_Act_Type2,
O3.OUTCOME_CODE as outcome_code3,
m2.method as Intended_Admit_Method2
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''21'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
		left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD


--exec (@sql)
'
) at [WPAS_Central];
END

---EXEC(' Select * from REF_WAIT_LEN_VIEW_ENH (''21'', ''26 MAY 2020'' ,'''','''','''','''') ') AT [WPAS_Central] 
--


GO
