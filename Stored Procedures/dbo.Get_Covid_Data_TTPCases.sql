SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Covid_Data_TTPCases] 
AS BEGIN

SELECT [CitizenID]
      ,[CaseID] 
      ,[CaseCreatedDate]
	  ,CAST([CaseCreatedDateTime] as time) as CaseCreatedTime
      ,[CaseModifiedDate]
	  ,CAST([CaseModifiedDateTime] as time) as CaseModifiedTime
      ,[CaseDescription]
      ,[NHSNumber]
      ,[FirstName]
      ,[LastName]
      ,[Address]
      ,[LocalAuthorityNameTeam]
      ,[LocalAuthorityCodeTeam]
      ,[LocalHealthBoardNameTeam]
      ,[LocalHealthBoardCodeTeam]
      ,[LocalAuthorityResidenceName]
      ,[LocalAuthorityResidenceCode]
      ,[LocalAuthorityResidenceONSCode]
      ,[LocalHealthBoardResidenceCode]
	  ,[LocalHealthBoardResidenceName]
      ,[LocalHealthBoardResidenceONSCode]
      ,[Postcode]
      ,[BirthDate]
      ,[Age]
      ,[SexDescription]
	  ,[EthnicityDescription]
      ,[VulnerabilityDescription]
	  ,[GPPracticeCodeCurrentlyRegistered]
	  ,[KeyWorkerFlag]
      ,[KeyWorkerCategory]
      ,[ParentIndexCaseID]
      ,PreviousStatus
      ,CAST(PreviousStatusDateTime as date) as PreviousStatusDate
      ,[LSOAResidenceCode]
	  ,[WIMDDecile]
      ,[WIMDQuintile]
      ,[Occupation]
      ,[ClosedSetting]
      ,[ComplexCareSetting]
	  ,[LaboratoryConfirmationStatus]
      ,[LatestTestResultCode]
      ,[LatestTestLaboratoryConfirmedDateTime]
      ,CAST([LatestTestLaboratoryConfirmedDateTime] as time) AS LatestTestLabConfirmedTime
	  ,[LatestTestSampleLocation]
	  ,CAST([LatestTestRequestDatetime] as date) as LatestTestRequestDate
	  ,CAST([LatestTestRequestDatetime] as time) as LatestTestRequestTime
      ,[LatestTestType]
      ,[DateOfDeath]
      ,[NumberOfSymptomsRecorded]
      ,[CaseType]
      ,[HospitalAdmission]
      ,[HospitalName]
      ,[HospitalisationDate]
      ,[ICUAdmitted]
	  ,[EndOfIsolationDate]
      ,[StatusDescription]
	  ,[PositiveResultFlag]
	  ,[MonitoringStatusDescription]
      ,[EligibleforContact]
      ,[ReasonIneligbleforContact]
	  ,[DemographicDetailsConfirmedFlag]
	  ,[IsPregnantFlag]
      ,[JobRoleName]
      ,[LocationOfEmployment]
      ,[LocationOfEmploymentPostcode]
      ,[LocationOfEmploymentLocalAuthorityName]
      ,[LastUpdated]

  FROM [7A1A1SRVINFONDR].[TTP].[dbo].[TTPCasesView]
  where casecreateddate >= '15 June 2021'

END
GO
