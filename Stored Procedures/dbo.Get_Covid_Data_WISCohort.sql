SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Covid_Data_WISCohort] AS BEGIN
WITH CTE AS (SELECT
      NULL as BatchID,
      [NHSNumberFormatted] as NHSNumber,
      [DateOfBirthFormatted] as DateOfBirth,
      [PRS_SEX] as Sex,
      [PRS_SURNAME] as Surname,
      [PRS_FORENAME] as Forename,
      [PRS_ADDRESS1] as Address1,
      [PRS_ADDRESS2] as Address2,
      [PRS_ADDRESS3] as Address3,
      [PRS_ADDRESS4] as Address4,
      [PRS_ADDRESS5] as Address5,
      [PRS_POSTCODE] as Postcode,    
      [PRS_ETHNIC_ORIGIN] as Ethnicity,
      [PracticeHealthBoard] as HealthBoard,
      [PRS_PRIORITY_GROUP] as PriorityGroup,
      NULL as DateCreated,
      CONVERT(Date, ImportDateTime) as DateUpdated,
      NULL as TimeCreated,
      
      CONVERT(time(0), ImportDateTime) as TimeUpdated,
      [PRS_TELEPHONE] as TelephoneNumber,
      [PRS_MOBILE] as MobilePhoneNumber,
      [PRS_EMAIL] as EmailAddress,
      [PRS_PRACTICE_CODE] as GPPractice,
      NULL as WDSGender,
      [PRS_MAIN_IMM_LOC_CODE] as ImmunisationLocation,
      WIS_IDENTIFIER as WISIdentifier,
      [PRS_OCC_ORGANISATION_NAME] as StaffOrganisationName,
      [PRS_OCC_FRONTLINE_INDICATOR] as StaffFrontlineIndicator,
      [PRS_OCC_SECTOR] as StaffWorkSector,
      [PRS_OCC_LOCATION_OF_WORK] as StaffWorkLocation,
      [PRS_OCC_JOB_ROLE_CATEGORY] as StaffJobRoleCategory,
      [PRS_OCC_STAFF_IDENTIFIER] as StaffIdentifier,
      NULL as SuccessfullyPushed,
      NULL as AuditDate,
      NULL as AuditTime,
      NULL as SubmittedBy,
      'BCU' as Area,
      'NDR' as Source,
      CONVERT(date,DateOfDeathFormatted) as DateOfDeath,
      DeceasedFlag as DeceasedFlag,
      [PRS_IDENTIFIER] as CISIdentifier,
      OPT_Vaccine_Date as OPTVaccineDate,
      OPT_Vaccine as OPTVaccine,
      OPT_Type_Code as OPTTypeCode,
      SUSPENSE_DATE as ImmunisationSuspenseDate,
      PRS_OCC_UNPAID_CARER as UnpaidCarer,
CASE WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) between 18 and 29 THEN 'P10c'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) between 30 and 39 THEN 'P10b'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) >= 40 THEN 'P10a'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) between 16 and 17 THEN 'P10d'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) between 12 and 15 THEN 'P10e'
ELSE [PRS_PRIORITY_GROUP] END as PriorityGroupDerived,

       RecordDeletedFromWis,

       FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) as Age,


       --CASE WHEN FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], '31 March 2021') / 365.25) < 18 and [PRS_PRIORITY_GROUP] = 'P10' THEN 'U18' ELSE NULL END as U18Flag
       NULL as U18Flag,
       NULL as NursingHomeFlag,
        NULL as NursingHomeType,
        NULL as EMIFlag,
        NULL as NursingHomeName,
        1 as RowNumber
        

 

  FROM  [7A1A1SRVINFONDR].[Covid_Vaccination].[dbo].[WIS_CohortData] C
  WHERE PRS_Surname not in ('NWISBCUTEST','NWISTEST','NWISTESTCROSSSEC')
  and [WIS_PATIENT_AREA] = '7A1'
  )

 

  ,CTE2 AS (

 

  SELECT
      NULL as BatchID,
      [NHSNumberFormatted] as NHSNumber,
      [DateOfBirthFormatted] as DateOfBirth,
      [PRS_SEX] as Sex,
      [PRS_SURNAME] as Surname,
      [PRS_FORENAME] as Forename,
      [PRS_ADDRESS1] as Address1,
      [PRS_ADDRESS2] as Address2,
      [PRS_ADDRESS3] as Address3,
      [PRS_ADDRESS4] as Address4,
      [PRS_ADDRESS5] as Address5,
      [PRS_POSTCODE] as Postcode,    
      [PRS_ETHNIC_ORIGIN] as Ethnicity,
      [PracticeHealthBoard] as HealthBoard,
      [PRS_PRIORITY_GROUP] as PriorityGroup,
      NULL as DateCreated,
      CONVERT(Date, ImportDateTime) as DateUpdated,
      NULL as TimeCreated,
      
      CONVERT(time(0), ImportDateTime) as TimeUpdated,
      [PRS_TELEPHONE] as TelephoneNumber,
      [PRS_MOBILE] as MobilePhoneNumber,
      [PRS_EMAIL] as EmailAddress,
      [PRS_PRACTICE_CODE] as GPPractice,
      NULL as WDSGender,
      [PRS_MAIN_IMM_LOC_CODE] as ImmunisationLocation,
      WIS_IDENTIFIER as WISIdentifier,
      [PRS_OCC_ORGANISATION_NAME] as StaffOrganisationName,
      [PRS_OCC_FRONTLINE_INDICATOR] as StaffFrontlineIndicator,
      [PRS_OCC_SECTOR] as StaffWorkSector,
      [PRS_OCC_LOCATION_OF_WORK] as StaffWorkLocation,
      [PRS_OCC_JOB_ROLE_CATEGORY] as StaffJobRoleCategory,
      [PRS_OCC_STAFF_IDENTIFIER] as StaffIdentifier,
      NULL as SuccessfullyPushed,
      NULL as AuditDate,
      NULL as AuditTime,
      NULL as SubmittedBy,
      'BCU' as Area,
      'NDR' as Source,
      CONVERT(date,DateOfDeathFormatted) as DateOfDeath,
      DeceasedFlag as DeceasedFlag,
      [PRS_IDENTIFIER] as CISIdentifier,
      OPT_Vaccine_Date as OPTVaccineDate,
      OPT_Vaccine as OPTVaccine,
      OPT_Type_Code as OPTTypeCode,
      SUSPENSE_DATE as ImmunisationSuspenseDate,
      PRS_OCC_UNPAID_CARER as UnpaidCarer,
CASE WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) between 18 and 29 THEN 'P10c'

            WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) between 30 and 39 THEN 'P10b'

            WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25)  >= 40  THEN 'P10a'

            WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) < 18 THEN 'P10d'

            ELSE [PRS_PRIORITY_GROUP] END as PriorityGroupDerived,

       RecordDeletedFromWis,

       FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], CAST(GETDATE() as date)) / 365.25) as Age,


       --CASE WHEN FLOOR(DATEDIFF(DAY, [DateOfBirthFormatted], '31 March 2021') / 365.25) < 18 and [PRS_PRIORITY_GROUP] = 'P10' THEN 'U18' ELSE NULL END as U18Flag
       NULL as U18Flag,
       NULL as NursingHomeFlag,
        NULL as NursingHomeType,
        NULL as EMIFlag,
        NULL as NursingHomeName,
        ROW_NUMBER() OVER (PARTITION BY NHSNumberFormatted ORDER BY CAST(replace(ISNULL([PRS_PRIORITY_GROUP],'P10'),'P','') as float)) as RowNumber
        --,WIS_PATIENT_AREA
        

 

  FROM  [7A1A1SRVINFONDR].[Covid_Vaccination].[dbo].[WIS_CohortData] C
  WHERE PRS_Surname not in ('NWISBCUTEST','NWISTEST','NWISTESTCROSSSEC')
  and [WIS_PATIENT_AREA] <> '7A1' AND [PracticeHealthBoard] = '7A1'
  )

 

    SELECT * FROM CTE C1

    UNION ALL

    SELECT * FROM CTE2 C2 
	
	WHERE C2.NHSNumber NOT IN (SELECT NHSNumber FROM CTE) and C2.RowNumber = 1

END
GO
