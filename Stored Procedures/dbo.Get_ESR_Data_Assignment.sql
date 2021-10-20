SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
[dbo].[Get_ESR_Data_Assignment]
as
begin

SELECT [RecordType]
      ,[PersonID]
      ,[AssignmentID]
      ,CONVERT(Date,[EffectiveStartDate]) as [EffectiveStartDate]
      ,CONVERT(Date,[EffectiveEndDate]) as [EffectiveEndDate]
      ,CONVERT(Date,[EarliestAssignmentStartDate]) as [EarliestAssignmentStartDate]
      ,[AssignmentType]
      ,[AssignmentNumber]
      ,[SystemAssignmentStatus]
      ,[UserAssignmentStatus]
      ,[EmployeeStatusFlag]
      ,[PayrollName]
      ,[PayrolPeriodType]
      ,[AssignmentLocationID]
      ,[SupervisorFlag]
      ,[SupervisorPersonID]
      ,[SupervisorAssignmentID]
      ,[SupervisorAssignmentNumber]
      ,[DepartmentManagerPersonID]
      ,[EmployeeCategory]
      ,[AssignmentCategory]
      ,[PrimaryAssignment]
      ,[NormalHoursSessions]
      ,[Frequency]
      ,[GradeContractHours]
      ,[FTE]
      ,[FlexibleWorkingPattern]
      ,[OrganisationID]
      ,[PositionID]
      ,[PositionName]
      ,[Grade]
      ,[GradeStep]
      ,[StartDateinGrade]
      ,[AnnualSalaryValue]
      ,[JobName]
      ,[PeopleGroup]
      ,[TandAFlag]
      ,[AssignmentNightWorkerAttribute]
      ,CONVERT(Date,[ProjectedHireDate]) as [ProjectedHireDate]
      ,[VacancyID]
      ,CONVERT(Date,[ContractEndDate]) as [ContractEndDate]
      ,CONVERT(Date,[IncrementDate]) as [IncrementDate]
      ,[MaximumPartTimeFlag]
      ,[AFCFlag]
      ,CONVERT(date,LEFT([LastUpdateDate],8)) as [LastUpdateDate]
      ,[LastWorkingDay]
      ,[EKSFSpinalPoint]
      ,[ManagerFlag]
      ,CONVERT(Date,[AssignmentEndDate]) as [AssignmentEndDate]
      ,[Column50]
      ,[ContractReason]
      ,[DeletionFlag]
	  --new fields mm130921
	  ,Row_Number()Over(Partition by AssignmentNumber order by EffectiveEndDate asc) as AssignmentOrder
 ,case when EffectiveEndDate = '1900-01-01' then 1
 when EffectiveEndDate = '31 Dec 4712' then 1 
      else 0 end as AssignmentLiveFlag
	  ,case when convert(date,EffectiveEndDate) = '01 Jan 1900' then dateadd(year,300,convert(date,EffectiveEndDate)) else EffectiveEndDate end as EffectiveEndDateAjusted
	  ,LoadDate as RetrivalDate
  FROM [SSIS_Loading].[ESR].[dbo].[Assignment]
   
  end
GO
