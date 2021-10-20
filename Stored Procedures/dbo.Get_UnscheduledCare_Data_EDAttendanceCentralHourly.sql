SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceCentralHourly]
	
AS
BEGIN
	
SET NOCOUNT ON;


SELECT 
	Area, Source, LocalPatientIdentifier, NHSNumber, PatientName, 
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
	PatientGroup,
	ArrivalMode,
	SiteCodeOfTreatment,
	CAST(CensusDateTime AS SmallDateTime),
	SiteDescription,
	AttendanceIdentifier,
	CAST(BreachEndDateTime AS DATE) AS BreachEndDate,
	CAST(BreachEndDateTime AS TIME) AS BreachEndTime,
	BreachReason AS BreachReason,
	EDClinicianSeen,
	DATEDIFF(MINUTE, CAST(DATENAME(DAY, ArrivalDate) + ' ' + DATENAME(MONTH, ArrivalDate) + ' ' + DATENAME(YEAR, ArrivalDate) AS DATETIME) +	CAST(LEFT(ArrivalTime,2) + ':' + RIGHT(ArrivalTime,2) AS DATETIME), CensusDateTime) AS [TimeWaiting],
	CAST(DATENAME(DAY, TreatmentCompleteDate) + ' ' + DATENAME(MONTH, TreatmentCompleteDate) + ' ' + DATENAME(YEAR, TreatmentCompleteDate) AS DATE) AS TreatmentEndDate,
	CAST(LEFT(TreatmentCompleteTime,2) + ':' + RIGHT(TreatmentCompleteTime,2) AS TIME) AS TreatmentEndTime,
	CAST(DATENAME(DAY, TreatmentStartDate) + ' ' + DATENAME(MONTH, TreatmentStartDate) + ' ' + DATENAME(YEAR, TreatmentStartDate) AS DATE) AS TreatmentStartDate,
	CAST(LEFT(TreatmentStartTime,2) + ':' + RIGHT(TreatmentStartTime,2) AS TIME) AS TreatmentStartTime,
	NULL as [TriageEndDate],
	NULL as [TriageEndTime],
	CAST(TriageStartDate AS DATE) AS TriageStartDate,
	CAST(STUFF(TriageStartTime,3,0,':') AS TIME) as TriageStartTime,
	NULL AS [Lodged]

FROM(
	SELECT * FROM OPENQUERY(WPAS_CENTRAL_NEWPORT,

	'
	SELECT
		PL.LOCALITY_DESCRIPTION AS Area,
		''WPAS'' AS Source,
		PT.CASENO AS LocalPatientIdentifier,
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
					WHEN TD.DISCRIMINATOR_ID IS NOT NULL THEN CAST(TD.DISCRIMINATOR_LEVEL AS INT)
					ELSE ED.TRIAGE_TREATMENT
				END
			ELSE ED.TRIAGE_TREATMENT
		END AS TriageCategory,
		CL.DESCRIPTION AS CurrentLocation,
		CASE
			WHEN ED.PATIENT_REASON=''RES'' THEN ''02''
			WHEN ED.PATIENT_REASON=''REU'' THEN ''03''
			ELSE ''01''
		END AS AttendanceCategory,
		ED.PATIENT_REASON AS PatientGroup,
		ED.PATIENT_ARRIVEDBY AS ArrivalMode,
		PL.PROVIDER_CODE AS SiteCodeOfTreatment,
		CAST(''NOW'' AS TIMESTAMP) AS CensusDateTime,
		ED.TRIAGE_DATE AS TriageStartDate,
		ED.TRIAGE_TIME AS TriageStartTime,
		TB.GP_CODE AS EDClinicianSeen,
		ED.LINKID AS AttendanceIdentifier,
		NULL AS Lodged
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
	WHERE
		T.TRT_TYPE =''EC'' AND
		ED.ARRIVAL_DATE IS NOT NULL AND
		PT.CASENO IS NOT NULL
	'
	) 
)ED_Attendances



     	
	

END

GO
