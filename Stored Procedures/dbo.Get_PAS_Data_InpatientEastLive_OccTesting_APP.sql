SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientEastLive_OccTesting_APP]
	@TableName varchar(50)
AS
BEGIN
	
SET NOCOUNT ON;

DECLARE @SQL AS VARCHAR(MAX)
SET @SQL='INSERT INTO '+@TableName+'
SELECT
	''East'' AS Area,
	''WPAS'' AS Source,
	CASENO AS LocalPatientIdentifer,
	NHS AS NHSNumber,
	RTRIM(SURNAME)+'', ''+FORENAME AS PatientName,
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
SELECT * FROM OPENQUERY(WPAS_East_Secondary,
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
        (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and reason not like ''''%MFD%'''' and reason not like ''''%mfd%''''  order by 1 desc)  AS PDD,
       (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and reason not like ''''%MFD%'''' and reason not like ''''%mfd%''''order by 1 asc) as OPDD, 
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
   (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and (reason  like ''''%MFD%'''' or reason  like ''''%mfd%'''')order by 1 asc) as MFD,
MASTER_TRT.LINKID AS LinkID,
RTRIM(MASTER_TRT.REAL_MANAGEMENT) AS PatientClassification
from 
	MASTER_TRT 
	LEFT join PATIENT on MASTER_TRT.CASENO = PATIENT.CASENO 
	LEFT join PADLOC on MASTER_TRT.CLOC = PADLOC.LOCCODE
	LEFT join GP2 on MASTER_TRT.CCONS = GP2.PRACTICE
where 
	MASTER_TRT.TRT_TYPE IN (''''AC'''',''''AL'''',''''AE'''')
'')
)IPAdmissions'


EXEC(@SQL)
END

GO
