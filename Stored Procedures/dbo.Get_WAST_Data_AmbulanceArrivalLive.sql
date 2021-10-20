SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Data_AmbulanceArrivalLive]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT
	   [SnapshotDateTime]
      ,[Hospital]
      ,[Dept]
      ,[Status]
      ,[Arrived]
      ,[Notified]
      ,[Handover]
      ,[MinsAtHosp]
      ,[H/OverDelay]
      ,[DelayAfterH/Over]
      ,[Callsign]
      ,[Crew1]
      ,[Crew2]
      ,[Nature]
      ,[Despatch]
      ,[HALO]
      ,[R]

	  INTO
		#TEMP1

	  FROM
		[SSIS_LOADING].[WAST].[dbo].[WAST_Live]

	SELECT 
	   CAST([SnapshotDateTime] as datetime) as [SnapshotDateTime]
      ,[Hospital]
      ,[Dept]
      ,[Status]
	  ,CAST([Arrived]  AS TIME) as [Arrived]
	  ,CAST([Notified] AS TIME) as [Notified]
	  ,CAST([Handover] AS TIME) as [Handover]
      ,[MinsAtHosp]
      ,[H/OverDelay]
      ,[DelayAfterH/Over]
      ,[Callsign]
      ,[Crew1]
      ,[Crew2]
      ,[Nature]
      ,[Despatch]
      ,[HALO]
      ,[R]
  FROM #TEMP1

  DROP TABLE #TEMP1

End
GO
