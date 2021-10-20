SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
[dbo].[Get_ESR_Data_Location]
as
begin

SELECT 

[RecordType]
      ,[LocationID]
      ,[LocationCode]
      ,[LocationDescription]
,CONVERT(date,InactiveDate) as InactiveDate
      ,[AssignmentAddressLine1]
      ,[AssignmentAddressLine2]
      ,[AssignmentAddressLine3]
      ,[Town]
      ,[County]
      ,[Postcode]
      ,[Country]
      ,[Telephone]
      ,[Fax]
      ,[PayslipDelivery]
      ,[SiteCode]
      ,[WelshLocationTranslation]
      ,[WelshAddressLine1]
      ,[WelshAddressLine2]
      ,[WelshAddressLine3]
      ,[WelshTownTranslation]
  ,CONVERT(date,LEFT([LastUpdateDate],8)) as LastUpdateDate
      ,[DeletionFlag]
	  	  ,LoadDate as RetrivalDate


  FROM [SSIS_Loading].[ESR].[dbo].[Location]



  end
GO
