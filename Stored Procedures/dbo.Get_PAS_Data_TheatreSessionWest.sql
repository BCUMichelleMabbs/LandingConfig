SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_PAS_Data_TheatreSessionWest]
*/
CREATE PROCEDURE [dbo].[Get_PAS_Data_TheatreSessionWest]
AS
BEGIN
SET NOCOUNT ON;

	EXEC ('
		DECLARE @start_date DATETIME = CAST(DATEADD(dd, -89, GETDATE()) AS DATE)
		DECLARE @end_date DATETIME = CONVERT(VARCHAR(8), GETDATE() - 1, 112)

		SELECT
			sps.spssn_Refno AS [ScheduleNo]
			, ''7A100'' AS [ProviderCode]
			,CAST(sps.start_dttm AS DATE) AS [SessionDate]
			,sps.spssn_Refno AS [Session]
			,LEFT(spec.main_ident, 3) AS [Spec]
			, '' '' AS [SessionType]
			,sp.code AS [TheatreCode]
			,NULL [LateFinishReason]
			, '' '' AS [LateStartReason]
			,sps.start_dttm AS [ScheduleSessionTime]
			,ISNULL((
				SELECT CONVERT(DATETIME, MIN(te.anaes_start_Dttm))
				FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[THEATRE_EVENTS] te
					JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[SCHEDULES] s3 ON s3.SCHDL_REFNO  = te.SCHDL_REFNO
				WHERE s3.SPSSN_REFNO = sps.SPSSN_REFNO), sps.START_DTTM)
			AS [ActualSessionTime]
			,sps.session_duration AS [TotalAvailableTime]
			,NULL AS [UnAvailableTime]
			,sps.Slot_duration AS [Interval]
			,REPLACE(sps.DESCRIPTION, '', '', '''') AS [SessionName]
			,NULL AS [EarlyFinishReason]
			,DATEADD(DAY, 0, DATEDIFF(DAY, 0, sps.start_dttm)) + DATEADD(DAY, 0 - DATEDIFF(DAY, 0, sps.end_dttm), sps.end_dttm) AS [SessionEnd]
			,ISNULL((
				SELECT CONVERT(DATETIME,max(s4.into_postop_Dttm))
				FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[SCHEDULES] s4
				WHERE s4.SPSSN_REFNO = sps.SPSSN_REFNO), sps.end_DTTM)
			AS [ActualFinishTime]
			,FREQN.description AS [SessionFrequency]
			,CASE WHEN cancel_Dttm IS NULL THEN ''NA'' ELSE ''CANC'' END AS [CancellationReason]
			,NULL AS [Anaesthetist]
			,pro.main_ident AS [Surgeon]
			,pro.main_ident AS [ResponsibleClinician]
			,CASE WHEN CONVERT(VARCHAR, sps.start_dttm, 114) < ''12:00:00:000'' THEN ''AM'' ELSE ''PM'' END AS [TimeOfDay]
		INTO #x_theatreextract_sessions
		FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[service_point_sessions] sps
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[service_points] sp ON sp.spont_Refno = sps.spont_Refno
			LEFT JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[specialties] spec ON spec.spect_Refno = sps.spect_Refno
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[reference_Values] slate ON slate.rfval_Refno = sps.slate_refno
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[reference_values] thtyp ON thtyp.rfval_Refno = sp.thtyp_refno
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[reference_Values] FREQN ON FREQN.rfval_Refno = sps.FREQN_Refno
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[prof_Carers] pro ON pro.proca_Refno = sps.proca_Refno
		WHERE sps.start_Dttm BETWEEN @start_date AND @end_date
			AND sp.sptyp_Refno = 100046
			AND ISNULL(sps.ARCHV_FLAG, ''N'') = ''N''


		ALTER TABLE #x_theatreextract_sessions
		ADD TotalOnList INT

		ALTER TABLE #x_theatreextract_sessions
		ADD NumberComplete INT

		ALTER TABLE #x_theatreextract_sessions
		ADD NumberCancelled INT

		ALTER TABLE #x_theatreextract_sessions
		ADD NumberCancelledOnDay INT


		----TotalOnList -- Updated by Dylan Jones 22/02/19 to ADD filter ON what IS counted AS an included patient
		UPDATE #x_theatreextract_sessions
		SET TotalOnList = (
			SELECT COUNT(*)
			FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[SCHEDULES] s
			WHERE s.spssn_Refno = #x_theatreextract_sessions.scheduleNo
				AND ISNULL(s.archv_flag, ''N'') = ''N''
				AND (CANCR_DTTM >= DATEADD(HOUR, -24, start_dttm) OR CANCR_DTTM IS NULL)
			)

		----NumberCancelled_on_list -- Updated by Dylan Jones 22/02/19 to ADD filter ON what IS counted AS an included patient
		UPDATE #x_theatreextract_sessions
		SET NumberCancelled = (
			SELECT COUNT(*)
			FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[SCHEDULES] s
			WHERE s.spssn_Refno = #x_theatreextract_sessions.scheduleNo
				AND s.cancr_dttm IS NOT NULL
				AND ISNULL(s.archv_flag, ''N'') = ''N''
				AND CANCR_DTTM >= DATEADD(HOUR, -24, start_dttm)
			)

		----NumberComplete---
		UPDATE #x_theatreextract_sessions
		SET NumberComplete = TotalOnList - NumberCancelled

		-----Theatre Type----------
		ALTER TABLE #x_theatreextract_sessions
		ALTER COLUMN SessionType VARCHAR(500)

		UPDATE #x_theatreextract_sessions
		SET SessionType = r.MAIN_CODE
		FROM  [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[reference_Values] r
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[service_point_sessions] sps ON r.rfval_Refno = sps.SESTY_refno
		WHERE sps.spssn_Refno = scheduleno

		-----LateStartReason Type----------
		ALTER TABLE #x_theatreextract_sessions
		ALTER COLUMN LateStartReason VARCHAR(500)

		UPDATE #x_theatreextract_sessions
		SET LateStartReason = ri.identifier
		FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[reference_Value_ids] ri
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[reference_Values] r ON r.rfval_Refno = ri.rfval_Refno AND ri.rityp_code = ''PIMS''
			JOIN [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[service_point_sessions] sps ON sps.slate_Refno = r.rfval_Refno
		WHERE sps.spssn_Refno = scheduleno

		-----Cancelled ON Day----------------
		UPDATE #x_theatreextract_sessions
		SET NumberCancelledOnDay = (
			SELECT COUNT(*)
			FROM [7A1AUSRVIPMSQL].[ipmproduction].[dbo].[SCHEDULES] s
			WHERE s.spssn_Refno = #x_theatreextract_sessions.scheduleNo
				AND ISNULL(s.archv_flag, ''N'') = ''N''
				AND CONVERT(DATE, s.cancr_Dttm) = CONVERT(DATE, s.start_dttm)
			)
	
		SELECT
			[ProviderCode] AS [ProviderCode],
			[SessionDate] AS [SessionDate],
			[Session] AS [Session],
			[Spec] AS [PlannedSpecialty],
			[SessionType] AS [SessionType],
			[TheatreCode] AS [TheatreCode],
			[LateFinishReason] AS [LateFinishReason],
			[LateStartReason] AS [LateStartReason],
			CAST([ScheduleSessionTime] AS DATE) AS [ScheduledStartDate],
			CAST([ScheduleSessionTime] AS TIME) AS [ScheduledStartTime],
			CAST([ActualSessionTime] AS DATE) AS [ActualStartDate],
			CAST([ActualSessionTime] AS TIME) AS [ActualStartTime],
			[TotalAvailableTime] AS [ScheduledSessionTime],
			[UnAvailableTime] AS [UnAvailableTime],
			[Interval] AS [Interval],
			[SessionName] AS [SessionName],
			[EarlyFinishReason] AS [EarlyFinishReason],
			CAST([SessionEnd] AS DATE) AS [SessionEndDate],
			CAST([SessionEnd] AS TIME) AS [SessionEndTime],
			CAST([ActualFinishTime] AS DATE) AS [ActualFinishDate],
			CAST([ActualFinishTime] AS TIME) AS [ActualFinishTime],
			[SessionFrequency] AS [SessionFrequency],
			[CancellationReason] AS [CancellationReason],
			[Anaesthetist] AS [Anaesthetist],
			[Surgeon] AS [Surgeon],
			[ResponsibleClinician] AS [ResponsibleClinician],
			[TimeOfDay] AS [TimeOfDay],
			[TotalOnList] AS [TotalOnList],
			[NumberComplete] AS [NumberComplete],
			[NumberCancelled] AS [NumberCancelled],
			[NumberCancelledOnDay] AS [NumberCancelledOnDay],
			''West'' AS [SenderOrganisation]
		FROM #x_theatreextract_sessions
	') AT [7A1AUSRVIPMSQL]
END
GO
