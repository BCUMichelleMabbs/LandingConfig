SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceCentralLive]
	
AS
BEGIN
	
SET NOCOUNT ON;

SELECT 
	Area, Source, LocalPersonIdentifier, NHSNumber, PatientName, 
	--DATENAME(DAY, PatientDateOfBirth) + ' ' + DATENAME(MONTH, PatientDateOfBirth) + ' ' + DATENAME(YEAR, PatientDateOfBirth) AS PatientDateOfBirth,
	CONVERT(DATE,PatientDateOfBirth) AS PatientDateOfBirth,
	CAST(DATENAME(DAY, ArrivalDate) + ' ' + DATENAME(MONTH, ArrivalDate) + ' ' + DATENAME(YEAR, ArrivalDate) AS DATE) AS ArrivalDate,
	CAST(LEFT(ArrivalTime,2) + ':' + RIGHT(ArrivalTime,2) AS TIME) AS ArrivalTime,
		
	CASE
		WHEN NULLIF(RTRIM(DischargeDate),'') IS NOT NULL THEN CAST(DischargeDate AS DATE)
		ELSE NULL
	END AS DepartureDate,
	CASE 
		WHEN NULLIF(RTRIM(DischargeTime),'') IS NULL THEN CAST('23:59' AS TIME)
		ELSE CAST(LEFT(DischargeTime,2) + ':' + RIGHT(DischargeTime,2) AS TIME)
	END AS DepartureTime,
	SiteCode AS SiteCode,
	
	CASE
		WHEN NULLIF(RTRIM(BedRequestedDate),'') IS NOT NULL THEN CAST(BedRequestedDate AS DATE)
		ELSE NULL
	END AS WaitingForBedDate,
	CASE 
		WHEN NULLIF(RTRIM(BedRequestedTime),'') IS NULL THEN CAST('23:59' AS TIME)
		ELSE CAST(LEFT(BedRequestedTime,2) + ':' + RIGHT(BedRequestedTime,2) AS TIME)
	END AS WaitingForBedTime,
	
	BedRequestedConsultantName AS WaitingForBedConsultant,
	BedRequestedConsultantGMC AS WaitingForBedGMC,
	BedRequestedWard AS WaitingForBedWard,
	BedRequestedSpecialty AS WaitingForBedSpecialty,
	TriageCategory,
	CurrentLocation,
	AttendanceCategory,
	AttendanceGroup,
	ArrivalMode,
	SiteCodeOfTreatment,
	CAST(CensusDateTime AS SmallDateTime),
	Active,
	SiteDescription,
	CAST(DATENAME(DAY, TreatmentStartDate) + ' ' + DATENAME(MONTH, TreatmentStartDate) + ' ' + DATENAME(YEAR, TreatmentStartDate) AS DATE) AS TreatmentStartDate,
	CAST(LEFT(TreatmentStartTime,2) + ':' + RIGHT(TreatmentStartTime,2) AS TIME) AS TreatmentStartTime,
	CAST(DATENAME(DAY, TreatmentCompleteDate) + ' ' + DATENAME(MONTH, TreatmentCompleteDate) + ' ' + DATENAME(YEAR, TreatmentCompleteDate) AS DATE) AS TreatmentEndDate,
	CAST(LEFT(TreatmentCompleteTime,2) + ':' + RIGHT(TreatmentCompleteTime,2) AS TIME) AS TreatmentEndTime,
	CAST(BreachEndDateTime AS DATE) AS BreachEndDate,
	CAST(BreachEndDateTime AS TIME) AS BreachEndTime,
	BreachReason AS BreachReason,
	CAST(TriageStartDate AS DATE) AS TriageStartDate,
	CAST(STUFF(TriageStartTime,3,0,':') AS TIME) as TriageStartTime,
	NULL as [TriageEndDate],
	NULL as [TriageEndTime],
	DATEDIFF(MINUTE, CAST(DATENAME(DAY, ArrivalDate) + ' ' + DATENAME(MONTH, ArrivalDate) + ' ' + DATENAME(YEAR, ArrivalDate) AS DATETIME) +	CAST(LEFT(ArrivalTime,2) + ':' + RIGHT(ArrivalTime,2) AS DATETIME), CensusDateTime) AS [TimeWaiting],
	EDClinicianSeen,
	AttendanceIdentifier,
	Note1,
	NoteType1,
	Note2,
	NoteType2,
	Note3,
	NoteType3,
	PresentingComplaint,
	NULL AS [Lodged],
	DischargeOutcome,
	NULL AS TriageComplaint,
	NULL AS TriageDiscriminator,
	NULL AS TriagePainScore,
	CRD1 AS ConsultationRequestDate1,
	CRT1 AS ConsultationRequestTime1,
	CRCD1 AS ConsultationRequestCompletedDate1,
	CRCT1 AS ConsultationRequestCompletedTime1,
	CRS1 AS ConsultationRequestSpecialty1,
	CRD2 AS ConsultationRequestDate2,
	CRT2 AS ConsultationRequestTime2,
	CRCD2 AS ConsultationRequestCompletedDate2,
	CRCT2 AS ConsultationRequestCompletedTime2,
	CRS2 AS ConsultationRequestSpecialty2,
	CRD3 AS ConsultationRequestDate3,
	CRT3 AS ConsultationRequestTime3,
	CRCD3 AS ConsultationRequestCompletedDate3,
	CRCT3 AS ConsultationRequestCompletedTime3,
	CRS3 AS ConsultationRequestSpecialty3



FROM(
	SELECT * FROM OPENQUERY(WPAS_CENTRAL_NEWPORT,

	'
	SELECT DISTINCT
		PL.LOCALITY_DESCRIPTION AS Area,
		''WPAS'' AS Source,
		PT.CASENO AS LocalPersonIdentifier,
		COALESCE(PT.NHS,'''') AS NHSNumber,
		PT.SURNAME||'', ''||PT.FORENAME AS PatientName,
		PT.BIRTHDATE AS PatientDateOfBirth,
		ED.ARRIVAL_DATE AS ArrivalDate,
		ED.ARRIVAL_TIME AS ArrivalTime,
		ED.TREATMENT_DATE AS TreatmentStartDate,
		CASE
			WHEN ED.TREATMENT_DATE IS NULL THEN NULL
			WHEN TRIM(ED.TREATMENT_TIME)='':'' THEN ''00:00''
			WHEN ED.TREATMENT_TIME IS NULL THEN ''00:00''
			WHEN TRIM(ED.TREATMENT_TIME)='''' THEN ''00:00''
			ELSE SUBSTRING(ED.TREATMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(ED.TREATMENT_TIME FROM 3 FOR 2) 
		END AS TreatmentStartTime,
		ED.TREATMENT_COMPLETE AS TreatmentCompleteDate,
		CASE
			WHEN ED.TREATMENT_COMPLETE IS NULL THEN NULL
			WHEN TRIM(ED.TREATMENT_COMPLETE_AT)='':'' THEN ''00:00''
			WHEN ED.TREATMENT_COMPLETE_AT IS NULL THEN ''00:00''
			WHEN TRIM(ED.TREATMENT_COMPLETE_AT)='''' THEN ''00:00''
		ELSE SUBSTRING(ED.TREATMENT_COMPLETE_AT FROM 1 FOR 2)||'':''||SUBSTRING(ED.TREATMENT_COMPLETE_AT FROM 3 FOR 2) 
		END AS TreatmentCompleteTime,
		BH.BREACH_END AS BreachEndDateTime,
		T.DISDATE AS DischargeDate,
		T.LEAVING_TIME AS DischargeTime,
		B.DESCRIPTION AS BreachReason,
		PL.BELONGS_TO AS SiteCode,
		PL.BASE_DESC AS SiteDescription,
		ED.BED_REQUESTED_AT AS BedRequestedDate,
		ED.BED_REQUESTED_TIME AS BedRequestedTime,
		CONS.GP_NAME AS BedRequestedConsultantName,
		CONS.GP_CODE AS BedRequestedConsultantGMC,
		PLWARD.LOCDESC AS BedRequestedWard,
		S.SPECIALTY_NAME AS BedRequestedSpecialty,
		CASE 
			WHEN ED.REGISTERED_DATE >=''25 SEPTEMBER 2017'' THEN
				CASE
					WHEN TD.DISCRIMINATOR_ID IS NOT NULL THEN 
						CASE 
							WHEN TD.DISCRIMINATOR_LEVEL=1 THEN ''01''
							WHEN TD.DISCRIMINATOR_LEVEL=2 THEN ''02''
							WHEN TD.DISCRIMINATOR_LEVEL=3 THEN ''03''
							WHEN TD.DISCRIMINATOR_LEVEL=4 THEN ''04''
							WHEN TD.DISCRIMINATOR_LEVEL=5 THEN ''05''
						END
					ELSE
					CASE
						WHEN ED.TRIAGE_TREATMENT IN(''R'',''MAJ'') THEN ''01''
						WHEN ED.TRIAGE_TREATMENT=''O'' THEN ''02''
						WHEN ED.TRIAGE_TREATMENT=''Y'' THEN ''03''
						WHEN ED.TRIAGE_TREATMENT IN (''G'',''INT'') THEN ''04''
						WHEN ED.TRIAGE_TREATMENT IN (''B'',''MIN'') THEN ''05''
						WHEN ED.SEE_AND_TREAT=''Y'' THEN ''06''
						ELSE ''''
					END
				END
			ELSE
				CASE
					WHEN ED.TRIAGE_TREATMENT IN(''R'',''MAJ'') THEN ''01''
					WHEN ED.TRIAGE_TREATMENT=''O'' THEN ''02''
					WHEN ED.TRIAGE_TREATMENT=''Y'' THEN ''03''
					WHEN ED.TRIAGE_TREATMENT IN (''G'',''INT'') THEN ''04''
					WHEN ED.TRIAGE_TREATMENT IN (''B'',''MIN'') THEN ''05''
					WHEN ED.SEE_AND_TREAT=''Y'' THEN ''06''
					ELSE ''''
				END
		END AS TriageCategory,
		CL.DESCRIPTION AS CurrentLocation,
		CASE
			WHEN ED.PATIENT_REASON=''RES'' THEN ''02''
			WHEN ED.PATIENT_REASON=''REU'' THEN ''03''
			ELSE ''01''
		END AS AttendanceCategory,
		COALESCE(REASON.EDDS_MAP,''99'') AS AttendanceGroup,
		CASE 
			WHEN ED.PATIENT_REASON=''RES'' THEN ''98''
			WHEN ED.PATIENT_ARRIVEDBY=''AM'' THEN ''01''
			WHEN ED.PATIENT_ARRIVEDBY=''FO'' THEN ''06''
			WHEN ED.PATIENT_ARRIVEDBY=''HE'' THEN ''02''
			WHEN ED.PATIENT_ARRIVEDBY=''OT'' THEN ''20''
			WHEN ED.PATIENT_ARRIVEDBY=''PO'' THEN ''07''
			WHEN ED.PATIENT_ARRIVEDBY=''PR'' THEN ''03''
			WHEN ED.PATIENT_ARRIVEDBY=''PU'' THEN ''05''
			WHEN ED.PATIENT_ARRIVEDBY=''C'' THEN ''03''
			WHEN ED.PATIENT_ARRIVEDBY=''TA'' THEN ''05''
		END AS ArrivalMode,
		PL.PROVIDER_CODE AS SiteCodeOfTreatment,
		CAST(''NOW'' AS TIMESTAMP) AS CensusDateTime,
		''Y'' AS Active,
	ED.TRIAGE_DATE AS TriageStartDate,
	ED.TRIAGE_TIME AS TriageStartTime,
	ED.TREATMENT_BY AS EDClinicianSeen,
	ED.LINKID AS AttendanceIdentifier,
	AN1.ACTNOTE AS Note1,
	AN1.NOTE_SUBTYPE AS NoteType1,
	AN2.ACTNOTE AS Note2,
	AN2.NOTE_SUBTYPE AS NoteType2,
	AN3.ACTNOTE AS Note3,
	AN3.NOTE_SUBTYPE AS NoteType3,
	ED.PATIENT_COMPLAINT AS PresentingComplaint,
	NULL AS Lodged,
	ED.PATIENT_DISPOSAL AS DischargeOutcome,
	CR1.REQUEST_DATE AS CRD1,
	LEFT(CR1.REQUEST_TIME,2)||'':''||RIGHT(CR1.REQUEST_TIME,2) AS CRT1,
	CR1.REQUEST_COMPLETED AS CRCD1,
	LEFT(CR1.REQUEST_COMPLETEDTIME,2)||'':''||RIGHT(CR1.REQUEST_COMPLETEDTIME,2) AS CRCT1,
	CR1.REQUEST_SPECIALTY AS CRS1,
	CR2.REQUEST_DATE AS CRD2,
	LEFT(CR2.REQUEST_TIME,2)||'':''||RIGHT(CR2.REQUEST_TIME,2) AS CRT2,
	CR2.REQUEST_COMPLETED AS CRCD2,
	LEFT(CR2.REQUEST_COMPLETEDTIME,2)||'':''||RIGHT(CR2.REQUEST_COMPLETEDTIME,2) AS CRCT2,
	CR2.REQUEST_SPECIALTY AS CRS2,
	CR3.REQUEST_DATE AS CRD3,
	LEFT(CR3.REQUEST_TIME,2)||'':''||RIGHT(CR3.REQUEST_TIME,2) AS CRT3,
	CR3.REQUEST_COMPLETED AS CRCD3,
	LEFT(CR3.REQUEST_COMPLETEDTIME,2)||'':''||RIGHT(CR3.REQUEST_COMPLETEDTIME,2) AS CRCT3,
	CR3.REQUEST_SPECIALTY AS CRS3

	FROM
		TREATMNT T
		LEFT JOIN AANDE_DATA ED ON T.LINKID = ED.LINKID
		LEFT JOIN TRIAGEDI TD ON ED.DISCRIMINATOR_ID=TD.DISCRIMINATOR_ID
		LEFT JOIN PATIENT PT ON T.CASENO = PT.CASENO
		LEFT JOIN PADLOC PL ON T.ALOC = PL.LOCCODE
		LEFT JOIN SPECS S ON ED.BED_SPECIALTY=S.SPECIALTY_REFERENCE_CODE
		LEFT JOIN GP2 CONS ON ED.BED_CONSULTANT=CONS.PRACTICE
		--LEFT JOIN GP2 CONS1 ON ED.TREATMENT_BY=CONS1.S
		LEFT JOIN GP2 TB ON TB.PRACTICE=ED.TREATMENT_BY
		LEFT JOIN PADLOC PLWARD ON ED.BED_WARD_SENTTO = PLWARD.LOCCODE
		LEFT JOIN AANDE_REASON REASON ON ED.PATIENT_REASON=REASON.CODE
		LEFT JOIN AANDE_LOCATION CL ON ED.AANDE_LOCATION=CL.CODE
		LEFT JOIN AANDE_BREACH_HISTORY BH ON T.LINKID=BH.LINKID AND BH.BREACH_KEY=(SELECT FIRST 1(innerBH.BREACH_KEY) FROM AANDE_BREACH_HISTORY innerBH WHERE innerBH.LINKID=T.LINKID AND innerBH.BREACH_END IS NOT NULL ORDER BY innerBH.BREACH_END ASC) 
		LEFT JOIN AANDE_BREACH B ON BH.BREACH_REASON=B.CODE
		LEFT JOIN ACTIVITYNOTES AN1 ON T.ACTNOTEKEY = AN1.ACTNOTEKEY AND 
				AN1.NOTE_TYPE=''RN'' AND 
				AN1.NOTE_SUBTYPE IN (''CG'',''GN'') AND 
				AN1.CREATE_DATE=(
					SELECT FIRST 1 innerAN1.CREATE_DATE FROM ACTIVITYNOTES innerAN1 WHERE 
						innerAN1.ACTNOTEKEY=AN1.ACTNOTEKEY AND
						innerAN1.NOTE_TYPE=''RN'' AND
						innerAN1.NOTE_SUBTYPE IN (''CG'',''GN'')
					ORDER BY
						innerAN1.CREATE_DATE ASC
				)
		LEFT JOIN ACTIVITYNOTES AN2 ON T.ACTNOTEKEY = AN2.ACTNOTEKEY AND 
				AN2.NOTE_TYPE=''RN'' AND 
				AN2.NOTE_SUBTYPE IN (''CG'',''GN'') AND 
				AN2.CREATE_DATE=(
					SELECT FIRST 1 SKIP 1 innerAN2.CREATE_DATE FROM ACTIVITYNOTES innerAN2 WHERE 
						innerAN2.ACTNOTEKEY=AN2.ACTNOTEKEY AND
						innerAN2.NOTE_TYPE=''RN'' AND
						innerAN2.NOTE_SUBTYPE IN (''CG'',''GN'')
					ORDER BY
						innerAN2.CREATE_DATE ASC
				)
		LEFT JOIN ACTIVITYNOTES AN3 ON T.ACTNOTEKEY = AN3.ACTNOTEKEY AND 
				AN3.NOTE_TYPE=''RN'' AND 
				AN3.NOTE_SUBTYPE IN (''CG'',''GN'') AND 
				AN3.CREATE_DATE=(
					SELECT FIRST 1 SKIP 2 innerAN3.CREATE_DATE FROM ACTIVITYNOTES innerAN3 WHERE 
						innerAN3.ACTNOTEKEY=AN3.ACTNOTEKEY AND
						innerAN3.NOTE_TYPE=''RN'' AND
						innerAN3.NOTE_SUBTYPE IN (''CG'',''GN'')
					ORDER BY
						innerAN3.CREATE_DATE ASC
				)
		LEFT JOIN AANDE_CODING CR1 ON T.LINKID=CR1.LINKID AND CR1.THECODE=''CON'' AND CR1.SEQ_NO=(SELECT FIRST 1 innerCR1.SEQ_NO FROM AANDE_CODING innerCR1 WHERE innerCR1.LINKID=T.LINKID AND innerCR1.THECODE=''CON'' ORDER BY innerCR1.ITEMNO, innerCR1.SEQ_NO DESC)
		LEFT JOIN AANDE_CODING CR2 ON T.LINKID=CR2.LINKID AND CR2.THECODE=''CON'' AND CR2.SEQ_NO=(SELECT FIRST 1 SKIP 1 innerCR2.SEQ_NO FROM AANDE_CODING innerCR2 WHERE innerCR2.LINKID=T.LINKID AND innerCR2.THECODE=''CON'' ORDER BY innerCR2.ITEMNO ASC, innerCR2.SEQ_NO DESC)
		LEFT JOIN AANDE_CODING CR3 ON T.LINKID=CR3.LINKID AND CR3.THECODE=''CON'' AND CR3.SEQ_NO=(SELECT FIRST 1 SKIP 2 innerCR3.SEQ_NO FROM AANDE_CODING innerCR3 WHERE innerCR3.LINKID=T.LINKID AND innerCR3.THECODE=''CON'' ORDER BY innerCR3.ITEMNO ASC, innerCR3.SEQ_NO DESC)
	WHERE
		T.TRT_TYPE IN (''EC'',''ED'') AND
		ED.ARRIVAL_DATE IS NOT NULL AND
		(ED.DISCHARGE_DATE IS NULL OR DATEDIFF(DAY,ED.DISCHARGE_DATE,CURRENT_TIMESTAMP) <= 3) AND
		PT.CASENO IS NOT NULL
	'
	)
)ED_Attendances

END
GO
