SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Update_UnscheduledCare_EDAttendanceTimeCalculation]
@Load_GUID AS VARCHAR(38)

AS	
BEGIN
	
	SET NOCOUNT ON;

UPDATE
	Foundation.dbo.UnscheduledCare_Data_EDAttendance
SET
	ArrivalToCompleted=
		DATEDIFF(MINUTE,
			CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
                    COALESCE(
                        CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate1 AS DATETIME2)),CAST(BreachEndTime1 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate2 AS DATETIME2)),CAST(BreachEndTime2 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate3 AS DATETIME2)),CAST(BreachEndTime3 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate4 AS DATETIME2)),CAST(BreachEndTime4 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate5 AS DATETIME2)),CAST(BreachEndTime5 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate6 AS DATETIME2)),CAST(BreachEndTime6 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TreatmentCompleteDate AS DATETIME2)),CAST(TreatmentCompleteTime AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(DepartureDate AS DATETIME2)),CAST(DepartureTime AS DATETIME2(0))) AS DATETIME2(0))
                    )
		),
	ArrivalToTreatmentStart=
		DATEDIFF(MINUTE,
              CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
              CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TreatmentStartDate AS DATETIME2)),CAST(TreatmentStartTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	ArrivalToTreatmentComplete=
		DATEDIFF(MINUTE,
              CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
        CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TreatmentCompleteDate AS DATETIME2)),CAST(TreatmentCompleteTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	ArrivalToTriageStart=
		DATEDIFF(MINUTE,
              CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
        CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TriageStartDate AS DATETIME2)),CAST(TriageStartTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	ArrivalToTriageEnd=
		DATEDIFF(MINUTE,
              CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
        CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TriageEndDate AS DATETIME2)),CAST(TriageEndTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	ArrivalToDischarge=
		DATEDIFF(MINUTE,
              CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
        CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(DischargeDate AS DATETIME2)),CAST(DischargeTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	ArrivalToEDClinicianSeen=
		DATEDIFF(MINUTE,
			CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(ArrivalDate AS DATETIME2)),CAST(ArrivalTime AS DATETIME2(0))) AS DATETIME2(0)),
			CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(EDClinicianSeenDate AS DATETIME2)),CAST(EDClinicianSeenTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	TriageToEDClinicianSeen=
		DATEDIFF(MINUTE,
			CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TriageStartDate AS DATETIME2)),CAST(TriageStartTime AS DATETIME2(0))) AS DATETIME2(0)),
			CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(EDClinicianSeenDate AS DATETIME2)),CAST(EDClinicianSeenTime AS DATETIME2(0))) AS DATETIME2(0))
		),
	TriageToCompleted=
		DATEDIFF(MINUTE,
			CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TriageStartDate AS DATETIME2)),CAST(TriageStartTime AS DATETIME2(0))) AS DATETIME2(0)),
                    COALESCE(
                        CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate1 AS DATETIME2)),CAST(BreachEndTime1 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate2 AS DATETIME2)),CAST(BreachEndTime2 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate3 AS DATETIME2)),CAST(BreachEndTime3 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate4 AS DATETIME2)),CAST(BreachEndTime4 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate5 AS DATETIME2)),CAST(BreachEndTime5 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(BreachEndDate6 AS DATETIME2)),CAST(BreachEndTime6 AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(TreatmentCompleteDate AS DATETIME2)),CAST(TreatmentCompleteTime AS DATETIME2(0))) AS DATETIME2(0)),
						CAST(DATEADD(DAY,DATEDIFF(DAY,'1 January 0001 00:00:00',CAST(DepartureDate AS DATETIME2)),CAST(DepartureTime AS DATETIME2(0))) AS DATETIME2(0))
                    )
		),
		CompletedDate=
			COALESCE(BreachEndDate1,BreachEndDate2,BreachEndDate3,BreachEndDate4,BreachEndDate5,BreachEndDate6,TreatmentCompleteDate,DepartureDate),
		CompletedTime=
			CASE
				WHEN BreachEndDate1 IS NOT NULL THEN BreachEndTime1
				WHEN BreachEndDate2 IS NOT NULL THEN BreachEndTime2
				WHEN BreachEndDate3 IS NOT NULL THEN BreachEndTime3
				WHEN BreachEndDate4 IS NOT NULL THEN BreachEndTime4
				WHEN BreachEndDate5 IS NOT NULL THEN BreachEndTime5
				WHEN TreatmentCompleteDate IS NOT NULL THEN TreatmentCompleteTime
				WHEN DepartureDate IS NOT NULL THEN DepartureTime
			END

FROM
	Foundation.dbo.UnscheduledCare_Data_EDAttendance EDA
WHERE
	EDA.Load_GUID=@Load_GUID

UPDATE Foundation.dbo.UnscheduledCare_Data_EDAttendance
SET EarlyWarningScore=ews.res_EF_Value
FROM
Foundation.dbo.UnscheduledCare_Data_EDAttendance EDA
INNER JOIN 
(
	SELECT res_EF_atdid, res_EF_Value
	FROM
	(	
		SELECT 
		ROW_NUMBER() OVER(PARTITION BY res_EF_atdid ORDER BY res_EF_created ASC) AS 'Row',
		res_EF_atdid,
		res_EF_Value
		FROM [BCUED\BCUED_DB].[EMIS_SYM_BCU_Live].dbo.Result_Details_ExtraFields 
		WHERE res_EF_fieldid = '1202'
		AND res_EF_Value <> ''
	) AS t
	WHERE t.Row ='1'
) AS ews ON CAST(ews.res_EF_atdid AS VARCHAR(20))= EDA.AttendanceIdentifier

WHERE 
--LEFT(EDA.AttendanceNumber,4) = 'YGED' AND
EDA.Load_GUID = @Load_GUID AND
EDA.Area='West' AND Source='WEDS'

ALTER INDEX [PK__Unschedu__B080ED075AA615B1] ON [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] REORGANIZE  WITH ( LOB_COMPACTION = ON )



END
	
GO
