SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



Create Procedure
[dbo].[Get_ESR_Data_Turnover]
as
begin

SELECT 

 [OrgL4] as OrganisationLevel4
      ,[OrgL5] as OrganisationLevel5
      ,[OrgL6] as OrganisationLevel6
      ,[OrgL7] as OrganisationLevel7
      ,[OrganizationName]
      ,[AverageFTE] as AverageFTE
      ,[LeaversFTE] as SumOfFTEActual
      ,convert(date,[CensusDate]) as [CensusDate]
  FROM [SSIS_Loading].[ESR].[dbo].[ESR_Data_Turnover]






  end
GO
