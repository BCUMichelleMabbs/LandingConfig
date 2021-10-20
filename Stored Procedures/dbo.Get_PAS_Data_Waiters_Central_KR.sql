SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: July 2017
-- Description:	Extract of all Waiters
-- Original version
-- =============================================


Create PROCEDURE [dbo].[Get_PAS_Data_Waiters_Central_KR]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)




--Assign the openquery to the string
set @sql = 'SELECT * FROM OPENQUERY(WPAS_Central, 
'' Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.CLIN_REF_DATE as ClinicalReferralDate,
		c.THECODE as OP_OPCS,
		''''OP'''' as WLTYPE,
		cast(''''Now'''' as date)
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''21'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice

UNION

Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.CLIN_REF_DATE as ClinicalReferralDate,
		c.thecode as IPDC_opcs,
		''''DC'''' as WLTYPE,
		cast(''''Now'''' as date)
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''31'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice

UNION

Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.CLIN_REF_DATE as ClinicalReferralDate,
		c.thecode as IPDC_opcs,
		''''IP'''' as WLTYPE,
		cast(''''Now'''' as date)
		
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''41'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice


UNION

Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.CLIN_REF_DATE as ClinicalReferralDate,
		c.thecode as IPDC_opcs,
		''''FU'''' as WLTYPE,
		cast(''''Now'''' as date)
		
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''FU'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice

UNION

Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.CLIN_REF_DATE as ClinicalReferralDate,
		c.thecode as IPDC_opcs,
		''''PP'''' as WLTYPE,
		cast(''''Now'''' as date)
		
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''PP'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice

	'' 
)'


/*
21 = Outpatient Waiting List
31 = Daycases Waiting List
41 = Inpatients Waiting List
FU = Follow Up Waiting List 
PP = Pathway Patients 
*/




declare @results table

(
  WaitStay						varchar(max),
  DaysWait						varchar(max),
  NHSNumber						varchar(max),
  CaseNumber					varchar(max),
  DateReferred					varchar(max),
  LinkID						varchar(max),
  ListType						varchar(max),
  ReferralIntent				varchar(max),
  ReferrerCode					varchar(max),
  ReferringOrganisationCode		varchar(max),
  RegisteredGPCode				varchar(max),
  RegisteredGPPractice			varchar(max),
  PostcodeAtTimeOfReferral		varchar(max),
  LHBofResidence				varchar(max),
  SourceOfReferral				varchar(max),
  PriorityOnLetter				varchar(max),
  OutcomeOfReferral				varchar(max),
  WaitingListDate				varchar(max),
  LocalConsultantCode			varchar(max),
  LocationCode					varchar(max),
  CategoryOfPatient				varchar(max),  --this is a retired data item if looking on the data dictionary for details
  PrioritySetByConsultant		varchar(max),
  WhichListIsPatientOn			varchar(max),
  BookedDate					varchar(max),
  ReasonBooked					varchar(max),
  FreeTextField_GPREFNO			varchar(max),
  ClinicalCondition				varchar(max),
  ChargedTo						varchar(max),
  AttendanceDate				varchar(max),
  DateDeferred					varchar(max),
  WaitingListSpecialty			varchar(max),
  WaitingListStatus				varchar(max),
  ContractsAuthorised			varchar(max),
  FreeTextField					VARCHAR(max),
  AgeGroup						varchar(max),
  AgeInDays						varchar(max),
  DateOfBirth					varchar(max),
  Sex							varchar(max),
  FullName						varchar(max),
  Telephone_DayTime				varchar(max),
  FullAddress					VARCHAR(max),
  Suspended						varchar(max),
  PatientsGPPractice			varchar(max), 
  PatientsGPPRacticeAddress		VARCHAR(max),
  SubSpecialtyNameTEXT			varchar(max),
  ConsultantNameTEXT			varchar(max),
  LocationTEXT					varchar(max),
  OriginalDiagnosisTEXT			VARCHAR(max),
  ExcludeFromPPO1W				varchar(max),
  MainSpecialtyNameTEXT			varchar(max),
  ACTNOTEKEY					varchar(max),
  PatientSurname				varchar(max),
  PatientForename				varchar(max),
  PurchaserText					varchar(max),
  FAXNO							varchar(max),
  DOC_REFERENCE_NO				varchar(max),
  UniquePatientIdendifier		varchar(max),
  RTTStartDate					varchar(max),
  RTTStopDate					varchar(max),
  RTTLengthOfWait				varchar(max),
  RTTLengthOfWait_Adjusted		varchar(max),
  RTTSpecialty					varchar(max),
  RTTACTNOTEKEYatStart			varchar(max),
  RTTExcludedSpecialtyFlag		varchar(max),
  PlannedDate					varchar(max),
  RTTSourceAtStart				varchar(max),
  RTTTypeAtStart				varchar(max),
  RTTTargetDate					varchar(max),
  RTTTargetDays					varchar(max),
  RTTWeeks_Adjusted				varchar(max),
  RTTWeeks						varchar(max),
  LengthOfWaitInWeeks			varchar(max),
  APPT_DIR_DESC					varchar(max),
  RTT_Stage						varchar(max),
  AdjustedDays					varchar(max),
  OTHER_INFO					VARbinary(max),
  ClinicNameText				VARCHAR(max),
  ClinicSessionKey				varchar(max),
  NEXT_APPT_DATE				varchar(max),
  NEXT_APPT_SESSION_NAME		VARCHAR(max),
  PREFERRED_LOCATION_TEXT		VARCHAR(max),
  DISCHARGE_DATE				varchar(max),		--not on the myrddin version of the SP
  NEXT_APPT_NEEDED				varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_DATE				varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_CODE				varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_DESCRIPTION		varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_CONS				varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_SPEC				varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_ALLNAME			varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_SPECIALTY_NAME		varchar(max),		--not on the myrddin version of the SP
  LAST_ACT_OUTCOME				varchar(max),		--not on the myrddin version of the SP
  LAST_ACT_TYPE					varchar(max),		--not on the myrddin version of the SP  
  LAST_EVENT_LOC				varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_LOC_DESCRIPTION	varchar(max),		--not on the myrddin version of the SP
  LAST_EVENT_LOCALITY			varchar(max),		--not on the myrddin version of the SP
  FU_ACTNOTEKEY					varchar(max),		--not on the myrddin version of the SP
  FU_TO_COME_IN_DATE			varchar(max),		--not on the myrddin version of the SP
  THEATRE_TYPE					varchar(max),		--not on the myrddin version of the SP
  ANAESTHETIC_TYPE				varchar(max),		--not on the myrddin version of the SP
  PLANNED_ASA_GRADE				varchar(max),		--not on the myrddin version of the SP
  INTENDED_ADMIT_METHOD			varchar(max),		--not on the myrddin version of the SP
  HealthCareProfessional		varchar(max),		--extra fields joined on above
  SiteCode					    varchar(max),		--extra fields joined on above
  TheatreType					varchar(max),		--extra fields joined on above
  AnaesType						varchar(max),		--extra fields joined on above
  BookedWard					varchar(max),		--extra fields joined on above
  DateOnSystem					varchar(max),		--extra fields joined on above
  ClinicalReferralDate			varchar(max),		--extra fields joined on above		
  Coding						varchar(max),		--extra fields joined on above
  WaitingListType				varchar(max),		--extra fields joined on above
  CensusDate					varchar(max)		--extra fields joined on above
)

Insert into @results(
  WaitStay,
  DaysWait,
  NHSNumber,
  CaseNumber,
  DateReferred,
  LinkID,
  ListType,
  ReferralIntent,
  ReferrerCode,
  ReferringOrganisationCode,
  RegisteredGPCode,
  RegisteredGPPractice,
  PostcodeAtTimeOfReferral,
  LHBofResidence,
  SourceOfReferral,
  PriorityOnLetter,
  OutcomeOfReferral,
  WaitingListDate,
  LocalConsultantCode,
  LocationCode,
  CategoryOfPatient,
  PrioritySetByConsultant,
  WhichListIsPatientOn,
  BookedDate,
  ReasonBooked,
  FreeTextField_GPREFNO,
  ClinicalCondition,
  ChargedTo,
  AttendanceDate,
  DateDeferred,
  WaitingListSpecialty,
  WaitingListStatus,
  ContractsAuthorised,
  FreeTextField,
  AgeGroup,
  AgeInDays,
  DateOfBirth,
  Sex,
  FullName,
  Telephone_DayTime,
  FullAddress,
  Suspended,
  PatientsGPPractice,
  PatientsGPPRacticeAddress,
  SubSpecialtyNameTEXT,
  ConsultantNameTEXT,
  LocationTEXT,
  OriginalDiagnosisTEXT,
  ExcludeFromPPO1W,
  MainSpecialtyNameTEXT,
  ACTNOTEKEY,
  PatientSurname,
  PatientForename,
  PurchaserText,
  FAXNO	,
  DOC_REFERENCE_NO,
  UniquePatientIdendifier,
  RTTStartDate,
  RTTStopDate,
  RTTLengthOfWait	,
  RTTLengthOfWait_Adjusted,
  RTTSpecialty,
  RTTACTNOTEKEYatStart,
  RTTExcludedSpecialtyFlag,
  PlannedDate,
  RTTSourceAtStart,
  RTTTypeAtStart,
  RTTTargetDate,
  RTTTargetDays,
  RTTWeeks_Adjusted,
  RTTWeeks,
  LengthOfWaitInWeeks,
  APPT_DIR_DESC	,
  RTT_Stage,
  AdjustedDays,
  OTHER_INFO,
  ClinicNameText,
  ClinicSessionKey,
  NEXT_APPT_DATE,
  NEXT_APPT_SESSION_NAME,
  PREFERRED_LOCATION_TEXT,
  DISCHARGE_DATE,
  NEXT_APPT_NEEDED,
  LAST_EVENT_DATE,
  LAST_EVENT_CODE,
  LAST_EVENT_DESCRIPTION,
  LAST_EVENT_CONS,
  LAST_EVENT_SPEC,
  LAST_EVENT_ALLNAME,
  LAST_EVENT_SPECIALTY_NAME,
  LAST_ACT_OUTCOME,
  LAST_ACT_TYPE	,
  LAST_EVENT_LOC,
  LAST_EVENT_LOC_DESCRIPTION,
  LAST_EVENT_LOCALITY,
  FU_ACTNOTEKEY,
  FU_TO_COME_IN_DATE,
  THEATRE_TYPE,
  ANAESTHETIC_TYPE,
  PLANNED_ASA_GRADE,
  INTENDED_ADMIT_METHOD,
  HealthCareProfessional,
  SiteCode,
  TheatreType,
  AnaesType,
  BookedWard,
  DateOnSystem,
  ClinicalReferralDate,				
  Coding,
  WaitingListType,
  CensusDate
)
exec (@sql)




select
  --WaitStay, 
  DaysWait,
  NHSNumber,
  CaseNumber as LocalPersonIdentifier,
  DateReferred as DateReferred,
  LinkID as SystemLinkID,
 --ListType,
  ReferralIntent,
  ReferrerCode as Referrer,
  ReferringOrganisationCode as ReferringOrganisation,
  RegisteredGPCode as GPAtTimeOfActivity,
  RegisteredGPPractice as GPPracticeAtTimeOfActivity,
  PostcodeAtTimeOfReferral as PostcodeAtTimeOfActivity,
  LHBofResidence as Commissioner,
  SourceOfReferral as ReferralSource,
  PriorityOnLetter,
  OutcomeOfReferral as Outcome,
  WaitingListDate,
  --LocalConsultantCode,
  --LocationCode as ActivityLocation,
  CategoryOfPatient as PatientCategory,
  PrioritySetByConsultant as HCPPriority,
  WhichListIsPatientOn,
  BookedDate,
  ReasonBooked,
  FreeTextField_GPREFNO as GpRefNo,
  ClinicalCondition,
  ChargedTo as CommissionerType,
  --AttendanceDate, --same as booked date
  --DateDeferred,
  WaitingListSpecialty as Specialty,
  --WaitingListStatus,
  --ContractsAuthorised,
  FreeTextField as Comments,
  --AgeGroup,
  AgeInDays as AgeOnAttendance,
  --DateOfBirth,
  --Sex,
  --FullName,
  --Telephone_DayTime,
  --FullAddress,
  --Suspended,
  --PatientsGPPractice,
 -- PatientsGPPRacticeAddress,
  --SubSpecialtyNameTEXT,
 -- ConsultantNameTEXT,
  --LocationTEXT,
  --OriginalDiagnosisTEXT,
  ExcludeFromPPO1W as ExcludeFromWLReporting,
  --MainSpecialtyNameTEXT,
  ACTNOTEKEY as Actnotekey,
  --PatientSurname,
  --PatientForename,
 -- PurchaserText,
  --FAXNO	,
  --DOC_REFERENCE_NO,
  UniquePatientIdendifier as UniquePathwayIdentifier,
  RTTStartDate,
  RTTStopDate,
  RTTLengthOfWait,
  RTTLengthOfWait_Adjusted as RTTLengthOfWaitAdjusted,
  RTTSpecialty,
  RTTACTNOTEKEYatStart as RTTActnotkeyAtStart,
  RTTExcludedSpecialtyFlag,
  PlannedDate,
  RTTSourceAtStart,
  RTTTypeAtStart,
  RTTTargetDate,
  RTTTargetDays,
  --RTTWeeks_Adjusted as RTTWeeksAdjusted,
  --RTTWeeks,
  --LengthOfWaitInWeeks,
  --APPT_DIR_DESC,
  RTT_Stage as RTTStage,
  AdjustedDays as RTTAdjustedDays,
  --OTHER_INFO,
  --ClinicNameText,
  ClinicSessionKey as SessionId,
  NEXT_APPT_DATE as NextAppointmentDate,
  --NEXT_APPT_SESSION_NAME as NextAppointmentSession,
  --PREFERRED_LOCATION_TEXT,
  DISCHARGE_DATE as DischargeDate,
  NEXT_APPT_NEEDED as NextAppointmentNeeded,
  LAST_EVENT_DATE as LastEventDate,
  LAST_EVENT_CODE as LastEvent,
  --LAST_EVENT_DESCRIPTION,
  LAST_EVENT_CONS as LastEventHCP,
  LAST_EVENT_SPEC as LastEventSpecialty,
  --LAST_EVENT_ALLNAME,
  --LAST_EVENT_SPECIALTY_NAME,
  LAST_ACT_OUTCOME as LastEventOutcome,
  LAST_ACT_TYPE	as LastActivityType,
  LAST_EVENT_LOC as LastEventLocation,
  --LAST_EVENT_LOC_DESCRIPTION,
  --LAST_EVENT_LOCALITY as LastEventLocality,
  FU_ACTNOTEKEY as FollowUPActnotekey,
  FU_TO_COME_IN_DATE as FollowUpTCIDate,
  --THEATRE_TYPE -- this is text not code,
  --ANAESTHETIC_TYPE,
  PLANNED_ASA_GRADE as PlannedASAGrade,
  --INTENDED_ADMIT_METHOD,
  HealthCareProfessional as HCP,
  SiteCode as ActivityLocation,
  TheatreType,
  AnaesType as AnaestheticType,
  BookedWard,
  DateOnSystem as DateOnSystem,
  --ClinicalReferralDate,
  Coding as ProcedureProposed,
  WaitingListType,
  CensusDate as CensusDate,
  'Central' as Area,
  'WPAS' as Source
from @results



END



GO
