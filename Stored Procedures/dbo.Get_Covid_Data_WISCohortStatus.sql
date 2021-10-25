SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Covid_Data_WISCohortStatus] AS BEGIN

with v1 as 
(
SELECT v.NHSNumber, v.VaccinationDate, v.VaccinationLocationName, v.VaccinationVaccineName, 'Vaccinated - Dose 1' as Status, v.VaccinationLocationCode,
ROW_NUMBER() OVER (PARTITION BY v.NHSNumber ORDER BY v.VaccinationDate) as rn
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1 
--and v.PossibleDuplicateWithin19Days is null
--and v.PossibleDuplicateSameDay is null
--and v.PossibleSecondDoseFlag is null
and v.AppointmentOutcome = '4'
and v.VaccinationVaccineName <> 'COVID-19 (NOVAVAX)'
)

,b1 as
(
SELECT b.NHSNumber, b.AppointmentDate, b.VaccinationLocationName, NULL as VaccinationVaccineName, 'Booked - Dose 1' as Status, b.VaccinationLocationCode,
ROW_NUMBER() OVER (PARTITION BY b.NHSNumber ORDER BY b.AppointmentDate) as rn
FROM [Foundation].[dbo].[Covid_Data_WISBooking] b
WHERE DoseNumber = 'First'
and AppointmentDate > b.LoadDate
)

,d1 as(
SELECT * FROM v1 where rn = 1
UNION ALL
SELECT * FROM b1 where rn = 1
and NHSNumber not in (select NHSNumber from v1 where rn = 1) 
)

--Dose 2

--, v2 as 
--(SELECT v.NHSNumber, v.AppointmentDate, v.VaccinationLocationName, v.VaccinationVaccineName, 'Vaccinated - Dose 2' as Status, v.VaccinationLocationCode,
--ROW_NUMBER() OVER (PARTITION BY v.NHSNumber ORDER BY v.AppointmentDate) as rn
--FROM Foundation.dbo.Covid_Data_WISVaccination v
--WHERE 1=1 
----and v.PossibleDuplicateWithin19Days is null
----and v.PossibleDuplicateSameDay is null
--and v.PossibleSecondDoseFlag is not null
--and v.AppointmentOutcome = '4'
--)

,b2 as
(
SELECT b.NHSNumber, b.AppointmentDate, NULL AS VaccinationLocationName, NULL as VaccinationVaccineName, 'Booked - Dose 2' as Status, b.VaccinationLocationCode,
ROW_NUMBER() OVER (PARTITION BY b.NHSNumber ORDER BY b.AppointmentDate) as rn
FROM [Foundation].[dbo].[Covid_Data_WISBooking] b
WHERE DoseNumber = 'Second'
and AppointmentDate > b.LoadDate
)

,d2 as(
SELECT * FROM v1 where rn = 2
UNION ALL
SELECT * FROM b2 where rn = 1
and NHSNumber not in (select NHSNumber from v1 where rn = 2) 
)

,n1 as 
(
SELECT v.NHSNumber, COUNT(*) as TrialDosesGiven
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1 
--and v.PossibleDuplicateWithin19Days is null
--and v.PossibleDuplicateSameDay is null
--and v.PossibleSecondDoseFlag is null
and v.AppointmentOutcome = '4'
and v.VaccinationVaccineName = 'COVID-19 (NOVAVAX)'
GROUP BY v.NHSNumber
)

SELECT 
	c.NHSNumber,
	c.GPPractice,
	c.DateOfDeath,
	c.DeceasedFlag,
	c.PriorityGroup,
	c.PriorityGroupDerived,
	c.DateOfBirth,
	c.Gender,
	c.Ethnicity,
	c.ImmunisationLocation,
	c.UnpaidCarer,
	c.StaffFrontlineIndicator,
	c.StaffIdentifier,
	c.StaffJobRoleCategory,
	c.StaffOrganisationName,
	c.StaffWorkLocation,
	c.StaffWorkSector,
	REPLACE(c.Postcode,' ','') as Postcode,

    CASE WHEN c.OPTVaccine = 'N' 
			and d2.VaccinationVaccineName is null THEN 'Yes'  
			ELSE 'No' END AS OptOut,
    CASE WHEN not (c.OPTVaccine = 'N' and d2.VaccinationVaccineName is null)
			--and d2.VaccinationVaccineName is null
			and c.ImmunisationSuspenseDate >= c.LoadDate THEN 'Yes'  
			ELSE 'No' END AS Suspended, 
    c.ImmunisationSuspenseDate, 

    d1.VaccinationDate as Dose1_AppointmentDate,
    d1.VaccinationLocationName as Dose1_VaccinationLocationName,
    d1.VaccinationVaccineName as Dose1_VaccinationVaccineName,
    d2.VaccinationDate as Dose2_AppointmentDate,
    d2.VaccinationLocationName as Dose2_VaccinationLocationName,
    d2.VaccinationVaccineName as Dose2_VaccinationVaccineName,

    CASE WHEN c.OPTVaccine = 'N' 
			and d2.VaccinationVaccineName is null THEN 'Opt Out'
		WHEN c.ImmunisationSuspenseDate >= LoadDate 
			--and d2.VaccinationVaccineName is null
			THEN 'Suspended'
        WHEN d2.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 2' 
        WHEN d2.Status = 'Booked - Dose 2' THEN 'Booked - Dose 2'
        WHEN d1.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 1' 
		WHEN d1.Status = 'Booked - Dose 1' THEN 'Booked - Dose 1'
            ELSE 'Unbooked' END as Status,

	CASE WHEN d1.VaccinationVaccineName is not null THEN 1
			ELSE 0 END as Dose1Vaccinated, 
	CASE WHEN d2.VaccinationVaccineName is not null  THEN 1
			ELSE 0 END as Dose2Vaccinated, 
	CASE WHEN d1.Status = 'Booked - Dose 1' THEN 1
			ELSE 0 END as Dose1Booked, 
	CASE WHEN d2.Status = 'Booked - Dose 2' THEN 1
			ELSE 0 END as Dose2Booked,
    C.Age,
	d1.VaccinationLocationCode as Dose1_VaccinationLocationCode,
	d2.VaccinationLocationCode as Dose2_VaccinationLocationCode,
	CASE WHEN c.OPTVaccine = 'N' 
			and d2.VaccinationVaccineName is null THEN 1 
			ELSE 0 END AS OptOutCount,
	CASE WHEN not (c.OPTVaccine = 'N' and d2.VaccinationVaccineName is null)
			--and d2.VaccinationVaccineName is null
			and c.ImmunisationSuspenseDate >= LoadDate THEN 1 
			ELSE 0 END AS SuspendedCount,

   CASE WHEN(CASE WHEN c.OPTVaccine = 'N' 
			and d2.VaccinationVaccineName is null THEN 'Opt Out'
		WHEN c.ImmunisationSuspenseDate >= LoadDate 
			--and d2.VaccinationVaccineName is null
			THEN 'Suspended'
        WHEN d2.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 2' 
        WHEN d2.Status = 'Booked - Dose 2' THEN 'Booked - Dose 2'
        WHEN d1.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 1' 
		WHEN d1.Status = 'Booked - Dose 1' THEN 'Booked - Dose 1'
            ELSE 'Unbooked' END) = 'Unbooked' THEN 1 ELSE 0 END  as Dose1Unbooked,

   CASE WHEN(CASE WHEN c.OPTVaccine = 'N' 
			and d2.VaccinationVaccineName is null THEN 'Opt Out'
		WHEN c.ImmunisationSuspenseDate >= LoadDate 
			--and d2.VaccinationVaccineName is null
			THEN 'Suspended'
        WHEN d2.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 2' 
        WHEN d2.Status = 'Booked - Dose 2' THEN 'Booked - Dose 2'
        WHEN d1.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 1' 
		WHEN d1.Status = 'Booked - Dose 1' THEN 'Booked - Dose 1'
            ELSE 'Unbooked' END) = 'Vaccinated - Dose 1' THEN 1 ELSE 0 END as Dose2Unbooked,
		n1.TrialDosesGiven,
	  'NDR' as [Source],
	  'BCU' as Area

   
FROM Foundation.dbo.Covid_Data_WISCohort c
LEFT JOIN d1 on c.NHSNumber = d1.NHSNumber
LEFT JOIN d2 on c.NHSNumber = d2.NHSNumber
LEFT JOIN n1 on c.NHSNumber = n1.NHSNumber

WHERE 1=1
--and DeceasedFlag = 0
and RecordDeletedFromWIS is NULL
and NOT (PriorityGroupDerived = 'P10' and Age < 18
         and 
		 CASE WHEN c.OPTVaccine = 'N' 
				and d2.VaccinationVaccineName is null THEN 'Opt Out'
			WHEN c.ImmunisationSuspenseDate >= LoadDate 
			--and d2.VaccinationVaccineName is null
				THEN 'Suspended'
			WHEN d2.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 2' 
			WHEN d2.Status = 'Booked - Dose 2' THEN 'Booked - Dose 2'
			WHEN d1.VaccinationVaccineName is not null THEN 'Vaccinated - Dose 1' 
			WHEN d1.Status = 'Booked - Dose 1' THEN 'Booked - Dose 1'
				ELSE 'Unbooked' END = 'Unbooked')

END
GO
