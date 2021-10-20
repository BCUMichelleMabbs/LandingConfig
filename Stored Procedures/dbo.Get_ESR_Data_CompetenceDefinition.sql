SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
[dbo].[Get_ESR_Data_CompetenceDefinition]
as
begin

SELECT 
[RecordType]
      ,[CompetenceID]
      ,[CompetenceName]
      ,[Description]
      ,CONVERT(Date,LEFT(DateFrom,8)) as DateFrom
	  ,CONVERT(Date,LEFT(DateTo,8)) as DateTo
      ,[BehaviouralIndicator]
      ,[CertificationRequired]
      ,[RatingScaleID]
      ,[EvaluationMethod]
      ,[RenewalPeriodFreq]
      ,[RenewalPeriodUnits]
      ,[CompetenceCluster]
      ,[CompetenceAlias]
      ,[VPDCode]
      ,[DeletionFlag]
       ,CONVERT(date,LEFT([LastUpdateDate],8)) as LastUpdateDate
	   	  ,LoadDate as RetrivalDate

  FROM [SSIS_Loading].[ESR].[dbo].[CompetenceDefinition]
   
  end
GO
