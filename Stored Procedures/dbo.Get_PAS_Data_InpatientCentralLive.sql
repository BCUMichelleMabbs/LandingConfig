SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientCentralLive]
	
AS
BEGIN
	
SET NOCOUNT ON;

SELECT
	'Central' AS Area,
	'WPAS' AS Source,
	CASENO AS LocalPatientIdentifer,
	NHS AS NHSNumber,
	RTRIM(SURNAME) AS Surname,
	CAST(BIRTHDATE AS DATE) AS DateOfBirth,
	SEX AS Sex,
	POSTCODE AS Postcode,
	Registered_GP AS RegisteredGP,
	GP_Practice AS RegisteredPractice,
	TRT_DATE AS AdmissionDate,
	PDD AS PDD,
	OPDD AS OPDD,
	RetentionReason AS RetentionReason,
	CLOC AS Ward,
	GP_CODE AS GMC,
	CCONS AS LocalConsultantCode,
	CSPEC AS Specialty,
	ACTNOTEKEY AS SpellNumber,
	TRT_INTENT AS IntendedManagement,
	ADMIT_METHOD AS AdmissionMethod,
	HomeLeave AS HomeLeave,
	CAST(MFD AS DATE) AS MFDDate,
	NULL AS MFDTime,
	BELONGS_TO AS Site,
	PatientClassification,
	LinkID,
	RTRIM(FORENAME) AS Forename,
	CAST(STUFF(APPOINTMENT_TIME,3,0,':') AS TIME) as [AdmissionTime],
	AdmissionSource AS AdmissionSource

	into #Results


FROM(
SELECT * FROM OPENQUERY(WPAS_CENTRAL_NEWPORT,
'
Select 
	PATIENT.CASENO,
	PATIENT.NHS,
	PATIENT.FORENAME,
	PATIENT.SURNAME,
	PATIENT.BIRTHDATE,
	PATIENT.SEX,
	PATIENT.POSTCODE,
	PATIENT.Registered_GP,
	PATIENT.GP_Practice,
	MASTER_TRT.TRT_DATE,
	MASTER_TRT.APPOINTMENT_TIME,
        (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 desc)  AS PDD,
       (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%''order by 1 asc) as OPDD, 
	'''' AS RetentionReason,
	MASTER_TRT.CLOC ,
	GP2.GP_CODE ,
	MASTER_TRT.CCONS ,
	MASTER_TRT.CSPEC,
	PADLOC.BELONGS_TO,
	PADLOC.BASE_DESC,
	MASTER_TRT.ACTNOTEKEY,
	MASTER_TRT.TRT_INTENT,
	MASTER_TRT.ADMIT_METHOD,
	'''' AS HomeLeave,
   (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) like ''%MFD%''order by 1 asc) as MFD,
   MASTER_TRT.LINKID AS LinkId,
   RTRIM(MASTER_TRT.REAL_MANAGEMENT) AS PatientClassification,
   MASTER_TRT.SOURCE AS AdmissionSource
from 
	MASTER_TRT 
	LEFT join PATIENT on MASTER_TRT.CASENO = PATIENT.CASENO 
	LEFT join PADLOC on MASTER_TRT.CLOC = PADLOC.LOCCODE
	LEFT join GP2 on MASTER_TRT.CCONS = GP2.PRACTICE
where 
	MASTER_TRT.TRT_TYPE IN (''AC'',''AL'',''AE'')
'
)
)InpatientAdmissions

   		---PDD & MFD Import from STREAM. (Updated at End of Script) JH 30/08/2018------

DECLARE @PDD Table (

Area varchar(20)
,PatientID varchar(20)
,AdmissionID varchar(20)
,PredictedDischargeDate date
,MedicallyFitDate date
,UpdateDateTime datetime
,Type varchar(10)

)
INSERT into @PDD 

SELECT 
[Area]
,[PatientId]
,[AdmissionId]
,[PredictedDischargeDate]
,[MedicallyFitDate]
,[UpdateDateTime]
,'Current' as Type
FROM [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] 

UNION

SELECT 
[Area]
,[PatientId]
,[AdmissionId]
,[PredictedDischargeDate]
,[MedicallyFitDate]
,[UpdateDateTime]
,'Historic' as Type
FROM [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory]

	

----Update Script for PDD Entry------

;with cte (PatientID,AdmissionID,PredictedDischargeDate,UpdateDateTime,RowNum) 
as (
select * from (
select 

PatientID
,AdmissionID
,PredictedDischargeDate
,UpdateDateTime
,ROW_NUMBER() over(PARTITION by PatientID,AdmissionID order by UpdateDateTime desc) as rn
from @PDD 
) t

where t.rn = 1
) 

update #Results set PDD =

PredictedDischargeDate
from cte p 
inner join #Results r
on  r.LocalPatientIdentifer = p.PatientID
and r.LinkID = p.AdmissionID 


----Update Script for MFD Entry------

;with cte (PatientID,AdmissionID,MedicallyFitDate,UpdateDateTime,RowNum) 
as (
select * from (
select 

PatientID
,AdmissionID
,MedicallyFitDate
,UpdateDateTime
,ROW_NUMBER() over(PARTITION by PatientID,AdmissionID order by UpdateDateTime desc) as rn
from @PDD 
) t

where t.rn = 1
) 

update #Results set MFDDate =

MedicallyFitDate
from cte p 
inner join #Results r
on r.LocalPatientIdentifer = p.PatientID
and r.LinkID = p.AdmissionID 

----Update Script for OPDD Entry------

;with cte (PatientID,AdmissionID,PredictedDischargeDate,UpdateDateTime,RowNum) 
as (
select * from (
select 

PatientID
,AdmissionID
,PredictedDischargeDate
,UpdateDateTime
,ROW_NUMBER() over(PARTITION by PatientID,AdmissionID order by UpdateDateTime asc) as rn
from @PDD 
) t

where t.rn = 1
) 

update #Results set OPDD =

PredictedDischargeDate
from cte p 
inner join #Results r
on  r.LocalPatientIdentifer  = p.PatientID
and r.LinkID = p.AdmissionID 



select 

Area,
Source,
LocalPatientIdentifer,
NHSNumber,
Surname,
DateOfBirth,
Sex,
Postcode,
RegisteredGP,
RegisteredPractice,
AdmissionDate,
PDD,
OPDD,
RetentionReason,
Ward,
GMC,
LocalConsultantCode,
Specialty,
SpellNumber,
IntendedManagement,
AdmissionMethod,
HomeLeave,
MFDDate,
MFDTime,
Site,
PatientClassification,
Forename,
LinkID,
AdmissionTime,
AdmissionSource

from #Results 
drop table #Results 


	

END

GO
