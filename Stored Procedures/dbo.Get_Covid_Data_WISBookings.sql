SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Covid_Data_WISBookings] AS BEGIN


with cte as
(
SELECT
      [PRS_ADDRESS1]	as	Address1,
      [PRS_ADDRESS2]	as	Address2,
      [PRS_ADDRESS3]	as	Address3,
      [PRS_ADDRESS4]	as	Address4,
      [PRS_ADDRESS5]	as	Address5,
      cast( [PRS_AGE] as int)	as	AgeAtVaccination,
      Convert(date, [AppointmentDateFormatted])	as	AppointmentDate,
	  Convert(time(0), AppointmentDateTimeFormatted)as AppointmentTime,
      [APPT_OUTCOME]	as	AppointmentOutcome,
      [PRS_CARE_HOME_RESIDENT]	as	CareHomeResident,
      Convert(date,[DateOfBirthFormatted])	as	DateOfBirth,
      Convert(date,[DateOfDeathFormatted])	as	DateOfDeath,
      [PRS_EMAIL]	as	EmailAddress,
      [PRS_EMERGENCY_CONTACT_NAME]	as	EmergencyContactName,
      [PRS_EMERGENCY_CONTACT_NUMBER]	as	EmergencyContactNumber,
      [PRS_ETHNIC_ORIGIN]	as	Ethnicity,
	  [EVENT_ID] as EventID,
      [PRS_FORENAME]	as	Forename ,
      [GeographyGridGB1E]	as	Geographygridgb1E,
      [GeographyGridGB1N]	as	Geographygridgb1N,
      Convert(date,[PRS_IMM_SUSPENSE_DATE])	as	ImmunisationSuspenseDate,
      [LocalAuthorityResidenceName]	as	LocalAuthorityResidenceName,
      [LocalAuthorityResidenceONSCode]	as	LocalAuthorityResidenceONSCode,
      [LocalHealthBoardResidenceName]	as	LocalealthboardResidenceName,
      [LocalHealthBoardResidenceCode]	as	LocalHealthBoardResidenceCode,
      [LocalHealthBoardResidenceONSCode]	as	LocalHealthBoardResidenceONSCode,
	    	case when   [PRS_IDENTIFIER] is null then [NHSNumberFormatted] + '-'+ isnull([PRS_OCC_STAFF_IDENTIFIER],[DateOfBirthFormatted]) else [PRS_IDENTIFIER] end	as	PersonIdentifier ,
      [LowerSuperOutputAreaCode]	as	LowerSuperOutputAreaCode,
      [MiddleSuperOutputAreaCode]	as	MiddleSuperOutPutAreaCode,
      [PRS_MOBILE]	as	MobilePhoneNumber,
      REPLACE(NHSNumberFormatted,' ','')	as	NHSNumber,
      [PRS_OCC_FRONTLINE_INDICATOR]	as	OccupationalFrontlineIndicator,
      [PRS_OCC_JOB_ROLE_CATEGORY]	as	OccupationalJobRoleCategory,
      [PRS_OCC_LOCATION_OF_WORK]	as	OccupationalLocationOfWork,
      [PRS_OCC_ORGANISATION_NAME]	as	OccupationalOrganisationName,
      Cast([PRS_OCC_SECTOR] as int)	as	OccupationalSector,
      [PRS_OCC_STAFF_IDENTIFIER] as	OccupationalStaffIdentifier,
     cast([OPT_TYPE_CODE]as int)	as	OPTTypeCode,
      [OPT_VACCINE]	as	OPTVaccine,
     Convert(date, [OPT_VACCINE_DATE])	as	OPTVaccineDate,
      [PRS_SEX]	as	PatientSex,
      [PostcodeFormatted]	as	Postcode,
      [PRS_PRACTICE_CODE]	as	PracticeCode,
      [PRS_PREFERRED_CONTACT_METHO]	as	PreferredContactMethod,
      [PRS_PREFERRED_LANGUAGE]	as	PreferredLanguage,
      [PRS_PRIORITY_GROUP]	as	PriorityGroup,
      [PRS_SURNAME]	as	Surname,
      [PRS_TELEPHONE]	as	TelephoneNumber,
      [UpperSuperOutputAreaCode]	as	UpperSuperOutPutAreaCode,   
      [VACC_COURSE_ID]	as	VaccinationCourseId,
      [LOCATION_CODE]	as	VaccinationLocationCode,
      [VACC_VACCINE_NAME]	as	VaccinationVaccineName,
      WIS_AREA as WisArea,
	  [WIMDDecile]	as	Wimddecile,
	  WIS_Identifier as WisIdentifier,
	  [WIS_PATIENT_AREA] as WisPatientArea,
	  [VaccinationLocationName] as VaccinationLocationName,
      [PriorityGroupDescription] as PriorityGroupDescription,
	  APPT_DATE_BOOKED as AppointmentDateBooked
  FROM  [7A1A1SRVINFONDR].[Covid_Vaccination].[dbo].[WIS_BookingData]

  ), cte2
  as
  (
SELECT distinct NHSNumberformatted
FROM  [7A1A1SRVINFONDR].[Covid_Vaccination].[dbo].WIS_VaccinationData 


where APPT_OUTCOME = '4'


  
  )


  select 
  c.Address1,
    Address2,
    Address3,
    Address4,
    Address5,
    AgeAtVaccination,
    AppointmentDate,
	AppointmentTime,
    AppointmentOutcome,
    CareHomeResident,
    DateOfBirth,
    DateOfDeath,
    EmailAddress,
    EmergencyContactName,
    EmergencyContactNumber,
    Ethnicity,
	EventID,
    Forename ,
    Geographygridgb1E,
    Geographygridgb1N,
    ImmunisationSuspenseDate,
    LocalAuthorityResidenceName,
    LocalAuthorityResidenceONSCode,
    LocalealthboardResidenceName,
    LocalHealthBoardResidenceCode,
    LocalHealthBoardResidenceONSCode,
	PersonIdentifier ,
    LowerSuperOutputAreaCode,
    MiddleSuperOutPutAreaCode,
    MobilePhoneNumber,
    NHSNumber,
    OccupationalFrontlineIndicator,
   	OccupationalJobRoleCategory,
    OccupationalLocationOfWork,
    OccupationalOrganisationName,
   	OccupationalSector,
    OccupationalStaffIdentifier,
  	OPTTypeCode,
    OPTVaccine,
    OPTVaccineDate,
    PatientSex,
    Postcode,
    PracticeCode,
    PreferredContactMethod,
    PreferredLanguage,
    PriorityGroup,
    Surname,
    TelephoneNumber,
    UpperSuperOutPutAreaCode,   
    VaccinationCourseId,
    VaccinationLocationCode,
	VaccinationVaccineName,
    WisArea,
	Wimddecile,
	WisIdentifier,
	WisPatientArea,
	VaccinationLocationName,
    PriorityGroupDescription
    ,CASE WHEN C2.NHSNumberformatted is null then 'First' else 'Second' END as DoseNumber
    ,'BCU' as Area,
    'NDR' as Source,
    CAST(AppointmentDateBooked as date) as DateAppointmentBooked,
	CAST(AppointmentDateBooked as time(0)) as TimeAppointmentBooked
  from cte c
  left join cte2 c2
  on c2.NHSNumberFormatted = c.NHSNumbeR





 -- select * from cte2 
  --where RowNum=1


END
GO
