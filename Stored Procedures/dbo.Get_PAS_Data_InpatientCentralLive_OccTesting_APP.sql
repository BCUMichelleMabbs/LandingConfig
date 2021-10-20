SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientCentralLive_OccTesting_APP]
	@TableName varchar(50)
AS
BEGIN
	
SET NOCOUNT ON;

DECLARE @SQL AS VARCHAR(MAX)
SET @SQL='INSERT INTO '+@TableName+'
SELECT
	''Central'' AS Area,
	''WPAS'' AS Source,
	CASENO AS LocalPatientIdentifer,
	NHS AS NHSNumber,
	RTRIM(SURNAME)+'' ''+FORENAME AS PatientName,
	CAST(BIRTHDATE AS DATE) AS PatientDateOfBirth,
	SEX AS Gender,
	POSTCODE AS Postcode,
	Registered_GP AS RegisteredGPCode,
	GP_Practice AS RegisteredPracticeCode,
	TRT_DATE AS AdmissionDate,
	PDD AS PredictedDischargeDate,
	OPDD AS OriginalPredictedDischargeDate,
	RetentionReason AS RetentionReason,
	CLOC AS WardCode,
	LOCDESC AS WardDescription,
	BELONGS_TO AS SiteCode,
	BASE_DESC AS SiteDescription,
	GP_CODE AS GMCCode,
	CCONS AS LocalConsultantCode,
	CSPEC AS SpecialtyCode,
	ACTNOTEKEY AS SpellNumber,
	TRT_INTENT AS IntendedManagement,
	ADMIT_METHOD AS AdmissionMethod,
	HomeLeave AS HomeLeave,
	MFD AS MFD,
	LINKID as LinkID,
	PatientClassification AS PatientClassification
FROM(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,
''
Select 
	PATIENT.CASENO AS CASENO,
	REPLACE(PATIENT.NHS,''''-'''','''''''') AS NHS,
	PATIENT.FORENAME,
	PATIENT.SURNAME,
	PATIENT.BIRTHDATE,
	PATIENT.SEX,
	PATIENT.POSTCODE,
	PATIENT.Registered_GP,
	PATIENT.GP_Practice,
	MASTER_TRT.TRT_DATE,
        (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and reason not like ''''%MFD%'''' order by 1 desc)  AS PDD,
       (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and reason not like ''''%MFD%''''order by 1 asc) as OPDD, 
	'''''''' AS RetentionReason,
	MASTER_TRT.CLOC ,
	PADLOC.LOCDESC ,
	GP2.GP_CODE ,
	MASTER_TRT.CCONS ,
	MASTER_TRT.CSPEC,
	PADLOC.BELONGS_TO,
		PADLOC.BASE_DESC,
	MASTER_TRT.ACTNOTEKEY,
	MASTER_TRT.TRT_INTENT,
	MASTER_TRT.ADMIT_METHOD,
	'''''''' AS HomeLeave,
   (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and reason like ''''%MFD%''''order by 1 asc) as MFD
   ,MASTER_TRT.LINKID,
   RTRIM(MASTER_TRT.REAL_MANAGEMENT) AS PatientClassification
from 
	MASTER_TRT 
	LEFT join PATIENT on MASTER_TRT.CASENO = PATIENT.CASENO 
	LEFT join PADLOC on MASTER_TRT.CLOC = PADLOC.LOCCODE
	LEFT join GP2 on MASTER_TRT.CCONS = GP2.PRACTICE
where 
	MASTER_TRT.TRT_TYPE IN (''''AC'''',''''AL'''',''''AE'''')
''
))IPAdmissions


	---PDD & MFD Import from STREAM. (Updated at End of Script) JH 30/08/2018------

DECLARE @PDD AS TABLE(

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

  ------------------------




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

update '+@TableName+' set PredictedDischargeDate =

p.PredictedDischargeDate
from cte p 
inner join '+@TableName+' r
on r.LinkID = p.AdmissionID 
and r.LocalPatientIdentifier = p.PatientID


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

update '+@TableName+' set MFD =

MedicallyFitDate
from cte p 
inner join '+@TableName+' r
on r.LinkID = p.AdmissionID 
and r.LocalPatientIdentifier = p.PatientID

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

update '+@TableName+' set OriginalPredictedDischargeDate =

p.PredictedDischargeDate
from cte p 
inner join '+@TableName+' r
on r.LinkID = p.AdmissionID 
and r.LocalPatientIdentifier = p.PatientID
'
EXEC(@SQL)
END

GO
