SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
[dbo].[Get_ESR_Ref_Position]
as
begin

SELECT 
[RecordType]
      ,[PositionID]
,CONVERT(date,EffectiveFromDate) as EffectiveFromDate
,CONVERT(date,EffectiveToDate) as EffectiveToDate
      ,[PositionNumber]
      ,[PositionName]
,CONVERT(decimal(10,2),CASE WHEN BudgetedFTE like '.%' then '0'+BudgetedFTE when BudgetedFTE = ' ' then null else BudgetedFTE END) As BudgetedFTE
      ,[SubjectiveCode]
      ,[JobStaffGroup]
      ,[JobRole]
      ,[OccupationCode]
      ,[Payscale]
      ,[GradeStep]
      ,[ISARegulatedPost]
      ,[OrganisationID]
      ,[HiringStatus]
      ,[PositionType]
      ,[Column18]
      ,[Column19]
      ,[Column20]
      ,[Column21]
      ,[WorkplaceOrgCode]
  ,CONVERT(date,LEFT([LastUpdateDate],8)) as LastUpdateDate
      ,[SubjectiveCodeDesc]
      ,[DeletionFlag]
	  	  ,LoadDate as RetrivalDate

  FROM [SSIS_Loading].[ESR].[dbo].[Position]



  end
GO
