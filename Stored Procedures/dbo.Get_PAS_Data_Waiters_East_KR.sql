SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: July 2017
-- Description:	Extract of all Waiters
-- ORIGINAL VERSION COPY AS AT 15/4/20
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_East_KR]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today=getdate()
set @TodayDateText=datename(day,@today) + ' ' + datename(month,@today) + ' ' + datename(year,@today)




--Assign the openquery to the string
set @sql='SELECT * FROM OPENQUERY(WPAS_East,
'' Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.dat_ref as DateReferred,
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
		r.dat_ref as DateReferred,
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
		r.dat_ref as DateReferred,
		c.thecode as IPDC_opcs,
		''''IP'''' as WLTYPE,
		cast(''''Now'''' as date)
		
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''41'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice






	'' 
)'



/*
UNION

Select 
		wl.*,
		GP2.GP_CODE as HealthCareProfessional,
		padloc.provider_code as SiteCode,
		r.thr_type as TheatreType,
		r.ref_anaes_type as AnaesType,
		r.pref_ward as BookedWard,
		r.datonsys as dateonsystem,
		r.dat_ref as DateReferred,
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
		r.dat_ref as DateReferred,
		c.thecode as IPDC_opcs,
		''''PP'''' as WLTYPE,
		cast(''''Now'''' as date)
		
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''PP'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice



21=Outpatient Waiting List
31=Daycases Waiting List
41=Inpatients Waiting List
FU=Follow Up Waiting List 
PP=Pathway Patients 
*/




declare @results table

(
  WaitStay						SMALLINT,
  DaysWait						varchar(10),
  NHSNumber						VARCHAR(17),
  CaseNumber					VARCHAR(10),
  Referraldate					DATE,
  LinkID						VARCHAR(20),
  ListType						VARCHAR(2),
  ReferralIntent				VARCHAR(1),
  ReferrerCode					VARCHAR(8),
  ReferringOrganisationCode		VARCHAR(6),
  RegisteredGPCode				VARCHAR(8),
  RegisteredGPPractice			VARCHAR(6),
  PostcodeAtTimeOfReferral		VARCHAR(8),
  LHBofResidence				VARCHAR(3),
  SourceOfReferral				VARCHAR(2),
  PriorityOnLetter				VARCHAR(1),
  OutcomeOfReferral				VARCHAR(2),
  WaitingListDate				DATE,
  LocalConsultantCode			VARCHAR(5),
  LocationCode					VARCHAR(5),
  CategoryOfPatient				VARCHAR(2), --this is a retired data item if looking on the data dictionary for details
  PrioritySetByConsultant		VARCHAR(1),
  WhichListIsPatientOn			VARCHAR(2),
  BookedDate					DATE,
  ReasonBooked					VARCHAR(1),
  FreeTextField_GPREFNO			VARCHAR(15),
  ClinicalCondition				VARCHAR(10),
  ChargedTo						CHAR(1),
  AttendanceDate				DATE,
  DateDeferred					DATE,
  WaitingListSpecialty			VARCHAR(6),
   WaitingListSubSpecialty		VARCHAR(6),
  WaitingListStatus				VARCHAR(2),
  ContractsAuthorised			SMALLINT,
  FreeTextField					VARCHAR(max),
  AgeGroup						VARCHAR(1),
  AgeInDays						INTEGER,
  DateOfBirth					DATE,
  Sex							VARCHAR(1),
  FullName						VARCHAR(80),
  Telephone_DayTime				VARCHAR(100),
  FullAddress					VARCHAR(150),
  Suspended						INTEGER,
  PatientsGPPractice			VARCHAR(6),
  PatientsGPPRacticeAddress		VARCHAR(100),
  SubSpecialtyNameTEXT			VARCHAR(30),
  ConsultantNameTEXT			VARCHAR(35),
  LocationTEXT					VARCHAR(100),
  OriginalDiagnosisTEXT			VARCHAR(70),
  ExcludeFromPPO1W				VARCHAR(1),
  MainSpecialtyNameTEXT			VARCHAR(30),
  ACTNOTEKEY					INTEGER,
  PatientSurname				VARCHAR(40),
  PatientForename				VARCHAR(40),
  PurchaserText					VARCHAR(30),
  FAXNO							VARCHAR(20),
  DOC_REFERENCE_NO				VARCHAR(20),
  UniquePatientIdendifier		VARCHAR(20),
  RTTStartDate					DATE,
  RTTStopDate					DATE,
  RTTLengthOfWait				INTEGER,
  RTTLengthOfWait_Adjusted		INTEGER,
  RTTSpecialty					VARCHAR(6),
  RTTACTNOTEKEYatStart			INTEGER,
  RTTExcludedSpecialtyFlag		VARCHAR(1),
  PlannedDate					DATE,
  RTTSourceAtStart				VARCHAR(2),
  RTTTypeAtStart				VARCHAR(2),
  RTTTargetDate					DATE,
  RTTTargetDays					INTEGER,
  RTTWeeks_Adjusted				INTEGER,
  RTTWeeks						INTEGER,
  LengthOfWaitInWeeks			INTEGER,
  APPT_DIR_DESC					VARCHAR(100),
  RTT_Stage						VARCHAR(2),
  AdjustedDays					INTEGER,
  OTHER_INFO					VARbinary(255),
  ClinicNameText				VARCHAR(255),
  ClinicSessionKey				INTEGER,
  NEXT_APPT_DATE				DATE,
  NEXT_APPT_SESSION_NAME		VARCHAR(255),
  PREFERRED_LOCATION_TEXT		VARCHAR(100),
  DISCHARGE_DATE				Date,				--not on the myrddin version of the SP
  NEXT_APPT_NEEDED				VARCHAR(2),			--not on the myrddin version of the SP
  LAST_EVENT_DATE				Date,				--not on the myrddin version of the SP
  LAST_EVENT_CODE				VARCHAR(2),			--not on the myrddin version of the SP
  LAST_EVENT_DESCRIPTION		VARCHAR(20),		--not on the myrddin version of the SP
  LAST_EVENT_CONS				VARCHAR(8),			--not on the myrddin version of the SP
  LAST_EVENT_SPEC				VARCHAR(6),			--not on the myrddin version of the SP
  LAST_EVENT_ALLNAME			VARCHAR(20),		--not on the myrddin version of the SP
  LAST_EVENT_SPECIALTY_NAME		VARCHAR(20),		--not on the myrddin version of the SP
  LAST_ACT_OUTCOME				varchar(2),			--not on the myrddin version of the SP
  LAST_ACT_TYPE					varchar(2),			--not on the myrddin version of the SP  
  LAST_EVENT_LOC				varchar(6),			--not on the myrddin version of the SP
  LAST_EVENT_LOC_DESCRIPTION	VARCHAR(20),		--not on the myrddin version of the SP
  LAST_EVENT_LOCALITY			varchar(6),			--not on the myrddin version of the SP
  FU_ACTNOTEKEY					int,				--not on the myrddin version of the SP
  FU_TO_COME_IN_DATE			date,				--not on the myrddin version of the SP
  THEATRE_TYPE					varchar(30),		--not on the myrddin version of the SP
  ANAESTHETIC_TYPE				varchar(30),		--not on the myrddin version of the SP
  PLANNED_ASA_GRADE				varchar(20),		--not on the myrddin version of the SP
  INTENDED_ADMIT_METHOD			varchar(30),		--not on the myrddin version of the SP
  HealthCareProfessional		varchar(8),
  SiteCode					    varchar(60),
  TheatreType					varchar(10),
  AnaesType						varchar(10),
  BookedWard					varchar(10),
  DateOnSystem					DATE,	
  DateReferred					DATE,
  Coding						varchar(8),
  --LastEventOutcome				varchar(2),
  WaitingListType				varchar(2),
  CensusDate					Date,
  Area                          varchar(10),
  Source                        varchar(10)
)

Insert into @results(
  WaitStay,
  DaysWait,
  NHSNumber,
  CaseNumber,
  Referraldate,
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
  HealthCareProfessional,
  SiteCode,
  TheatreType,
  AnaesType,
  BookedWard,
  DateOnSystem,
  DateReferred,
  Coding,
  --LastEventOutcome,
  WaitingListType,
  CensusDate,
  Area,
  Source
)
exec (@sql)




select
   --WaitStay,
  DaysWait,
  NHSNumber,
  CaseNumber as LocalPatientIdentifier,
  ReferralDate as DateReferred,
  LinkID as SystemLinkID,
 --ListType,
  ReferralIntent,
  ReferrerCode as Referrer,
  ReferringOrganisationCode as OrganisationOfReferrer,
  RegisteredGPCode as GPAtTimeOfActivity,
  RegisteredGPPractice as GPPracticeAtTimeOfActivity,
  PostcodeAtTimeOfReferral as PostcodeAtTimeOfActivity,
  LHBofResidence as Commissioner,
  SourceOfReferral as ReferralSource,
  PriorityOnLetter,
  OutcomeOfReferral as Outcome,
  WaitingListDate as DateOnWaitingList,
  --LocalConsultantCode,
  --LocationCode as ActivityLocation,
  '' as SiteCode,       --HWL -commented out by kerry - ask Kerry delete from field table?
  CategoryOfPatient as PatientCategory,
  PrioritySetByConsultant as PriorityOfHCP,
  WhichListIsPatientOn as TreatmentType,
  BookedDate as DateBooked,
  ReasonBooked,
  FreeTextField_GPREFNO as GpRefNo,
  ClinicalCondition,
  ChargedTo as CommissionerType,
  --AttendanceDate,--same as booked date
  --DateDeferred,
  '' as DateOFAppointment,  --HWL -commented out by kerry - ask Kerry delete from field table?
  '' as DateDeferred,       --HWL -commented out by kerry - ask Kerry delete from field table?
  WaitingListSpecialty as Specialty,
  --WaitingListStatus,     --HWL -commented out by kerry - ask Kerry delete from field table?
  --ContractsAuthorised,   --HWL -commented out by kerry - ask Kerry delete from field table?
  FreeTextField as Comments,
  --AgeGroup,
  AgeInDays as AgeAtAttendance,
  --DateOfBirth,
  --Sex,
  --FullName,
  --Telephone_DayTime,
  --FullAddress,
  --Suspended,  --HWL -commented out by kerry - ask Kerry delete from field table?
  --PatientsGPPractice,
 -- PatientsGPPRacticeAddress,
  --SubSpecialtyNameTEXT,
 -- ConsultantNameTEXT,
  --LocationTEXT,
  --OriginalDiagnosisTEXT,--HWL -commented out by kerry - ask Kerry delete from field table?
  ExcludeFromPPO1W as ExcludeFromWLReporting,
  --MainSpecialtyNameTEXT,
  ACTNOTEKEY as Actnotekey,
  --PatientSurname,
  --PatientForename,
 -- PurchaserText,
  --FAXNO	,
  --DOC_REFERENCE_NO,
  UniquePatientIdendifier as UniquePathwayIdentifier,
  RTTStartDate as DateRTTStart,
  RTTStopDate as DateRTTStop,
  RTTLengthOfWait,
  RTTLengthOfWait_Adjusted as RTTLengthOfWaitAdjusted,
  RTTSpecialty,
  RTTACTNOTEKEYatStart as RTTActnotkeyAtStart,
  RTTExcludedSpecialtyFlag,
  PlannedDate as DatePlanned,
  RTTSourceAtStart,
  RTTTypeAtStart,
  RTTTargetDate as DateRTTTarget,
  RTTTargetDays,
  --RTTWeeks_Adjusted as RTTWeeksAdjusted,
  --RTTWeeks,
  --LengthOfWaitInWeeks,
  --APPT_DIR_DESC,
  RTT_Stage as RTTStage,
  AdjustedDays as RTTAdjustedDays, --- HWL ALL FIELDS BEYOND THIS ROW NOT IN FIELDS TABLE
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
  DateReferred,
  Coding as ProcedureProposed,
   '' as LastEventOutcome,
  WaitingListType,
  CensusDate as CensusDate,
  'East' as Area,
  'Myrddin' as Source
from @results




END







GO
