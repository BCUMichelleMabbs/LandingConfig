SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_PAS_Ref_Clinic]
	AS
BEGIN
SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	ClinicCode varchar(30),
	ClinicName varchar(100),
	Source varchar(10),
	Location varchar(50),
	Specialty varchar(50),
	HCP varchar(30),
	AverageBooked int,
	MinorOutpatientProcedure varchar(1)
)

INSERT INTO @Results(ClinicCode,ClinicName,Source,Location,Specialty,HCP ,AverageBooked, MinorOutpatientProcedure)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	select distinct 
SessionKey as ClinicCode
,Name as ClinicName
,''WPAS'' as Source
,Location
,Specialty
,Clinician as HCP
,NULL as AverageBooked
,null as MinorOutpatientProcedure
from sessions
	')


INSERT INTO @Results(ClinicCode,ClinicName,Source,Location,Specialty,HCP,AverageBooked, MinorOutpatientProcedure )	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	select distinct 
SessionKey as ClinicCode
,Name as ClinicName
,''Myrddin'' as Source
,Location
,Specialty
,Clinician as HCP
,NULL as AverageBooked
,null as MinorOutpatientProcedure
from sessions
	')
/*
INSERT INTO @Results(ClinicCode,ClinicName,Source,Location,Specialty,HCP,AverageBooked)	
select distinct 
sps.code as ClinicCode
,CASE WHEN sps.code like 'C-%' then sps.code else sps.DESCRIPTION END as ClinicName
,'PiMS' as Source
,sp.NAME as [Location]
,spec.MAIN_IDENT as [Specialty]
,pro.MAIN_IDENT as [HCP]
,NULL as [AverageBooked]

from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].SERVICE_POINT_SESSIONS sps
join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].SERVICE_POINTs sp
on sp.SPONT_REFNO = sps.SPONT_REFNO 
join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].Specialties spec
on spec.SPECT_REFNO = sps.SPECT_REFNO 
join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].prof_Carers pro
on pro.PROCA_REFNO = sp.PROCA_REFNO 

where ISNULL(sps.archv_flag,'N') = 'N'
and sps.template_flag = 'Y'
*/
;with cte as (
	select distinct 
		sps.code as ClinicCode
		,CASE WHEN sps.code like 'C-%' then sps.code else sps.DESCRIPTION END as ClinicName
		,'PiMS' as Source
		,sp.NAME as [Location]
		,spec.MAIN_IDENT as [Specialty]
		,pro.MAIN_IDENT as [HCP]
		,NULL as [AverageBooked]
		,null as MinorOutpatientProcedure
		,Row_Number() over(Partition by sps.code order by sps.create_dttm desc) RN
	from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].SERVICE_POINT_SESSIONS sps
		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].SERVICE_POINTs sp
		on sp.SPONT_REFNO = sps.SPONT_REFNO 
		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].Specialties spec
		on spec.SPECT_REFNO = sps.SPECT_REFNO 
		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].prof_Carers pro
		on pro.PROCA_REFNO = sp.PROCA_REFNO 
	where ISNULL(sps.archv_flag,'N') = 'N'
		and sps.template_flag = 'Y'
) 
INSERT INTO @Results(ClinicCode,ClinicName,Source,Location,Specialty,HCP,AverageBooked, MinorOutpatientProcedure)	
select ClinicCode,ClinicName,Source,Location,Specialty,HCP,AverageBooked, MinorOutpatientProcedure 
from cte where RN = 1


	UPDATE @Results SET MinorOutpatientProcedure =
	case 
			when ClinicName like '%Haemophilia%' then 'N'
			when ClinicName like '%Mop Up%' then 'N'
			when ClinicName like '%MOPD%' then 'N'
			when ClinicName like '%MOP%' then 'Y'
			when ClinicName like '%MINOR OP%' then 'Y'
			when ClinicName like '%Minop%' then 'Y'
			when ClinicName like '%m/op%' then 'Y'
			when ClinicName like '%M/OP%' then 'Y'
	else 'N'
	end 
 

	
SELECT DISTINCT
LTRIM(RTRIM(ClinicCode)) as ClinicCode,
LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(ClinicName, CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) as ClinicName,
LTRIM(RTRIM(Source)) as Source,
LTRIM(RTRIM(Location)) as Location,
LTRIM(RTRIM(Specialty)) as Specialty,
LTRIM(RTRIM(HCP)) as HCP,
AverageBooked,
MinorOutpatientProcedure
FROM @Results
ORDER BY LTRIM(RTRIM(ClinicCode))
END
GO
