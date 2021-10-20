SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Update_PAS_TheatreSession_Time]
*/
CREATE PROCEDURE [dbo].[Update_PAS_TheatreSession_Time]
	@LoadGUID VARCHAR(38)

AS
BEGIN
SET NOCOUNT ON;

	UPDATE [Foundation].[dbo].[PAS_Data_TheatreSession]
	SET [UnAvailableTime] = CASE WHEN (DATEDIFF(MINUTE, CAST([ActualStartDate] AS DATETIME)+CAST([ActualStartTime] AS DATETIME), CAST([ActualFinishDate] AS DATETIME)+CAST([ActualFinishTime] AS DATETIME)))>= [ScheduledSessionTime] THEN 0 ELSE DATEDIFF(MINUTE, CAST([ScheduledStartDate] AS DATETIME)+CAST([ScheduledStartTime] AS DATETIME), CAST([SessionEndDate] AS DATETIME)+CAST([SessionEndTime] AS DATETIME)) - (DATEDIFF(MINUTE, CAST([ActualStartDate] AS DATETIME)+CAST([ActualStartTime] AS DATETIME), CAST([ActualFinishDate] AS DATETIME)+CAST([ActualFinishTime] AS DATETIME))) END
	WHERE [SenderOrganisation] IN ('Cent', 'East')

	UPDATE [Foundation].[dbo].[PAS_Data_TheatreSession]
	SET TimeOfDay =
		CASE
			WHEN CAST([ActualStartTime] AS TIME) >= '8:00:00.000' AND CAST([ActualFinishTime] AS TIME) <= '12:30:00.000' THEN 'AM'
			WHEN CAST([ActualStartTime] AS TIME) >= '12:30:00.000' AND CAST([ActualFinishTime] AS TIME) <= '17:00:00.000' THEN 'PM'
			WHEN CAST([ActualStartTime] AS TIME) >= '17:00:00.000' AND CAST([ActualFinishTime] AS TIME) <= '21:30:00.000' THEN 'Eve'
			WHEN CAST([ActualStartTime] AS TIME) >= '8:00:00.000' AND CAST([ActualFinishTime] AS TIME) <= '17:30:00.000' THEN 'All'
			WHEN CAST([ActualStartTime] AS TIME) >= '0:01:00.000' AND CAST([ActualFinishTime] AS TIME) <= '23:59:00.000' THEN 'Emerg'
			ELSE 'Night'
		END
	WHERE [SenderOrganisation] IN ('Cent', 'East')
END
GO
