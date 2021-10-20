SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure
[dbo].[Get_ESR_Data_MandatoryTraining]
as
begin


SELECT 
  [OrgL4] as OrganisationLevel4
      ,[OrgL5] as OrganisationLevel5
      ,[OrgL6] as OrganisationLevel6
      ,[OrgL7] as OrganisationLevel7
      ,[OrganizationName]
      ,[SumofAchieved]
      ,[SumofRequired]
	 ,  CONVERT(date,CensusDate)  as CensusDate
  FROM [SSIS_Loading].[ESR].[dbo].[ESR_Data_MandatoryTraining]

  end
GO
