SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceWestLive]
	
AS
BEGIN
	
SET NOCOUNT ON;
SELECT [Area]
      ,[Source]
      ,[HospitalNumber]
      ,[NHSNumber]
      ,[PatientName]
      ,[DTTM_OF_BIRTH]
      ,[ArrivalDate]
      ,[ArrivalTime]
      ,[DepartureDate]
      ,[DepartureTime]
      ,[HospitalId]
      ,[Expr3]
      ,[Expr4]
      ,[Expr5]
      ,[Expr6]
      ,[Expr7]
      ,[Expr8]
      ,[TriageCategory]
      ,[CurrentLocation]
      ,[AttendanceCategory]
      ,[AttendanceGroup]
      ,[ArrivalMode]
      ,[SiteCodeOfTreatment]
      ,[CensusDateTime]
      ,[Active]
      ,[HospitalName]
      ,[TreatmentStartDate]
      ,[TreatmentStartTime]
      ,[TreatmentEndDate]
      ,[TreatmentEndTime]
      ,[BreachEndDate]
      ,[BreachEndTime]
      ,[BreachReason]
      ,[TriageStartDate]
      ,[TriageStartTime]
      ,[TriageEndDate]
      ,[TriageEndTime]
      ,[TimeWaiting]
      ,[EDClinicianSeen]
      ,[AttendanceIdentifier]
      ,[Note1]
      ,[NoteType1]
      ,[Note2]
      ,[NoteType2]
      ,[Note3]
      ,[NoteType3]
      ,[Presenting Complaint]
	  ,[Lodged],
	  DischargeOutcome,
	  NULL AS TriageComplaint,
		NULL AS TriageDiscriminator,
	NULL AS TriagePainScore,
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
  FROM  [7A1AUSRVIPMSQL].[iPMProduction].[dbo].[BCU_Foundation_LiveED_Feed]


END

GO
