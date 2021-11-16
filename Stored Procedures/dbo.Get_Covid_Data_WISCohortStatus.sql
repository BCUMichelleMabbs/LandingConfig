SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Covid_Data_WISCohortStatus] AS BEGIN

-- Dose 1

with v1 as
(
SELECT v.NHSNumber, v.VaccinationDate, v.VaccinationLocationName, v.VaccinationVaccineName, 'Vaccinated - Dose 1' as Status, v.VaccinationLocationCode, DoseSequence,PriorityGroup,
ROW_NUMBER() OVER (PARTITION BY v.NHSNumber ORDER BY v.AppointmentDate) as rn
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1
and v.AppointmentOutcome = '4'
and DoseSequence = '1'
)

,b1 as
(
SELECT b.NHSNumber, b.AppointmentDate, b.VaccinationLocationName, NULL as VaccinationVaccineName, 'Future Booked' as Status, b.VaccinationLocationCode, NULL as DoseSequence,PriorityGroup,
ROW_NUMBER() OVER (PARTITION BY b.NHSNumber ORDER BY b.AppointmentDate) as rn
FROM [Foundation].[dbo].[Covid_Data_WISBooking] b
WHERE 1=1 
and AppointmentDate > b.LoadDate
)

,d1 as(
SELECT * FROM v1 where rn = 1
UNION ALL
SELECT * FROM b1 where rn = 1
and NHSNumber not in (select NHSNumber from v1 where rn = 1) -- First dose not yet given
)

--Dose 2
, v2 as
(SELECT v.NHSNumber, v.VaccinationDate, v.VaccinationLocationName, v.VaccinationVaccineName, 'Vaccinated - Dose 2' as Status, v.VaccinationLocationCode, DoseSequence,PriorityGroup,
ROW_NUMBER() OVER (PARTITION BY v.NHSNumber ORDER BY v.AppointmentDate) as rn
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1
and v.AppointmentOutcome = '4'
and DoseSequence = '2'
)


,d2 as(
SELECT * FROM v2 where rn = 1
UNION ALL
SELECT * FROM b1 where rn = 1
and NHSNumber not in (select NHSNumber from v2 where rn = 1) -- Second dose not yet given
and NHSNumber in (select NHSNumber from v1 where rn = 1)      -- First dose given
)

-- Dose 3
,v3 as
(SELECT v.NHSNumber, v.VaccinationDate, v.VaccinationLocationName, v.VaccinationVaccineName, 'Vaccinated - Dose 3' as Status, v.VaccinationLocationCode, '3' as DoseSequence, PriorityGroup,
ROW_NUMBER() OVER (PARTITION BY v.NHSNumber ORDER BY v.AppointmentDate) as rn
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1
and v.AppointmentOutcome = '4'
and DoseSequence in ('3')
and PriorityGroup in ('P0.1','P0.2')
AND AppointmentDate >= '16 September 2021'
)

, vb as
(SELECT v.NHSNumber, v.VaccinationDate, v.VaccinationLocationName, v.VaccinationVaccineName, 'Vaccinated - Booster' as Status, v.VaccinationLocationCode, DoseSequence,PriorityGroup,
ROW_NUMBER() OVER (PARTITION BY v.NHSNumber ORDER BY v.AppointmentDate) as rn
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1
and v.AppointmentOutcome = '4'
and (DoseSequence = 'B1' or (DoseSequence = '3' and PriorityGroup not in ('P0.1','P0.2')))
AND AppointmentDate >= '16 September 2021'
)

,d3 as(
SELECT * FROM v3 where rn = 1 
UNION ALL
SELECT * FROM b1 where rn = 1
and PriorityGroup in ('P0.1','P0.2')
and NHSNumber not in (select NHSNumber from v3 where rn = 1) -- Third dose not yet given
and NHSNumber in (select NHSNumber from v2 where rn = 1) -- First dose given
and NHSNumber in (select NHSNumber from v1 where rn = 1) -- Second dose given
)

,db as(
SELECT * FROM vb where rn = 1
UNION ALL
SELECT * FROM b1 where rn = 1
and PriorityGroup not in ('P0.1','P0.2')
and NHSNumber not in (select NHSNumber from vb where rn = 1) -- Third dose not yet given
and NHSNumber in (select NHSNumber from v2 where rn = 1) -- First dose given
and NHSNumber in (select NHSNumber from v1 where rn = 1)-- Second dose given
)

,n1 as
(
SELECT v.NHSNumber, COUNT(*) as TotalDoses
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1
and v.AppointmentOutcome = '4'
GROUP BY NHSNumber
)

,c1 as
(
SELECT v.NHSNumber,AppointmentDate
FROM Foundation.dbo.Covid_Data_WISVaccination v
WHERE 1=1
and v.AppointmentOutcome <> '4'
and AppointmentDate >= '16 September 2021'
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

NULL as Status,

CASE WHEN d1.VaccinationVaccineName is not null THEN 1 ELSE 0 END as Dose1Vaccinated,
CASE WHEN d2.VaccinationVaccineName is not null THEN 1 ELSE 0 END as Dose2Vaccinated,

CASE WHEN d1.VaccinationDate is not null and d1.VaccinationVaccineName is null THEN 1 ELSE 0 END as Dose1Booked,
CASE WHEN d2.VaccinationDate is not null and d2.VaccinationVaccineName is null THEN 1 ELSE 0 END as Dose2Booked,
C.Age,

d1.VaccinationLocationCode as Dose1_VaccinationLocationCode,
d2.VaccinationLocationCode as Dose2_VaccinationLocationCode,

CASE WHEN c.OPTVaccine = 'N'
and d2.VaccinationVaccineName is null THEN 1
ELSE 0 END AS OptOutCount,
CASE WHEN not (c.OPTVaccine = 'N' and d2.VaccinationVaccineName is null)
and c.ImmunisationSuspenseDate >= LoadDate THEN 1
ELSE 0 END AS SuspendedCount,


CASE WHEN d1.VaccinationDate is null 
       and (ImmunisationSuspenseDate is null or ImmunisationSuspenseDate < LoadDate)
       and OPTVaccine is null 
       THEN 1 ELSE 0 END  as Dose1Unbooked,


CASE WHEN d2.VaccinationDate is null 
       and d1.VaccinationVaccineName is not null 
       and (ImmunisationSuspenseDate is null or ImmunisationSuspenseDate < LoadDate)
       and OPTVaccine is null 
       THEN 1 ELSE 0 END  as Dose2Unbooked,

NULL as TrialDosesGiven,

'NDR' as [Source],
'BCU' as Area,

CASE WHEN d2.VaccinationVaccineName is not null THEN DATEADD(DD,183,d2.VaccinationDate)
       ELSE NULL END AS BoosterEligibleDate,

d3.VaccinationDate as Dose3_AppointmentDate,
d3.VaccinationLocationName as Dose3_VaccinationLocationName,
d3.VaccinationVaccineName as Dose3_VaccinationVaccineName,
CASE WHEN d3.VaccinationVaccineName is not null THEN 1 ELSE 0 END as Dose3Vaccinated,
CASE WHEN d3.VaccinationDate is not null and d3.VaccinationVaccineName is null THEN 1 ELSE 0 END as Dose3Booked,

db.VaccinationDate as Booster_AppointmentDate,
db.VaccinationLocationName as Booster_VaccinationLocationName,
db.VaccinationVaccineName as Booster_VaccinationVaccineName,
CASE WHEN db.VaccinationVaccineName is not null THEN 1 ELSE 0 END as BoosterVaccinated,
CASE WHEN db.VaccinationDate is not null and db.VaccinationVaccineName is null THEN 1 ELSE 0 END AS BoosterBooked,

case when (n1.TotalDoses - CASE WHEN d1.VaccinationVaccineName is not null THEN 1 ELSE 0 END -
CASE WHEN d2.VaccinationVaccineName is not null THEN 1 ELSE 0 END -
CASE WHEN d3.VaccinationVaccineName is not null THEN 1 ELSE 0 END -
CASE WHEN db.VaccinationVaccineName is not null THEN 1 ELSE 0 END) is NULL then 0 else 
(n1.TotalDoses - CASE WHEN d1.VaccinationVaccineName is not null THEN 1 ELSE 0 END -
CASE WHEN d2.VaccinationVaccineName is not null THEN 1 ELSE 0 END -
CASE WHEN d3.VaccinationVaccineName is not null THEN 1 ELSE 0 END -
CASE WHEN db.VaccinationVaccineName is not null THEN 1 ELSE 0 END) END
as AdditionalDoses,
CASE WHEN db.VaccinationDate is null and c.PriorityGroup not in ('P0.1','P0.2') and d2.VaccinationVaccineName is not null 
and c.NHSNumber in (SELECT DISTINCT c1.NHSNumber FROM c1 WHERE c.NHSNumber = c1.NHSNumber and c1.AppointmentDate > d2.VaccinationDate) 
THEN 1 ELSE 0 END AS BoosterCancelled

FROM Foundation.dbo.Covid_Data_WISCohort c
LEFT JOIN d1 on c.NHSNumber = d1.NHSNumber
LEFT JOIN d2 on c.NHSNumber = d2.NHSNumber
LEFT JOIN d3 on c.NHSNumber = d3.NHSNumber
LEFT JOIN n1 on c.NHSNumber = n1.NHSNumber
LEFT JOIN db on c.NHSNumber = db.NHSNumber and db.rn = 1

WHERE RecordDeletedFromWIS IS NULL
AND
(
ISNULL(c.PriorityGroup,'') <> 'P10'
OR
(
c.PriorityGroup = 'P10'
AND
DATEADD(YEAR,12,DateOfBirth) <= EOMONTH(GETDATE(),0)

)
)


END
GO
