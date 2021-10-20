SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Eform_Data_USCDowngrade]

AS

BEGIN

SELECT 


      PatientNumber as LocalPatientIdentifier
      ,RegisteredGpPracticeCode as RegisteredGPPracticeCode
      ,ReferralDate as DateReferral
      ,SpecialtyDescriptionFull as SpecialtyConsultantClinicalCondition
      ,CAST(CurrentCensusDate as Date) as CensusDate
      ,USChangeType as UnscheduledChangeType
      ,WLEntryNumber as WaitingListNumber
      ,NHSNumber as NHSNumber
      ,SenderOrganisation  as SenderOrganisation
      ,SpecialtyCode as SpecialtyCode
      ,ConsltantCode as ConsultantCode
      ,ConsultantName as ConsultantName
      ,CurrentUSC as CurrentUSC
      ,CurrentUSCType as CurrentUSCType
      ,CAST(PreviousCensusDate as Date) as PreviousCensusDate
      ,PreviousUSC as PreviousUSC
      ,PreviousUSCType as PreviousUSCType
      ,SubSpecialtyCode as SubSpecialtyCode
      ,ReferralReason as ReferralReasonCode
      ,ClinicalCondition as ClinicalConditionCode
	  ,ReferralSource as ReferralSource
      ,CAST(SubmitDate as Date) as ValidationDate
      ,DowngradeReason as DowngradeReason
      ,Nadex as Nadex
      ,CAST(AuditedDateTime as DateTime) as AuditedDateTime
      ,Comments as Comments
      

  FROM [SSIS_LOADING].[EFORMS].[dbo].[USCCancer]

END
GO
