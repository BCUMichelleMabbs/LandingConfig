SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Covid_Data_VaccinationStock] 
AS BEGIN

SELECT [Area]
      ,[VaccineType]
      ,[Measure]
      ,[WeekCommencing]
      ,[Value]
      ,[Total]
      ,[LocationCode]
      ,[LocationName]
      ,[Source]

  FROM SSIS_loading.[Covid].[dbo].[Covid_Data_VaccinationStock]

END
GO
