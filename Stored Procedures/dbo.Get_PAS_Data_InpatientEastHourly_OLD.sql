SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientEastHourly_OLD]
	
AS
BEGIN
	
SET NOCOUNT ON;
SELECT
	'East' AS Area,
	'Myrddin' AS Source,
	CASENO AS LocalPatientIdentifier,
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
	RTRIM(FORENAME) AS Forename,
	LinkId,
	GETDATE() AS SnapshotDateTime,
		null as HospitalDischargedTo ,
	null as LocationOfPatient,
	null as TransferredTo,
	null as IsolationRequired,
	null as IsolationReasonPrevious	,
	null as DateIsolationIdentified,
	null as IsolationCurrent,
	null as IsolationReasonCurrent,
	null as IsolationRiskAssessmentPrevious,
	null as IsolationRiskAssessmentCurrent
FROM(
SELECT * FROM OPENQUERY(WPAS_EAST,
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
    (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 desc)  AS PDD,
    (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 asc) as OPDD, 
	'''' AS RetentionReason,
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
	'''' AS HomeLeave,
   (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) like ''%MFD%'' order by 1 asc) as MFD,
   MASTER_TRT.LINKID AS LinkId,
   RTRIM(MASTER_TRT.REAL_MANAGEMENT) AS PatientClassification
from 
	MASTER_TRT 
	LEFT join PATIENT on MASTER_TRT.CASENO = PATIENT.CASENO 
	LEFT join PADLOC on MASTER_TRT.CLOC = PADLOC.LOCCODE
	LEFT join GP2 on MASTER_TRT.CCONS = GP2.PRACTICE
where 
	MASTER_TRT.TRT_TYPE IN (''AC'',''AL'',''AE'')
')
)InpatientAdmissions	
	

END

GO
