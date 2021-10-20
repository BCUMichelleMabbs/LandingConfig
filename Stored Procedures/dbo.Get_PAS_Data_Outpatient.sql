SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatient]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SQL AS VARCHAR(MAX)
   	DECLARE @LastTreatmentDate AS DATE = (SELECT ISNULL(MAX(AppointmentDate),'1 January 2016') FROM [Foundation].[dbo].[PAS_Data_Outpatient])
	DECLARE @LastTreatmentDateString AS VARCHAR(30) = DATENAME(DAY,@LastTreatmentDate) + ' ' + DATENAME(MONTH,@LastTreatmentDate) + ' ' + DATENAME(YEAR,@LastTreatmentDate)

	DECLARE @Outpatients AS TABLE(
		NHSNumber VARCHAR(MAX),
		CaseNumber VARCHAR(MAX),
		TreatmentDate VARCHAR(MAX),
		AppointmentTime VARCHAR(MAX),
		LinkId VARCHAR(MAX),
		TreatmentType VARCHAR(MAX),
		TreatmentIntent VARCHAR(MAX),
		Priority VARCHAR(MAX),
		AttendanceConsultant VARCHAR(MAX),
		AttendanceLocation VARCHAR(MAX),
		Source VARCHAR(MAX),
		Outcome VARCHAR(MAX),
		Referrer VARCHAR(MAX),
		ReferrerOrganisation VARCHAR(MAX),
		RegisteredGP VARCHAR(MAX),
		RegisteredGPPractice VARCHAR(MAX),
		PatientPostcodeAtTimeOfTreatment VARCHAR(MAX),
		DHA VARCHAR(MAX),
		Category VARCHAR(MAX),
		ClinicNumber VARCHAR(MAX),
		AdmittingSpecialty VARCHAR(MAX),
		ClinicCode VARCHAR(MAX),
		ArrivalTime VARCHAR(MAX),
		LeavingTime VARCHAR(MAX),
		SlotKey VARCHAR(MAX),
		NextApptConsultant VARCHAR(MAX),
		NextApptSpecialty VARCHAR(MAX),
		NextApptLocation VARCHAR(MAX),
		NextApptTreatmentDate VARCHAR(MAX),
		NextApptActNoteKey VARCHAR(MAX),
		CPTFlag VARCHAR(MAX),
		Area VARCHAR(MAX),
		GPRefNo VARCHAR(MAX),
		RealManagement VARCHAR(MAX),
		NextApproxAppt VARCHAR(MAX),
		ActNoteKey VARCHAR(MAX),
		PatientReferralDate VARCHAR(MAX),
		ClinicalReferralDate VARCHAR(MAX),
		WaitingListDate VARCHAR(MAX),
		ReferrerPriority VARCHAR(MAX),
		ReferralSource VARCHAR(MAX),
		ConsultantSpecialty VARCHAR(MAX),
		HCPCode VARCHAR(MAX),
		ReferralIntention VARCHAR(MAX),
		PathwayEventType VARCHAR(MAX),
		PathwayEventSource VARCHAR(MAX),
		ExcludePathway VARCHAR(MAX),
		UniquePathwayId VARCHAR(MAX),
		SessionType VARCHAR(MAX),
		SessionLocation VARCHAR(MAX),
		DateNotified VARCHAR(MAX),
		ReferralSpecialty VARCHAR(MAX),
		ConsultantReadyTime VARCHAR(MAX),
		TreatmentTime VARCHAR(MAX),
		OtherInfo VARCHAR(MAX)
	)

	SET @SQL='SELECT * FROM OPENQUERY(WPAS_CENTRAL,''SELECT first 10000
			T.NHS AS NHSNumber,
			T.CASENO AS CaseNumber,
			T.TRT_DATE AS TreatmentDate,
			CASE
				WHEN T.TRT_DATE IS NULL THEN NULL
				WHEN TRIM(T.APPOINTMENT_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.APPOINTMENT_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.APPOINTMENT_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
			END AS AppointmentTime,
			T.LINKID AS LinkId,
			T.TRT_TYPE AS TreatmentType,
			T.TRT_INTENT AS TreatmentIntent,
			T.PRIORITY AS Priority,
			T.ACONS AS AttendanceConsultant,
			T.ALOC AS AttendanceLocation,
			T.SOURCE AS Source,
			T.OUTCOME AS Outcome,
			COALESCE(T.GP_TRT,R.CONS) AS Referrer,
			COALESCE(T.GP_PRAC,R.LOC) AS ReferrerOrganisation,
			T.REG_GP AS RegisteredGP,
			T.REG_PRAC AS RegisteredGPPractice,
			T.POSTCODE AS PatientPostcodeAtTimeOfTreatment,
			T.DHA_CODE AS DHA,
			T.CATEGORY AS Category,
			T.OPCLINICNO AS ClinicNumber,
			T.ASPEC AS AdmittingSpecialty,
			T.CLINIC_CODE AS ClinicCode,
			CASE
				WHEN TRIM(T.ARRIVAL_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.ARRIVAL_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.ARRIVAL_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.ARRIVAL_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.ARRIVAL_TIME FROM 3 FOR 2) 
			END AS ArrivalTime,
			CASE
				WHEN TRIM(T.LEAVING_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.LEAVING_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.LEAVING_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.LEAVING_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.LEAVING_TIME FROM 3 FOR 2) 
			END AS LeavingTime,
			T.SLOTKEY AS SlotKey,
			T.NEXT_APPT_CONS AS NextApptConsultant,
			T.NEXT_APPT_SPEC AS NextApptSpecialty,
			T.NEXT_APPT_LOC AS NextApptLocation,
			T.NEXT_APPT_TRT_DATE AS NextApptTreatmentDate,
			T.NEXT_APPT_ACTNOTEKEY AS NextApptActNoteKey,
			''''Y'''' AS CPTFlag,
			''''East'''' AS Area,
			T.GPREFNO AS GPRefNo,
			T.REAL_MANAGEMENT AS RealManagement,
			T.NEXT_APPROX_APPT AS NextApproxAppt,
			T.ACTNOTEKEY AS ActNoteKey,
			COALESCE(R.DAT_REF,R.CLIN_REF_DATE) AS PatientReferralDate,
			CASE
				WHEN R.SOURCE_REFER=''''G'''' THEN R.DAT_REF
				ELSE R.DATONSYS
			END AS ClinicalReferralDate,
			CASE
				WHEN R.SOURCE_REFER=''''G'''' THEN R.DAT_REF
				ELSE R.DAT_REF
			END AS WaitingListDate,
			R.CONS_PRTY AS ReferrerPriority,
			R.SOURCE_REFER AS ReferralSource,
			C.CONSULTANT_SPECIALTY AS ConsultantSpecialty,
			T.ACONS AS HCPCode,
			R.INTENT_REFER AS ReferralIntention,
			P.EVENT_TYPE AS PathwayEventType,
			P.EVENT_SOURCE AS PathwayEventSource,
			SP.EXCLUDE_PATHWAY AS ExcludePathway,
			P.UPI AS UniquePathwayId,
			SE.SESSIONTYPE AS SessionType,
			SE.LOCATION AS SessionLocation,
			T.DATE_NOTIFIED AS DateNotified,
			R.SPEC AS ReferralSpecialty,
			CASE
				WHEN TRIM(T.TIME_CONS_READY)='''':'''' THEN ''''00:00''''
				WHEN T.TIME_CONS_READY IS NULL THEN ''''00:00''''
				WHEN TRIM(T.TIME_CONS_READY)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.TIME_CONS_READY FROM 1 FOR 2)||'''':''''||SUBSTRING(T.TIME_CONS_READY FROM 3 FOR 2) 
			END AS ConsultantReadyTime,
			CASE
				WHEN TRIM(T.TRT_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.TRT_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.TRT_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.TRT_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.TRT_TIME FROM 3 FOR 2) 
			END AS TreatmentTime,
			CAST(SUBSTRING(T.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) AS OtherInfo
		FROM
			TREATMNT T
			LEFT JOIN REFER R ON T.LINKID = R.LINKID
			LEFT JOIN PATHWAYMGT P ON T.ACTNOTEKEY=P.ACTNOTEKEY



			--LEFT JOIN GP2 ON T.ACONS = GP2.PRACTICE			--Taken out as per instruction from KR 18/11 as we need local code in foundation not GMC



			LEFT JOIN CONS C ON ((T.ACONS = C.CONSULTANT_INITIALS) AND (C.MAIN <> ''''''''))
			LEFT JOIN SPECS SP ON T.ASPEC=SP.SPECIALTY_REFERENCE_CODE
			LEFT JOIN SESSIONS SE ON T.OPCLINICNO=SE.SESSIONKEY
			
		WHERE
			T.TRT_DATE > ''''' + @LastTreatmentDateString + ''''' AND
			TREATMNT.TRT_TYPE LIKE ''''O%''''
			
	'')'
	INSERT INTO @Outpatients
	EXEC(@SQL)

	SET @SQL='SELECT * FROM OPENQUERY(WPAS_EAST,''SELECT first 10000
			T.NHS AS NHSNumber,
			T.CASENO AS CaseNumber,
			T.TRT_DATE AS TreatmentDate,
			CASE
				WHEN T.TRT_DATE IS NULL THEN NULL
				WHEN TRIM(T.APPOINTMENT_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.APPOINTMENT_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.APPOINTMENT_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
			END AS AppointmentTime,
			T.LINKID AS LinkId,
			T.TRT_TYPE AS TreatmentType,
			T.TRT_INTENT AS TreatmentIntent,
			T.PRIORITY AS Priority,
			T.ACONS AS AttendanceConsultant,
			T.ALOC AS AttendanceLocation,
			T.SOURCE AS Source,
			T.OUTCOME AS Outcome,
			COALESCE(T.GP_TRT,R.CONS) AS Referrer,
			COALESCE(T.GP_PRAC,R.LOC) AS ReferrerOrganisation,
			T.REG_GP AS RegisteredGP,
			T.REG_PRAC AS RegisteredGPPractice,
			T.POSTCODE AS PatientPostcodeAtTimeOfTreatment,
			T.DHA_CODE AS DHA,
			T.CATEGORY AS Category,
			T.OPCLINICNO AS ClinicNumber,
			T.ASPEC AS AdmittingSpecialty,
			T.CLINIC_CODE AS ClinicCode,
			CASE
				WHEN TRIM(T.ARRIVAL_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.ARRIVAL_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.ARRIVAL_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.ARRIVAL_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.ARRIVAL_TIME FROM 3 FOR 2) 
			END AS ArrivalTime,
			CASE
				WHEN TRIM(T.LEAVING_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.LEAVING_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.LEAVING_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.LEAVING_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.LEAVING_TIME FROM 3 FOR 2) 
			END AS LeavingTime,
			T.SLOTKEY AS SlotKey,
			T.NEXT_APPT_CONS AS NextApptConsultant,
			T.NEXT_APPT_SPEC AS NextApptSpecialty,
			T.NEXT_APPT_LOC AS NextApptLocation,
			T.NEXT_APPT_TRT_DATE AS NextApptTreatmentDate,
			T.NEXT_APPT_ACTNOTEKEY AS NextApptActNoteKey,
			''''Y'''' AS CPTFlag,
			''''East'''' AS Area,
			T.GPREFNO AS GPRefNo,
			T.REAL_MANAGEMENT AS RealManagement,
			T.NEXT_APPROX_APPT AS NextApproxAppt,
			T.ACTNOTEKEY AS ActNoteKey,
			COALESCE(R.DAT_REF,R.CLIN_REF_DATE) AS PatientReferralDate,
			CASE
				WHEN R.SOURCE_REFER=''''G'''' THEN R.DAT_REF
				ELSE R.DATONSYS
			END AS ClinicalReferralDate,
			CASE
				WHEN R.SOURCE_REFER=''''G'''' THEN R.DAT_REF
				ELSE R.DAT_REF
			END AS WaitingListDate,
			R.CONS_PRTY AS ReferrerPriority,
			R.SOURCE_REFER AS ReferralSource,
			C.CONSULTANT_SPECIALTY AS ConsultantSpecialty,
			T.ACONS AS HCPCode,
			R.INTENT_REFER AS ReferralIntention,
			P.EVENT_TYPE AS PathwayEventType,
			P.EVENT_SOURCE AS PathwayEventSource,
			SP.EXCLUDE_PATHWAY AS ExcludePathway,
			P.UPI AS UniquePathwayId,
			SE.SESSIONTYPE AS SessionType,
			SE.LOCATION AS SessionLocation,
			T.DATE_NOTIFIED AS DateNotified,
			R.SPEC AS ReferralSpecialty,
			CASE
				WHEN TRIM(T.TIME_CONS_READY)='''':'''' THEN ''''00:00''''
				WHEN T.TIME_CONS_READY IS NULL THEN ''''00:00''''
				WHEN TRIM(T.TIME_CONS_READY)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.TIME_CONS_READY FROM 1 FOR 2)||'''':''''||SUBSTRING(T.TIME_CONS_READY FROM 3 FOR 2) 
			END AS ConsultantReadyTime,
			CASE
				WHEN TRIM(T.TRT_TIME)='''':'''' THEN ''''00:00''''
				WHEN T.TRT_TIME IS NULL THEN ''''00:00''''
				WHEN TRIM(T.TRT_TIME)='''''''' THEN ''''00:00''''
				ELSE SUBSTRING(T.TRT_TIME FROM 1 FOR 2)||'''':''''||SUBSTRING(T.TRT_TIME FROM 3 FOR 2) 
			END AS TreatmentTime,
			CAST(SUBSTRING(T.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) AS OtherInfo
		FROM
			TREATMNT T
			LEFT JOIN REFER R ON T.LINKID = R.LINKID
			LEFT JOIN PATHWAYMGT P ON T.ACTNOTEKEY=P.ACTNOTEKEY



			--LEFT JOIN GP2 ON T.ACONS = GP2.PRACTICE			--Taken out as per instruction from KR 18/11 as we need local code in foundation not GMC



			LEFT JOIN CONS C ON ((T.ACONS = C.CONSULTANT_INITIALS) AND (C.MAIN <> ''''''''))
			LEFT JOIN SPECS SP ON T.ASPEC=SP.SPECIALTY_REFERENCE_CODE
			LEFT JOIN SESSIONS SE ON T.OPCLINICNO=SE.SESSIONKEY
			
		WHERE
			T.TRT_DATE > ''''' + @LastTreatmentDateString + ''''' AND
			TREATMNT.TRT_TYPE LIKE ''''O%''''
			
	'')'
	INSERT INTO @Outpatients
	EXEC(@SQL)

	--INSERT INTO @Outpatients
	--EXEC('SELECT first 10000
	--		T.NHS AS NHSNumber,
	--		T.CASENO AS CaseNumber,
	--		T.TRT_DATE AS TreatmentDate,
	--		CASE
	--			WHEN T.TRT_DATE IS NULL THEN NULL
	--			WHEN TRIM(T.APPOINTMENT_TIME)='':'' THEN ''00:00''
	--			WHEN T.APPOINTMENT_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.APPOINTMENT_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
	--		END AS AppointmentTime,
	--		T.LINKID AS LinkId,
	--		T.TRT_TYPE AS TreatmentType,
	--		T.TRT_INTENT AS TreatmentIntent,
	--		T.PRIORITY AS Priority,
	--		T.ACONS AS AttendanceConsultant,
	--		T.ALOC AS AttendanceLocation,
	--		T.SOURCE AS Source,
	--		T.OUTCOME AS Outcome,
	--		COALESCE(T.GP_TRT,R.CONS) AS Referrer,
	--		COALESCE(T.GP_PRAC,R.LOC) AS ReferrerOrganisation,
	--		T.REG_GP AS RegisteredGP,
	--		T.REG_PRAC AS RegisteredGPPractice,
	--		T.POSTCODE AS PatientPostcodeAtTimeOfTreatment,
	--		T.DHA_CODE AS DHA,
	--		T.CATEGORY AS Category,
	--		T.OPCLINICNO AS ClinicNumber,
	--		T.ASPEC AS AdmittingSpecialty,
	--		T.CLINIC_CODE AS ClinicCode,
	--		CASE
	--			WHEN TRIM(T.ARRIVAL_TIME)='':'' THEN ''00:00''
	--			WHEN T.ARRIVAL_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.ARRIVAL_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.ARRIVAL_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.ARRIVAL_TIME FROM 3 FOR 2) 
	--		END AS ArrivalTime,
	--		CASE
	--			WHEN TRIM(T.LEAVING_TIME)='':'' THEN ''00:00''
	--			WHEN T.LEAVING_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.LEAVING_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.LEAVING_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.LEAVING_TIME FROM 3 FOR 2) 
	--		END AS LeavingTime,
	--		T.SLOTKEY AS SlotKey,
	--		T.NEXT_APPT_CONS AS NextApptConsultant,
	--		T.NEXT_APPT_SPEC AS NextApptSpecialty,
	--		T.NEXT_APPT_LOC AS NextApptLocation,
	--		T.NEXT_APPT_TRT_DATE AS NextApptTreatmentDate,
	--		T.NEXT_APPT_ACTNOTEKEY AS NextApptActNoteKey,
	--		''Y'' AS CPTFlag,
	--		''East'' AS Area,
	--		T.GPREFNO AS GPRefNo,
	--		T.REAL_MANAGEMENT AS RealManagement,
	--		T.NEXT_APPROX_APPT AS NextApproxAppt,
	--		T.ACTNOTEKEY AS ActNoteKey,
	--		COALESCE(R.DAT_REF,R.CLIN_REF_DATE) AS PatientReferralDate,
	--		CASE
	--			WHEN R.SOURCE_REFER=''G'' THEN R.DAT_REF
	--			ELSE R.DATONSYS
	--		END AS ClinicalReferralDate,
	--		CASE
	--			WHEN R.SOURCE_REFER=''G'' THEN R.DAT_REF
	--			ELSE R.DAT_REF
	--		END AS WaitingListDate,
	--		R.CONS_PRTY AS ReferrerPriority,
	--		R.SOURCE_REFER AS ReferralSource,
	--		C.CONSULTANT_SPECIALTY AS ConsultantSpecialty,
	--		GP2.GP_CODE AS HCPCode,
	--		R.INTENT_REFER AS ReferralIntention,
	--		P.EVENT_TYPE AS PathwayEventType,
	--		P.EVENT_SOURCE AS PathwayEventSource,
	--		SP.EXCLUDE_PATHWAY AS ExcludePathway,
	--		P.UPI AS UniquePathwayId,
	--		SE.SESSIONTYPE AS SessionType,
	--		SE.LOCATION AS SessionLocation,
	--		T.DATE_NOTIFIED AS DateNotified,
	--		R.SPEC AS ReferralSpecialty,
	--		CASE
	--			WHEN TRIM(T.TIME_CONS_READY)='':'' THEN ''00:00''
	--			WHEN T.TIME_CONS_READY IS NULL THEN ''00:00''
	--			WHEN TRIM(T.TIME_CONS_READY)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.TIME_CONS_READY FROM 1 FOR 2)||'':''||SUBSTRING(T.TIME_CONS_READY FROM 3 FOR 2) 
	--		END AS ConsultantReadyTime,
	--		CASE
	--			WHEN TRIM(T.TRT_TIME)='':'' THEN ''00:00''
	--			WHEN T.TRT_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.TRT_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.TRT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.TRT_TIME FROM 3 FOR 2) 
	--		END AS TreatmentTime,
	--		CAST(SUBSTRING(T.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) AS OtherInfo
	--	FROM
	--		TREATMNT T
	--		LEFT JOIN REFER R ON T.LINKID = R.LINKID
	--		LEFT JOIN PATHWAYMGT P ON T.ACTNOTEKEY=P.ACTNOTEKEY
	--		LEFT JOIN GP2 ON T.ACONS = GP2.PRACTICE
	--		LEFT JOIN CONS C ON ((T.ACONS = C.CONSULTANT_INITIALS) AND (C.MAIN <> ''''''''))
	--		LEFT JOIN SPECS SP ON T.ASPEC=SP.SPECIALTY_REFERENCE_CODE
	--		LEFT JOIN SESSIONS SE ON T.OPCLINICNO=SE.SESSIONKEY
			
	--	WHERE
	--		T.TRT_DATE > ''' + @LastTreatmentDateString + ''' AND
	--		TREATMNT.TRT_TYPE LIKE ''O%''
			
	--'
	--) AT [WPAS_CENTRAL];


	--INSERT INTO @Outpatients
	--EXEC('SELECT first 10000
	--		T.NHS AS NHSNumber,
	--		T.CASENO AS CaseNumber,
	--		T.TRT_DATE AS TreatmentDate,
	--		CASE
	--			WHEN T.TRT_DATE IS NULL THEN NULL
	--			WHEN TRIM(T.APPOINTMENT_TIME)='':'' THEN ''00:00''
	--			WHEN T.APPOINTMENT_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.APPOINTMENT_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
	--		END AS AppointmentTime,
	--		T.LINKID AS LinkId,
	--		T.TRT_TYPE AS TreatmentType,
	--		T.TRT_INTENT AS TreatmentIntent,
	--		T.PRIORITY AS Priority,
	--		T.ACONS AS AttendanceConsultant,
	--		T.ALOC AS AttendanceLocation,
	--		T.SOURCE AS Source,
	--		T.OUTCOME AS Outcome,
	--		COALESCE(T.GP_TRT,R.CONS) AS Referrer,
	--		COALESCE(T.GP_PRAC,R.LOC) AS ReferrerOrganisation,
	--		T.REG_GP AS RegisteredGP,
	--		T.REG_PRAC AS RegisteredGPPractice,
	--		T.POSTCODE AS PatientPostcodeAtTimeOfTreatment,
	--		T.DHA_CODE AS DHA,
	--		T.CATEGORY AS Category,
	--		T.OPCLINICNO AS ClinicNumber,
	--		T.ASPEC AS AdmittingSpecialty,
	--		T.CLINIC_CODE AS ClinicCode,
	--		CASE
	--			WHEN TRIM(T.ARRIVAL_TIME)='':'' THEN ''00:00''
	--			WHEN T.ARRIVAL_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.ARRIVAL_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.ARRIVAL_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.ARRIVAL_TIME FROM 3 FOR 2) 
	--		END AS ArrivalTime,
	--		CASE
	--			WHEN TRIM(T.LEAVING_TIME)='':'' THEN ''00:00''
	--			WHEN T.LEAVING_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.LEAVING_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.LEAVING_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.LEAVING_TIME FROM 3 FOR 2) 
	--		END AS LeavingTime,
	--		T.SLOTKEY AS SlotKey,
	--		T.NEXT_APPT_CONS AS NextApptConsultant,
	--		T.NEXT_APPT_SPEC AS NextApptSpecialty,
	--		T.NEXT_APPT_LOC AS NextApptLocation,
	--		T.NEXT_APPT_TRT_DATE AS NextApptTreatmentDate,
	--		T.NEXT_APPT_ACTNOTEKEY AS NextApptActNoteKey,
	--		''Y'' AS CPTFlag,
	--		''East'' AS Area,
	--		T.GPREFNO AS GPRefNo,
	--		T.REAL_MANAGEMENT AS RealManagement,
	--		T.NEXT_APPROX_APPT AS NextApproxAppt,
	--		T.ACTNOTEKEY AS ActNoteKey,
	--		COALESCE(R.DAT_REF,R.CLIN_REF_DATE) AS PatientReferralDate,
	--		CASE
	--			WHEN R.SOURCE_REFER=''G'' THEN R.DAT_REF
	--			ELSE R.DATONSYS
	--		END AS ClinicalReferralDate,
	--		CASE
	--			WHEN R.SOURCE_REFER=''G'' THEN R.DAT_REF
	--			ELSE R.DAT_REF
	--		END AS WaitingListDate,
	--		R.CONS_PRTY AS ReferrerPriority,
	--		R.SOURCE_REFER AS ReferralSource,
	--		C.CONSULTANT_SPECIALTY AS ConsultantSpecialty,
	--		GP2.GP_CODE AS HCPCode,
	--		R.INTENT_REFER AS ReferralIntention,
	--		P.EVENT_TYPE AS PathwayEventType,
	--		P.EVENT_SOURCE AS PathwayEventSource,
	--		SP.EXCLUDE_PATHWAY AS ExcludePathway,
	--		P.UPI AS UniquePathwayId,
	--		SE.SESSIONTYPE AS SessionType,
	--		SE.LOCATION AS SessionLocation,
	--		T.DATE_NOTIFIED AS DateNotified,
	--		R.SPEC AS ReferralSpecialty,
	--		CASE
	--			WHEN TRIM(T.TIME_CONS_READY)='':'' THEN ''00:00''
	--			WHEN T.TIME_CONS_READY IS NULL THEN ''00:00''
	--			WHEN TRIM(T.TIME_CONS_READY)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.TIME_CONS_READY FROM 1 FOR 2)||'':''||SUBSTRING(T.TIME_CONS_READY FROM 3 FOR 2) 
	--		END AS ConsultantReadyTime,
	--		CASE
	--			WHEN TRIM(T.TRT_TIME)='':'' THEN ''00:00''
	--			WHEN T.TRT_TIME IS NULL THEN ''00:00''
	--			WHEN TRIM(T.TRT_TIME)='''' THEN ''00:00''
	--			ELSE SUBSTRING(T.TRT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.TRT_TIME FROM 3 FOR 2) 
	--		END AS TreatmentTime,
	--		CAST(SUBSTRING(T.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) AS OtherInfo
	--	FROM
	--		TREATMNT T
	--		LEFT JOIN REFER R ON T.LINKID = R.LINKID
	--		LEFT JOIN PATHWAYMGT P ON T.ACTNOTEKEY=P.ACTNOTEKEY
	--		LEFT JOIN GP2 ON T.ACONS = GP2.PRACTICE
	--		LEFT JOIN CONS C ON ((T.ACONS = C.CONSULTANT_INITIALS) AND (C.MAIN <> ''''''''))
	--		LEFT JOIN SPECS SP ON T.ASPEC=SP.SPECIALTY_REFERENCE_CODE
	--		LEFT JOIN SESSIONS SE ON T.OPCLINICNO=SE.SESSIONKEY
			
	--	WHERE
	--		T.TRT_DATE > ''' + @LastTreatmentDateString + ''' AND
	--		TREATMNT.TRT_TYPE LIKE ''O%''
			
	--'
	--) AT [WPAS_EAST];


	SELECT * FROM @Outpatients
END
GO
