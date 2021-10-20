SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: May 2020
-- Description:	Extract of all Outpatient Data
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatients_Central]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	--DECLARE @LastTreatmentDate AS DATE = '20 september 2020'
	
		DECLARE @LastTreatmentDate AS DATE = (SELECT ISNULL(MAX(DateOfAppointment),'1 September 2020') FROM [Foundation].[dbo].[PAS_Data_Outpatients] WHERE Source ='WPAS' )
  --DECLARE @LastTreatmentDate AS DATE = DATEADD(dd,-365,getdate())
	DECLARE @LastTreatmentDateString AS VARCHAR(30) = DATENAME(DAY,@LastTreatmentDate) + ' ' + DATENAME(MONTH,@LastTreatmentDate) + ' ' + DATENAME(YEAR,@LastTreatmentDate)

	--select @LastTreatmentDateString, @EndDate

		EXEC('SELECT distinct 
			
			nullif(rtrim(T.NHS), '''') AS NHSNumber,
			nullif(rtrim(T.CASENO), '''') AS LocalPatientIdentifier,

			extract(YEAR from T.TRT_DATE)||''-''||extract(month from T.TRT_DATE)||''-''||extract(DAY from T.TRT_DATE) as DateOfAppointment,

			CASE
				WHEN T.APPOINTMENT_TIME IS NULL THEN NULL
				WHEN TRIM(T.APPOINTMENT_TIME)='':'' THEN null
				WHEN TRIM(T.APPOINTMENT_TIME)='''' THEN null
				WHEN TRIM(T.APPOINTMENT_TIME)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
			END AS TimeOfAppointment,

			nullif(rtrim(T.LINKID), '''') AS SystemLinkId,
			nullif(rtrim(T.TRT_TYPE), '''') AS TreatmentType,
			nullif(rtrim(T.TRT_INTENT), '''') AS IntendedManagement,
			nullif(rtrim(R.Cons_Prty), '''') AS PriorityOfHCP,
			nullif(rtrim(T.ACONS), '''')  AS HCPatAppointment, 
			nullif(rtrim(T.Aloc), '''') as LocationOfAppointment, 
			nullif(rtrim(T.Source), '''') as TypeOfAppointment, 
			nullif(rtrim(t.Outcome), '''') as OutcomeOfAppointment, 
			nullif(rtrim(T.GP_Trt), '''') as Referrer, 
			nullif(rtrim(T.GP_Prac), '''') as ReferringOrganisation, 
			nullif(rtrim(t.REG_GP), '''') as GPAtTimeOfActivity, 
			nullif(rtrim(t.reg_prac), '''') as GPPracticeAtTimeOfActivity, 

			CASE STRLEN(t.postcode)
			WHEN 6 THEN
				CASE
					WHEN SUBSTRING(T.POSTCODE FROM 3 FOR 1)='' '' THEN SUBSTRING(T.POSTCODE FROM 1 FOR 2)||SUBSTRING(T.POSTCODE FROM 4 FOR 3)
					ELSE T.POSTCODE
					END
			WHEN 7 THEN
				CASE 
					WHEN SUBSTRING(T.POSTCODE FROM 4 FOR 1)='' '' THEN SUBSTRING(T.POSTCODE FROM 1 FOR 3)||SUBSTRING(T.POSTCODE FROM 5 FOR 3)
					ELSE T.POSTCODE
					END
			WHEN 8 THEN
				CASE 
					WHEN SUBSTRING(T.POSTCODE FROM 5 FOR 1)='' '' THEN SUBSTRING(T.POSTCODE FROM 1 FOR 4)||SUBSTRING(T.POSTCODE FROM 6 FOR 3)
					ELSE T.POSTCODE
					END
			ELSE T.POSTCODE
			END as PostcodeAtTimeOfActivity,

			nullif(rtrim(t.dha_code), '''') as LHBOfResidence,
			nullif(rtrim(t.category), '''') as PatientCategory,
			nullif(rtrim(t.charged_to), '''') as CommissionerType, 

			--cost this field is null for all O records 10/06/2020

			nullif(rtrim(t.gprefno), '''') as GPRefNoOnTreatment,

			--Admit_method this field is null for all O records 10/06/2020
			--nullif(rtrim(t.ccons), '''') as HCPatActivity,  --this is the same as acons, paul and claire confirm they use acons
			--nullif(rtrim(t.cloc), '''') as LocationOfActivity, --this is the same as aloc, paul and claire confirm they use acons


			--extract(YEAR from t.disdate)||''-''||extract(month from t.disdate)||''-''||extract(DAY from t.disdate) as PathwayDischargeDate,
			--nullif(rtrim(t.dismethod), '''') as PathwayDischargeMethod, -- No Data
			--nullif(rtrim(t.destination), '''') as PathwayDischargeDestination, -- No Data
			--nullif(rtrim(t.hosp_dest), '''') as PathwaySiteDischargedTo,  --No Data

			--Extract_modified unsure what use this field would be to anyone 10/06/2020
			--Transferred this is related to the IP record 10/06/2020


			nullif(rtrim(t.opclinicno), '''') as ClinicNumber,


			CASE
				WHEN T.TRT_TIME IS NULL THEN NULL
				WHEN TRIM(T.TRT_TIME)='':'' THEN null
				WHEN TRIM(T.TRT_TIME)='''' THEN null
				WHEN TRIM(T.TRT_TIME)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(T.TRT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.TRT_TIME FROM 3 FOR 2) 
			END AS TimeOfTreatment,



			CASE
				WHEN T.Leaving_TIME IS NULL THEN NULL
				WHEN TRIM(T.Leaving_TIME)='':'' THEN null
				WHEN TRIM(T.Leaving_TIME)='''' THEN null
				WHEN TRIM(T.Leaving_TIME)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(T.leaving_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.Leaving_TIME FROM 3 FOR 2) 
			END AS TimeLeftAppointment,

			nullif(rtrim(t.staff_grade), '''') as staffgrade,

			--Transport this field is null for all O records 10/06/2020

			nullif(rtrim(t.Reason_DNA), '''') as ReasonForDNA,

			--Services_On_Disch this field is null for all O records 10/06/2020
			--Provider_Spell_no this field is null for all O records 10/06/2020

			nullif(rtrim(T.ASPEC), '''') as SpecialtyOfAppointment,

			--nullif(rtrim(T.CSPEC), '''') as SpecialtyOfActivity,  --this is the same as aspec, paul and claire confirm they use acons
			 --notes_ready this field is null for all O records 10/06/2020
			 --OPClinician this field is null for all O records 10/06/2020

			CASE
				WHEN T.time_cons_ready IS NULL THEN NULL
				WHEN TRIM(T.time_cons_ready)='':'' THEN null
				WHEN TRIM(T.time_cons_ready)='''' THEN null
				WHEN TRIM(T.time_cons_ready)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(T.time_cons_ready FROM 1 FOR 2)||'':''||SUBSTRING(T.time_cons_ready FROM 3 FOR 2) 
			END AS TimeHCPReady,

			--Myrddin this field is null for all O records 10/06/2020

			nullif(rtrim(t.purchaser), '''') as Commissioner,
			nullif(rtrim(T.REAL_MANAGEMENT), '''') AS PatientClassification,
			nullif(rtrim(T.SLOTKEY), '''') AS ClinicSlotKey,
			
			--SSERVERDEATHREG this field is null for all O records 10/06/2020
			
			extract(YEAR from t.next_approx_appt)||''-''||extract(month from t.next_approx_appt)||''-''||extract(DAY from t.next_approx_appt) as DateOfNextAppoximnateAppointment,
			extract(YEAR from t.create_date)||''-''||extract(month from t.Create_Date)||''-''||extract(DAY from t.Create_Date) as DateAppointmentCreated,
			
			--Create_User do we need to know who created the activity?
			
			extract(YEAR from t.last_modify_date)||''-''||extract(month from t.last_modify_date)||''-''||extract(DAY from t.last_modify_date) as DateActivityLastModified,
			
			--Last_Modify_User do we need to know who modified the activity?
			--Doc_reference_no  
			--Doc_Ref_next
		
			nullif(rtrim(T.next_appt_needed), '''') as IsNextAppointmentNeeded,
			nullif(rtrim(T.next_appt_freq), '''') as NextAppointmentDue,
			nullif(rtrim(T.next_appt_cons), '''') as HCPOfNextAppointment,
			
			nullif(rtrim(T.confirm_appt), '''') as AppointmentConfirmed,

			--sendccl

			CAST(SUBSTRING(T.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) AS OtherInformation,
			nullif(rtrim(T.next_appt_loc), '''') as LocationOfNextAppointment,
			nullif(rtrim(T.ACTNOTEKEY), '''') AS Actnotekey,

			--pam_assess

			nullif(rtrim(t.Outcome_Reason), '''')  as OutcomeReason,
			nullif(rtrim(T.ignore_for_FU_PB), '''') AS IgnorePartialBooking,

			--Confirm_Letter_Override
			--letter_status
			--appt_locked

			nullif(rtrim(T.appt_directive), '''') AS AppointmentDirective,
			nullif(rtrim(T.future_appt_directive), '''') AS FutureAppointmentDirective,

			--est_disdate
			--hosp_source
			--sync_date

			extract(YEAR from t.date_notified)||''-''||extract(month from t.date_notified)||''-''||extract(DAY from t.date_notified)  as DateNotified,

			--basecase

			nullif(rtrim(t.Clinic_Code), '''') as ClinicCode,

			nullif(rtrim(t.next_appt_pref_clinic), '''') as NextAppointmentPreferredClinic,
			nullif(rtrim(t.next_Clin_con), '''') as HCPAtNextAppointment,

			nullif(rtrim(t.Appt_Type), '''') as AppointmentType,
			nullif(rtrim(t.Rott_Reason), '''') as ReasonForRemoval,

			--OverrideDefaultDNALetter
			--OverrideDNALetter

			extract(YEAR from t.next_appt_trt_date)||''-''||extract(month from t.next_appt_trt_date)||''-''||extract(DAY from t.next_appt_trt_date)  as DateOfnextappointment,
			nullif(rtrim(t.next_appt_actnotekey), '''') as nextAppointmentActNoteKey,
			nullif(rtrim(t.Current_health_risk_factor), '''') as HealthRiskFactor,
			nullif(rtrim(t.next_health_risk_Factor), '''') as NextHealthRiskFactor,

			--planned_op_complete
		
			extract(YEAR from P.Event_Date)||''-''||extract(month from P.Event_Date)||''-''||extract(DAY from P.Event_Date) as PathwayEventDate,
			nullif(rtrim(P.Event_Type), '''') as PathwayEventType,
			nullif(rtrim(P.UPI), '''') as PathwayUPI,
			nullif(rtrim(P.Event_Source), '''') as PathwayEventSource,
			nullif(rtrim(P.pwaykey), '''') as PathwayKey,

			extract(YEAR from P.create_Date)||''-''||extract(month from P.create_Date)||''-''||extract(DAY from P.create_Date) as PathwayCreateDate,
			extract(YEAR from P.Update_Date)||''-''||extract(month from P.Update_Date)||''-''||extract(DAY from P.Update_Date) as PathwayModifyDate,
			

			''Central'' as Area,
			''WPAS'' AS Source,


			extract(YEAR from R.DAT_REF)||''-''||extract(month from R.DAT_REF)||''-''||extract(DAY from R.DAT_REF) as DateReferred,
			extract(YEAR from R.Clin_Ref_Date)||''-''||extract(month from R.Clin_Ref_Date)||''-''||extract(DAY from R.Clin_Ref_Date) as DateClinicallyReferred,
			extract(YEAR from R.Datonsys)||''-''||extract(month from R.Datonsys)||''-''||extract(DAY from R.Datonsys) as DateOnSystem,
			nullif(rtrim(R.SPEC), '''') AS SpecialtyOnreferral,
			nullif(rtrim(R.Source_refer), '''') as SourceOfReferral,
			nullif(rtrim(R.Clinical_Condition), '''') as ClinicalCondition,
			CAST(SUBSTRING(R.FText FROM 1 FOR 8000) AS VARCHAR(8000)) as NotesOnReferral,
			nullif(rtrim(R.GPRefNo), '''') as GPRefNoOnReferral,

							
			nullif(rtrim(SE.scheduleID), '''') as ClinicScheduleID,
			nullif(rtrim(SE.SESSIONTYPE), '''') AS ClinicSessionType,
			nullif(rtrim(SE.LOCATION), '''') AS ClinicSessionLocation,
		

		--null as ReferralLinkId, -- added into the foundation table as a computed field
		--null as OutpatientLinkId,-- added into the foundation table as a computed field
		--null as InpatientLinkId,-- added into the foundation table as a computed field
		--null as patientlinkid,-- added into the foundation table as a computed field


		nullif(rtrim(OPCODING.THECODE), '''') AS Procedure1,
		nullif(rtrim(OPCODING2.THECODE), '''') AS Procedure2,
		nullif(rtrim(OPCODING3.THECODE), '''') AS Procedure3,
		nullif(rtrim(OPCODING4.THECODE), '''') AS Procedure4,
		nullif(rtrim(OPCODING5.THECODE), '''') AS Procedure5,
		nullif(rtrim(OPCODING6.THECODE), '''') AS Procedure6,
		nullif(rtrim(OPCODING7.THECODE), '''') AS Procedure7,
		nullif(rtrim(OPCODING8.THECODE), '''') AS Procedure8,
		nullif(rtrim(OPCODING9.THECODE), '''') AS Procedure9,
		nullif(rtrim(OPCODING10.THECODE), '''') AS Procedure10,
		nullif(rtrim(OPCODING11.THECODE), '''') AS Procedure11,
		nullif(rtrim(OPCODING12.THECODE), '''') AS Procedure12,


		CAST(SUBSTRING(T2.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) as OtherInformationPrevious,
		nullif(rtrim(T2.ActNotekey), '''') AS ActNoteKeyPrevious ,

		extract(YEAR from T2.Trt_Date)||''-''||extract(month from T2.Trt_Date)||''-''||extract(DAY from T2.Trt_Date) as DateOfLastAppointment ,
		nullif(rtrim(T2.GPRefNo), '''') AS GPRefNoPrevious,


	
		CASE	WHEN T.DATE_NOTIFIED IS NULL THEN NULL 
				ELSE DATEDIFF(day, T.DATE_NOTIFIED, T.TRT_DATE) END AS DaysNotifedBeforeAppointment,
		
		extract(YEAR from t.PIFU_Date)||''-''||extract(month from t.PIFU_Date)||''-''||extract(DAY from t.PIFU_Date) as DatePatientInitiatedFollowUp,
		nullif(rtrim(t.Consult_Method), '''') as ConsultationMethod,
		nullif(rtrim(t.Virtual_Type), '''') as VirtualContactType,
		nullif(rtrim(t.Next_Consult_Method), '''') as NextConsultationMethod,
		nullif(rtrim(t.Next_Virtual_Type), '''') as NextVirtualContactType,

		CAST(SUBSTRING(t.Virtual_contact_details FROM 1 FOR 8000) AS VARCHAR(8000)) as ContactDetailsForVirtualAppointment,
		nullif(rtrim(t.Unsuccess_Attempt_one), '''') as UnsuccessfulAttemptToContactPatient1,
		nullif(rtrim(t.Unsuccess_Attempt_two), '''') as UnsuccessfulAttemptToContactPatient2,

		
			CASE
				WHEN T.Arrival_TIME IS NULL THEN NULL
				WHEN TRIM(T.Arrival_TIME)='':'' THEN null
				WHEN TRIM(T.Arrival_TIME)='''' THEN null
				WHEN TRIM(T.Arrival_TIME)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(T.Arrival_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.Arrival_TIME FROM 3 FOR 2) 
			END AS TimeArrivedAtAppointment,

			nullif(rtrim(T.next_appt_Spec), '''') as SpecialtyOfNextAppointment
			
		FROM
			TREATMNT T
			LEFT JOIN REFER R ON T.LINKID = R.LINKID
		
		 LEFT OUTER JOIN PATHWAYMGT P ON 
						(P.ACTNOTEKEY = T.ACTNOTEKEY)
                   AND (COALESCE(P.EVENT_SOURCE,''MO'') = ''MO'' 
                   AND P.PWAYKEY = (SELECT FIRST 1 PATH2.PWAYKEY
                         FROM PATHWAYMGT PATH2
                         WHERE PATH2.ACTNOTEKEY = T.ACTNOTEKEY
                         AND COALESCE(PATH2.EVENT_SOURCE,''MO'')=''MO'' ))

			
			LEFT JOIN SESSIONS SE ON T.OPCLINICNO = SE.SESSIONKEY
			

		LEFT JOIN OPCODING ON			(TREATMNT.LINKID = OPCODING.LINKID AND TREATMNT.TRT_DATE = OPCODING.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING.APPOINTMENT_TIME AND OPCODING.ITEMNO = 1 and OPCODING.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING2 ON (TREATMNT.LINKID = OPCODING2.LINKID AND TREATMNT.TRT_DATE = OPCODING2.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING2.APPOINTMENT_TIME AND OPCODING2.ITEMNO = 2 and OPCODING2.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING3 ON (TREATMNT.LINKID = OPCODING3.LINKID AND TREATMNT.TRT_DATE = OPCODING3.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING3.APPOINTMENT_TIME AND OPCODING3.ITEMNO = 3 and OPCODING3.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING4 ON (TREATMNT.LINKID = OPCODING4.LINKID AND TREATMNT.TRT_DATE = OPCODING4.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING4.APPOINTMENT_TIME AND OPCODING4.ITEMNO = 4 and OPCODING4.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING5 ON (TREATMNT.LINKID = OPCODING5.LINKID AND TREATMNT.TRT_DATE = OPCODING5.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING5.APPOINTMENT_TIME AND OPCODING5.ITEMNO = 5 and OPCODING5.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING6 ON (TREATMNT.LINKID = OPCODING6.LINKID AND TREATMNT.TRT_DATE = OPCODING6.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING6.APPOINTMENT_TIME AND OPCODING6.ITEMNO = 6 and OPCODING6.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING7 ON (TREATMNT.LINKID = OPCODING7.LINKID AND TREATMNT.TRT_DATE = OPCODING7.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING7.APPOINTMENT_TIME AND OPCODING7.ITEMNO = 7 and OPCODING7.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING8 ON (TREATMNT.LINKID = OPCODING8.LINKID AND TREATMNT.TRT_DATE = OPCODING8.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING8.APPOINTMENT_TIME AND OPCODING8.ITEMNO = 8 and OPCODING8.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING9 ON (TREATMNT.LINKID = OPCODING9.LINKID AND TREATMNT.TRT_DATE = OPCODING9.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING9.APPOINTMENT_TIME AND OPCODING9.ITEMNO = 9 and OPCODING9.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING10 ON (TREATMNT.LINKID = OPCODING10.LINKID AND TREATMNT.TRT_DATE = OPCODING10.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING10.APPOINTMENT_TIME AND OPCODING10.ITEMNO = 10 and OPCODING10.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING11 ON (TREATMNT.LINKID = OPCODING11.LINKID AND TREATMNT.TRT_DATE = OPCODING11.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING11.APPOINTMENT_TIME AND OPCODING11.ITEMNO = 11 and OPCODING11.CODE_TYPE = ''OP'')
		LEFT JOIN OPCODING OPCODING12 ON (TREATMNT.LINKID = OPCODING12.LINKID AND TREATMNT.TRT_DATE = OPCODING12.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING12.APPOINTMENT_TIME AND OPCODING12.ITEMNO = 12 and OPCODING12.CODE_TYPE = ''OP'')
		
		LEFT JOIN TREATMNT T2 ON T2.CASENO = T.CASENO AND T2.LINKID = T.LINKID  AND T2.ACTNOTEKEY = 
													(SELECT FIRST 1 TRT3.ACTNOTEKEY
                                       FROM TREATMNT TRT3
                                       WHERE TRT3.LINKID = T.LINKID
                                       AND TRT3.CASENO = T.CASENO 
                                       AND TRT3.ACTNOTEKEY <> T.actnotekey
                                       AND TRT3.TRT_DATE < T.TRT_DATE
                                       AND TRT3.OUTCOME NOT LIKE ''9%''
                                       ORDER by TRT3.TRT_DATE desc)

		WHERE
			T.TRT_DATE > ''' + @LastTreatmentDateString + '''
			and t.trt_type like ''O%''

			
			
	'
	) AT [WPAS_Central];


END

GO
