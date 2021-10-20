SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Data_CADVehicles]

AS
BEGIN
	SET NOCOUNT ON;
	select
	      AS3DestinationHospital
      ,AttendedHospital
      ,CallSign
      ,ClinicAttended
      ,HandOverTime
      ,HospitalAttendedHealthBoardCode
      ,HospitalCodeClean
      ,HospitalHealthBoard
      ,HospitalName
      ,HospitalTypeName
,IncidentID
      ,IsStoodDown
      ,ResponseLastUpdate
      ,TimeTriaged
      ,TransportFromHospitalID
      ,TransportToHospitalID
      ,VehicleAllocationSequenceNumber
      ,VehicleArrivalAtSceneDateTime
      ,VehicleAtHospDateTime
      ,VehicleClearDateTime
      ,VehicleID
      ,VehicleLeftSceneDateTime
      ,VehicleType
      ,VehicleTypeName

  FROM [7A1A1SRVINFONDR].[WAST].[dbo].[CADVehicles]
    where ResponseLastUpdate >= dateadd(week,-1,convert(date,getdate())) --run the last weeks
End
GO
