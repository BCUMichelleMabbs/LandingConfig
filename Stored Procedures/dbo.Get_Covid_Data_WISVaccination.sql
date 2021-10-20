SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Covid_Data_WISVaccination] AS BEGIN



with cte as
(
select
[PRS_ADDRESS1] as Address1,
[PRS_ADDRESS2] as Address2,
[PRS_ADDRESS3] as Address3,
[PRS_ADDRESS4] as Address4,
[PRS_ADDRESS5] as Address5,
cast( [PRS_AGE] as int) as AgeAtVaccination,
Convert(date, [APPT_APPOINTMENT_DATE]) as AppointmentDate,
REPLACE(REPLACE([APPT_ELIGIBILITY_NOTE], CHAR(13),' '), CHAR(10),' ') as AppointmentEligibilityNote,
[ELIG_HAS_ALLERGIES] as AppointmentEligibilityQuestion1,
[ELIG_ANAPHYLAXIS] as AppointmentEligibilityQuestion2,
[ELIG_RECEIVED_VACCINATION_7DAYS] as AppointmentEligibilityQuestion3,
[ELIG_CONTRAINDICATION] as AppointmentEligibilityQuestion4,
[ELIG_CONSENT_GIVEN] as AppointmentEligibilityVaccineConsent,
[APPT_OUTCOME] as AppointmentOutcome,
[PRS_CARE_HOME_RESIDENT] as CareHomeResident,
Convert(date,[PRS_DATE_OF_BIRTH]) as DateOfBirth,
Convert(date,[PRS_DATE_OF_DEATH]) as DateOfDeath,
[PRS_EMAIL] as EmailAddress,
[PRS_EMERGENCY_CONTACT_NAME] as EmergencyContactName,
[PRS_EMERGENCY_CONTACT_NUMBER] as EmergencyContactNumber,
[PRS_ETHNIC_ORIGIN] as Ethnicity,
[PRS_FORENAME] as Forename ,
[GeographyGridGB1E] as Geographygridgb1E,
[GeographyGridGB1N] as Geographygridgb1N,
Convert(date,[PRS_IMM_SUSPENSE_DATE]) as ImmunisationSuspenseDate,
[LocalAuthorityResidenceName] as LocalAuthorityResidenceName,
[LocalAuthorityResidenceONSCode] as LocalAuthorityResidenceONSCode,
[LocalHealthBoardResidenceName] as LocalealthboardResidenceName,
[LocalHealthBoardResidenceCode] as LocalHealthBoardResidenceCode,
[LocalHealthBoardResidenceONSCode] as LocalHealthBoardResidenceONSCode,
case when [PRS_IDENTIFIER] is null then [PRS_NHS_NUMBER] + '-'+ isnull([PRS_OCC_STAFF_IDENTIFIER],[PRS_DATE_OF_BIRTH]) else [PRS_IDENTIFIER] end as PersonIdentifier ,
[LowerSuperOutputAreaCode] as LowerSuperOutputAreaCode,
[MiddleSuperOutputAreaCode] as MiddleSuperOutPutAreaCode,
[PRS_MOBILE] as MobilePhoneNumber,
[PRS_NHS_NUMBER] as NHSNumber,
[PRS_OCC_FRONTLINE_INDICATOR] as OccupationalFrontlineIndicator,
[PRS_OCC_JOB_ROLE_CATEGORY] as OccupationalJobRoleCategory,
[PRS_OCC_LOCATION_OF_WORK] as OccupationalLocationOfWork,
[PRS_OCC_ORGANISATION_NAME] as OccupationalOrganisationName,
Cast([PRS_OCC_SECTOR] as int) as OccupationalSector,
[PRS_OCC_STAFF_IDENTIFIER] as OccupationalStaffIdentifier,
cast([OPT_TYPE_CODE]as int) as OPTTypeCode,
[OPT_VACCINE] as OPTVaccine,
Convert(date, [OPT_VACCINE_DATE]) as OPTVaccineDate,
[PRS_SEX] as PatientSex, [PostcodeFormatted] as Postcode,
[PRS_PRACTICE_CODE] as PracticeCode,
[PRS_PREFERRED_CONTACT_METHOD] as PreferredContactMethod,
[PRS_PREFERRED_LANGUAGE] as PreferredLanguage,
[PRS_PRIORITY_GROUP] as PriorityGroup,
[PRS_SURNAME] as Surname,
[PRS_TELEPHONE] as TelephoneNumber,
[UpperSuperOutputAreaCode] as UpperSuperOutPutAreaCode,
[VACC_ADVERSE_REACTION] as VaccinationAdverseReaction,
[VACC_ADVERSE_REACTION_NOTE] as VaccinationAdverseReactionNote,
[VACC_ADVERSE_REACTION_TYPE] as VaccinationAdverseReactionType,
[VACC_COURSE_ID] as VaccinationCourseId,
convert(date,[VACC_DATE_OF_VACCINE]) as VaccinationDate,
[VACC_DATE_OF_VACCINE] as VaccinationDateOfVaccine,
NULL as VaccinationDateTime, --cast([VACC_DATE_OF_VACCINE] as datetime) + cast( VACC_TIME_OF_VACCINE as datetime) as VaccinationDateTime,
[VACC_DILUTANT_BATCH_NUMBER] as VaccinationDilutantBatchNumber,
[VACC_DILUTANT_MANUFACTURER] as VaccinationDilutantManufacturer,
[VACC_EXPIRY_DATE] as VaccinationExpiry,
convert(date,[VACC_EXPIRY_DATE]) as VaccinationExpiryDate,
NULL AS  VaccinationExpiryDateTime, --cast([VACC_EXPIRY_DATE] as datetime) + cast([VACC_EXPIRY_TIME] as datetime) as VaccinationExpiryDateTime,
convert(time,[VACC_EXPIRY_TIME]) as VaccinationExpiryTime,
[VACC_LOCATION_CODE] as VaccinationLocationCode,
[VACC_ROUTE_OF_ADMINISTRATION] as VaccinationRouteOfAdministration,
[VACC_SITE_OF_ADMINISTRATION] as VaccinationSiteOfAdministration,
[VACC_TIME_ALTERED] as VaccinationTimeAltered,
[VACC_TIME_OF_VACCINE] as VaccinationTimeOfVaccine,
[VACC_VACCINE_BATCH_NUMBER] as VaccinationVaccinationBatchNumber,
[VACC_VACCINE_NAME] as VaccinationVaccineName,
[VCR_VACCINATOR_ID] as VaccinatorVaccinatorId,
[VCR_VACCINATOR_NAME] as VaccinatorVaccinatorName,
[WIMDDecile] as Wimddecile,
(((((((ISNULL(CONVERT([varchar],[PRS_NHS_NUMBER]),CONVERT([varchar], [PRS_DATE_OF_BIRTH]))+'|')
+ CONVERT([varchar],convert(date,[APPT_APPOINTMENT_DATE])))+'|')+ISNULL(CONVERT([varchar],[VACC_TIME_OF_VACCINE]),'NULL'))+'|')
+ CONVERT([varchar],[APPT_OUTCOME]))+'|VAC') as AppointmentID,
ROW_NUMBER() over (Partition by ISNULL([PRS_NHS_NUMBER],[PRS_DATE_OF_BIRTH]) order by [APPT_APPOINTMENT_DATE] asc,[VACC_TIME_OF_VACCINE] asc ) AS AppointmentNumber,
[VaccinationLocationName] as VaccinationLocationName,
NULL as PriorityGroupDescription, --[PriorityGroupDescription] as PriorityGroupDescription,
s.Name as SubmittingOrganisation,
convert(date,GETDATE()) as LastUpdated,
PossibleDuplicateSameDay,
PossibleDuplicateWithin21Days,
PossibleSecondDoseFlag,
NULL as ImportDateTime, --CAST(ImportDateTime as datetime) as ImportDateTime,
NULL as UpdateDateTime,--CAST(UpdateDateTime as datetime) as UpdateDateTime,
NULL as StagedFromCIS,
NULL as CisIDOrigin,
EpisodeID,
EpisodeNumber,
NULL as CisDerivedPriorityGroup,
NULL as AgeCategorisedPriorityGroup,
NULL as Status,
NULL as WisChangedToCorrectAgeCategorisedGroup,
EVENT_ID,
'BCU' as Area,
'NDR' as Source,
CASE WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [PRS_DATE_OF_BIRTH], CAST(GETDATE() as date)) / 365.25) between 18 and 29 THEN 'P10c'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [PRS_DATE_OF_BIRTH], CAST(GETDATE() as date)) / 365.25) between 30 and 39 THEN 'P10b'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [PRS_DATE_OF_BIRTH], CAST(GETDATE() as date)) / 365.25) >= 40 THEN 'P10a'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [PRS_DATE_OF_BIRTH], CAST(GETDATE() as date)) / 365.25) between 16 and 17 THEN 'P10d'
WHEN [PRS_PRIORITY_GROUP] = 'P10' AND FLOOR(DATEDIFF(DAY, [PRS_DATE_OF_BIRTH], CAST(GETDATE() as date)) / 365.25) between 12 and 15 THEN 'P10e'
ELSE [PRS_PRIORITY_GROUP] END as PriorityGroupDerived,
convert(date,[VACC_DATE_ENTERED]) as DateVaccinationEntered,
VaccinatingLHB,
[ELIG_PREGNANT] AS PregnancyFlag,
[DOSE_SEQUENCE] AS DoseSequence,
[STANDARD_PATHWAY] as StandardPathway,
[VACCINATION_PROCEDURE_TERM] as VaccinationProcedure,
[VACCINE_PRODUCT_CODE] as VaccineProductCode,
[VACCINE_PRODUCT_TERM] as VaccineProductDesc


FROM [7A1A1SRVINFONDR].[Covid_Vaccination].[dbo].[WIS_OutcomeData] w
LEFT JOIN SSIS_Loading.Covid.dbo.Covid_Ref_SubmittingOrganisation s on s.Code = w.[PRS_OCC_ORGANISATION_NAME]
--WHERE Convert(date, [AppointmentDateFormatted]) >= DATEADD(DD, -29, CAST(GETDATE() as date))
WHERE (PRS_SURNAME not in ('NWISTESTCROSSSEC','NWISJONESTEST') AND PRS_SURNAME NOT LIKE '%NWISTEST%')
AND
(VaccinatingLHB = '7A1'
OR
(
(VaccinatingLHB <> '7A1' or VaccinatingLHB IS NULL)
AND
(
PRS_PRACTICE_CODE LIKE 'W91%'
OR
PRS_PRACTICE_CODE LIKE 'W94%'
OR
PRS_PRACTICE_CODE IN
('W00007','W00065','W00076','W00095')
)
))
), cte2
as
(
select
* from cte
)
select * from cte2
--where RowNum=1
END
GO
