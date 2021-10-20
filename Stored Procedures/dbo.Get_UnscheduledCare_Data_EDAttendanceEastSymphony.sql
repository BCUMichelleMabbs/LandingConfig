SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceEastSymphony]
	
AS
BEGIN
	
	SET NOCOUNT ON;



	
	
DECLARE @LastAttendanceDate AS DATE = (SELECT ISNULL(MAX(ArrivalDate),'29 September 2021') FROM [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] WHERE Area='East' AND Source='WEDS')
DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)--+' 23:59:59.995'
DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())
--DECLARE @DateToString AS VARCHAR(30) = '28 february 2021'
	
EXEC('

USE [EMIS_SYM_BCU_Live]
declare @flm_mtid int, @NHSid int 
DECLARE @LPIType AS INT
DECLARE @LPIBackupType AS int

set @LPIType=(select top 1 lkp_id from dbo.lookups where lkp_name = ''BCUE PMI Number'')
set @LPIBackupType=(select top 1 lkp_id from dbo.lookups where lkp_name = ''Symphony Patient ID'')

declare @Diagn int
set @flm_mtid = (select top 1 mt_id from dbo.mappingtypes where mt_name = ''EDDS'')
set @NHSid =(select top 1 lkp_id from dbo.Lookups where lkp_name = ''NHSNumber'')



set @Diagn = (select top 1 rps_value from dbo.cfg_reportsettings where rps_name = ''Diagnosis'')
DECLARE @ImagingRequest AS TABLE(
	RowNumber		INT,
	AttendanceId	INT,
	RequestDate		DATE,
	RequestTime		TIME,
	RequestType		INT,
	RequestSite		INT,
	RequestSide		INT
)
INSERT INTO @ImagingRequest
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY R.req_atdid ORDER BY R.req_date ASC) AS RowNumber,
	A.atd_id AS AttendanceId,
	CAST(R.req_date AS DATE) AS RequestDate,
	CAST(R.req_date AS TIME) AS RequestTime,
	R.req_request AS RequestType,
	R.req_field1 AS RequestSite,
	R.req_field2 AS RequestSide
FROM
	dbo.Request_Details R
	INNER JOIN dbo.Attendance_Details A ON R.req_atdid=A.atd_id
WHERE
	R.req_depid IN (Select rps_value from dbo.cfg_reportsettings where rps_name = ''Radiology'') AND 
	R.req_inactive = 0 AND
	CAST(a.atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(a.atd_arrivaldate AS DATE) < '''+@DateToString+'''
) AS ImagingRequests


---Collecting Investigation Mvdefs
set nocount on
DECLARE @TemporaryInv_Disch AS TABLE(
	id	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	res_atdid	INT,
	res_date	DATETIME,
	res_result	VARCHAR(200)
)
DECLARE @Pathology_Requests_Disch AS TABLE(
	resID	INT NOT NULL IDENTITY(1,1),
	RES_ATDID	INT,
	res_date	DATETIME,
	res_result	INT
)						
insert @TemporaryInv_Disch (res_atdid,res_date,res_result)
select res_atdid, res_date, res_field6 from dbo.result_details
inner join dbo.attendance_details on atd_id = res_atdid
where res_depid = 119 and res_inactive = 0 
and CAST(atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(atd_arrivaldate AS DATE) < '''+@DateToString+'''


										 
declare @atdid int, @max int, @min int
declare @MVDEFValue varchar(200)
declare @resdate datetime
declare @position int
declare @SingleValue varchar(150)
						
						
select @max= max([id]), @min = min ([id]) from @TemporaryInv_Disch


while @min < = @max
begin

	--	print @min
	select @atdid =res_atdid ,@resdate=res_date, @MVDEFValue=res_result from @TemporaryInv_Disch where id = @min
 	set @position=0
	set @SingleValue = '' ''
	set @MVDEFValue = isnull(@MVDEFValue,'''')	
	if @MVDEFValue <> '''' and @MVDEFValue <> ''0''
	begin
			set @position=patindex(''%||%'',@MVDEFValue)
			if @position>0 
				while @position>0
				begin	
										  	
					--print @MVDEFValue
					--print  write code to split the value and save it in the temp table
					set @SingleValue = left(@MVDEFValue,@position-1)
					--print ''YA pls save value here; '' + @SingleValue 


					insert into @Pathology_Requests_Disch (res_atdid,res_date,res_result)
					values (@atdid,@resdate, @SingleValue)
											
					set @MVDEFValue = substring(@MVDEFValue,@position+2,200)
					--print @MVDEFValue	
					set @position=patindex(''%||%'',@MVDEFValue)
					if @position=0
					begin
						--print '' save value here; '' + @MVDEFValue
						insert into @Pathology_Requests_Disch (res_atdid,res_date,res_result)
						values (@atdid,@resdate, @MVDEFValue)
					end 											
				end
			else
				begin
					--print '' save value here; '' + @MVDEFValue
						insert into @Pathology_Requests_Disch (res_atdid,res_date,res_result)
						values (@atdid,@resdate, @MVDEFValue)
				end
		end					       					
		set @min = @min + 1
							
end


DECLARE @PathologyRequest AS TABLE(
	RowNumber		INT,
	AttendanceId	INT,
	RequestDate		DATE,
	RequestTime		TIME,
	RequestType		INT
)
INSERT INTO @PathologyRequest
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY PR.res_atdid ORDER BY PR.res_date ASC) AS RowNumber,
	res_atdid AS AttendanceId,
	CAST(PR.res_date AS DATE) AS RequestDate,
	CAST(PR.res_date AS TIME) AS RequestTime,
	PR.res_result AS RequestType
FROM
	@Pathology_Requests_Disch PR
) AS PathologyRequests

---Collecting Treatment Mvdefs.... LKa & CM
set nocount on
DECLARE @TemporaryTreat_Disch AS TABLE(
	id	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	res_atdid	INT,
	res_date	DATETIME,
	res_result	VARCHAR(200)
)
DECLARE @Treatments_Requests_Disch AS TABLE(
	resID	INT NOT NULL IDENTITY(1,1),
	RES_ATDID	INT,
	res_date	DATETIME,
	res_result	INT
)										
insert  @TemporaryTreat_Disch (res_atdid,res_date,res_result)
select res_atdid, res_date, res_field6 from dbo.result_details
inner join dbo.attendance_details on res_atdid = atd_id 
where res_depid in (Select rps_value from dbo.cfg_reportsettings where rps_name = ''Treatment'')
and res_inactive = 0 
and CAST(atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(atd_arrivaldate AS DATE) < '''+@DateToString+'''
	
insert  @TemporaryTreat_Disch (res_atdid,res_date,res_result)				
select res_atdid, res_date, res_result from dbo.result_details
inner join dbo.attendance_details on res_atdid = atd_id 
where res_depid in (Select rps_value from dbo.cfg_reportsettings where rps_name = ''Treatment'')
and res_inactive = 0 
and CAST(atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(atd_arrivaldate AS DATE) < '''+@DateToString+'''
									
select @max= max([id]), @min = min ([id]) from @TemporaryTreat_Disch


while @min < = @max
begin

	select @atdid =res_atdid , @MVDEFValue=res_result, @resdate=res_date from @TemporaryTreat_Disch where id = @min
 	set @position=0
	set @SingleValue = '' ''
	set @MVDEFValue = isnull(@MVDEFValue,'''')	
	if @MVDEFValue <> '''' and @MVDEFValue <> ''0''
	begin
			set @position=patindex(''%||%'',@MVDEFValue)
			if @position>0 
				while @position>0
				begin	
					--print @MVDEFValue
					--print  write code to split the value and save it in the temp table
					set @SingleValue = left(@MVDEFValue,@position-1)
										
					insert into @Treatments_Requests_Disch (res_atdid,res_date,res_result)
					values (@atdid,@resdate, @SingleValue)
											
					set @MVDEFValue = substring(@MVDEFValue,@position+2,200)
					--print @MVDEFValue	
					set @position=patindex(''%||%'',@MVDEFValue)
					if @position=0
					begin
						--print '' save value here; '' + @MVDEFValue
						insert into @Treatments_Requests_Disch (res_atdid,res_result,res_date)
						values (@atdid, @MVDEFValue, @resdate)
					end 											
				end
			else
				begin
					--print '' save value here; '' + @MVDEFValue
						insert into @Treatments_Requests_Disch (res_atdid,res_result,res_date)
						values (@atdid,@MVDEFValue,@resdate)
				end
		end					       					
		set @min = @min + 1
end

DECLARE @Treatment AS TABLE(
	RowNumber		INT,
	AttendanceId	INT,
	TreatmentDate	DATE,
	TreatmentTime	TIME,
	TreatmentType	INT
)
INSERT INTO @Treatment
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY TR.RES_ATDID ORDER BY TR.res_date ASC) AS RowNumber,
	TR.RES_ATDID AS AttendanceId,
	CAST(TR.res_date AS DATE) AS RequestDate,
	CAST(TR.res_date AS TIME) AS RequestTime,
	TR.res_result AS RequestType
FROM
	@Treatments_Requests_Disch TR
) AS Treatment
DECLARE @Diagnosis AS TABLE(
	RowNumber			INT,
	AttendanceId		INT,
	DiagnosisDate		DATE,
	DiagnosisTime		TIME,
	DiagnosisType		INT,
	DiagnosisSite		INT,
	DiagnosisSide		INT
)
INSERT INTO @Diagnosis
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY R.res_atdid ORDER BY R.res_date ASC,R.res_resid ASC) AS RowNumber,
	A.atd_id AS AttendanceId,
	CAST(R.res_date AS DATE) AS DiagnosisDate,
	CAST(R.res_date AS TIME) AS DiagnosisTime,
	R.res_result AS DiagnosisType,
	R.res_field1 AS DiagnosisSite,
	R.res_field2 AS DiagnosisSide
FROM
	dbo.Result_details R
	INNER JOIN dbo.Attendance_Details A ON R.res_atdid=A.atd_id
WHERE
	R.res_depid IN (Select rps_value from dbo.cfg_reportsettings where rps_name = ''DIAGNOSIS'') AND 
	R.res_inactive = 0 AND
	CAST(atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(atd_arrivaldate AS DATE) < '''+@DateToString+'''
) AS Diagnosis

DECLARE @TriageTreatment AS TABLE(
	RowNumber			INT,
	AttendanceId		INT,
	TreatmentDate		DATE,
	TreatmentTime		TIME,
	Treatment			INT
)
INSERT INTO @TriageTreatment
SELECT
	ROW_NUMBER() OVER (PARTITION BY T.tri_atdid ORDER BY T.tri_date ASC,T.tri_trid ASC),
	A.atd_id,
	CAST(T.tri_date AS DATE),
	CAST(T.tri_date AS TIME),
	Value AS Treatment
FROM
	dbo.Triage T
	INNER JOIN dbo.Attendance_Details A ON T.tri_atdid=A.atd_id
	CROSS APPLY STRING_SPLIT(T.tri_treatment,''|'')
WHERE
	T.tri_inactive = 0 AND 
	Value !='''' AND
	CAST(A.atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(A.atd_arrivaldate AS DATE) < '''+@DateToString+'''

SELECT DISTINCT
	''East'' AS Area,
	''WEDS'' AS Source,
	a.atd_id AS AttendanceIdentifier,
	LEFT(ISNULL(
		(SELECT TOP 1 RTRIM(psi_system_id) FROM dbo.Patient_system_ids PSID WHERE PSID.psi_system_name=@LPIType AND psi_pid=pat_pid),
		(SELECT TOP 1 RTRIM(psi_system_id) FROM dbo.Patient_system_ids PSID WHERE PSID.psi_system_name=@LPIBackupType AND psi_pid=pat_pid)
	),8) AS LocalPatientIdentifier,
	NULLIF(RTRIM((SELECT TOP 1 LEFT(psi_system_id,10) FROM dbo.patient_System_ids WHERE psi_system_name = @NHSid AND psi_pid=pat_pid)),'''') AS NHSNumber,
	NULLIF(CASE PATGP.gp_code 
		WHEN ''G9999998'' THEN CAST(PATGP.gp_id AS VARCHAR(10))
		ELSE PATGP.gp_code
	END,'''') AS RegisteredGP,
	--NULLIF(PATGP.gp_code,'') AS RegisteredGP,
	--GPLINK.gpa_gpid AS RegisteredGP,
	NULLIF(GPPRAC.pr_praccode,'''') AS RegisteredPractice,
	--LEFT(GPPRAC.pr_praccode,6) AS RegisteredPractice,
	--GPAdd.add_addid AS RegisteredPractice,
	NULLIF(CASE 
		WHEN PermAdd.add_postcode IS NULL THEN (
			CASE WHEN TempAdd.add_postcode IS NULL THEN (
				CASE LEN(ContAdd.add_postcode)
					WHEN 5 THEN SubString(ContAdd.add_postcode,1,2) + ''   '' + SubString(ContAdd.add_postcode,3,3)
					WHEN 6 THEN SubString(ContAdd.add_postcode,1,3) + ''  '' +  SubString(ContAdd.add_postcode,4,3)
 					WHEN 7 THEN SubString(ContAdd.add_postcode,1,4) + '' '' + SubString(ContAdd.add_postcode,5,3)
					WHEN 8 THEN SubString(ContAdd.add_postcode,1,5) + '''' + SubString(ContAdd.add_postcode,6,3)
					ELSE ContAdd.add_postcode
				END)
				ELSE (
					CASE LEN(TempAdd.add_postcode) 
						WHEN 5 THEN SubString(TempAdd.add_postcode,1,2) + ''   '' + SubString(TempAdd.add_postcode,3,3)
						WHEN 6 THEN SubString(TempAdd.add_postcode,1,3) + ''  '' +  SubString(TempAdd.add_postcode,4,3)
						WHEN 7 THEN SubString(TempAdd.add_postcode,1,4) + '' '' + SubString(TempAdd.add_postcode,5,3)
						WHEN 8 THEN SubString(TempAdd.add_postcode,1,5) + '''' + SubString(TempAdd.add_postcode,6,3)
						ELSE TempAdd.add_postcode
					END) 
				END)
		ELSE (
			CASE LEN(PermAdd.add_postcode) 
				WHEN 5 THEN SubString(PermAdd.add_postcode,1,2) + ''   '' + SubString(PermAdd.add_postcode,3,3)
				WHEN 6 THEN SubString(PermAdd.add_postcode,1,3) + ''  '' +  SubString(PermAdd.add_postcode,4,3)
				WHEN 7 THEN SubString(PermAdd.add_postcode,1,4) + '' '' + SubString(PermAdd.add_postcode,5,3)
				WHEN 8 THEN SubString(PermAdd.add_postcode,1,5) + '''' + SubString(PermAdd.add_postcode,6,3)
				ELSE PermAdd.add_postcode
			END) 
	END,'''') AS PatientPostcode, 
	CASE 
		WHEN PermAdd.add_postcode IS NULL THEN (SELECT TOP 1 left(ha_pcg,3) FROM dbo.ha_pcg WHERE TempAdd.add_postcode=ha_pcg.ha_postcode )
		ELSE(SELECT TOP 1 LEFT(ha_pcg,3) FROM dbo.ha_pcg WHERE PermAdd.add_postcode=ha_pcg.ha_postcode )
	END AS DHA,
	NULLIF(REFGP.gp_code,'''') AS ReferringGP, 
    NULLIF(REFGPPRAC.pr_praccode,'''') AS ReferringPractice, 
	NULL AS IncidentDate,
	NULL AS IncidentTime,
	CAST(a.atd_arrivaldate AS DATE) AS ArrivalDate,
	CAST(a.atd_arrivaldate AS TIME) AS ArrivalTime,
	NULL AS AmbulanceHandoverDate,
	NULL AS AmbulanceHandoverTime,
	NULLIF(CAST(a.atd_regdate AS DATE),''2200-01-01'') AS RegisteredDate,
	CASE WHEN CAST(a.atd_regdate AS DATE)=''2200-01-01'' THEN NULL ELSE CAST(a.atd_regdate AS TIME) END AS RegisteredTime,
	CAST((SELECT TOP 1 tri_date FROM dbo.triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC) AS DATE) AS TriageStartDate, 
	CAST((SELECT TOP 1 tri_date FROM dbo.triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC) AS TIME) AS TriageStartTime,
	NULL AS TriageEndDate,
	NULL AS TriageEndTime, 
	CAST((SELECT TOP 1 res_date FROM dbo.result_details WHERE res_depid IN (SELECT rps_value FROM dbo.cfg_reportsettings WHERE rps_name = ''SeeA+EClinicianOutcome'') AND res_atdid = a.atd_id AND res_inactive<>1) AS DATE) AS EDClinicianSeenDate,
	CAST((SELECT TOP 1 res_date FROM dbo.result_details WHERE res_depid IN (SELECT rps_value FROM dbo.cfg_reportsettings WHERE rps_name = ''SeeA+EClinicianOutcome'') AND res_atdid = a.atd_id AND res_inactive<>1) AS TIME) AS EDClinicianSeenTime,
	--Can now use the @Treatment table instead
	Treatment1.TreatmentDate AS TreatmentStartDate,
	Treatment1.TreatmentTime AS TreatmentStartTime,
	--CAST((SELECT TOP (1) res_date FROM dbo.Result_details AS Treat WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings AS CFG_ReportSettings_8 WHERE (rps_name = ''Treatment''))) AND res_atdid = a.atd_id AND res_inactive <> 1 ORDER BY res_date ASC) AS DATE) AS TreatmentStartDate,
	--CAST((SELECT TOP (1) res_date FROM dbo.Result_details AS Treat WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings AS CFG_ReportSettings_8 WHERE (rps_name = ''Treatment''))) AND res_atdid = a.atd_id AND res_inactive <> 1 ORDER BY res_date ASC) AS TIME) AS TreatmentStartTime,
	--NEXT 2 ROWS ARE TAKEN FROM THE ORIGINAL MDS EXTRACT - not sure why it''s like this...?
	CAST((SELECT TOP (1) res_date FROM dbo.Result_details WHERE (res_depid = (SELECT dep_id FROM dbo.CFG_DEProcedures WHERE (dep_Caption = ''Breach Exception''))) AND res_atdid = a.atd_id AND res_inactive <> 1) AS DATE) AS TreatmentCompleteDate,
	CAST((SELECT TOP (1) res_date FROM dbo.Result_details WHERE (res_depid = (SELECT dep_id FROM dbo.CFG_DEProcedures WHERE (dep_Caption = ''Breach Exception''))) AND res_atdid = a.atd_id AND res_inactive <> 1) AS TIME) AS TreatmentCompleteTime,
	--the dep of 41 is used for BedRequest - but 41 is also used for DTA - so does this mean that they assume when the bed is requested that is also the dta?  So I think we''re getting the same thing but in a slightly different way.....
	CAST((SELECT TOP (1) req_date FROM dbo.Request_Details WHERE (req_depid IN (SELECT dep_id FROM dbo.CFG_DEProcedures WHERE (dep_Caption = ''DTA''))) AND req_atdid = a.atd_id AND req_inactive <> 1) AS DATE) AS DecisionToAdmitDate,
	CAST((SELECT TOP (1) req_date FROM dbo.Request_Details WHERE (req_depid IN (SELECT dep_id FROM dbo.CFG_DEProcedures WHERE (dep_Caption = ''DTA''))) AND req_atdid = a.atd_id AND req_inactive <> 1) AS TIME) AS DecisionToAdmitTime,
	--NULL AS DecisionToAdmitDate,  
	--NULL AS DecisionToAdmitTime,
	--NULL AS BreachEndDate,
	--NULL AS BreachEndTime,
	NULLIF(CAST(a.atd_dischdate AS DATE),''2200-01-01'') AS DischargeDate,
	CASE WHEN CAST(a.atd_dischdate AS DATE)=''2200-01-01'' THEN NULL ELSE CAST(a.atd_dischdate AS TIME) END AS DischargeTime,
	NULLIF(CAST((
		CASE a.atd_attendancetype 
			WHEN 1 THEN a.atd_dischdate
			ELSE (SELECT TOP 1 cul_locationdate FROM dbo.current_locations WHERE cul_locationid IN (SELECT TOP 1 loc_id FROM dbo.cfg_locations WHERE loc_name = ''Left Department'') AND cul_atdid = a.atd_id ORDER BY cul_locationdate DESC)
		END
	) AS DATE),''2200-01-01'') AS DepartureDate,

	CASE WHEN CAST((
		CASE a.atd_attendancetype 
			WHEN 1 THEN a.atd_dischdate
			ELSE (SELECT TOP 1 cul_locationdate FROM dbo.current_locations WHERE cul_locationid IN (SELECT TOP 1 loc_id FROM dbo.cfg_locations WHERE loc_name = ''Left Department'') AND cul_atdid = a.atd_id ORDER BY cul_locationdate DESC)
		END
	) AS DATE)=''2200-01-01'' THEN NULL 
	ELSE 
	CAST((
		CASE a.atd_attendancetype 
			WHEN 1 THEN a.atd_dischdate
			ELSE (SELECT TOP 1 cul_locationdate FROM dbo.current_locations WHERE cul_locationid IN (SELECT TOP 1 loc_id FROM dbo.cfg_locations WHERE loc_name = ''Left Department'') AND cul_atdid = a.atd_id ORDER BY cul_locationdate DESC)
		END
	) AS TIME) END AS DepartureTime, 
	--NULL AS ConsultationRequestDate,
	--NULL AS ConsultationRequestTime,
	--NULL AS ConsultationResponseDate,
	--NULL AS ConsultationResponseTime,
	--LOOK IN STAGETIMES_view - ONLY SOME OF THE VALUES HAVE AN OUTCOME DEFINED (SPECIALTY AND RADIOLOGY FOR EXAMPLE) WHEREAS OTHERS (TREATMENT AND TRANSPORT FOR EXAMPLE) JUST USE THE SAME FIELD AND THEREFORE COME OUT WITH THE SAME VALUE!!!
	--SO AT THE MOMENT IT DOESN;T LOOK LIKE YOU CAN HAVE TREATMENTENDDATE/TIME ETC
	CAST((SELECT TOP (1) res_date FROM dbo.Result_details AS Trans WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings AS CFG_ReportSettings_5 WHERE (rps_name = ''Transport''))) AND res_atdid = A.atd_id AND res_inactive <> 1) AS DATE) AS TransportRequestedDate,
	CAST((SELECT TOP (1) res_date FROM dbo.Result_details AS Trans WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings AS CFG_ReportSettings_5 WHERE (rps_name = ''Transport''))) AND res_atdid = A.atd_id AND res_inactive <> 1) AS TIME) AS TransportRequestedTime,
	NULL AS TransportArrivedDate,  
	NULL AS TransportArrivedTime,
	CAST((SELECT TOP (1) req_date FROM dbo.Request_Details WHERE (req_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequest''))) AND req_atdid = a.atd_id AND req_inactive <> 1) AS DATE) AS BedRequestedDate,
	CAST((SELECT TOP (1) req_date FROM dbo.Request_Details WHERE (req_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequest''))) AND req_atdid = a.atd_id AND req_inactive <> 1) AS TIME) AS BedRequestedTime,
	CAST((SELECT TOP (1) res_date FROM dbo.Result_details WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequestOutcome''))) AND res_atdid = a.atd_id AND res_inactive <> 1) AS DATE) AS BedRequestedOutcomeDate,
	CAST((SELECT TOP (1) res_date FROM dbo.Result_details WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequestOutcome''))) AND res_atdid = a.atd_id AND res_inactive <> 1) AS TIME) AS BedRequestedOutcomeTime,
	--LEFT(a.atd_ambcrew, 8) AS AmbulanceReference,
	NULLIF(RTRIM(a.atd_ambcrew),'''') AS AmbulanceReference,
	--''7A1AU'' AS SiteCodeOfTreatment,
	--18 March 2021 - Change made to SiteCodeOfTreatment to allow for the identification of MIU sites after rollout of Symphony to MIUs
	--I would (should) leave it as the locally generated code but as we''ve already been outputting a national code (7A1AU) I don''t want to cause problems with anything
	--that anyone has based on this (if they''ve used 7a1au in criteria etc without needing a join for example)
	--Also, as usual, this change has been actioned on short notice and we''d have to give people a fair bit of notice to change things if we''re going to change the type of codes in a field
	CASE LEFT(atd_num,2)
		WHEN ''WM'' THEN ''7A1A4''
		WHEN ''MC'' THEN ''7A1AD''
	END AS SiteCodeOfTreatment,
	NULLIF(CAST(REPLACE(REPLACE(a.atd_complaintid,'','',''''),'''''''','''') AS VARCHAR(255)),'''') AS PresentingComplaint,
	NULLIF(a.atd_refsource,0) AS ReferralSource,
	NULLIF(a.atd_arrmode,0) AS ArrivalMode,
	NULLIF(CASE a.atd_attendancetype 
		WHEN 1 THEN ISNULL(NULLIF(
			(select distinct not_text
				from 
				dbo.attendance_details innerA2
				inner join dbo.episodes on atd_epdid = epd_id 
				inner join dbo.lookupmappings on flm_lkpid = atd_reason
				inner join dbo.notes on not_noteid = flm_value
			where 
				innerA2.atd_attendancetype = 1 and 
				innerA2.atd_id <> 0 and 
				innerA2.atd_deleted<>1 AND 
				innerA2.atd_id=a.atd_id),'''')
			,
			(select distinct not_text
				from 
				dbo.attendance_details innerA1
				inner join dbo.episodes on atd_epdid = epd_id 
				inner join dbo.lookupmappings on flm_lkpid = atd_reason
				inner join dbo.notes on not_noteid = flm_value
			where 
				innerA1.atd_attendancetype <> 1 and 
				innerA1.atd_id <> 0 and 
				innerA1.atd_deleted<>1 and 
				right(innerA1.atd_num,1)=''1'' AND 
				innerA1.atd_epdid=a.atd_epdid)
			)
		ELSE LEFT((select top 1 not_text from dbo.notes where not_noteid = (select top 1 flm_value from dbo.lookupmappings where flm_lkpid = a.atd_reason and flm_mtid = 6)), 2) 
	end,'''') as PatientGroup,
	
	CASE
		WHEN RTRIM(a.atd_accompany)='''' THEN NULL
		WHEN CHARINDEX(''||'',a.atd_accompany)=0 THEN a.atd_accompany
		ELSE SUBSTRING(a.atd_accompany,1,CHARINDEX(''||'',a.atd_accompany)-1)
	END AS AccompaniedBy1,
	CASE
		WHEN CHARINDEX(''||'',a.atd_accompany)=0 THEN NULL
		ELSE SUBSTRING(a.atd_accompany,CHARINDEX(''||'',a.atd_accompany)+2,4) 
	END AS AccompaniedBy2,
	NULLIF(a.atd_location,0) AS IncidentLocation,
	--NULL AS IncidentActivity,
	--NULLIF(a.atd_activity,0) AS IncidentActivity,
	CASE
		WHEN (select not_text from dbo.notes where not_noteid = (select top 1 flm_value from dbo.lookupmappings where flm_lkpid = a.atd_reason and flm_mtid = @flm_mtid)) not in (11,12,13,14,15) THEN ''98''
		ELSE
		ISNULL(
			CASE
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_activity) in 
						(''Badminton'',''Baseball'',''BasketBall'',''Combat Sports'',''Cricket'',''Cycling'',''Football'',''Golf'',''Gymnastics'',''Hockey'',''Netball'',''Rugby'',''Running'', ''Squash'',''Tennis'',''Water Sports'') THEN ''03''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_activity) in
						(''Aero Sports'' , ''Climbing'' , ''Horse riding'' , ''Ice Skating'' , ''Martial Arts'', ''Motor Sports'' , ''Skate boarding'',''Swimming'' , ''Weight Lifting'') THEN ''04''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_activity) = ''Miscellaneous'' THEN ''08''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = (select top 1 rta_patientype from dbo.RTA_Details where rta_atdid = a.atd_id)) in
						(''Cyclist'' , ''Driver'' , ''Front Seat Passenger'' , ''Horse Rider'' , ''Motorcycle Passenger'', ''Motorcyclist'' , ''Other'' , ''Pedestrian'' ,''Rear Seat Passenger''  , ''Unknown'') THEN ''06'' 
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_location) = ''Work Place'' THEN ''01''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_location) = ''Educational Establishment'' THEN ''02''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_location) in
						(''Countryside '',''Firework Display'',''Licenced Premises'',''Park'',''Recreational Area'',''Sports ground'') THEN ''04''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_location) in
						(''Home'',''Residential/Nursing Home'') THEN ''05''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_location) = ''UNKNOWN'' THEN ''98''
				WHEN (select top 1 lkp_name from dbo.lookups where lkp_id = a.atd_location) in
						(''Commercial Area'',''Farm'',''Hospital'',''Industrial Area'',''Major Incident'',''Other'',''Public Place'',''Street'',''Town Centre'',''Town Centre Pub/Club'') THEN ''99''
			END,''99'') END AS IncidentActivity,
	--CASE a.atd_attendancetype
	--	WHEN 1 THEN ''6''
	--	ELSE
	--	(SELECT TOP 1 tri_category FROM triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC)
	--END AS TriageCategory,
	(SELECT TOP 1 tri_category FROM dbo.triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC) AS TriageCategory, 

	NULLIF((SELECT TOP 1 tri_complaint FROM dbo.triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC),'''') AS TriageComplaint, 
	NULLIF(RTRIM((SELECT TOP 1 tri_treatment FROM dbo.triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC)),'''') AS TriageTreatment,
	
	TT1.Treatment AS TriageTreatment1,
	TT2.Treatment AS TriageTreatment2,
	TT3.Treatment AS TriageTreatment3,
	TT4.Treatment AS TriageTreatment4,
	TT5.Treatment AS TriageTreatment5,
	TT6.Treatment AS TriageTreatment6,
	TT7.Treatment AS TriageTreatment7,
	TT8.Treatment AS TriageTreatment8,
	TT9.Treatment AS TriageTreatment9,
	TT10.Treatment AS TriageTreatment10,
	
	
	NULLIF(RTRIM((SELECT TOP 1 tri_discriminator FROM dbo.triage WHERE tri_atdid = a.atd_id AND tri_inactive <> 1 ORDER BY tri_date ASC)),'''') AS TriageDiscriminator, 
	NULLIF(LEFT(a.atd_immunize,4),'''') AS Immunisation,
	--CASE 
	--	ISNUMERIC(pdt_EF_Value) WHEN 1 THEN
	--		CASE 
	--			WHEN pdt_EF_Value LIKE (''%[,.\ ]%'') THEN pdt_EF_Value 
	--			else (select not_text from notes where not_noteid = cast(pdt_EF_Value as int)) 
	--		END
	--	ELSE pdt_EF_Value 
	--END AS School,
	NULL AS School,
	NULLIF(a.atd_dischoutcome,0) AS DischargeOutcome,
	NULLIF(a.atd_dischdest,0) AS DischargeDestination,

	CASE
		WHEN a.atd_attendancetype=1 THEN 4
		--WHEN RIGHT(a.atd_num, 1) != ''1'' THEN 4
		WHEN (
			SELECT 
				TOP 1 res_result 
			FROM  dbo.Result_details 
				INNER JOIN dbo.lookups ON lkp_id = res_result 
			WHERE 
					res_inactive<>1 AND 
					res_atdid = a.atd_id AND 
					lkp_name LIKE ''%alcohol%'' AND 
					Result_details.res_depid = @Diagn
		) <> 0 THEN 1 
		ELSE 3
	END AS AlcoholRelated,

	NULLIF(a.atd_timesince,0) AS TimeSinceIncident,
	(SELECT TOP (1) req_field1 FROM dbo.Request_Details WHERE (req_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequest''))) AND req_atdid = a.atd_id AND req_inactive <> 1) AS BedRequestedWard,
	NULL AS BedRequestedConsultant,
	(SELECT TOP (1) req_request FROM dbo.Request_Details WHERE (req_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequest''))) AND req_atdid = a.atd_id AND req_inactive <> 1) AS BedRequestedSpecialty,
	(SELECT TOP (1) res_result FROM dbo.Result_details WHERE (res_depid IN (SELECT rps_value FROM dbo.CFG_ReportSettings WHERE (rps_name = ''A+E BedRequestOutcome''))) AND res_atdid = a.atd_id AND res_inactive <> 1) AS BedRequestedOutcome,
	(SELECT TOP 1 res_staff1 FROM dbo.result_details WHERE res_depid IN (SELECT rps_value FROM dbo.cfg_reportsettings WHERE rps_name = ''SeeA+EClinicianOutcome'') AND res_atdid = a.atd_id AND res_inactive<>1) AS EDClinicianSeen,
	CASE a.atd_attendancetype
		WHEN 1 THEN ''Y''
		ELSE ''N''
	END AS SeeAndTreat,
	CASE a.atd_attendancetype 
		WHEN 1 THEN ''02''--Planned follow up 
		ELSE
			CASE RIGHT(a.atd_num, 1) 
				WHEN ''1'' THEN ''01''--New attendance 
				ELSE ''03''--Unplanned follow up 	
			END
	END AS AttendanceCategory,
	--Appropriateness of Attendance
	/*We''ll say for now it''s
	1 Appropriate
	2 Not appropriate
	3 Not applicable (planned follow up)
	so that it kind of follows the current codes - but these can change, doesn''t really matter
	This was just taken from the original MDSExtractDisch stored proc*/
	CASE a.atd_attendancetype 
		WHEN 1 THEN 3
		ELSE 1
	END AS AppropriateAttendance,
	NULLIF(RTA.rta_patientype,0) AS RTAPatientType,
	MECH.atd_EF_Value AS MechanismOfInjury,
	/*****************************************************************************
	DIAGNOSIS
	*****************************************************************************/
	NULLIF(Diagnosis1.DiagnosisType,0) AS Diagnosis1DiagnosisType,
	Diagnosis1.DiagnosisDate AS Diagnosis1DiagnosisDate,
	Diagnosis1.DiagnosisTime AS Diagnosis1DiagnosisTime,
	NULLIF(Diagnosis1.DiagnosisSite,0) AS Diagnosis1DiagnosisSite,
	NULLIF(Diagnosis1.DiagnosisSide,0) AS Diagnosis1DiagnosisSide,
	NULLIF(Diagnosis2.DiagnosisType,0) AS Diagnosis2DiagnosisType,
	Diagnosis2.DiagnosisDate AS Diagnosis2DiagnosisDate,
	Diagnosis2.DiagnosisTime AS Diagnosis2DiagnosisTime,
	NULLIF(Diagnosis2.DiagnosisSite,0) AS Diagnosis2DiagnosisSite,
	NULLIF(Diagnosis2.DiagnosisSide,0) AS Diagnosis2DiagnosisSide,
	NULLIF(Diagnosis3.DiagnosisType,0) AS Diagnosis3DiagnosisType,
	Diagnosis3.DiagnosisDate AS Diagnosis3DiagnosisDate,
	Diagnosis3.DiagnosisTime AS Diagnosis3DiagnosisTime,
	NULLIF(Diagnosis3.DiagnosisSite,0) AS Diagnosis3DiagnosisSite,
	NULLIF(Diagnosis3.DiagnosisSide,0) AS Diagnosis3DiagnosisSide,
	NULLIF(Diagnosis4.DiagnosisType,0) AS Diagnosis4DiagnosisType,
	Diagnosis4.DiagnosisDate AS Diagnosis4DiagnosisDate,
	Diagnosis4.DiagnosisTime AS Diagnosis4DiagnosisTime,
	NULLIF(Diagnosis4.DiagnosisSite,0) AS Diagnosis4DiagnosisSite,
	NULLIF(Diagnosis4.DiagnosisSide,0) AS Diagnosis4DiagnosisSide,
	NULLIF(Diagnosis5.DiagnosisType,0) AS Diagnosis5DiagnosisType,
	Diagnosis5.DiagnosisDate AS Diagnosis5DiagnosisDate,
	Diagnosis5.DiagnosisTime AS Diagnosis5DiagnosisTime,
	NULLIF(Diagnosis5.DiagnosisSite,0) AS Diagnosis5DiagnosisSite,
	NULLIF(Diagnosis5.DiagnosisSide,0) AS Diagnosis5DiagnosisSide,
	NULLIF(Diagnosis6.DiagnosisType,0) AS Diagnosis6DiagnosisType,
	Diagnosis6.DiagnosisDate AS Diagnosis6DiagnosisDate,
	Diagnosis6.DiagnosisTime AS Diagnosis6DiagnosisTime,
	NULLIF(Diagnosis6.DiagnosisSite,0) AS Diagnosis6DiagnosisSite,
	NULLIF(Diagnosis6.DiagnosisSide,0) AS Diagnosis6DiagnosisSide,
	/*****************************************************************************
	IMAGING REQUESTS
	*****************************************************************************/
	NULLIF(Xray1.RequestType,0) AS Xray1RequestType,
	Xray1.RequestDate AS XRay1RequestDate,
	Xray1.RequestTime AS XRay1RequestTime,
	NULLIF(Xray1.RequestSite,0) AS Xray1RequestSite,
	NULLIF(Xray1.RequestSide,0) AS Xray1RequestSide,
	NULLIF(Xray2.RequestType,0) AS Xray2RequestType,
	Xray2.RequestDate AS XRay2RequestDate,
	Xray2.RequestTime AS XRay2RequestTime,
	NULLIF(Xray2.RequestSite,0) AS Xray2RequestSite,
	NULLIF(Xray2.RequestSide,0) AS Xray2RequestSide,
	NULLIF(Xray3.RequestType,0) AS Xray3RequestType,
	Xray3.RequestDate AS XRay3RequestDate,
	Xray3.RequestTime AS XRay3RequestTime,
	NULLIF(Xray3.RequestSite,0) AS Xray3RequestSite,
	NULLIF(Xray3.RequestSide,0) AS Xray3RequestSide,
	NULLIF(Xray4.RequestType,0) AS Xray4RequestType,
	Xray4.RequestDate AS XRay4RequestDate,
	Xray4.RequestTime AS XRay4RequestTime,
	NULLIF(Xray4.RequestSite,0) AS Xray4RequestSite,
	NULLIF(Xray4.RequestSide,0) AS Xray4RequestSide,
	NULLIF(Xray5.RequestType,0) AS Xray5RequestType,
	Xray5.RequestDate AS XRay5RequestDate,
	Xray5.RequestTime AS XRay5RequestTime,
	NULLIF(Xray5.RequestSite,0) AS Xray5RequestSite,
	NULLIF(Xray5.RequestSide,0) AS Xray5RequestSide,
	NULLIF(Xray6.RequestType,0) AS Xray6RequestType,
	Xray6.RequestDate AS XRay6RequestDate,
	Xray6.RequestTime AS XRay6RequestTime,
	NULLIF(Xray6.RequestSite,0) AS Xray6RequestSite,
	NULLIF(Xray6.RequestSide,0) AS Xray6RequestSide,
	/*****************************************************************************
	PATHOLOGY REQUESTS (it''s not just pathology)
	*****************************************************************************/
	NULLIF(Pathology1.RequestType,0) AS Investigation1RequestType,
	Pathology1.RequestDate AS Investigation1RequestDate,
	Pathology1.RequestTime AS Investigation1RequestTime,
	NULLIF(Pathology2.RequestType,0) AS Investigation2RequestType,
	Pathology2.RequestDate AS Investigation2RequestDate,
	Pathology2.RequestTime AS Investigation2RequestTime,
	NULLIF(Pathology3.RequestType,0) AS Investigation3RequestType,
	Pathology3.RequestDate AS Investigation3RequestDate,
	Pathology3.RequestTime AS Investigation3RequestTime,
	NULLIF(Pathology4.RequestType,0) AS Investigation4RequestType,
	Pathology4.RequestDate AS Investigation4RequestDate,
	Pathology4.RequestTime AS Investigation4RequestTime,
	NULLIF(Pathology5.RequestType,0) AS Investigation5RequestType,
	Pathology5.RequestDate AS Investigation5RequestDate,
	Pathology5.RequestTime AS Investigation5RequestTime,
	NULLIF(Pathology6.RequestType,0) AS Investigation6RequestType,
	Pathology6.RequestDate AS Investigation6RequestDate,
	Pathology6.RequestTime AS Investigation6RequestTime,
	/*****************************************************************************
	TREATMENTS
	*****************************************************************************/
	NULLIF(Treatment1.TreatmentType,0) AS Treatment1TreatmentType,
	Treatment1.TreatmentDate AS Treatment1TreatmentDate,
	Treatment1.TreatmentTime AS Treatment1TreatmentTime,
	NULLIF(Treatment2.TreatmentType,0) AS Treatment2TreatmentType,
	Treatment2.TreatmentDate AS Treatment2TreatmentDate,
	Treatment2.TreatmentTime AS Treatment2TreatmentTime,
	NULLIF(Treatment3.TreatmentType,0) AS Treatment3TreatmentType,
	Treatment3.TreatmentDate AS Treatment3TreatmentDate,
	Treatment3.TreatmentTime AS Treatment3TreatmentTime,
	NULLIF(Treatment4.TreatmentType,0) AS Treatment4TreatmentType,
	Treatment4.TreatmentDate AS Treatment4TreatmentDate,
	Treatment4.TreatmentTime AS Treatment4TreatmentTime,
	NULLIF(Treatment5.TreatmentType,0) AS Treatment5TreatmentType,
	Treatment5.TreatmentDate AS Treatment5TreatmentDate,
	Treatment5.TreatmentTime AS Treatment5TreatmentTime,
	NULLIF(Treatment6.TreatmentType,0) AS Treatment6TreatmentType,
	Treatment6.TreatmentDate AS Treatment6TreatmentDate,
	Treatment6.TreatmentTime AS Treatment6TreatmentTime,
	NULLIF(a.atd_activity,0) AS SportsActivity,
	CASE 
		WHEN a.atd_dischoutcome = 6350 THEN ''Y''
		ELSE NULL
	END AS LeftWithoutSeen,
	NULL AS CascardNumber,
	NULL AS PatientRefNo,
	NULL AS BREACHKEY1,
	NULL AS BREACHREASON1,
	NULL AS BREACHSTARTDATE1,
	NULL AS BREACHSTARTTIME1,
	NULL AS BREACHENDDATE1,
	NULL AS BREACHENDTIME1,
	NULL AS BREACHKEY2,
	NULL AS BREACHREASON2,
	NULL AS BREACHSTARTDATE2,
	NULL AS BREACHSTARTTIME2,
	NULL AS BREACHENDDATE2,
	NULL AS BREACHENDTIME2,
	NULL AS BREACHKEY3,
	NULL AS BREACHREASON3,
	NULL AS BREACHSTARTDATE3,
	NULL AS BREACHSTARTTIME3,
	NULL AS BREACHENDDATE3,
	NULL AS BREACHENDTIME3,
	NULL AS BREACHKEY4,
	NULL AS BREACHREASON4,
	NULL AS BREACHSTARTDATE4,
	NULL AS BREACHSTARTTIME4,
	NULL AS BREACHENDDATE4,
	NULL AS BREACHENDTIME4,
	NULL AS BREACHKEY5,
	NULL AS BREACHREASON5,
	NULL AS BREACHSTARTDATE5,
	NULL AS BREACHSTARTTIME5,
	NULL AS BREACHENDDATE5,
	NULL AS BREACHENDTIME5,
	NULL AS BREACHKEY6,
	NULL AS BREACHREASON6,
	NULL AS BREACHSTARTDATE6,
	NULL AS BREACHSTARTTIME,
	NULL AS BREACHENDDATE6,
	NULL AS BREACHENDTIME6,
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
	NULL AS ConsultationRequestSpecialty3,
	NULL AS ConsultationRequestDate4,
	NULL AS ConsultationRequestTime4,
	NULL AS ConsultationRequestCompletedDate4,
	NULL AS ConsultationRequestCompletedTime4,
	NULL AS ConsultationRequestSpecialty4,
	NULL AS ConsultationRequestDate5,
	NULL AS ConsultationRequestTime5,
	NULL AS ConsultationRequestCompletedDate5,
	NULL AS ConsultationRequestCompletedTime5,
	NULL AS ConsultationRequestSpecialty5,
	NULL AS ConsultationRequestDate6,
	NULL AS ConsultationRequestTime6,
	NULL AS ConsultationRequestCompletedDate6,
	NULL AS ConsultationRequestCompletedTime6,
	NULL AS ConsultationRequestSpecialty6,
	a.atd_num AS AttendanceNumber
FROM 
	dbo.attendance_details a
	INNER JOIN dbo.episodes on a.atd_epdid = epd_id 
	INNER JOIN dbo.patient on epd_pid = pat_pid 
	INNER JOIN dbo.Patient_details on pdt_pid=pat_pid 
	--LEFT JOIN Patient_Details_ExtraFields PDEF on patient.pat_pid=PDEF.pdt_EF_pdtpid and PDEF.pdt_EF_FieldID = 1050 --School
	LEFT OUTER JOIN dbo.GPPracticeAddressLink GPLINK on pdt_gpid = GPLINK.gpa_gpid 
	   AND GPLINK.gpa_status = 2661   -- Status = Active
	   AND gpa_prid = pdt_practise   -- link on GP Practice as well
	LEFT OUTER JOIN dbo.GP_practise GPPRAC on GPPRAC.pr_id = GPLINK.gpa_prid
	LEFT OUTER JOIN dbo.GP PATGP on PATGP.gp_id = GPLINK.gpa_gpid
	LEFT OUTER JOIN dbo.Address GPAdd on GPLINK.gpa_praddid = GPAdd.add_addid 
		AND GPAdd.add_linktype = 2 
		AND GPAdd.add_type IN 
			(
				(SELECT TOP 1 Lkp_ID FROM dbo.lookups WHERE Lookups.Lkp_Name = ''Principle Practice Address'' AND lkp_parentid = (SELECT TOP 1 lkp_id FROM dbo.lookups WHERE lkp_name = ''Practice Address Type'' AND lkp_parentid = 0)),
				(SELECT TOP 1 Lkp_ID FROM dbo.lookups WHERE Lookups.Lkp_Name = ''Secondary Practice Address'' AND lkp_parentid = (SELECT TOP 1 lkp_id FROM dbo.lookups WHERE lkp_name = ''Practice Address Type'' AND lkp_parentid = 0)),
				(SELECT TOP 1 Lkp_ID FROM dbo.lookups WHERE Lookups.Lkp_Name = ''GP Address''))
	LEFT OUTER JOIN dbo.GP REFGP ON REFGP.gp_id = a.atd_gpid
	LEFT OUTER JOIN dbo.GP_Practise REFGPPRAC ON REFGPPRAC.Pr_id = a.atd_prcode
	LEFT OUTER JOIN dbo.Address ContAdd ON ContAdd.add_linkid = pat_pid AND ContAdd.add_linktype = 1 AND ContAdd.add_type = (SELECT TOP 1 Lkp_ID FROM dbo.lookups WHERE Lookups.Lkp_Name = ''Contact Address'')
	LEFT OUTER JOIN dbo.Address TempAdd ON TempAdd.add_linkid = pat_pid AND TempAdd.add_linktype = 1 AND TempAdd.add_type = (SELECT TOP 1 Lkp_ID FROM dbo.lookups WHERE Lookups.Lkp_Name = ''Temporary address'')
	LEFT OUTER JOIN dbo.Address PermAdd ON PermAdd.add_linkid = pat_pid AND PermAdd.add_linktype = 1 AND PermAdd.add_type = (SELECT TOP 1 Lkp_ID FROM dbo.lookups WHERE Lookups.Lkp_Name = ''Permanent address'')
	LEFT JOIN dbo.RTA_Details RTA ON a.atd_id=RTA.rta_atdid
	LEFT JOIN dbo.Attendance_Details_ExtraFields MECH ON a.atd_id=MECH.atd_EF_atdid AND MECH.atd_EF_FieldID=1070
	LEFT JOIN @ImagingRequest XRay1 ON a.atd_id=XRay1.AttendanceId AND XRay1.RowNumber=1
	LEFT JOIN @ImagingRequest XRay2 ON a.atd_id=XRay2.AttendanceId AND XRay2.RowNumber=2
	LEFT JOIN @ImagingRequest XRay3 ON a.atd_id=XRay3.AttendanceId AND XRay3.RowNumber=3
	LEFT JOIN @ImagingRequest XRay4 ON a.atd_id=XRay4.AttendanceId AND XRay4.RowNumber=4
	LEFT JOIN @ImagingRequest XRay5 ON a.atd_id=XRay5.AttendanceId AND XRay5.RowNumber=5
	LEFT JOIN @ImagingRequest XRay6 ON a.atd_id=XRay6.AttendanceId AND XRay6.RowNumber=6
	LEFT JOIN @PathologyRequest Pathology1 ON a.atd_id=Pathology1.AttendanceId AND Pathology1.RowNumber=1
	LEFT JOIN @PathologyRequest Pathology2 ON a.atd_id=Pathology2.AttendanceId AND Pathology2.RowNumber=2
	LEFT JOIN @PathologyRequest Pathology3 ON a.atd_id=Pathology3.AttendanceId AND Pathology3.RowNumber=3
	LEFT JOIN @PathologyRequest Pathology4 ON a.atd_id=Pathology4.AttendanceId AND Pathology4.RowNumber=4
	LEFT JOIN @PathologyRequest Pathology5 ON a.atd_id=Pathology5.AttendanceId AND Pathology5.RowNumber=5
	LEFT JOIN @PathologyRequest Pathology6 ON a.atd_id=Pathology6.AttendanceId AND Pathology6.RowNumber=6
	LEFT JOIN @Treatment Treatment1 ON a.atd_id=Treatment1.AttendanceId AND Treatment1.RowNumber=1
	LEFT JOIN @Treatment Treatment2 ON a.atd_id=Treatment2.AttendanceId AND Treatment2.RowNumber=2
	LEFT JOIN @Treatment Treatment3 ON a.atd_id=Treatment3.AttendanceId AND Treatment3.RowNumber=3
	LEFT JOIN @Treatment Treatment4 ON a.atd_id=Treatment4.AttendanceId AND Treatment4.RowNumber=4
	LEFT JOIN @Treatment Treatment5 ON a.atd_id=Treatment5.AttendanceId AND Treatment5.RowNumber=5
	LEFT JOIN @Treatment Treatment6 ON a.atd_id=Treatment6.AttendanceId AND Treatment6.RowNumber=6
	LEFT JOIN @Diagnosis Diagnosis1 ON a.atd_id=Diagnosis1.AttendanceId AND Diagnosis1.RowNumber=1
	LEFT JOIN @Diagnosis Diagnosis2 ON a.atd_id=Diagnosis2.AttendanceId AND Diagnosis2.RowNumber=2
	LEFT JOIN @Diagnosis Diagnosis3 ON a.atd_id=Diagnosis3.AttendanceId AND Diagnosis3.RowNumber=3
	LEFT JOIN @Diagnosis Diagnosis4 ON a.atd_id=Diagnosis4.AttendanceId AND Diagnosis4.RowNumber=4
	LEFT JOIN @Diagnosis Diagnosis5 ON a.atd_id=Diagnosis5.AttendanceId AND Diagnosis5.RowNumber=5
	LEFT JOIN @Diagnosis Diagnosis6 ON a.atd_id=Diagnosis6.AttendanceId AND Diagnosis6.RowNumber=6
	LEFT JOIN @TriageTreatment TT1 ON a.atd_id=TT1.AttendanceId AND TT1.RowNumber=1
	LEFT JOIN @TriageTreatment TT2 ON a.atd_id=TT2.AttendanceId AND TT2.RowNumber=2
	LEFT JOIN @TriageTreatment TT3 ON a.atd_id=TT3.AttendanceId AND TT3.RowNumber=3
	LEFT JOIN @TriageTreatment TT4 ON a.atd_id=TT4.AttendanceId AND TT4.RowNumber=4
	LEFT JOIN @TriageTreatment TT5 ON a.atd_id=TT5.AttendanceId AND TT5.RowNumber=5
	LEFT JOIN @TriageTreatment TT6 ON a.atd_id=TT6.AttendanceId AND TT6.RowNumber=6
	LEFT JOIN @TriageTreatment TT7 ON a.atd_id=TT7.AttendanceId AND TT7.RowNumber=7
	LEFT JOIN @TriageTreatment TT8 ON a.atd_id=TT8.AttendanceId AND TT8.RowNumber=8
	LEFT JOIN @TriageTreatment TT9 ON a.atd_id=TT9.AttendanceId AND TT9.RowNumber=9
	LEFT JOIN @TriageTreatment TT10 ON a.atd_id=TT10.AttendanceId AND TT10.RowNumber=10
WHERE 
	CAST(a.atd_arrivaldate AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(a.atd_arrivaldate AS DATE) < '''+@DateToString+''' AND 
	atd_deleted=0 AND
	LEFT(A.ATD_NUM,2)IN(''WM'',''MC'')
	--AND epd_deptid = 1

ORDER BY
	A.atd_id ASC	
')AT [BCUED\BCUED_DB];
END
GO
