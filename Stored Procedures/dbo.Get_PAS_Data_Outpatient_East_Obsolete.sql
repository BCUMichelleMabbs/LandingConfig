SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: June 2017
-- Description:	Extract of all Outpatient Data
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatient_East_Obsolete]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	
-- 	DECLARE @LastTreatmentDate AS DATE = (SELECT ISNULL(MAX(AppointmentDate),'1 January 2010') FROM [Foundation].[dbo].[PAS_Data_Outpatient] WHERE Source='Myrddin' and AppointmentDate <> '2999-12-31')
DECLARE @LastTreatmentDate AS DATE = '1 Jan 2019'
	DECLARE @LastTreatmentDateString AS VARCHAR(30) = DATENAME(DAY,@LastTreatmentDate) + ' ' + DATENAME(MONTH,@LastTreatmentDate) + ' ' + DATENAME(YEAR,@LastTreatmentDate)

	EXEC('SELECT distinct
			T.NHS AS NHSNumber,
			T.CASENO AS LocalPersonIdentifier,
			T.TRT_DATE AS AppointmentDate,
			CASE
				WHEN T.TRT_DATE IS NULL THEN NULL
				WHEN TRIM(T.APPOINTMENT_TIME)='':'' THEN ''00:00''
				WHEN T.APPOINTMENT_TIME IS NULL THEN ''00:00''
				WHEN TRIM(T.APPOINTMENT_TIME)='''' THEN ''00:00''
				ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
			END AS AppointmentTime,
			T.LINKID AS SystemLinkId,
			T.TRT_TYPE AS TrListPositionAtTimeOfExtract,
			T.TRT_INTENT AS IntendedManagement,
			CASE 
			WHEN R.CONS_PRTY = ''1''  then ''2''
			WHEN R.CONS_PRTY = ''3''  then ''1''
			END
			
			 AS HCPPriority,
			GP2.GP_CODE AS AttendanceHCP,
			pad.PROVIDER_CODE AS Location,
			''Myrddin'' AS Source,
			
				CASE
		WHEN SP.EXCLUDE_PATHWAY IS NOT NULL THEN ''9''
		WHEN SUBSTRING(P.EVENT_TYPE FROM 1 FOR 1) = ''4'' THEN ''4''
		WHEN SUBSTRING(P.EVENT_TYPE FROM 1 FOR 1) = ''5'' THEN ''6''
		WHEN SUBSTRING(P.EVENT_TYPE FROM 1 FOR 1) IN (''6'', ''7'') THEN ''5''
		WHEN SUBSTRING(P.EVENT_TYPE FROM 1 FOR 1) is null THEN '' ''
		ELSE ''9''
	END
 AS RTTOutcome,
			--t.Outcome_Reason as OutcomeReason,
			COALESCE(R.GP_REF,R.REG_GP) AS Referrer,
			COALESCE(R.GP_PRAC,R.REG_PRAC) AS ReferrerOrganisation,
			T.REG_GP AS GPAtTimeofActivity,
			T.REG_PRAC AS GPPracticeAtTimeOfActivity,
			T.POSTCODE AS PostcodeAtTimeOfActivity,
			T.DHA_CODE AS Commissioner,
			CASE 
		when SUBSTRING(T.CATEGORY FROM 1 FOR 1) = ''1'' THEN ''01''
		when SUBSTRING(T.CATEGORY FROM 1 FOR 1) = ''2'' THEN ''02''
		when SUBSTRING(T.CATEGORY FROM 1 FOR 1) = ''3'' THEN ''03''
		
		ELSE ''01''
	END
			 AS PatientCategory,
			T.OPCLINICNO AS ClinicNumber,
			T.ASPEC AS Specialty,
			T.OPCLINICNO AS ClinicCode,
			CASE
				WHEN TRIM(T.ARRIVAL_TIME)='':'' THEN ''00:00''
				WHEN T.ARRIVAL_TIME IS NULL THEN ''00:00''
				WHEN TRIM(T.ARRIVAL_TIME)='''' THEN ''00:00''
				ELSE SUBSTRING(T.ARRIVAL_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.ARRIVAL_TIME FROM 3 FOR 2) 
			END AS ArrivalTime,
			CASE
				WHEN TRIM(T.LEAVING_TIME)='':'' THEN ''00:00''
				WHEN T.LEAVING_TIME IS NULL THEN ''00:00''
				WHEN TRIM(T.LEAVING_TIME)='''' THEN ''00:00''
				ELSE SUBSTRING(T.LEAVING_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.LEAVING_TIME FROM 3 FOR 2) 
			END AS LeavingTime,
			T.SLOTKEY AS ClinicSlotKey,
			''''  AS NextAppointmentHCP,
			''''  AS NextAppointmentSpecialty,
			''''  AS NextAppointmentLocation,
			'''' AS NextAppointmentDate,
			'''' AS NextAppointmentActnotekey,
			''N'' AS CPTFlag,
			T.GPREFNO AS GPRefNo,
			T.REAL_MANAGEMENT AS PatientClassification,
			T.NEXT_APPROX_APPT AS NextApproximateAppointment,
			T.ACTNOTEKEY AS Actnotekey,
			COALESCE(R.DAT_REF,R.CLIN_REF_DATE) AS PatientReferralDate,
			CASE
				WHEN R.SOURCE_REFER=''G'' THEN R.DAT_REF
				ELSE R.DATONSYS
			END AS ClinicalReferralDate,
	
				CASE 
			WHEN R.lttr_PRTY = ''1''  then ''2''
			WHEN R.lttr_PRTY = ''3''  then ''1''
			END
			 AS ReferrerPriority,
				CASE 
		WHEN R.SOURCE_REFER = ''H'' THEN ''01''
		WHEN R.SOURCE_REFER = ''8'' THEN ''02''
		WHEN R.SOURCE_REFER in (''1'', ''G'', ''S'') THEN ''03''
		WHEN R.SOURCE_REFER = ''6'' THEN ''04''
		WHEN R.SOURCE_REFER IN (''4'', ''CB'', ''CC'', ''CH'', ''CI'', ''CR'', ''GI'', ''NP'', ''NQ'', ''NR'', ''NX'', ''NY'', ''PD'', ''PH'',  ''PI'', ''PK'', ''PM'', ''PN'', ''PQ'') THEN ''05''
		WHEN R.SOURCE_REFER IN (''5'') THEN ''06''
		WHEN R.SOURCE_REFER = ''3'' THEN ''15''
		WHEN R.SOURCE_REFER = ''2'' THEN ''92''
		ELSE ''08''

	END AS ReferralSource,  
			cons.Consultant_specialty as HCPSpecialty,
			T.ACONS as HCPCode,

			R.INTENT_REFER AS ReferralIntent,
			P.EVENT_TYPE AS PathwayEventType,
			P.EVENT_SOURCE AS PathwayEventSource,
			SP.EXCLUDE_PATHWAY AS ExcludePathway,
			P.UPI AS UniquePathwayIdentifier,
			SE.SESSIONTYPE AS SessionType,
			SE.LOCATION AS SessionLocation,
			T.DATE_NOTIFIED AS DateNotified,
			R.SPEC AS ReferralSpecialty,
			CASE
				WHEN TRIM(T.TIME_CONS_READY)='':'' THEN ''00:00''
				WHEN T.TIME_CONS_READY IS NULL THEN ''00:00''
				WHEN TRIM(T.TIME_CONS_READY)='''' THEN ''00:00''
				ELSE SUBSTRING(T.TIME_CONS_READY FROM 1 FOR 2)||'':''||SUBSTRING(T.TIME_CONS_READY FROM 3 FOR 2) 
			END AS HCPReadyTime,
			CASE
				WHEN TRIM(T.TRT_TIME)='':'' THEN ''00:00''
				WHEN T.TRT_TIME IS NULL THEN ''00:00''
				WHEN TRIM(T.TRT_TIME)='''' THEN ''00:00''
				ELSE SUBSTRING(T.TRT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.TRT_TIME FROM 3 FOR 2) 
			END AS ActivityTime,
			CAST(SUBSTRING(T.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) AS OtherInfo,
			T.APPT_DIRECTIVE AS AppointmentDirective,
			CASE 
                WHEN t.outcome IN (''9B'') THEN ''8'' --DID NOT PHONE 
                WHEN t.outcome IN (''92'',''94'', ''97'',''9A'',''9D'', ''9N'',''9J'') THEN ''2''  --CNA 
                WHEN t.outcome IN (''96'', ''91'',''9C'') THEN ''3'' --DNA 
                WHEN t.outcome IN (''93'', ''98'', ''(9E'') THEN ''4'' -- CANCELLED BY HOSP 
                when t.outcome IS null then null 
                --when Other_Info like ''%~BNA~%'' then '' '' 
                ELSE ''5'' 
        END as AttendedorDNA,
				CASE 
		when T.TRT_Intent = ''P'' then ''3''
		WHEN T.ASPEC like ''%333'' THEN ''3'' -- KR added this line in to account for all pre-ops 25052017, this is inline with wpas extract
		WHEN T.SOURCE IN (''21'', ''23'') THEN ''1''
		WHEN T.SOURCE IN (''25'',''33'', ''43'', ''65'') THEN ''2''
	ELSE ''1'' END as AttendanceCategory,
t.Staff_Grade,
				OPCODING.THECODE as Procedure1,
		OPCODING2.THECODE AS Procedure2,
		OPCODING3.THECODE AS Procedure3,
		OPCODING4.THECODE AS Procedure4,
		OPCODING5.THECODE AS Procedure5,
		OPCODING6.THECODE AS Procedure6,
		OPCODING7.THECODE AS Procedure7,
		OPCODING8.THECODE AS Procedure8,
		OPCODING9.THECODE AS Procedure9,
		OPCODING10.THECODE AS Procedure10,
		OPCODING11.THECODE AS Procedure11,
		OPCODING12.THECODE AS Procedure12,
		R.Dat_Ref as WaitingListDate,
		t.Outcome as LocalOutcome,
		refer.local_reason_booked as LocalOutcomeReason,
		NULL as ActivityType,
		NULL as TraumaSubSpec


			
			
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

			
			
		
	
			LEFT JOIN SPECS SP ON T.ASPEC=SP.SPECIALTY_REFERENCE_CODE
			LEFT JOIN SESSIONS SE ON T.OPCLINICNO=SE.SESSIONKEY
			left join padloc pad on pad.loccode = t.aloc
				LEFT OUTER JOIN GP2 ON T.ACONS = GP2.PRACTICE
				left join padloc pad2 on pad2.loccode = t.NEXT_APPT_LOC
				left outer join cons on ((Treatmnt.acons = cons.consultant_initials) and (cons.main <> ''''))
				LEFT JOIN OPCODING ON (T.LINKID = OPCODING.LINKID AND T.TRT_DATE = OPCODING.TRT_DATE AND T.APPOINTMENT_TIME = OPCODING.APPOINTMENT_TIME AND OPCODING.ITEMNO = 1 and OPCoding.Code_Type=''OP'' )
		LEFT JOIN OPCODING OPCODING2 ON (TREATMNT.LINKID = OPCODING2.LINKID AND TREATMNT.TRT_DATE = OPCODING2.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING2.APPOINTMENT_TIME AND OPCODING2.ITEMNO = 2 and OPCoding2.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING3 ON (TREATMNT.LINKID = OPCODING3.LINKID AND TREATMNT.TRT_DATE = OPCODING3.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING3.APPOINTMENT_TIME AND OPCODING3.ITEMNO = 3 and OPCoding3.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING4 ON (TREATMNT.LINKID = OPCODING4.LINKID AND TREATMNT.TRT_DATE = OPCODING4.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING4.APPOINTMENT_TIME AND OPCODING4.ITEMNO = 4 and OPCoding4.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING5 ON (TREATMNT.LINKID = OPCODING5.LINKID AND TREATMNT.TRT_DATE = OPCODING5.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING5.APPOINTMENT_TIME AND OPCODING5.ITEMNO = 5 and OPCoding5.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING6 ON (TREATMNT.LINKID = OPCODING6.LINKID AND TREATMNT.TRT_DATE = OPCODING6.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING6.APPOINTMENT_TIME AND OPCODING6.ITEMNO = 6 and OPCoding6.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING7 ON (TREATMNT.LINKID = OPCODING7.LINKID AND TREATMNT.TRT_DATE = OPCODING7.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING7.APPOINTMENT_TIME AND OPCODING7.ITEMNO = 7 and OPCoding7.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING8 ON (TREATMNT.LINKID = OPCODING8.LINKID AND TREATMNT.TRT_DATE = OPCODING8.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING8.APPOINTMENT_TIME AND OPCODING8.ITEMNO = 8 and OPCoding8.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING9 ON (TREATMNT.LINKID = OPCODING9.LINKID AND TREATMNT.TRT_DATE = OPCODING9.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING9.APPOINTMENT_TIME AND OPCODING9.ITEMNO = 9 and OPCoding9.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING10 ON (TREATMNT.LINKID = OPCODING10.LINKID AND TREATMNT.TRT_DATE = OPCODING10.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING10.APPOINTMENT_TIME AND OPCODING10.ITEMNO = 10 and OPCoding10.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING11 ON (TREATMNT.LINKID = OPCODING11.LINKID AND TREATMNT.TRT_DATE = OPCODING11.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING11.APPOINTMENT_TIME AND OPCODING11.ITEMNO = 11 and OPCoding11.Code_Type=''OP'')
		LEFT JOIN OPCODING OPCODING12 ON (TREATMNT.LINKID = OPCODING12.LINKID AND TREATMNT.TRT_DATE = OPCODING12.TRT_DATE AND TREATMNT.APPOINTMENT_TIME = OPCODING12.APPOINTMENT_TIME AND OPCODING12.ITEMNO = 12 and OPCoding12.Code_Type=''OP'')





		WHERE
			T.TRT_DATE > ''' + @LastTreatmentDateString + ''' AND
			TREATMNT.TRT_TYPE LIKE ''O%''
			and TREATMNT.TRT_TYPE <> ''ON''
			
	'
	) AT [WPAS_East];


END
 
GO
