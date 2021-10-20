SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: July 2017
-- Description:	Extract of all Waiters
-- Amend Date:  15/4/2020  - HWL :Ensure extract loads into New WH - RunTime Approx 27m
--              03/06/20   - HWL :This script compiles and executes data but doesn't load direct into foundation
--                           Unable to Execute an execute
--              16/09/2020 - HWL X6 new fields in REF_WAIT_LEN_VIEW_ENH included     
-- =============================================


CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Central]
	
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
		c.thecode as Coding,
		''''DC'''' as WLTYPE,
		cast(''''Now'''' as Date),
		TT.TRT_TYPE as TRT_TYPE2, 
		ou.OUTCOME_CODE AS outcome_code2,
		CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as Last_Act_Type2,
		O3.OUTCOME_CODE as outcome_code3,
		m2.method as Intended_Admit_Method2
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''31'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
	    left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD

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
		c.thecode as Coding,
		''''IP'''' as WLTYPE,
		cast(''''Now'''' as Date),
        TT.TRT_TYPE as TRT_TYPE2, 
		ou.OUTCOME_CODE AS outcome_code2,
		CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as Last_Act_Type2,
		O3.OUTCOME_CODE as outcome_code3,
		m2.method as Intended_Admit_Method2
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''41'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
		left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD

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
		c.thecode as Coding,
		''''FU'''' as WLTYPE,
		cast(''''Now'''' as Date),
		TT.TRT_TYPE as TRT_TYPE2, 
		ou.OUTCOME_CODE AS outcome_code2,
		CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as Last_Act_Type2,
		O3.OUTCOME_CODE as outcome_code3,
		m2.method as Intended_Admit_Method2
		
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''FU'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
		left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD

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
		c.thecode as Coding,
		''''PP'''' as WLTYPE,
		cast(''''Now'''' as Date),
		TT.TRT_TYPE as TRT_TYPE2, 
		ou.OUTCOME_CODE AS outcome_code2,
		CASE WHEN TT.TRt_type is null  then OU.OUTCOME_CODE ELSE TT.TRt_type END as Last_Act_Type2,
		O3.OUTCOME_CODE as outcome_code3,
		m2.method as Intended_Admit_Method2
	
	from 
		REF_WAIT_LEN_VIEW_ENH (''''PP'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl
		left join Refer R on WL.LinkID = R.LINKID
		left join coding c on c.linkid = wl.linkid and((c.itemno=1) or (c.itemno is null)) and c.when_coded = ''''4''''
		left join padloc on wl.loc = padloc.loccode
		left join GP2 on r.cons = gp2.practice
		left join TRT_TYPE TT ON TT.trt_DESCRIPTION = wl.LAST_act_type 
        left join OUTCOME OU ON OU.DESCRIPT = wl.LAST_act_type
		left join OUTCOME O3 ON O3.DESCRIPT = wl.LAST_act_OUTCOME
		left join ADMITMTH m2 on m2.description = wl.INTENDED_ADMIT_METHOD

	'' 
)'


/*
21 = Outpatient Waiting List
31 = Daycases Waiting List
41 = Inpatients Waiting List
FU = Follow Up Waiting List 
PP = Pathway Patients 
*/

/*
declare @results table

(
   WaitStay						SMALLINT,		
  DaysWait						varchar(10),    --574
  NHSNumber						VARCHAR(17),	--575
  CaseNumber					VARCHAR(10),	--576
  Referraldate					DATE,			--577
  LinkID						VARCHAR(20),	--578
  ListType						VARCHAR(20),
  ReferralIntent				VARCHAR(1),		--580
  ReferrerCode					VARCHAR(8),		--581
  ReferringOrganisationCode		VARCHAR(6),		--582
  RegisteredGPCode				VARCHAR(8),		--584
  RegisteredGPPractice			VARCHAR(6),		--585
  PostcodeAtTimeOfReferral		VARCHAR(8),		--586
  LHBofResidence				VARCHAR(3),		--587
  SourceOfReferral				VARCHAR(2),		--588
  PriorityOnLetter				VARCHAR(1),		--589
  OutcomeOfReferral				VARCHAR(2),		--590
  WaitingListDate				DATE,			--591
  LocalConsultantCode			VARCHAR(5),		--3639  also healthcareprofessional field
  LocationCode				    VARCHAR(5),		--592   also sitecode field
  --SiteCode				    VARCHAR(5),		--592
  CategoryOfPatient				VARCHAR(2),		--593 - KR--this is a retired data item if looking on the data dictionary for details
  PrioritySetByConsultant		VARCHAR(1),		--594
  WhichListIsPatientOn			VARCHAR(2),		--595
  BookedDate					DATE,			--596
  ReasonBooked					VARCHAR(1),		--597
  FreeTextField_GPREFNO			VARCHAR(15),	--598
  ClinicalCondition				VARCHAR(10),	--599
  ChargedTo						CHAR(1),		--600
  AttendanceDate				DATE,			--601
  DateDeferred					DATE,			--602
  WaitingListSpecialty			VARCHAR(6),		--603
  --WaitingListSubSpecialty		VARCHAR(6),		
  WaitingListStatus				VARCHAR(2),		--605
  ContractsAuthorised			SMALLINT,		--607
  FreeTextField					VARCHAR(max),	--608
  AgeGroup						VARCHAR(1),
  AgeInDays						INTEGER,		--610
  DateOfBirth					DATE,
  Sex							VARCHAR(1),
  FullName						VARCHAR(80),
  Telephone_DayTime				VARCHAR(100),
  FullAddress					VARCHAR(150),
  Suspended						INTEGER,		--612
  PatientsGPPractice			VARCHAR(6),		--585 RegisteredGPPractice
  PatientsGPPRacticeAddress		VARCHAR(100),
  SubSpecialtyNameTEXT			VARCHAR(30),
  ConsultantNameTEXT			VARCHAR(35),
  LocationTEXT					VARCHAR(100),
  OriginalDiagnosisTEXT			VARCHAR(70),		--613
  ExcludeFromPPO1W				VARCHAR(1),			--614
  MainSpecialtyNameTEXT			VARCHAR(30),		
  ACTNOTEKEY					INTEGER,			--615
  PatientSurname				VARCHAR(40),
  PatientForename				VARCHAR(40),
  PurchaserText					VARCHAR(30),
  FAXNO							VARCHAR(20),
  DOC_REFERENCE_NO				VARCHAR(20),		--6145
  UniquePatientIdendifier		VARCHAR(20),		--616
  RTTStartDate					DATE,				--617
  RTTStopDate					DATE,				--618
  RTTLengthOfWait				INTEGER,			--619
  RTTLengthOfWait_Adjusted		INTEGER,			--620
  RTTSpecialty					VARCHAR(6),			--621
  RTTACTNOTEKEYatStart			INTEGER,			--622
  RTTExcludedSpecialtyFlag		VARCHAR(1),			--623
  PlannedDate					DATE,				--624
  RTTSourceAtStart				VARCHAR(2),			--625
  RTTTypeAtStart				VARCHAR(2),			--626
  RTTTargetDate					DATE,				--627
  RTTTargetDays					INTEGER,			--629
  RTTWeeks_Adjusted				INTEGER,
  RTTWeeks						INTEGER,
  LengthOfWaitInWeeks			INTEGER,
  APPT_DIR_DESC					VARCHAR(100),		--6127
  RTT_Stage						VARCHAR(2),			--633
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
  LAST_EVENT_LOCALITY			varchar(6),  		--not on the myrddin version of the SP
  FU_ACTNOTEKEY					int,				--not on the myrddin version of the SP
  FU_TO_COME_IN_DATE			date,				--not on the myrddin version of the SP
  THEATRE_TYPE					varchar(40),		--not on the myrddin version of the SP
  ANAESTHETIC_TYPE				varchar(30),		--not on the myrddin version of the SP
  PLANNED_ASA_GRADE				varchar(20),		--not on the myrddin version of the SP
  INTENDED_ADMIT_METHOD			varchar(50),		--not on the myrddin version of the SP
  TARGET_DATE                   date,
  HEALTH_RISK_FACTOR            varchar(3),
  WEIGHTED_PR_F                 varchar(3),
  PERCENTAGE_OVERRUN            INTEGER,
  ARMED_SERVICES_KEYNOTE        varchar(800),  -- HWL - to this point fileds matches REF_WAIT_LEN_VIEW_ENH
  HealthCareProfessional		varchar(8),			--3639
  SiteCode					    varchar(5),			--592
  TheatreType					varchar(10),
  AnaesType						varchar(10),		--3647
  BookedWard					varchar(10),		--3643
  DateOnSystem					DATE,	
  DateReferred					DATE,
   Coding						varchar(8),
  --LastEventOutcome			varchar(2),
  WaitingListType				varchar(2),
  CensusDate					Date				--3642
  --Area                          varchar(10),		--6104
  --Source                        varchar(10)		--6106

*/

declare @results table

(
  WaitStay						SMALLINT,		
  DaysWait						varchar(10),    --574
  NHSNumber						VARCHAR(17),	--575
  CaseNumber					VARCHAR(10),	--576
  Referraldate					DATE,			--577
  LinkID						VARCHAR(20),	--578
  ListType						VARCHAR(20),
  ReferralIntent				VARCHAR(1),		--580
  ReferrerCode					VARCHAR(8),		--581
  ReferringOrganisationCode		VARCHAR(6),		--582
  RegisteredGPCode				VARCHAR(8),		--584
  RegisteredGPPractice			VARCHAR(6),		--585
  PostcodeAtTimeOfReferral		VARCHAR(8),		--586
  LHBofResidence				VARCHAR(3),		--587
  SourceOfReferral				VARCHAR(2),		--588
  PriorityOnLetter				VARCHAR(1),		--589
  OutcomeOfReferral				VARCHAR(2),		--590
  WaitingListDate				DATE,			--591
  LocalConsultantCode			VARCHAR(5),		--3639  also healthcareprofessional field
  LocationCode				    VARCHAR(5),		--592   also sitecode field
  CategoryOfPatient				VARCHAR(2),		--593 - KR--this is a retired data item if looking on the data dictionary for details
  PrioritySetByConsultant		VARCHAR(1),		--594
  WhichListIsPatientOn			VARCHAR(2),		--595
  BookedDate					DATE,			--596
  ReasonBooked					VARCHAR(1),		--597
  FreeTextField_GPREFNO			VARCHAR(20),	--598
  ClinicalCondition				VARCHAR(10),	--599
  ChargedTo						VARCHAR(1),		--600
  AttendanceDate				DATE,			--601
  DateDeferred					DATE,			--602
  WaitingListSpecialty			VARCHAR(6),		--603
  WaitingListStatus				VARCHAR(2),		--605
  ContractsAuthorised			SMALLINT,		--607
  FreeTextField					VARCHAR(max),	--608
  AgeGroup						VARCHAR(1),
  AgeInDays						INTEGER,		--610
  DateOfBirth					DATE,
  Sex							VARCHAR(1),
  FullName						VARCHAR(80),
  Telephone_DayTime				VARCHAR(100),
  FullAddress					VARCHAR(200),
  Suspended						INTEGER,		--612
  PatientsGPPractice			VARCHAR(6),		--585 RegisteredGPPractice
  PatientsGPPRacticeAddress		VARCHAR(200),
  SubSpecialtyNameTEXT			VARCHAR(30),
  ConsultantNameTEXT			VARCHAR(35),
  LocationTEXT					VARCHAR(200),
  OriginalDiagnosisTEXT			VARCHAR(100),		--613
  ExcludeFromPPO1W				VARCHAR(1),			--614
  MainSpecialtyNameTEXT			VARCHAR(30),		
  ACTNOTEKEY					INTEGER,			--615
  PatientSurname				VARCHAR(40),
  PatientForename				VARCHAR(40),
  PurchaserText					VARCHAR(30),
  FAXNO							VARCHAR(20),
  DOC_REFERENCE_NO				VARCHAR(20),		-- 6145
  UniquePatientIdendifier		VARCHAR(20),		--616
  RTTStartDate					DATE,				--617
  RTTStopDate					DATE,				--618
  RTTLengthOfWait				INTEGER,			--619
  RTTLengthOfWait_Adjusted		INTEGER,			--620
  RTTSpecialty					VARCHAR(6),			--621
  RTTACTNOTEKEYatStart			INTEGER,			--622
  RTTExcludedSpecialtyFlag		VARCHAR(1),			--623
  PlannedDate					DATE,				--624
  RTTSourceAtStart				VARCHAR(2),			--625
  RTTTypeAtStart				VARCHAR(2),			--626
  RTTTargetDate					DATE,				--627
  RTTTargetDays					INTEGER,			--629
  RTTWeeks_Adjusted				INTEGER,
  RTTWeeks						INTEGER,
  LengthOfWaitInWeeks			INTEGER,
  APPT_DIR_DESC					VARCHAR(100),		--6127
  RTT_Stage						VARCHAR(2),			--633
  AdjustedDays					INTEGER,			--6128
  OTHER_INFO					VARbinary(max),    -- HWL:Leave as Max-field from MasterTreat table
  ClinicNameText				VARCHAR(max),      
  ClinicSessionKey				INTEGER,		   -- 6129
  NEXT_APPT_DATE				DATE,			   -- 6130
  NEXT_APPT_SESSION_NAME		VARCHAR(355),
  PREFERRED_LOCATION_TEXT		VARCHAR(100),
  DISCHARGE_DATE				Date,				      --not on the myrddin version of the SP
  NEXT_APPT_NEEDED				VARCHAR(max),		      --not on the myrddin version of the SP
  LAST_EVENT_DATE				Date,				--6131--not on the myrddin version of the SP
  LAST_EVENT_CODE				VARCHAR(4),			--6132--not on the myrddin version of the SP
  LAST_EVENT_DESCRIPTION		VARCHAR(200),		      --not on the myrddin version of the SP
  LAST_EVENT_CONS				VARCHAR(8),			--6133--not on the myrddin version of the SP
  LAST_EVENT_SPEC				VARCHAR(6),			--6134--not on the myrddin version of the SP
  LAST_EVENT_ALLNAME			VARCHAR(200),		      --not on the myrddin version of the SP
  LAST_EVENT_SPECIALTY_NAME		VARCHAR(200),		      --not on the myrddin version of the SP
  LAST_ACT_OUTCOME				varchar(200),		--6136--not on the myrddin version of the SP
  LAST_ACT_TYPE					varchar(200),		--6137--not on the myrddin version of the SP  
  LAST_EVENT_LOC				varchar(6),			--6138--not on the myrddin version of the SP
  LAST_EVENT_LOC_DESCRIPTION	VARCHAR(200),		      --not on the myrddin version of the SP
  LAST_EVENT_LOCALITY			varchar(50),  		      --not on the myrddin version of the SP
  FU_ACTNOTEKEY					int,				--6139--not on the myrddin version of the SP
  FU_TO_COME_IN_DATE			date,				--6140--not on the myrddin version of the SP
  THEATRE_TYPE					varchar(50),		--6123--not on the myrddin version of the SP
  ANAESTHETIC_TYPE				varchar(30),		--3647--not on the myrddin version of the SP
  PLANNED_ASA_GRADE				varchar(20),		--6141--not on the myrddin version of the SP
  INTENDED_ADMIT_METHOD			varchar(50),		--6143--not on the myrddin version of the SP
  TARGET_DATE                   date,				--3640
  HEALTH_RISK_FACTOR            varchar(3),			--6117
  WEIGHTED_PR_F                 varchar(3),			--6118
  PERCENTAGE_OVERRUN            INTEGER,            --6120 --will this work ok? - percentage???
  ARMED_SERVICES_KEYNOTE        varchar(800),       --6121 
  VIRTUAL_TYPE                  varchar(2),
  CONSULT_METHOD                varchar(1),
  PREVIOUS_VIRTUAL_TYPE         varchar(2),
  PREVIOUS_CONSULT_METHOD       varchar(1),
  PREF_VIRTUAL_TYPE             varchar(2),
  PREF_CONSULT_METHOD           varchar(1),
  HealthCareProfessional		varchar(8),			--3639
  SiteCode					    varchar(5),			--592
  TheatreType					varchar(10),        --6123
  AnaesType						varchar(10),		--3647
  BookedWard					varchar(10),		--3643
  DateOnSystem					DATE,				--6124
  ClinicalReferralDate          DATE,
  Coding						varchar(8),			--6126
  WaitingListType				varchar(2),			--6144
  CensusDate					Date,				--3642
  TRT_TYPE2                     varchar(2),
  outcome_code2                 varchar(2),
  Last_Act_Type2                varchar(2),
  outcome_code3                 varchar(2),
  Intended_Admit_Method2        varchar(2)
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
  FAXNO,
  DOC_REFERENCE_NO,
  UniquePatientIdendifier,
  RTTStartDate,
  RTTStopDate,
  RTTLengthOfWait,
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
  LAST_ACT_TYPE,					
  LAST_EVENT_LOC,				
  LAST_EVENT_LOC_DESCRIPTION,	
  LAST_EVENT_LOCALITY,			
  FU_ACTNOTEKEY,					
  FU_TO_COME_IN_DATE,			
  THEATRE_TYPE,					
  ANAESTHETIC_TYPE,				
  PLANNED_ASA_GRADE,			
  INTENDED_ADMIT_METHOD,	
  TARGET_DATE,                  
  HEALTH_RISK_FACTOR,            
  WEIGHTED_PR_F,                
  PERCENTAGE_OVERRUN,            
  ARMED_SERVICES_KEYNOTE, 
  VIRTUAL_TYPE,
  CONSULT_METHOD,
  PREVIOUS_VIRTUAL_TYPE,
  PREVIOUS_CONSULT_METHOD,
  PREF_VIRTUAL_TYPE,
  PREF_CONSULT_METHOD,
  HealthCareProfessional,
  SiteCode,			
  TheatreType,
  AnaesType,
  BookedWard,
  DateOnSystem,
  ClinicalReferralDate,
  Coding,
  WaitingListType,
  CensusDate,
  TRT_TYPE2, 
  outcome_code2,
  Last_Act_Type2,
  outcome_code3,
  Intended_Admit_Method2 
        
)
exec (@sql)



-----------------------------------------------------------------------------
-- Get Data for Loading into New Warehouse - Format as for Dataset=30
-----------------------------------------------------------------------------
select 
  DaysWait,
  NHSNumber,
  CaseNumber as LocalPatientIdentifier,
  ReferralDate as DateReferred,
  LinkID as SystemLinkID,
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
  LocationCode as LocationCode,
  CategoryOfPatient as PatientCategory,
  PrioritySetByConsultant as PriorityOfHCP,
  WhichListIsPatientOn as TreatmentType,
  BookedDate as DateBooked,
  ReasonBooked,
  FreeTextField_GPREFNO as GPRefNo,
  ClinicalCondition,
  ChargedTo as CommissionerType,
  AttendanceDate as DateOfAppointment,      --same as booked date
  DateDeferred as DateDeferred,
  WaitingListSpecialty as Specialty,
  WaitingListStatus as ListStatus,     
  ContractsAuthorised,  
  FreeTextField as Comments,
  AgeInDays as AgeAtAttendance,
  Suspended,  
  OriginalDiagnosisTEXT as OriginalDiagnosis,
  ExcludeFromPPO1W as ExcludeFromWLReporting,
  ACTNOTEKEY as ActNoteKey,
  UniquePatientIdendifier as UniquePathwayIdentifier,
  RTTStartDate as DateRTTStart,
  RTTStopDate as DateRTTStop,
  RTTLengthOfWait,
  RTTLengthOfWait_Adjusted as RTTLengthOfWaitAdjusted,
  RTTSpecialty,
  RTTACTNOTEKEYatStart as RTTActNotekeyAtStart,
  RTTExcludedSpecialtyFlag,
  PlannedDate as DatePlanned,
  RTTSourceAtStart,
  RTTTypeAtStart,
  RTTTargetDate as DateRTTTarget,
  RTTTargetDays,
  RTT_Stage as RTTStage,
'' as DateOfLastDNAOrPatientCancelled,
'' as CommentsFromWaitingList,
'' as WaitingListRefNo,
'' as ScheduleRefNo,
'' as ReferralRefNo,
Coding as ProcedureIntended,
'' as ProcedureProposed,
HealthCareProfessional as HCP,        ---LOCAL CODE IN CONS FIELD - LOCAL REQUIRED NOT THIS ONE?
TARGET_DATE as DateOfOriginalTarget,
CensusDate as DateWaitingListCensus,
BookedWard as BookedWardOrClinicCode,
'' as CommentsOfReferral,
'' as TimeEstimatedInTheatre,
AnaesType as AnaestheticType,
'' as ServiceType,
'Centre' as Area,
'Wpas' as Source,
HEALTH_RISK_FACTOR as HealthRiskFactor,
WEIGHTED_PR_F as WeightedPRF,
PERCENTAGE_OVERRUN as PercentageOverRun,
ARMED_SERVICES_KEYNOTE ArmedServicesKeyNote,
SiteCode,
TheatreType,
DateOnSystem as DateOnSystem,
Coding,
APPT_DIR_DESC as ApptDirDesc,				-- for Outpatients leave in
AdjustedDays as DaysAdjusted, 
ClinicSessionKey,
NEXT_APPT_DATE as DateNextAppointment,
LAST_EVENT_DATE as DateLastEvent,
LAST_EVENT_CODE as LastEventCode,
LAST_EVENT_CONS as HCPLastEvent,
LAST_EVENT_SPEC as SpecialtyLastEvent,
OUTCOME_CODE3 as LastActOutcome,
LAST_ACT_TYPE2 as LastActType,
LAST_EVENT_LOC as LastEventLoc,
FU_ACTNOTEKEY as FUActNotekey,
FU_TO_COME_IN_DATE as DateFUToComeIn,
PLANNED_ASA_GRADE as PlannedASAGrade,
INTENDED_ADMIT_METHOD2 as IntendedAdmitMethod,
WaitingListType,				 -- ListType also in data
DOC_REFERENCE_NO as DocReferenceNo,
VIRTUAL_TYPE as VirtualTpe,
CONSULT_METHOD as ConsultMethod,
PREVIOUS_VIRTUAL_TYPE as PreviousVirtualType,
PREVIOUS_CONSULT_METHOD as PreviousConsultMethod,
PREF_VIRTUAL_TYPE as PrefVirtualType,
PREF_CONSULT_METHOD as PrefConsultMethod

from @results


END

---EXEC(' Select * from REF_WAIT_LEN_VIEW_ENH (''21'', ''26 MAY 2020'' ,'''','''','''','''') ') AT [WPAS_Central] 
--

SELECT * FROM @results
GO
GRANT VIEW DEFINITION ON  [dbo].[Get_PAS_Data_Waiters_Central] TO [CYMRU\He105872]
GO
