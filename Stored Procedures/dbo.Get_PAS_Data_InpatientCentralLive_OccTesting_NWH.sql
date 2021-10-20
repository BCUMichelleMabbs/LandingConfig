SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientCentralLive_OccTesting_NWH]
	@TableName varchar(50)
AS
BEGIN
	
SET NOCOUNT ON;

--DECLARE @Results AS TABLE(
--[Area] [varchar](7) NULL,
--[Source] [varchar](7) NULL,
--[LocalPatientIdentifier] [varchar](30) NULL,
--[NHSNumber] [varchar](30) NULL,
--[PatientName] [varchar](100) NULL,
--[DateOfBirth] [date] NULL,
--[Sex] [varchar](10) NULL,
--[Postcode] [varchar](10) NULL,
--[RegisteredGP] [varchar](10) NULL,
--[RegisteredPractice] [varchar](10) NULL,
--[AdmissionDate] [date] NULL,
--[PDD] [date] NULL,
--[OPDD] [date] NULL,
--[RetentionReason] [varchar](20) NULL,
--[Ward] [varchar](10) NULL,
--[GMC] [varchar](10) NULL,
--[LocalConsultantCode] [varchar](10) NULL,
--[Specialty] [varchar](10) NULL,
--[SpellNumber] [varchar](10) NULL,
--[IntendedManagement] [varchar](10) NULL,
--[AdmissionMethod] [varchar](10) NULL,
--[HomeLeave] [varchar](10) NULL,
--[MFD] [date] NULL,
--[Site] [varchar](10) NULL,
--LinkId VARCHAR(50)
--)


DECLARE @SQL AS VARCHAR(MAX)
SET @SQL=
'INSERT INTO '+@TableName+'
SELECT
	''Central'' AS Area,
	''WPAS'' AS Source,
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
	PatientClassification AS PatientClassification,
	FORENAME AS Forename,
	LINKID as LinkID
	

FROM(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,
''
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
        (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''''%MFD%'''' order by 1 desc)  AS PDD,
       (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''''%MFD%''''order by 1 asc) as OPDD, 
	'''''''' AS RetentionReason,
	MASTER_TRT.CLOC ,
	GP2.GP_CODE ,
	MASTER_TRT.CCONS ,
	MASTER_TRT.CSPEC,
	PADLOC.BELONGS_TO,
	PADLOC.BASE_DESC,
	MASTER_TRT.ACTNOTEKEY,
	MASTER_TRT.TRT_INTENT,
	MASTER_TRT.ADMIT_METHOD,
	'''''''' AS HomeLeave,
   (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) like ''''%MFD%''''order by 1 asc) as MFD,
   LinkID,
   RTRIM(MASTER_TRT.REAL_MANAGEMENT) AS PatientClassification
from 
	MASTER_TRT 
	LEFT join PATIENT on MASTER_TRT.CASENO = PATIENT.CASENO 
	LEFT join PADLOC on MASTER_TRT.CLOC = PADLOC.LOCCODE
	LEFT join GP2 on MASTER_TRT.CCONS = GP2.PRACTICE
where 
	MASTER_TRT.TRT_TYPE IN (''''AC'''',''''AL'''',''''AE'''')
''
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
,''Current'' as Type
FROM [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] 

UNION

SELECT 
[Area]
,[PatientId]
,[AdmissionId]
,[PredictedDischargeDate]
,[MedicallyFitDate]
,[UpdateDateTime]
,''Historic'' as Type
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

update '+@TableName+' set PDD =

PredictedDischargeDate
from cte p 
inner join '+@TableName+' r
on  r.LocalPatientIdentifier = p.PatientID
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

update '+@TableName+' set MFDDate =

MedicallyFitDate
from cte p 
inner join '+@TableName+' r
on r.LocalPatientIdentifier = p.PatientID
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

update '+@TableName+' set OPDD =

PredictedDischargeDate
from cte p 
inner join '+@TableName+' r
on  r.LocalPatientIdentifier  = p.PatientID
and r.LinkID = p.AdmissionID 
'

EXEC (@SQL)


--SET @SQL='select 

--Area,
--Source,
--LocalPatientIdentifier,
--NHSNumber,
--PatientName,
--DateOfBirth,
--Sex,
--Postcode,
--RegisteredGP,
--RegisteredPractice,
--AdmissionDate,
--PDD,
--OPDD,
--RetentionReason,
--Ward,
--GMC,
--LocalConsultantCode,
--Specialty,
--SpellNumber,
--IntendedManagement,
--AdmissionMethod,
--HomeLeave,
--MFD,
--Site,
--LinkId

--from '+@TableName

--EXEC(@SQL)


	

END

GO
