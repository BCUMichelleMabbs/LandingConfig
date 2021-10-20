SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Update_PAS_Outpatient_SessionBookings]
as
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	SessionName		VARCHAR(20),
	SessionDate  date,
	SessionCount int
)

INSERT INTO @Results(SessionName,SessionDate,SessionCount)	
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	select 

 Opclinicno
 ,trt_Date
 ,count(*)

from treatmnt

where trt_Date > ''01 Jan 2010''
and trt_type like ''O%''
and opclinicno is not null 

group by  Opclinicno
 ,trt_Date

		
')


INSERT INTO @Results(SessionName,SessionDate,SessionCount)	
SELECT * FROM OPENQUERY(WPAS_EAST_Secondary,'
	select 

 Opclinicno
 ,trt_Date
 ,count(*)

from treatmnt

where trt_Date > ''01 Jan 2010''
and trt_type like ''O%''
and opclinicno is not null 

group by  Opclinicno
 ,trt_Date

		
')

INSERT INTO @Results(SessionName,SessionDate,SessionCount)	
select 

sps.code as SessionCode 
,CONVERT(Date,s.start_Dttm) as SessionDate
,count(*) as SessionCount


from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].dbo.SCHEDULES s
join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].dbo.service_point_Sessions sps
on sps.spssn_Refno = s.spssn_Refno

where s.start_Dttm > '2010-01-01'

group by sps.code
,CONVERT(Date,s.start_Dttm)



Update Foundation.dbo.PAS_Data_Outpatient
set SessionBookings = R.SessionCount 
from @Results r
inner join Foundation.dbo.PAS_Data_Outpatient o
on o.ClinicCode = r.SessionName 
and CONVERT(Date,o.AppointmentDate) = CONVERT(date,r.SessionDate) 


END

GO
