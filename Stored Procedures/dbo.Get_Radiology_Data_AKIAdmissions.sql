SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[Get_Radiology_Data_AKIAdmissions] 
AS BEGIN 


select [Dataset]
      ,[MeasureNo] as MeasureNumber
      ,[Measure]
      ,[Grp] as GRP
      ,[HospitalName]
      ,[MonthStartDate] as MonthDate
      ,[Admissions]
      ,[CensusDate]

from [7A1A1SRVINFODEV].[Elain].[dbo].[OLE DB Destination]

END
GO
