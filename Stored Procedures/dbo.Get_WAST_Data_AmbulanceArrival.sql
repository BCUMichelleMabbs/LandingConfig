SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Data_AmbulanceArrival]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT [IncidentID]
      ,CAST(LEFT([IncidentDateTime],23) as datetime) as [IncidentDateTime]
      ,[IncidentDate]
      ,[IncidentTime]
      ,CAST(LEFT([VehicleAtHospDateTime],23) as datetime) as [VehicleAtHospDateTime]
      ,[VehicleAtHospitalDate]
      ,[VehicleAtHospitalTime]
      ,CAST(LEFT([TriageDateTime],23) as datetime) as [TriageDateTime]
      ,[TriageDate]
      ,[TriageTime]
      ,CAST(LEFT([HandOverDateTime],23) as datetime) as [HandOverDateTime]
      ,[HandOverDate]
      ,[HandOverTime]
      ,[IncidentLocationNorthing]
      ,[IncidentLocationEasting]
      ,[PostCode]
      ,[PostcodeArea]
      ,[CallReceivedMethod]
      ,CASE [HospitalName]
					WHEN 'Wrexham Maelor' THEN 'Wrexham Maelor Hospital'
					WHEN 'Ysbyty Glan Clwyd' THEN 'Glan Clwyd Hospital'
				ELSE [HospitalName]
		END AS [HospitalName]
      ,[IncidentLocation]
      ,[ZoneCode]
      ,[Zone]
      ,[VehicleType]
      ,[IncidentType]
      ,[IncidentCategory]
      ,[NatureOfIncident]
      ,CAST([LateReasonFlag] as VARCHAR) as [LateReasonFlag]
      ,[LateTurnaroundReason]
      ,[TotalTransports]
      ,[Notifications]
      ,[NoNotification]
      ,[Handovers]
      ,[UpToFifteen]
      ,[FifteenToThirty]
      ,[ThirtyToFortyFive]
      ,[FortyFiveToSixty]
      ,[SixtyToOneTwenty]
      ,[OneTwentyToOneEighty]
      ,[OverOneEighty]
      ,[HandoverBy]
      ,[Weighted]
      ,CAST([PerfIn15] as VARCHAR) as [PerfIn15]
      ,[Perf]
      ,[Incidents]
      ,CAST(LEFT([LastUpdatedDateTime],23) as datetime) as [LastUpdatedDateTime]
      ,[LastUpdatedDate]
      ,[LastUpdatedTime]
  FROM [SSIS_LOADING].[WAST].[dbo].[WAST_Data_Historic]

End
GO
