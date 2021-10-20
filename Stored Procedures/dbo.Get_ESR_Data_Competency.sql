SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
[dbo].[Get_ESR_Data_Competency]
as
begin

SELECT 
[RecordType]
      ,[PersonID]
      ,[CompetencyElementID]
      ,[CompetencyType]
      ,[CompetencyStatus]
      ,[CompetencyName]
,CONVERT(Date,DateFrom) as DateFrom
,CONVERT(date,DateTo) as DateTo
      ,[ProficiencyLevel]
      ,[VPDCode]
      ,CONVERT(Date,[CertificationDate]) as [CertificationDate]
      ,[CertificationMethod]
      ,CONVERT(Date,[NextCertificationDate]) as [NextCertificationDate]
      ,[CompetenceID]
      ,[BusinessGroupID]
      ,[JobID]
      ,[OrganisationID]
      ,[PositionID]
      ,[ProficiencyLevelID]
      ,[ProficiencyHighLevelID]
      ,[EssentialFlag]
      ,[RecordType2]
  ,CONVERT(date,LEFT([LastUpdateDate],8)) as LastUpdateDate
      ,[DateLastAwarded]
      ,[AwardedBy]
      ,[Title]
      ,[LastUpdatedBy]
      ,[DeletionFlag]
	  	  ,LoadDate as RetrivalDate

  FROM [SSIS_Loading].[ESR].[dbo].[Competency]



  end
GO
