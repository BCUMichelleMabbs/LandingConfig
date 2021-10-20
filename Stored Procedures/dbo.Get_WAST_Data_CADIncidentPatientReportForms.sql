SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Data_CADIncidentPatientReportForms]

AS
BEGIN
	SET NOCOUNT ON;
	select
	 [IncidentID] 
	 ,[PCRNo]
	 ,[PCROrder] 
	 ,[VehicleAllocationSequenceNumber]
      ,[VehicleID]

      
     
  FROM [7A1A1SRVINFONDR].[WAST].[dbo].[CADIncidentPatientReportForms]

End
GO
