SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure
[dbo].[Get_ESR_Data_PADR]
as
begin

SELECT 

 [Org L3]
      ,[Org L4]
      ,[Org L5]
      ,[Org L6]
      ,[Org L7]
      ,[Organization Name]
      ,[Staff Group]
      ,[Role]
      ,[Appraisal Date]
      ,[Next Appraisal Date]
      ,[Appraisal Date (incl# out of period)]
      ,[Status]
      ,[Detailed Status]
      ,[Complete]
      ,[All]
	  ,CONVERT(date,GetDate()) as LastUpdateDate
  FROM [SSIS_Loading].[ESR].[dbo].[PADR]  







  end
GO
