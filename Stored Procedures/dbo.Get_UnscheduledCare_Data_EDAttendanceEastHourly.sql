SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceEastHourly]
	
AS
BEGIN
	
SET NOCOUNT ON;

SELECT
	'East' AS Area,
	'Symphony' AS Source,
	pat_pid AS LocalPatientIdentifier, 
    ISNULL(REPLACE(NHSV.psi_system_id,' ',''),'') AS NHSNumber, 
    UPPER(RTRIM(pat_surname) + ', ' + RTRIM(pat_forename)) AS PatientName, 
	pat_dob AS PatientDateOfBirth,
    CAST(a.atd_arrivaldate AS DATE) AS ArrivalDate, 
	CAST(a.atd_arrivaldate AS TIME) AS ArrivalTime,
	CASE WHEN cast(a.atd_dischdate AS DATE) >= '1 JANUARY 2100' then null ELSE CAST(a.atd_dischdate AS DATE) END AS DepartureDate, 
	CASE WHEN cast(a.atd_dischdate AS DATE) >= '1 JANUARY 2100' then null ELSE CAST(a.atd_dischdate AS TIME) END AS DepartureTime,
    151 as SiteCode, 
    NULL AS WaitingForBedDate,
	NULL AS WaitingForBedTime,
	'' AS WaitingForBedConsultant,
	'' AS WaitingForBedGMC,
	'' AS WaitingForBedWard,
	'' AS WaitingForBedSpecialty,
	(SELECT TOP 1 tri_category FROM [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].triage WHERE tri_atdid = a.atd_id and tri_inactive <> 1 ORDER BY tri_date ASC) AS TriageCategory, 
    (SELECT TOP 1 CFGL.loc_name FROM [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].[Current_Locations] CL LEFT JOIN [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].cfg_locations CFGL ON CFGL.loc_id = CL.cul_locationid WHERE a.atd_id=CL.cul_atdid ORDER BY CL.cul_locationdate DESC) AS CurrentLocation, 
    case a.atd_attendancetype when 1 then '02' else case right(a.atd_num, 1) when '1' then '01' else '03' 	end end AS AttendanceCategory, 
    case a.atd_attendancetype when 1 then COALESCE(NULLIF(p.not_text,''),'99') else isnull(left((select top 1 not_text from [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].notes where not_noteid = 
    (select top 1 flm_value from [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].lookupmappings where flm_lkpid = a.atd_reason and flm_mtid = 8)), 2),'') end as PatientGroup,
    a.atd_arrmode AS ArrivalMode, 
    '7A1A4' AS SiteCodeOfTreatment,
	GETDATE() AS CensusDateTime,
	'Wrexham Maelor Hospital' AS SiteDescription,
	a.atd_id AS AttendanceIdentifier,
	NULL AS BreachEndDate,
	NULL AS BreachEndTime,
	'' AS BreachReason,
	'' AS EDClinicianSeen,
	DATEDIFF(MINUTE,  CAST(a.atd_arrivaldate AS DATETIME), GETDATE()) AS [TimeWaiting],
	NULL AS TreatmentEndDate,
	NULL AS TreatmentEndTime,
	NULL AS TreatmentStartDate,
	NULL AS TreatmentStartTime,
	NULL as [TriageEndDate],
	NULL as [TriageEndTime],
	CAST(tr2.tri_date AS DATE) as [TriageStartDate],
	CAST(tr2.tri_date AS TIME) as [TriageStartTime],
		NULL AS Lodged
FROM 
    [RYPA4SRVSQL0014.CYMRU.NHS.UK].Wrexham_Live.dbo.attendance_details a 
    inner join [RYPA4SRVSQL0014.CYMRU.NHS.UK].Wrexham_Live.dbo.episodes on a.atd_epdid = epd_id 
    inner join [RYPA4SRVSQL0014.CYMRU.NHS.UK].Wrexham_Live.dbo.patient on epd_pid = pat_pid 
    left join [RYPA4SRVSQL0014.CYMRU.NHS.UK].Wrexham_Live.dbo.NHS_numbers_View NHSV ON NHSV.psi_pid = pat_pid 
    --left join [RYPA4SRVSQL0014.CYMRU.NHS.UK].Wrexham_Live.dbo.Patient_PasNumbers_View PATV ON PATV.psi_pid = pat_pid
	left outer join [RYPA4SRVSQL0014.CYMRU.NHS.UK].Wrexham_Live.dbo.[PatGroup2_Disch] p on a.atd_id = p.atd_id
	LEFT JOIN (SELECT [tri_atdid], MIN(tri_date) as tri_date FROM [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].[Triage] GROUP BY [tri_atdid]) tr2  ON tr2.[tri_atdid] = a.[atd_id]

WHERE 
	a.atd_arrivaldate between GETDATE() -5 and GETDATE() AND 
	(CAST(a.atd_dischdate AS DATE)>= '1 JANUARY 2100' OR a.atd_dischdate IS NULL) AND
    atd_deleted = 0 AND 
    epd_deptid = 1
   	
	

END
GO
