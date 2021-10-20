SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
[dbo].[Get_ESR_Data_Person]
as
begin

SELECT 
[RecordType]
      ,[PersonID]
      ,convert(date,[EffectiveStartDate]) as [EffectiveStartDate]
      ,convert(date,[EffectiveEndDate]) as [EffectiveEndDate]
      ,[EmployeeNumber]
      ,[Title]
      ,[LastName]
      ,[FirstName]
      ,[MiddleNames]
      ,[MaidenName]
      ,[PreferredName]
      ,[PreviousLastName]
      ,[Gender]
      ,convert(date,[DateofBirth]) as [DateofBirth]
      ,[NationalInsuranceNo]
      ,[NHSUniqueID]
      ,convert(date,[HireDate]) as [HireDate]
      ,convert(date,[ActualTerminationDate]) as [ActualTerminationDate]
      ,[TerminationReason]
      ,[EmployeeStatusFlag]
      ,[WTROptOut]
      ,convert(date,[WTROptOutDate]) as [WTROptOutDate]
      ,[EthnicOrigin]
      ,[Column24]
      ,[CountryofBirth]
      ,[PreviousEmployer]
      ,[PreviousEmployerType]
      ,convert(date,[CSD3Months]) as [CSD3Months]
      ,convert(date,[CSD12Months]) as [CSD12Months]
      ,[NHSCRSUUID]
      ,[Column31]
      ,[Column32]
      ,[Column33]
      ,[SystemPersonType]
      ,[UserPersonType]
      ,[OfficeEmailAddress]
      ,convert(date,[NHSStartDate]) as [NHSStartDate]
      ,[Column38]
      ,CONVERT(date,LEFT([LastUpdateDate],8)) as LastUpdateDate
      ,[DisabilityFlag]
      ,[DeletionFlag]

		,row_number()Over(Partition by PersonID order by EffectiveEndDate asc) as PersonOrder
		,case when EffectiveEndDate = '1900-01-01' then 1
		 when EffectiveEndDate = '31 Dec 4712' then 1 
		else 0 end as PersonLiveFlag
   	  	  ,case when convert(date,EffectiveEndDate) = '01 Jan 1900' then dateadd(year,300,convert(date,EffectiveEndDate)) else EffectiveEndDate end as EffectiveEndDateAjusted
  	  ,LoadDate as RetrivalDate

  
  from [SSIS_Loading].[ESR].[dbo].[Person]

  end
GO
