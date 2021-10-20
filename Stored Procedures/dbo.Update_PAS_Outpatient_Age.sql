SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Update_PAS_Outpatient_Age]
as 
begin


DECLARE @Results AS TABLE(
	AgeSKey int
	,PatientSKey int
	,SourceSKey int
	,DateSKey int
)

INSERT INTO @Results (AgeSKey,PatientSKey,SourceSKey,DateSKey)
(
select 


a.AgeSKey 
,p.PatientSKey
,s.SourceSKey
,d.DateSKey

from 
Foundation.dbo.PAS_Data_Outpatient o
join [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Patient p
on p.Source = o.source
and p.LocalPatientIdentifier = o.localPatientIdentifier
and o.appointmentdate between p.StartDate and ISNULL(p.EndDate,getdate())
join [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Age a
on a.Age = CAST(DATEDIFF(day,p.dateofbirth,o.appointmentdate)/365.25 as INT)
join [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Source s
on s.NAME = o.Source
join [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Date d
on d.date = o.AppointmentDate 


where o.AppointmentDate >= '01 Jan 2015'

)

Update [BCUINFO\BCUDATAWAREHOUSE].FACT.dbo.PAS_Outpatient
set AgeSKey = R.AgeSKey
from @Results r
inner join [BCUINFO\BCUDATAWAREHOUSE].FACT.dbo.PAS_Outpatient o
on o.SourceSKey = R.SourceSKey 
and o.PatientSKey = r.PatientSKey 
and o.TreatmentDateSKey = r.DateSKey 

END
GO
