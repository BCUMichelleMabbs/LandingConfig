SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceWestHourly]
	
AS
BEGIN
	
SET NOCOUNT ON;

SELECT 
	'West' AS Area,
	'Pims' AS Source,
    patnt.pasid as LocalPatientIdentifier, 
    patnt.nhs_identifier as NHSNumber, 
    patnt.surname + ', ' +patnt.forename as PatientName, 
	patnt.dttm_of_birth AS PatientDateOfBirth,
    CAST(aeatt.arrived_dttm AS DATE) AS ArrivalDate,
	CAST(aeatt.arrived_dttm AS TIME) AS ArrivalTime,
    CAST(aeatt.departed_dttm AS DATE) AS DepartureDate,
	CAST(aeatt.departed_dttm AS TIME) AS DepartureTime,
	parnt.main_ident as SiteCode, 
    
    NULL AS WaitingForBedDate,
	NULL AS WaitingForBedTime,
	'' AS WaitingForBedConsultant,
	'' AS WaitingForBedGMC,
	'' AS WaitingForBedWard,
	'' AS WaitingForBedSpecialty,
	AER.TRCAT_REFNO  AS TriageCategory,
    SP.DESCRIPTION AS CurrentLocation,
    aeatt.ATCAT_REFNO AS AttendanceCategory,
    aeatt.AEPGR_REFNO AS PatientGroup,
    aeatt.ARMOD_REFNO AS ArrivalMode,  
    CASE
		WHEN parnt.main_ident='01' THEN '7A1AU'
		WHEN parnt.main_ident='02' THEN '7A1AV'
		WHEN parnt.main_ident='04' THEN '7A1AX'
		WHEN parnt.main_ident='11' THEN '7A1AY'
		WHEN parnt.main_ident='15' THEN '7A1DC'
		WHEN parnt.main_ident='36' THEN '7A1CA'
		WHEN parnt.main_ident='TWMH' THEN '7A1B2'
		ELSE parnt.main_ident
    END AS SiteCodeOfTreatment,
	GETDATE() AS CensusDateTime,
	parnt.description as SiteDescription,
	aeatt.AEATT_REFNO AS AttendanceIdentifier,
	NULL AS BreachEndDate,
	NULL AS BreachEndTime,
	'' AS BreachReason,
	(	SELECT TOP (1) pro.SURNAME + ', ' + pro.FORENAME AS Clinician
        FROM	[7A1AUSRVIPMSQL].iPMProduction.dbo.AE_ATTENDANCES AS ae
		INNER JOIN	[7A1AUSRVIPMSQL].iPMProduction.dbo.AE_STAYS AS ah ON ah.AEATT_REFNO = ae.AEATT_REFNO
		INNER JOIN	[7A1AUSRVIPMSQL].iPMProduction.dbo.PATIENTS AS p ON p.PATNT_REFNO = ae.PATNT_REFNO
		INNER JOIN	[7A1AUSRVIPMSQL].iPMProduction.dbo.PROF_CARERS AS pro ON pro.PROCA_REFNO = ah.PROCA_REFNO
		INNER JOIN	[7A1AUSRVIPMSQL].iPMProduction.dbo.SPECIALTIES AS spec ON spec.SPECT_REFNO = ah.SPECT_REFNO
		WHERE 1 = 1
		AND (p.PASID = patnt.PASID)
		AND (CONVERT(date, ae.ARRIVED_DTTM) = CONVERT(date, aeatt.ARRIVED_DTTM))
		ORDER BY ah.SEEN_DTTM DESC
	) AS EDClinicianSeen,
	DATEDIFF(MINUTE, CAST(aeatt.arrived_dttm AS DATETIME), GETDATE()) as [TimeWaiting],
	CAST(aeatt.MED_DISCH_DTTM AS DATE) AS TreatmentEndDate,
	CAST(aeatt.MED_DISCH_DTTM AS TIME) AS TreatmentEndTime,
	CAST(aeatt.treated_dttm AS DATE) AS TreatmentStartDate,
	CAST(aeatt.treated_dttm AS TIME) AS TreatmentStartTime,
	CAST(aear.TriageEnd AS DATE) as [TriageEndDate],
	CAST(aear.TriageEnd AS TIME) as [TriageEndTime],
	CAST(aear.[TriageStart] as DATE) as [TriageStartDate],
	CAST(aear.[TriageStart] as TIME) as [TriageStartTime],
	Lodged_Flag AS [Lodged]
FROM 
    [7A1AUSRVIPMSQL].iPMProduction.dbo.ae_attendances aeatt 
    join [7A1AUSRVIPMSQL].iPMProduction.dbo.patients patnt on patnt.patnt_refno = aeatt.patnt_refno and isnull(patnt.archv_flag,'N')='N'
    join [7A1AUSRVIPMSQL].iPMProduction.dbo.health_organisations heorg on aeatt.heorg_refno = heorg.heorg_Refno 
    join [7A1AUSRVIPMSQL].iPMProduction.dbo.health_organisations parnt on heorg.parnt_refno = parnt.heorg_Refno 
	LEFT JOIN [7A1AUSRVIPMSQL].iPMProduction.dbo.ae_attendance_roles AER ON aeatt.AEATT_REFNO=AER.AEATT_REFNO AND AER.atrol_refno = (SELECT MAX(atrol1.atrol_refno) FROM [7A1AUSRVIPMSQL].iPMProduction.dbo.ae_attendance_roles atrol1 WHERE aeatt.aeatt_refno = atrol1.aeatt_refno AND ISNULL(atrol1.archv_flag,'N') = 'N')
	LEFT JOIN [7A1AUSRVIPMSQL].iPMProduction.dbo.[REFERENCE_VALUES] RV ON AER.TRCAT_REFNO=RV.RFVAL_REFNO
	LEFT JOIN [7A1AUSRVIPMSQL].iPMProduction.dbo.[SERVICE_POINTS] SP ON aeatt.SPONT_REFNO=SP.SPONT_REFNO
	--LEFT JOIN [7A1AUSRVIPMSQL].[iPMProduction].[dbo].[AE_ATTENDANCE_ROLES]  aear ON aeatt.aeatt_Refno=aear.aeatt_Refno
	LEFT JOIN (SELECT aeatt_Refno, MIN(Triag_Start_dttm) AS [TriageStart], MIN(Triag_end_dttm) as TriageEnd FROM [7A1AUSRVIPMSQL].[iPMProduction].[dbo].[AE_ATTENDANCE_ROLES] GROUP BY [aeatt_Refno]) aear  ON aear.[aeatt_Refno] = aeatt.aeatt_Refno

WHERE 
    --aeatt.arrived_dttm between getdate() - 3 and getdate() AND 
	aeatt.departed_dttm IS NULL AND
    isnull(aeatt.archv_flag,'N')='N'


END

GO
