SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Covid_Data_LIMS_MDS]

AS
BEGIN
	SET NOCOUNT ON;
 SELECT
      CRN as LocalPatientIdentifier,
      NHSNo as NHSNumber,
      SubjectFirstForename + ' ' +  SubjectSurname as PatientName,
      CONVERT(date, SubjectDOB) as DoB,
      SubjectGenderCode as Gender,
      AddressLine1,
      AddressLine2,
      AddressLine3,
      AddressLine4,
      SubjectPostcode as Postcode,
      GPPractice,
      CTUPersonType,
      CTULocation,
      CTULocationParentOrganisationCode as CTUParentOrganisationCode,
      CTULocationParentOrganisationName as CTUParentOrganisationName,
      TestingLabCode,
      TestingLabName,
      LocationCode as CTHOSCode,
      Location as CTHOSName,    
      PatientTypeDescription as PatientType,
      RequestType,
      OutbreakCode,
      Outbreak,      
      TestSetStatus,     
      CONVERT(date, EntryDateTime ) as TestEntryDate,
      CONVERT(time, EntryDateTime) as TestEntryTime,
      CONVERT(date, SpecimenCollectedDate ) as TestCollectedDate,
      CONVERT(time, SpecimenCollectedTime) as TestCollectedTime,
      CONVERT(date, SpecimenReceivedDate ) as TestReceivedDate,
      CONVERT(time, SpecimenReceivedTime) as TestReceivedTime,
      CONVERT(date, AuthorisedDate ) as TestAuthorisationDate,
      CONVERT(time, AuthorisedTime) as TestAuthorisationTime,
      [TATReq (m)] AS TATReq,
      [TATLab (m)] as TATLab,
      CASE WHEN ResultCode = 'D7' and AuthorisedDate is not null THEN 'Positive'
		   WHEN ResultCode = 'LL7' and AuthorisedDate is not null THEN 'Low Level'
		   WHEN ResultCode = 'ND7' and AuthorisedDate is not null  then 'Negative'
		   WHEN ResultCode = 'D7' and AuthorisedDate is  null THEN 'Positive - Not Authorised'
		   WHEN ResultCode = 'ND7' and AuthorisedDate is null  then 'Negative - Not Authorised'
		   WHEN ResultCode not in ('ND7','D7') and AuthorisedDate is null then 'In Progress'
		   END AS Result,
      CASE WHEN NewCaseFlag = 1 THEN 'Y' ELSE 'N' END as NewCaseFlag,
      LocalHealthBoardResidenceCode,
      LocalAuthorityResidenceName,
      CASE WHEN LighthouseLabFlag = 1 THEN 'Y' ELSE 'N' END as LighthouseLabFlag,
      GETDATE() as LastUpdated,
	  Episode as VisitNumber,
	  _updated as LastModified,
	  CONVERT(date,CreatedDateTime ) as TestCreatedDate,
	  CONVERT(time,CreatedDateTime ) as TestCreatedTime

      
  FROM [7A1A1SRVINFONDR].[LIMS].[dbo].[CovidMDS]
  
 WHERE CONVERT(date,EntryDateTime) >= DATEADD( DD, -30, GETDATE())
 
End
GO
