SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Update_PAS_NonContact_ActivityType]

@Load_GUID AS VARCHAR(38)
as
begin

--TEMPORARY WHILE MARTIN PARRY ADDS FUNCIONALITY TO FRAMEWORK--

Update [Foundation].[dbo].[PAS_Data_NonContact]
Set TraumaSubSpec = CASE WHEN RIGHT(AdmittingSpecialty,3) = '444' THEN 1 ELSE 0 END
WHERE Load_GUID = @Load_GUID


----Derive Nursing Activity Types-----


update a
set a.activitytype = 'Specialist Nurse'
from Foundation.dbo.PAS_Data_NonContact a
where a.activitytype = 'Nurse-Led'
and   a.StaffGrade = '04'
and   a.source = 'WPAS'
AND  Load_GUID=@Load_GUID
update a
set a.activitytype = 'Independent Nurse'
from Foundation.dbo.PAS_Data_NonContact a
where a.activitytype = 'Nurse-Led'
and   a.StaffGrade  = '03'
and   a.source = 'WPAS'
AND  Load_GUID=@Load_GUID


----Derive East Activity Types


update o
set o.activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.East_Spec_ActivityTypes a
inner join Foundation.dbo.PAS_Data_NonContact  o on a.specialty = LEFT(o.AdmittingSpecialty,3) 

WHERE
	Source = 'Myrddin' 
AND  Load_GUID=@Load_GUID

update o
set activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.East_SubSpec_ActivityTypes a
inner join Foundation.dbo.PAS_Data_NonContact  o on a.localsubspecialty = RIGHT(o.AdmittingSpecialty,3) 

where Source = 'Myrddin'
AND  Load_GUID=@Load_GUID
update o
set activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.East_CombinedSpec_ActivityTypes a 
inner join Foundation.dbo.PAS_Data_NonContact  o on a.combinedspecialty =o.AdmittingSpecialty

where Source = 'Myrddin'
AND  Load_GUID=@Load_GUID
update l
set activitytype = 'Nurse-Led' 
from Foundation.dbo.PAS_Data_NonContact l
where Left(l.AttendanceHCP,1) <> 'C'
and   l.AdmittingSpecialty in ('710200', '711000', '713000')
and  l.source = 'Myrddin'
AND  Load_GUID=@Load_GUID

-- Rev 1.2
update l
set activitytype = 'Pre-Op' 
from Foundation.dbo.PAS_Data_NonContact l
where l.AttendanceCategory in ('3', '03')
and   l.source in ('Myrddin','PIMS')
AND  Load_GUID=@Load_GUID
-- Rev 1.1
update l
set activitytype = 'Consultant' 
from Foundation.dbo.PAS_Data_NonContact l
where ((l.ActivityType is null) or (RTrim(l.ActivityType) = ''))
AND  Load_GUID=@Load_GUID


----Derive WPAS Activity Types


update l
set activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.WPAS_Spec_ActivityTypes a
inner join Foundation.dbo.PAS_Data_NonContact l on a.specialty = LEFT(l.AdmittingSpecialty,3)

where l.source = 'WPAS'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID
update l
set activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.WPAS_SubSpec_ActivityTypes a
inner join Foundation.dbo.PAS_Data_NonContact l on a.LocalSubspecialty = RIGHT(l.AdmittingSpecialty,3)
where l.source = 'WPAS'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID

update l
set activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.WPAS_CombinedSpec_ActivityTypes a 
inner join Foundation.dbo.PAS_Data_NonContact l on a.combinedspecialty = l.AdmittingSpecialty
where l.source = 'WPAS'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID
update l
set activitytype = 'OBD/NCO'
from  Foundation.dbo.PAS_Data_NonContact l
Where RTrim(l.TreatmentType) = 'ON'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID
update l
set activitytype = 'Consultant'
from  Foundation.dbo.PAS_Data_NonContact l
Where l.HCPCode like '[CD][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID
update l
set activitytype = 'Consultant'
from  Foundation.dbo.PAS_Data_NonContact l
Where l.HCPCode like '[D][D][ ][0-9][0-9][0-9][0-9][0-9]'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID

update l
set activitytype = 'Consultant'
from  Foundation.dbo.PAS_Data_NonContact l
Where l.HCPCode like '[D][D][0-9][0-9][0-9][0-9][0-9][0-9]'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'

AND  Load_GUID=@Load_GUID


update l
set activitytype = 'Consultant'
from  Foundation.dbo.PAS_Data_NonContact l

Where l.HCPCode like 'PL%'
and   l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID
update l
set activitytype = 'Non-Consultant'
from  Foundation.dbo.PAS_Data_NonContact l
Where l.ActivityType is null
and	l.AppointmentDate >= '01 April 2016'
AND  Load_GUID=@Load_GUID
-----Derive West Activity Types


update l
set activitytype = a.activitytype 
from [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.West_Spec_ActivityTypes a
inner join Foundation.dbo.PAS_Data_NonContact l

on LEFT(l.AdmittingSpecialty,3) = a.specialty

where  l.Source = 'PIMS'
AND  Load_GUID=@Load_GUID
-- Rev 1.1
update l
set activitytype = 'Pre-Op' 
from Foundation.dbo.PAS_Data_NonContact l
where l.Source = 'PIMS'
and   l.AttendanceCategory  in ('3', '03')
AND  Load_GUID=@Load_GUID
-- Rev 1.3/1.4
update l
set activitytype = 'Dexa Scan' 
from Foundation.dbo.PAS_Data_NonContact l
Inner Join [7a1a1srvinfodw1].Ardentia_Healthware_5_Reference.dbo.XOPA_Sess_West s on l.ActNoteKey  = s.attend_id
where l.source = 'PIMS'
and   s.clin_desc like '%DEXA%' 
AND  Load_GUID=@Load_GUID
END
GO
