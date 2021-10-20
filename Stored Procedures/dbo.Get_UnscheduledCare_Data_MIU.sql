SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_MIU]
	
AS
BEGIN
	
SELECT  [Date]
      ,[Site]
      ,[NewTreatedUnder4Hrs]
      ,[NewTreatedOver4Hrs]
      ,[ReviewTreatedUnder4Hrs]
      ,[ReviewTreatedOver4Hrs]
      ,[PlannedFollow-Up]
      ,[NewTreatedUnder4Hrs]+[NewTreatedOver4Hrs]+[ReviewTreatedUnder4Hrs]+[ReviewTreatedOver4Hrs] AS [Total Seen]
  FROM [SSIS_Loading].[EFORMS].[dbo].[X_MIU]

END
GO
