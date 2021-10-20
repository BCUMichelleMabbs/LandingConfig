SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceCentralOldWH]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	
   	DECLARE @LastAttendanceDate AS DATE = (SELECT ISNULL(MAX(ArrivalDate),'31 DECEMBER 2010') FROM [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] WHERE Area='Central')
	DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)
	DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())

SELECT
	'Central' AS Area,
	'OldWH' AS Source,
	NULL AS AttendanceIdentifier,
	LocalPatientIdentifier AS LocalPatientIdentifier,
    NHSNumber AS NHSNumber,
	NULL AS RegisteredGP,
	RegisteredGPPracticeCode AS RegisteredPractice,
	PostcodeUsualAddress AS PatientPostcode,
	NULL AS DHA,
	NULL AS ReferringGP,
	CASE
		WHEN SourceOfServiceRequest IN ('02','03') THEN ReferringOrganisationCode  --Any others to go in here?
		ELSE NULL
	END AS ReferringPractice,
	CAST(HealthEventDate AS DATE) AS IncidentDate,
	CAST(HealthEventTime AS TIME) AS IncidentTime,
	CAST(AdministrativeArrivalDate AS DATE) AS ArrivalDate,
	CAST(AdministrativeArrivalTime AS TIME) AS ArrivalTime,
	NULL AS AmbulanceHandoverDate,
	NULL AS AmbulanceHandoverTime,
	NULL AS RegisteredDate,
	NULL AS RegisteredTime,
	NULL AS TriageStartDate,
	NULL AS TriageStartTime,
	NULL AS TriageEndDate,
	NULL AS TriageEndTime,
	NULL AS EDClinicianSeenDate,
	NULL AS EDClinicianSeenTime,
	NULL AS TreatmentStartDate,
	NULL AS TreatmentStartTime,
	CAST(TreatmentEndDate AS DATE) AS TreatmentCompleteDate,
	CAST(TreatmentEndTime AS TIME) AS TreamentCompleteTime,
	NULL AS DecisionToAdmitDate,
	NULL AS DecisionToAdmitTime,
	--NULL AS BreachEndDate,
	--NULL AS BreachEndTime,
	AdministrativeEndDate AS DischargeDate,
	AdministrativeEndTime AS DischargeTime,
	NULL AS DepartureDate,
	NULL AS DepartureTime,
	NULL AS TransportRequestedDate,
	NULL AS TransportRequestedTime,
	NULL AS TransportArrivedDate,
	NULL AS TransportArrivedTime,
	NULL AS BedRequestedDate,
	NULL AS BedRequestedTime,
	NULL AS BedRequestedOutcomeDate,
	NULL AS BedRequestedOutcomeTime,
	AmbulanceIncidentNumber AS AmbulanceReference,
	SiteCodeOfTreatment AS SiteCodeOfTreatment,
	PresentingComplaint AS PresentingComplaint,
	NULL AS ReferralSource,
	CASE ArrivalMode		--03 and 05 actually could map to 2 local codes but....
		WHEN '01' THEN 'AM'
		WHEN '02' THEN 'HE'
		WHEN '03' THEN 'PR'
		WHEN '05' THEN 'PU'
		WHEN '06' THEN 'FO'
		WHEN '07' THEN 'PO'
		WHEN '20' THEN 'OT'
	END AS ArrivalMode,
	NULL AS PatientGroup,
	NULL AS AccompaniedBy1,
	NULL AS AccompaniedBy2,
	NULL AS IncidentLocation,
	CASE 
		WHEN ActivityAtTimeOfInjury IN ('1','01') THEN 'PW'
		WHEN ActivityAtTimeOfInjury = '03' THEN 'CS'		--Maps to 2 separate local codes
		WHEN ActivityAtTimeOfInjury IN ('4','04') THEN 'OL'
		WHEN ActivityAtTimeOfInjury IN ('5','05') THEN 'DY'	--Maps to 2 separate local codes
		WHEN ActivityAtTimeOfInjury IN ('8','08') THEN 'OT'
		WHEN ActivityAtTimeOfInjury = '98' THEN 'NA'
		WHEN ActivityAtTimeOfInjury = '99' THEN NULL
	END AS IncidentActivity,
	TriageCategory AS TriageCategory,
	NULL AS TriageComplaint,
	NULL AS TriageTreatment,
	NULL AS TriageTreatment1,
	NULL AS TriageTreatment2,
	NULL AS TriageTreatment3,
	NULL AS TriageTreatment4,
	NULL AS TriageTreatment5,
	NULL AS TriageTreatment6,
	NULL AS TriageTreatment7,
	NULL AS TriageTreatment8,
	NULL AS TriageTreatment9,
	NULL AS TriageTreatment10,
	NULL AS TriageDiscriminator,
	NULL AS Immunisation,
	NULL AS School,
	(SELECT COALESCE(
	CASE
		WHEN OutcomeOfAttendance ='01' THEN 'ADM'
		WHEN OutcomeOfAttendance ='02' THEN 'IPO'
		WHEN OutcomeOfAttendance ='03' THEN '20'
		WHEN OutcomeOfAttendance ='04' THEN 'OPD'
		WHEN OutcomeOfAttendance ='05' THEN 'GP'
		WHEN OutcomeOfAttendance ='06' THEN 'DENT'
		WHEN OutcomeOfAttendance ='07' THEN 'HOME'
		WHEN OutcomeOfAttendance ='08' THEN 'REATT'
		WHEN OutcomeOfAttendance ='09' THEN 'OWN'
		ELSE NULL
	END,
	CASE
		WHEN OutcomeOfAttendance ='10' THEN 'DIED'
		WHEN OutcomeOfAttendance ='11' THEN 'DOA'
		ELSE NULL
	END)) AS DischargeOutcome,
	NULL AS DischargeDestination,
	AlcoholIndicator AS AlcoholRelated,
	NULL AS TimeSinceIncident,
	NULL AS BedRequestedWard,
	NULL AS BedRequestedConsultant,
	NULL AS BedRequestedSpecialty,
	NULL AS BedRequestedOutcome,
	NULL AS EDClinicianSeen,
	CASE
		WHEN TriageCategory='06' THEN 'Y'
		ELSE 'N'
	END AS SeeAndTreat,
	AttendanceCategory AS AttendanceCategory,
	NULL AS AppropriateAttendance,		--There are more values in here than just the 01, 02, and 03 that are in the reference table and in the NDS
	RoadUser AS RTAPatientType,
	MechanismOfInjury AS MechanismOfInjury,
	PrincipalDiagnosis AS Diagnosis1DiagnosisType,
	NULL AS Diagnosis1DiagnosisDate,
	NULL AS Diagnosis1DiagnosisTime,
	AnatomicalArea1 AS Diagnosis1DiagnosisSite,
	AnatomicalSide1 AS Diagnosis1DiagnosisSide,
	Diagnosis2 AS Diagnosis2DiagnosisType,
	NULL AS Diagnosis2DiagnosisDate,
	NULL AS Diagnosis2DiagnosisTime,
	AnatomicalArea2 AS Diagnosis2DiagnosisSite,
	AnatomicalSide2 AS Diagnosis2DiagnosisSide,
	Diagnosis3 AS Diagnosis3DiagnosisType,
	NULL AS Diagnosis3DiagnosisDate,
	NULL AS Diagnosis3DiagnosisTime,
	AnatomicalArea3 AS Diagnosis3DiagnosisSite,
	AnatomicalSide3 AS Diagnosis3DiagnosisSide,
	Diagnosis4 AS Diagnosis4DiagnosisType,
	NULL AS Diagnosis4DiagnosisDate,
	NULL AS Diagnosis4DiagnosisTime,
	AnatomicalArea4 AS Diagnosis4DiagnosisSite,
	AnatomicalSide4 AS Diagnosis4DiagnosisSide,
	Diagnosis5 AS Diagnosis5DiagnosisType,
	NULL AS Diagnosis5DiagnosisDate,
	NULL AS Diagnosis5DiagnosisTime,
	AnatomicalArea5 AS Diagnosis5DiagnosisSite,
	AnatomicalSide5 AS Diagnosis5DiagnosisSide,
	Diagnosis6 AS Diagnosis6DiagnosisType,
	NULL AS Diagnosis6DiagnosisDate,
	NULL AS Diagnosis6DiagnosisTime,
	AnatomicalArea6 AS Diagnosis6DiagnosisSite,
	AnatomicalSide6 AS Diagnosis6DiagnosisSide,
	NULL AS Xray1RequestType,
	NULL AS Xray1RequestDate,
	NULL AS Xray1RequestTime,
	NULL AS Xray1RequestSite,
	NULL AS Xray1RequestSide,
	NULL AS Xray2RequestType,
	NULL AS Xray2RequestDate,
	NULL AS Xray2RequestTime,
	NULL AS Xray2RequestSite,
	NULL AS Xray2RequestSide,
	NULL AS Xray3RequestType,
	NULL AS Xray3RequestDate,
	NULL AS Xray3RequestTime,
	NULL AS Xray3RequestSite,
	NULL AS Xray3RequestSide,
	NULL AS Xray4RequestType,
	NULL AS Xray4RequestDate,
	NULL AS Xray4RequestTime,
	NULL AS Xray4RequestSite,
	NULL AS Xray4RequestSide,
	NULL AS Xray5RequestType,
	NULL AS Xray5RequestDate,
	NULL AS Xray5RequestTime,
	NULL AS Xray5RequestSite,
	NULL AS Xray5RequestSide,
	NULL AS Xray6RequestType,
	NULL AS Xray6RequestDate,
	NULL AS Xray6RequestTime,
	NULL AS Xray6RequestSite,
	NULL AS Xray6RequestSide,
	Investigation1 AS Investigation1RequestType,
	NULL AS Investigation1RequestDate,
	NULL AS Investigation1RequestTime,
	Investigation2 AS Investigation2RequestType,
	NULL AS Investigation2RequestDate,
	NULL AS Investigation2RequestTime,
	Investigation3 AS Investigation3RequestType,
	NULL AS Investigation3RequestDate,
	NULL AS Investigation3RequestTime,
	Investigation4 AS Investigation4RequestType,
	NULL AS Investigation4RequestDate,
	NULL AS Investigation4RequestTime,
	Investigation5 AS Investigation5RequestType,
	NULL AS Investigation5RequestDate,
	NULL AS Investigation5RequestTime,
	Investigation6 AS Investigation6RequestType,
	NULL AS Investigation6RequestDate,
	NULL AS Investigation6RequestTime,
	Treatment1 AS Treatment1TreatmentType,
	NULL AS Treatment1TreatmentDate,
	NULL AS Treatment1TreatmentTime,
	Treatment2 AS Treatment2TreatmentType,
	NULL AS Treatment2TreatmentDate,
	NULL AS Treatment2TreatmentTime,
	Treatment3 AS Treatment3TreatmentType,
	NULL AS Treatment3TreatmentDate,
	NULL AS Treatment3TreatmentTime,
	Treatment4 AS Treatment4TreatmentType,
	NULL AS Treatment4TreatmentDate,
	NULL AS Treatment4TreatmentTime,
	Treatment5 AS Treatment5TreatmentType,
	NULL AS Treatment5TreatmentDate,
	NULL AS Treatment5TreatmentTime,
	Treatment6 AS Treatment6TreatmentType,
	NULL AS Treatment6TreatmentDate,
	NULL AS Treatment6TreatmentTime,
	SportActivity AS SportsActivity,
	CASE OutcomeOfAttendance 
		WHEN '09' THEN '1'
	END AS LeftWithoutSeen,
	CasCardNumber AS CascardNumber,
	'' AS PatientRefNo,
	'' AS BREACHKEY1,
	'' AS BREACHREASON1,
	NULL AS BREACHSTARTDATE1,
	NULL AS BREACHSTARTTIME1,
	NULL AS BREACHENDDATE1,
	NULL AS BREACHENDTIME1,
	'' AS BREACHKEY2,
	'' AS BREACHREASON2,
	NULL AS BREACHSTARTDATE2,
	NULL AS BREACHSTARTTIME2,
	NULL AS BREACHENDDATE2,
	NULL AS BREACHENDTIME2,
	'' AS BREACHKEY3,
	'' AS BREACHREASON3,
	NULL AS BREACHSTARTDATE3,
	NULL AS BREACHSTARTTIME3,
	NULL AS BREACHENDDATE3,
	NULL AS BREACHENDTIME3,
	'' AS BREACHKEY4,
	'' AS BREACHREASON4,
	NULL AS BREACHSTARTDATE4,
	NULL AS BREACHSTARTTIME4,
	NULL AS BREACHENDDATE4,
	NULL AS BREACHENDTIME4,
	'' AS BREACHKEY5,
	'' AS BREACHREASON5,
	NULL AS BREACHSTARTDATE5,
	NULL AS BREACHSTARTTIME5,
	NULL AS BREACHENDDATE5,
	NULL AS BREACHENDTIME5,
	'' AS BREACHKEY6,
	'' AS BREACHREASON6,
	NULL AS BREACHSTARTDATE6,
	NULL AS BREACHSTARTTIME,
	NULL AS BREACHENDDATE6,
	NULL AS BREACHENDTIME6,
	NULL AS ConsultationRequestDate1,
	NULL AS ConsultationRequestTime1,
	NULL AS ConsultationRequestCompletedDate1,
	NULL AS ConsultationRequestCompletedTime1,
	'''' AS ConsultationRequestSpecialty1,
	NULL AS ConsultationRequestDate2,
	NULL AS ConsultationRequestTime2,
	NULL AS ConsultationRequestCompletedDate2,
	NULL AS ConsultationRequestCompletedTime2,
	'''' AS ConsultationRequestSpecialty2,
	NULL AS ConsultationRequestDate3,
	NULL AS ConsultationRequestTime3,
	NULL AS ConsultationRequestCompletedDate3,
	NULL AS ConsultationRequestCompletedTime3,
	'''' AS ConsultationRequestSpecialty3,
	NULL AS ConsultationRequestDate4,
	NULL AS ConsultationRequestTime4,
	NULL AS ConsultationRequestCompletedDate4,
	NULL AS ConsultationRequestCompletedTime4,
	'''' AS ConsultationRequestSpecialty4,
	NULL AS ConsultationRequestDate5,
	NULL AS ConsultationRequestTime5,
	NULL AS ConsultationRequestCompletedDate5,
	NULL AS ConsultationRequestCompletedTime5,
	'''' AS ConsultationRequestSpecialty5,
	NULL AS ConsultationRequestDate6,
	NULL AS ConsultationRequestTime6,
	NULL AS ConsultationRequestCompletedDate6,
	NULL AS ConsultationRequestCompletedTime6,
	'''' AS ConsultationRequestSpecialty6,
	NULL AS AttendanceNumber
FROM 
	[7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].[dbo].[XEDDS_General] EDG
WHERE
	SenderOrganisation='Cent' AND
	AdministrativeArrivalDate <'18 November 2016' AND
	AdministrativeArrivalDate > @LastAttendanceDateString

END

GO
