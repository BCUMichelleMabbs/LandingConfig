SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceWestSymphonyHourly]
	
AS
BEGIN
	
SET NOCOUNT ON;

DECLARE @LPIType AS INT
DECLARE @LPIBackupType AS int
declare @NHSid int 
set @NHSid =(select top 1 lkp_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups where lkp_name = 'NHSNumber')
set @LPIType=(select top 1 lkp_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookups where lkp_name = 'BCUW PMI Number')
set @LPIBackupType=(select top 1 lkp_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookups where lkp_name = 'Symphony Patient ID')
--SELECT * FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookups where lkp_name LIKE '%Patient%'
--SELECT * FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookups where lkp_parentid=1581

SELECT DISTINCT
	'West',
	'WEDS',
	LEFT(ISNULL(
		(SELECT TOP 1 RTRIM(psi_system_id) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient_system_ids PSID WHERE PSID.psi_system_name=@LPIType AND psi_pid=pat_pid),
		(SELECT TOP 1 RTRIM(psi_system_id) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient_system_ids PSID WHERE PSID.psi_system_name=@LPIBackupType AND psi_pid=pat_pid)
	),8) AS LocalPatientIdentifier,
    NULLIF(RTRIM((SELECT TOP 1 LEFT(psi_system_id,10) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.patient_System_ids WHERE psi_system_name = @NHSid AND psi_pid=pat_pid)),'') AS NHSNumber,
    UPPER(RTRIM(pat_surname) + ', ' + RTRIM(pat_forename)) AS PatientName, 
	pat_dob,
    CAST(a.atd_arrivaldate AS DATE) AS ArrivalDate, 
	CAST(a.atd_arrivaldate AS TIME) AS ArrivalTime,
	CASE WHEN cast(a.atd_dischdate AS DATE) >= '1 JANUARY 2100' then null ELSE CAST(a.atd_dischdate AS DATE) END AS DepartureDate, 
	CASE WHEN cast(a.atd_dischdate AS DATE) >= '1 JANUARY 2100' then null ELSE CAST(a.atd_dischdate AS TIME) END AS DepartureTime, 
	NULL as SiteCode, 
	NULL AS WaitingForBedDate,
	NULL AS WaitingForBedTime,
	'' AS WaitingForBedConsultant,
	'' AS WaitingForBedGMC,
	'' AS WaitingForBedWard,
	'' AS WaitingForBedSpecialty,
	(SELECT TOP 1 tri_category FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.triage WHERE tri_atdid = a.atd_id and tri_inactive <> 1 ORDER BY tri_date DESC) AS TriageCategory, 
    --(SELECT TOP 1 CFGL.loc_name FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[Current_Locations] CL LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.cfg_locations CFGL ON CFGL.loc_id = CL.cul_locationid WHERE a.atd_id=CL.cul_atdid ORDER BY CL.cul_locationdate DESC) AS CurrentLocation, 
	--Change to current location as request by EJ on 8-12-2020
	(SELECT TOP 1 CFGL.loc_name FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[Current_Locations] CL LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.cfg_locations CFGL ON CFGL.loc_id = CL.cul_locationid WHERE a.atd_id=CL.cul_atdid ORDER BY CL.cul_update DESC) AS CurrentLocation, 
    case a.atd_attendancetype when 1 then '02' else case right(a.atd_num, 1) when '1' then '01' else '03' 	end end AS AttendanceCategory, 
	--Fix for missing PatGroup2_Disch table from R Henderson 2-12-2020
	CASE a.atd_reason 
              WHEN 0 THEN '99'
              ELSE isnull(left((
                     SELECT TOP 1 
                           not_text 
                     FROM 
                           [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.notes 
                     WHERE 
                           not_noteid = (
                                  SELECT TOP 1 
                                         flm_value 
                                  FROM 
                                         [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookupmappings 
                                  WHERE 
                                         flm_lkpid = a.atd_reason 
                                         AND flm_mtid = 8
                                  )
                     ), 2),'') end as PatientGroup,
    --case a.atd_attendancetype when 1 then COALESCE(NULLIF(p.not_text,''),'99') else isnull(left((select top 1 not_text from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.notes where not_noteid = 
    --(select top 1 flm_value from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookupmappings where flm_lkpid = a.atd_reason and flm_mtid = 8)), 2),'') end as PatientGroup,
    a.atd_arrmode AS ArrivalMode, 
    --'7A1AU' AS SiteCodeOfTreatment,
	CASE SUBSTRING(atd_num,0,CHARINDEX('-',atd_num))
		WHEN 'YGED' THEN '7A1AU'
		WHEN 'LLGH' THEN '7A1AV'
        WHEN 'YA' THEN '7A1CA'
		WHEN 'YP' THEN '7A1DC'
		WHEN 'YBB' THEN '7A1AX'
		WHEN 'YD' THEN '7A1AY'
		WHEN 'TM' THEN '7A1B2'
	END AS SiteCodeOfTreatment,
	GETDATE() AS CensusDateTime,
	--'Bangor Hospital' AS SiteDescription,
	CASE SUBSTRING(atd_num,0,CHARINDEX('-',atd_num))
		WHEN 'YGED' THEN 'Bangor Hospital'
		WHEN 'LLGH' THEN 'Llandudno General Hospital'
        WHEN 'YA' THEN 'Alltwen Hospital'
		WHEN 'YP' THEN 'Penrhos Stanley Hospital'
		WHEN 'YBB' THEN 'Bryn Beryl Hospital'
		WHEN 'YD' THEN 'Dolgellau Hospital'
		WHEN 'TM' THEN 'Tywyn & District War Memorial Hospital'
	END AS SiteDescription,
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
    [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.attendance_details a 
    inner join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.episodes on a.atd_epdid = epd_id 
    inner join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.patient on epd_pid = pat_pid 
    --left outer join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[PatGroup2_Disch] p on a.atd_id = p.atd_id
	LEFT JOIN (SELECT [tri_atdid], MIN(tri_date) as tri_date FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.[dbo].[Triage] GROUP BY [tri_atdid]) tr2  ON tr2.[tri_atdid] = a.[atd_id]

WHERE 
    a.atd_arrivaldate between GETDATE() -3 and GETDATE() AND 
	(CAST(a.atd_dischdate AS DATE)>= '1 JANUARY 2100' OR a.atd_dischdate IS NULL) AND
    atd_deleted = 0 


END

GO
