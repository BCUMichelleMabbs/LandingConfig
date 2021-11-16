SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_WAST_Data_NotificationAndHandover]

AS
BEGIN

SET NOCOUNT ON;

SELECT

	[IncidentID],
	[IncidentDateTime],
	[IncWeekDay],
	[VehicleAtHospDateTime],
	[TimeTriaged],
	[HandOverTime],
	[IncidentLocationNorthing],
	[IncidentLocationEasting],
	[PostCode],
	[PostcodeArea],
	[CallReceivedMethodDescription],
	[HospitalName],
	[IncidentLocationDescription],
	[LHB],
	[Locality],
	[ZoneCode],
	[ZONE],
	[VehicleType],
	[IncidentType],
	[IncidentCategory],
	[NatureOfIncident],
	[LateReasonFlag],
	[LateTurnaroundReason],
	[TotalTransports],
	[Notifications],
	[NoNotification],
	[Handovers],
	[UpToFifteen],
	[FifteenToThirty],
	[ThirtyToFortyFive],
	[FortyFiveToSixty],
	[SixtyToOneTwenty],
	[OneTwentyToOneEighty],
	[OverOneEighty],
	[HandoverBy],
	[Weighted],
	[PerfIn15],
	[Perf],
	[Incidents]

FROM [WAST].[dbo].[BCU_NotificationandHandover]

WHERE 1 = 1
AND CAST([VehicleAtHospDateTime] AS DATE) <> CAST(GETDATE() AS DATE) -- TO EXCLUDE TODAY AS WE ONLY WANT HISTORIC & TODAY ONLY GOES UP TO 3AM --
AND YEAR([VehicleAtHospDateTime]) = '2019'

End
GO
