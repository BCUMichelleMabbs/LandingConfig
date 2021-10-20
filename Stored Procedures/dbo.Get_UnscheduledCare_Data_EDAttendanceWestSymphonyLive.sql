SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceWestSymphonyLive]
	
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
    NULL as HospitalId, 
    
	NULL AS WaitingForBedDate,
	NULL AS WaitingForBedTime,
	'' AS WaitingForBedConsultant,
	'' AS WaitingForBedGMC,
	'' AS WaitingForBedWard,
	'' AS WaitingForBedSpecialty,
	CASE a.atd_attendancetype
		WHEN 1 THEN '6'
		ELSE
		(SELECT TOP 1 tri_category FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.triage WHERE tri_atdid = a.atd_id and tri_inactive <> 1 ORDER BY tri_date DESC) 
	END AS TriageCategory, 
    --(SELECT TOP 1 CFGL.loc_name FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[Current_Locations] CL LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.cfg_locations CFGL ON CFGL.loc_id = CL.cul_locationid WHERE a.atd_id=CL.cul_atdid ORDER BY CL.cul_locationdate DESC) AS CurrentLocation, 
	--Change to use update date for current location as request by EJ on 8-12-2020
	--(SELECT TOP 1 CFGL.loc_name FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[Current_Locations] CL LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.cfg_locations CFGL ON CFGL.loc_id = CL.cul_locationid WHERE a.atd_id=CL.cul_atdid ORDER BY CL.cul_update DESC) AS CurrentLocation, 
	--Change to use created date for current location as request by EJ on 21-12-2020
	(SELECT TOP 1 CFGL.loc_name FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[Current_Locations] CL LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.cfg_locations CFGL ON CFGL.loc_id = CL.cul_locationid WHERE a.atd_id=CL.cul_atdid ORDER BY CL.cul_created DESC) AS CurrentLocation, 

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
                     ), 2),'') end as AttendanceGroup,


    --case a.atd_attendancetype when 1 then COALESCE(NULLIF(p.not_text,''),'99') else isnull(left((select top 1 not_text from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.notes where not_noteid = 
    --(select top 1 flm_value from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookupmappings where flm_lkpid = a.atd_reason and flm_mtid = 8)), 2),'') end as AttendanceGroup,
    CASE 
		WHEN a.atd_attendancetype = '1' THEN '98' 
		WHEN a.atd_arrmode IN ('0','6976','6639','6640') THEN '20' 
		WHEN a.atd_arrmode IN ('6629','6631','6632') THEN '01' 
		WHEN a.atd_arrmode='6634' THEN '02' 
		WHEN a.atd_arrmode='6636' THEN '03' 
		WHEN a.atd_arrmode IN ('6630','6637','6638') THEN '05' 
		WHEN a.atd_arrmode='6633' THEN '06' 
		WHEN a.atd_arrmode='6635' THEN '07' 
	END AS ArrivalMode, 
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
	'Y' AS Active,
	--'Bangor Hospital',
	CASE SUBSTRING(atd_num,0,CHARINDEX('-',atd_num))
		WHEN 'YGED' THEN 'Bangor Hospital'
		WHEN 'LLGH' THEN 'Llandudno General Hospital'
        WHEN 'YA' THEN 'Alltwen Hospital'
		WHEN 'YP' THEN 'Penrhos Stanley Hospital'
		WHEN 'YBB' THEN 'Bryn Beryl Hospital'
		WHEN 'YD' THEN 'Dolgellau Hospital'
		WHEN 'TM' THEN 'Tywyn & District War Memorial Hospital'
	END,
	NULL AS TreatmentStartDate,
	NULL AS TreatmentStartTime,
	NULL AS TreatmentEndDate,
	NULL AS TreatmentEndTime,
	NULL AS BreachEndDate,
	NULL AS BreachEndTime,
	'' AS BreachReason,
	CAST(tr2.tri_date AS DATE) as [TriageStartDate],
	CAST(tr2.tri_date AS TIME) as [TriageStartTime],
	NULL as [TriageEndDate],
	NULL as [TriageEndTime],
	DATEDIFF(MINUTE,  CAST(a.atd_arrivaldate AS DATETIME), GETDATE()) AS [TimeWaiting],
	'' AS EDClinicianSeen,
	a.atd_id AS AttendanceIdentifier,
	NULL AS Note1,
	NULL AS NoteType1,
	NULL AS Note2,
	NULL AS NoteType2,
	NULL AS Note3,
	NULL AS NoteType3,
	--cast(replace(replace(a.atd_complaintid,',',''),'''','') as varchar(255)) AS [PresentingComplaint],
	PC.lkp_name AS PresentingComplaint,
	NULL AS Lodged,
	NULLIF(a.atd_dischoutcome,0) AS DischargeOutcome,
	LastTriage.tri_complaint AS TriageComplaint,
	LastTriage.tri_discriminator AS TriageDiscriminator,
	LastTriage.tri_painscore AS TriagePainScore,
	NULL AS ConsultationRequestDate1,
	NULL AS ConsultationRequestTime1,
	NULL AS ConsultationRequestCompletedDate1,
	NULL AS ConsultationRequestCompletedTime1,
	NULL AS ConsultationRequestSpecialty1,
	NULL AS ConsultationRequestDate2,
	NULL AS ConsultationRequestTime2,
	NULL AS ConsultationRequestCompletedDate2,
	NULL AS ConsultationRequestCompletedTime2,
	NULL AS ConsultationRequestSpecialty2,
	NULL AS ConsultationRequestDate3,
	NULL AS ConsultationRequestTime3,
	NULL AS ConsultationRequestCompletedDate3,
	NULL AS ConsultationRequestCompletedTime3,
	NULL AS ConsultationRequestSpecialty3

FROM 
    [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.attendance_details a 
    inner join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.episodes on a.atd_epdid = epd_id 
    inner join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.patient on epd_pid = pat_pid 
    --left outer join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.[PatGroup2_Disch] p on a.atd_id = p.atd_id
	LEFT JOIN (SELECT [tri_atdid], MIN(tri_date) as tri_date FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.[dbo].[Triage] GROUP BY [tri_atdid]) tr2  ON tr2.[tri_atdid] = a.[atd_id]
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups PC ON a.atd_complaintid=PC.lkp_id AND PC.lkp_parentid=8772
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.[dbo].[Triage] LastTriage ON a.atd_id =LastTriage.tri_atdid AND 
		LastTriage.tri_created=(SELECT max(tri_created) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.[dbo].[Triage] ThisTriage WHERE a.atd_id=ThisTriage.tri_atdid)
WHERE 
    a.atd_arrivaldate between GETDATE() -3 and GETDATE() AND 
    atd_deleted = 0 AND 
    --epd_deptid = 1 AND
	LEFT(A.ATD_NUM,2) IN ('LL','TM','ED','YA','YP','YB','YG')	

END

GO
