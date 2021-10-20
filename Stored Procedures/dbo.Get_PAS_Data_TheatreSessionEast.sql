SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_PAS_Data_TheatreSessionEast]
*/
CREATE PROCEDURE [dbo].[Get_PAS_Data_TheatreSessionEast]
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @firstDate DATE = DATEADD(dd, -89, CAST(GETDATE() AS DATE))
	,@secondDate DATE = CAST(GETDATE()-1 AS DATE)
	,@firstDateText VARCHAR(50)
	,@secondDateText VARCHAR(50)

	SET @firstDateText = CONVERT(VARCHAR, @firstDate, 106)
	SET @secondDateText = CONVERT(VARCHAR, @secondDate, 106)

	EXEC('
	SELECT DISTINCT
		''7A100'' AS ProviderCode,
		EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) AS SessionDate,
		TSR.SESSIONKEY AS Session,
		LEFT(s.Specialty, 3) AS PlannedSpecialty,
		tsr.SESSION_TYPE AS SessionType,
		tpo.thr_Location AS TheatreCode,
		notes.Late_Finish_Reason AS LateFinishReason,
		notes.Late_Start_Reason AS LateStartReason,
		CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END AS ScheduledStartDate,
		CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.starttime)||'':''||EXTRACT(MINUTE FROM tsr.starttime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.starttime), 4) ELSE NULL END AS ScheduledStartTime,
		COALESCE((
			SELECT EXTRACT(DAY FROM MIN(MIN_TIME.THE_TIME))||'' ''||DECODE(EXTRACT(MONTH FROM MIN(MIN_TIME.THE_TIME)), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM MIN(MIN_TIME.THE_TIME))
			FROM THR_TIMES MIN_TIME, THR_PATIENT_OP THR1
			WHERE THR1.OP_DATE = TPO.OP_DATE
				AND THR1.SESSIONKEY = TSR.SESSIONKEY
				AND THR1.ACTUAL_VISIT = ''Y''
				AND THR1.LINKID = MIN_TIME.LINKID
				AND MIN_TIME.ACTUAL_VISIT = ''Y''
				AND MIN_TIME.TIME_TYPE IN (''AC'' ,''IT'')
				AND MIN_TIME.THRSPELL = THR1.THRSPELL
		),CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END
		) AS ActualStartDate,
		COALESCE((
			SELECT EXTRACT(HOUR FROM MIN(MIN_TIME.THE_TIME))||'':''||EXTRACT(MINUTE FROM MIN(MIN_TIME.THE_TIME))||'':''||LEFT(EXTRACT(SECOND FROM MIN(MIN_TIME.THE_TIME)), 4)
			FROM THR_TIMES MIN_TIME, THR_PATIENT_OP THR1
			WHERE THR1.OP_DATE = TPO.OP_DATE
				AND THR1.SESSIONKEY = TSR.SESSIONKEY
				AND THR1.ACTUAL_VISIT = ''Y''
				AND THR1.LINKID = MIN_TIME.LINKID
				AND MIN_TIME.ACTUAL_VISIT = ''Y''
				AND MIN_TIME.TIME_TYPE IN (''AC'' ,''IT'')
				AND MIN_TIME.THRSPELL = THR1.THRSPELL
		),CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.starttime)||'':''||EXTRACT(MINUTE FROM tsr.starttime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.starttime), 4) ELSE NULL END
		) AS ActualStartTime,
		DATEDIFF(minute, CAST(EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date)||'' ''||EXTRACT(HOUR FROM tsr.starttime)||'':''||EXTRACT(MINUTE FROM tsr.starttime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.starttime), 4) AS timestamp), CAST(EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date)||'' ''||EXTRACT(HOUR FROM tsr.endtime)||'':''||EXTRACT(MINUTE FROM tsr.endtime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.endtime), 4) AS timestamp)) AS ScheduledSessionTime,
		NULL AS UnAvailableTime,
		Sch.DayINTERVAL AS Interval,
		REPLACE(CASE WHEN tsr.session_name IS NULL THEN s.name ELSE tsr.session_Name END,'','','''') AS SessionName,
		notes.Early_Finish_Reason AS EarlyFinishReason,
		CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END AS SessionEndDate,
		CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.endtime)||'':''||EXTRACT(MINUTE FROM tsr.endtime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.endtime), 4) ELSE NULL END AS SessionEndTime,
		COALESCE((
			SELECT EXTRACT(DAY FROM MAX(MAX_TIME.THE_TIME))||'' ''||DECODE(EXTRACT(MONTH FROM MAX(MAX_TIME.THE_TIME)), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM MAX(MAX_TIME.THE_TIME))
			FROM THR_TIMES MAX_TIME, THR_PATIENT_OP THR2
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''Y''
				AND THR2.LINKID = MAX_TIME.LINKID
				AND MAX_TIME.ACTUAL_VISIT = ''Y''
				AND MAX_TIME.TIME_TYPE IN (''IC'',''SP'')
				AND MAX_TIME.THRSPELL = THR2.THRSPELL
		),CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END
		) AS ActualFinishDate,
		COALESCE((
			SELECT EXTRACT(HOUR FROM MAX(MAX_TIME.THE_TIME))||'':''||EXTRACT(MINUTE FROM MAX(MAX_TIME.THE_TIME))||'':''||LEFT(EXTRACT(SECOND FROM MAX(MAX_TIME.THE_TIME)), 4)
			FROM THR_TIMES MAX_TIME, THR_PATIENT_OP THR2
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''Y''
				AND THR2.LINKID = MAX_TIME.LINKID
				AND MAX_TIME.ACTUAL_VISIT = ''Y''
				AND MAX_TIME.TIME_TYPE IN (''IC'',''SP'')
				AND MAX_TIME.THRSPELL = THR2.THRSPELL
		),CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.endtime)||'':''||EXTRACT(MINUTE FROM tsr.endtime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.endtime), 4) ELSE NULL END
		) AS ActualFinishTime,
		s.frequency AS SessionFrequency,
		notes.Cancellation_Reason AS CancellationReason,
		notes.ANAESTHETIST AS Anaesthetist,
		tsr.Clinician AS Surgeon,
		s.Clinician AS ResponsibleClinician,
		NULL AS TimeOfDay,
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				LEFT JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND THR2.Cancel_Reason IS NULL
				AND tt4.the_time IS NULL
		)+
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND ((tt4.the_time IS NULL) or tt4.the_time >= THR2.OP_DATE -1)
		) AS TotalOnList,
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				LEFT JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND THR2.Cancel_Reason IS NULL
				AND tt4.the_time IS NULL
		) AS NumberComplete,
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND ((tt4.the_time IS NULL) or tt4.the_time >= THR2.OP_DATE -1)
		) AS NumberCancelled,
		(
			SELECT Count(Distinct THR1.LinkID)
			FROM THR_PATIENT_OP THR1
				LEFT JOIN thr_times tt4 ON THR1.linkid = tt4.linkid AND THR1.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE (THR1.ACTUAL_VISIT = ''N'')
				AND LEFT(tt4.the_time,11) = LEFT(THR1.OP_DATE,11)
				AND THR1.OP_DATE = TPO_N.OP_DATE
				AND THR1.SESSIONKEY = TPO_N.SESSIONKEY
		) AS NumberCancelledOnDay,
		''East'' AS SenderOrganisation
	FROM THR_PATIENT_OP TPO
		LEFT JOIN THR_SESSION_RANGES TSR ON (TSR.SESSIONKEY = TPO.SESSIONKEY AND TPO.OP_DATE >= TSR.STARTDATE AND TPO.OP_DATE <= TSR.ENDDATE AND TPO.ACTUAL_VISIT = ''Y'' AND TSR.ONE_DAY_CHG = ''N'')
		LEFT JOIN SESSIONS S ON (S.SESSIONKEY = TPO.SESSIONKEY AND S.STARTDATE <= TPO.OP_DATE AND S.ENDDATE >= TPO.OP_DATE AND S.SESSIONTYPE = 3 AND TPO.ACTUAL_VISIT = ''Y'')
		LEFT JOIN THR_PATIENT_OP TPO_N ON (TPO_N.SESSIONKEY = TPO.SESSIONKEY AND TPO_N.LINKID = TPO.LINKID AND TPO_N.THRSPELL = TPO.THRSPELL AND TPO_N.ACTUAL_VISIT = ''N'')
		LEFT JOIN THR_SESSION_NOTES NOTES ON (NOTES.SESSIONKEY = TPO.SESSIONKEY AND NOTES.SESSION_DATE = TPO.OP_DATE)
		LEFT JOIN SCHEDULE SCH ON (SCH.SCHKEY = S.SCHEDULEID)
	WHERE
	(
		tpo.OP_Date BETWEEN ''' + @firstDateText + ''' AND '''+ @secondDateText + '''
		AND TSR.SESSIONKEY IS NOT NULL
		AND (CAST(tpo.op_date AS VARCHAR(30)) || CAST(TSR.SESSIONKEY AS VARCHAR(10)))
		NOT IN (SELECT (CAST(TSR1.STARTDATE AS VARCHAR(30)) || CAST(TSR1.SESSIONKEY AS VARCHAR(10))) FROM THR_SESSION_RANGES TSR1 WHERE TSR1.SESSIONKEY = TSR.SESSIONKEY AND
		TSR1.STARTDATE = TPO.OP_DATE AND TPO.ACTUAL_VISIT = ''Y'' AND TSR1.ONE_DAY_CHG = ''Y'')
	)

	UNION

	SELECT DISTINCT
		''7A100'' AS ProviderCode,
		EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) AS SessionDate,
		TSR.SESSIONKEY AS Session,
		LEFT(TSR.SPECIALTY, 3) AS PlannedSpecialty,
		tsr.SESSION_TYPE AS SessionType,
		tpo.thr_Location AS TheatreCode,
		notes.Late_Finish_Reason AS LateFinishReason,
		notes.Late_Start_Reason AS LateStartReason,
		CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END AS ScheduledStartDate,
		CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.starttime)||'':''||EXTRACT(MINUTE FROM tsr.starttime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.starttime), 4) ELSE NULL END AS ScheduledStartTime,
		COALESCE((
			SELECT EXTRACT(DAY FROM MIN(MIN_TIME.THE_TIME))||'' ''||DECODE(EXTRACT(MONTH FROM MIN(MIN_TIME.THE_TIME)), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM MIN(MIN_TIME.THE_TIME))
			FROM THR_TIMES MIN_TIME, THR_PATIENT_OP THR1
			WHERE THR1.OP_DATE = TSR.STARTDATE
				AND THR1.SESSIONKEY = TSR.SESSIONKEY
				AND THR1.ACTUAL_VISIT = ''Y''
				AND THR1.LINKID = MIN_TIME.LINKID
				AND MIN_TIME.ACTUAL_VISIT = ''Y''
				AND MIN_TIME.TIME_TYPE IN (''AC'' ,''IT'')
				AND MIN_TIME.THRSPELL = THR1.THRSPELL
		),CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END
		) AS ActualStartDate,
		COALESCE((
			SELECT EXTRACT(HOUR FROM MIN(MIN_TIME.THE_TIME))||'':''||EXTRACT(MINUTE FROM MIN(MIN_TIME.THE_TIME))||'':''||LEFT(EXTRACT(SECOND FROM MIN(MIN_TIME.THE_TIME)), 4)
			FROM THR_TIMES MIN_TIME, THR_PATIENT_OP THR1
			WHERE THR1.OP_DATE = TSR.STARTDATE
				AND THR1.SESSIONKEY = TSR.SESSIONKEY
				AND THR1.ACTUAL_VISIT = ''Y''
				AND THR1.LINKID = MIN_TIME.LINKID
				AND MIN_TIME.ACTUAL_VISIT = ''Y''
				AND MIN_TIME.TIME_TYPE IN (''AC'' ,''IT'')
				AND MIN_TIME.THRSPELL = THR1.THRSPELL
		),CASE WHEN tsr.starttime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.starttime)||'':''||EXTRACT(MINUTE FROM tsr.starttime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.starttime), 4) ELSE NULL END
		) AS ActualStartTime,
		DATEDIFF(minute, CAST(EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date)||'' ''||EXTRACT(HOUR FROM tsr.starttime)||'':''||EXTRACT(MINUTE FROM tsr.starttime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.starttime), 4) AS timestamp), CAST(EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date)||'' ''||EXTRACT(HOUR FROM tsr.endtime)||'':''||EXTRACT(MINUTE FROM tsr.endtime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.endtime), 4) AS timestamp)) AS ScheduledSessionTime,
		NULL AS UnAvailableTime,
		Sch.DayINTERVAL AS Interval,
		REPLACE(CASE WHEN tsr.session_name IS NULL THEN s.name ELSE tsr.session_Name END,'','','''') AS SessionName,
		notes.Early_Finish_Reason AS EarlyFinishReason,
		CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END AS SessionEndDate,
		CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.endtime)||'':''||EXTRACT(MINUTE FROM tsr.endtime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.endtime), 4) ELSE NULL END AS SessionEndTime,
		COALESCE((
			SELECT EXTRACT(DAY FROM MAX(MAX_TIME.THE_TIME))||'' ''||DECODE(EXTRACT(MONTH FROM MAX(MAX_TIME.THE_TIME)), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM MAX(MAX_TIME.THE_TIME))
			FROM THR_TIMES MAX_TIME, THR_PATIENT_OP THR2
			WHERE THR2.OP_DATE = TSR.STARTDATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''Y''
				AND THR2.LINKID = MAX_TIME.LINKID
				AND MAX_TIME.ACTUAL_VISIT = ''Y''
				AND MAX_TIME.TIME_TYPE IN (''IC'',''SP'')
				AND MAX_TIME.THRSPELL = THR2.THRSPELL
		),CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(DAY FROM tpo.OP_Date)||'' ''||DECODE(EXTRACT(MONTH FROM tpo.OP_Date), ''1'', ''Jan'', ''2'', ''Feb'', ''3'', ''Mar'', ''4'', ''Apr'', ''5'', ''May'', ''6'', ''Jun'', ''7'', ''Jul'', ''8'', ''Aug'', ''9'', ''Sep'', ''10'', ''Oct'', ''11'', ''Nov'', ''12'', ''Dec'', NULL)||'' ''||EXTRACT(YEAR FROM tpo.OP_Date) ELSE NULL END
		) AS ActualFinishDate,
		COALESCE((
			SELECT EXTRACT(HOUR FROM MAX(MAX_TIME.THE_TIME))||'':''||EXTRACT(MINUTE FROM MAX(MAX_TIME.THE_TIME))||'':''||LEFT(EXTRACT(SECOND FROM MAX(MAX_TIME.THE_TIME)), 4)
			FROM THR_TIMES MAX_TIME, THR_PATIENT_OP THR2
			WHERE THR2.OP_DATE = TSR.STARTDATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''Y''
				AND THR2.LINKID = MAX_TIME.LINKID
				AND MAX_TIME.ACTUAL_VISIT = ''Y''
				AND MAX_TIME.TIME_TYPE IN (''IC'',''SP'')
				AND MAX_TIME.THRSPELL = THR2.THRSPELL
		),CASE WHEN tsr.endtime IS NOT NULL THEN EXTRACT(HOUR FROM tsr.endtime)||'':''||EXTRACT(MINUTE FROM tsr.endtime)||'':''||LEFT(EXTRACT(SECOND FROM tsr.endtime), 4) ELSE NULL END
		) AS ActualFinishTime,
		s.frequency AS SessionFrequency,
		notes.Cancellation_Reason AS CancellationReason,
		notes.ANAESTHETIST AS Anaesthetist,
		tsr.Clinician AS Surgeon,
		s.Clinician AS ResponsibleClinician,
		NULL AS TimeOfDay,
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				LEFT JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND THR2.Cancel_Reason IS NULL
				AND tt4.the_time IS NULL
		)+
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND ((tt4.the_time IS NULL) or tt4.the_time >= THR2.OP_DATE -1)
		) AS TotalOnList,
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				LEFT JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND THR2.Cancel_Reason IS NULL
				AND tt4.the_time IS NULL
		) AS NumberComplete,
		(
			SELECT Count(Distinct THR2.LINKID)
			FROM THR_PATIENT_OP THR2
				JOIN thr_times tt4 ON THR2.linkid = tt4.linkid AND THR2.thrspell = tt4.thrspell AND tt4.time_type = ''CN''
			WHERE THR2.OP_DATE = TPO.OP_DATE
				AND THR2.SESSIONKEY = TSR.SESSIONKEY
				AND THR2.ACTUAL_VISIT = ''N''
				AND ((tt4.the_time IS NULL) or tt4.the_time >= THR2.OP_DATE -1)
		) AS NumberCancelled,
		(
			SELECT Count(Distinct T1.LinkID)
			FROM THR_PATIENT_OP T1
				LEFT JOIN thr_times t4 ON T1.linkid = t4.linkid AND T1.thrspell = t4.thrspell AND t4.time_type = ''CN''
			WHERE (T1.ACTUAL_VISIT = ''N'')
				AND LEFT(t4.the_time,11) = LEFT(T1.OP_DATE,11)
				AND T1.OP_DATE = TPO_N.OP_DATE
				AND T1.SESSIONKEY = TPO_N.SESSIONKEY
		) AS NumberCancelledOnDay,
		''East'' AS SenderOrganisation
	FROM THR_PATIENT_OP TPO
		LEFT JOIN THR_SESSION_RANGES TSR ON (TSR.SESSIONKEY = TPO.SESSIONKEY AND TPO.OP_DATE = TSR.STARTDATE AND TPO.OP_DATE = TSR.ENDDATE AND TSR.ONE_DAY_CHG = ''Y'')
		LEFT JOIN SESSIONS S ON (S.SESSIONKEY = TPO.SESSIONKEY AND S.STARTDATE <= TPO.OP_DATE AND S.ENDDATE >= TPO.OP_DATE AND S.SESSIONTYPE = 3 )
		LEFT JOIN THR_PATIENT_OP TPO_N ON (TPO_N.SESSIONKEY = TPO.SESSIONKEY AND TPO_N.LINKID = TPO.LINKID AND TPO_N.THRSPELL = TPO.THRSPELL AND TPO_N.ACTUAL_VISIT = ''N'')
		LEFT JOIN THR_SESSION_NOTES NOTES ON (NOTES.SESSIONKEY = TPO.SESSIONKEY AND NOTES.SESSION_DATE = TPO.OP_DATE)
		LEFT JOIN SCHEDULE SCH ON (SCH.SCHKEY = S.SCHEDULEID)
	WHERE
	(
		tpo.OP_Date BETWEEN ''' + @firstDateText + ''' AND '''+ @secondDateText + '''
		AND TSR.SESSIONKEY IS NOT NULL
	)
	'
	) AT [WPAS_East_Secondary]
END
GO
