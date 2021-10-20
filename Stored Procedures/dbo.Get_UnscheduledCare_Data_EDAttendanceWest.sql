SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EDAttendanceWest]
	
AS
BEGIN
	
	SET NOCOUNT ON;



--EXEC [7A1AUSRVIPMSQLR\REPORTS].[iPMProduction].dbo.BCU_Info_Attendances

DECLARE @LastAttendanceDate AS DATE = (SELECT ISNULL(MAX(ArrivalDate),'31 December 2016') FROM [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] WHERE Area='West' AND SiteCodeOfTreatment!='7A1AU')
DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)--+' 23:59:59.995'
DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())--+' 23:59:59.995 '

EXEC('
USE [iPMProduction]

DECLARE	@cityp_natgp	numeric(10,0),@cityp_gmc	numeric(10,0),@cityp_dent	numeric(10,0),@hityp_natnl	numeric(10,0),@prtyp_gmprc  numeric(10,0)
SET @cityp_natgp = (	select	rfval_refno
	from	[iPMProduction].dbo.reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''NATGP''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @cityp_gmc = (	select	rfval_refno
	from	[iPMProduction].dbo.reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''GMC''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @cityp_dent = (	select	rfval_refno
	from	[iPMProduction].dbo.reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''NATDP''
		and	ISNULL(archv_flag,''N'') = ''N'' )


SET @hityp_natnl = (	select	rfval_refno
	from	[iPMProduction].dbo.reference_values
	where	rfvdm_code = ''HITYP''
	 	and	main_code = ''NATNL''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @prtyp_gmprc = ( select rfval_refno
                    from   reference_values
                    where  rfvdm_code = ''PRTYP''
                    and  main_code = ''GMPRC''
                    and  ISNULL(archv_flag,''N'') = ''N'' )


DECLARE @Diagnosis AS TABLE(
	RowNumber			INT,
	AttendanceId		NUMERIC(10,0),
	DiagnosisDate		DATE,
	DiagnosisTime		TIME,
	DiagnosisType		NUMERIC(10,0)
)
INSERT INTO @Diagnosis
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY A.AEATT_REFNO ORDER BY DP.CREATE_DTTM ASC) AS RowNumber,
	A.AEATT_REFNO AS AttendanceId,
	CAST(DP.CREATE_DTTM AS DATE) AS DiagnosisDate,
	CAST(DP.CREATE_DTTM AS TIME) AS DiagnosisTime,
	O.ODPCD_REFNO AS DiagnosisType
FROM
	AE_ATTENDANCES A
	JOIN DIAGNOSIS_PROCEDURES DP ON A.AEATT_REFNO=DP.SORCE_REFNO
	JOIN [dbo].[ODPCD_CODES] O ON DP.ODPCD_REFNO = O.ODPCD_REFNO 
	JOIN dbo.REFERENCE_VALUES RV ON RV.RFVAL_REFNO=DP.MPLEV_REFNO
WHERE
	DP.SORCE_CODE=''AEATT'' AND
	DP.CCSXT_CODE=''AEDIG'' AND
	DP.DPTYP_CODE=''DIAGN'' AND
	CAST(A.ARRIVED_DTTM AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(A.ARRIVED_DTTM AS DATE) < '''+@DateToString+''' AND
	ISNULL(A.ARCHV_FLAG,''N'')=''N'' AND
	ISNULL(DP.ARCHV_FLAG,''N'')=''N''
) AS Diagnosis
--THE DIAGNOSIS, SITES AND SIDES ARE A BIT MORE RANDOM THAN IN SYMPHONY AS, AS FAR AS I CAN TELL AT THE MOMENT, THEY DON''T MATCH TO EACH OTHER
--ALSO, MOST OF THE SITES ARE ''SECONDARY'' WITHOUT A ''PRIMARY'' SO WE CAN''T EVEN USE THAT
--SO INSTEAD OF KEEPING THE SITE AND AREAS IN THE DIAGNOSIS TABLE WE''LL HAVE TO CREATE TABLES FOR EACH OF THEM
--The ''Side'' is a bit sketchy as well as it''s included in the Site code, currently it''s just the right 2 characters of the code....
DECLARE @SiteAndSide AS TABLE(
	RowNumber			INT,
	AttendanceId		NUMERIC(10,0),
	DiagnosisSite		NUMERIC(10,0),
	DiagnosisSide		VARCHAR(2)
)
INSERT INTO @SiteAndSide
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY A.AEATT_REFNO ORDER BY DP.CREATE_DTTM ASC) AS RowNumber,
	A.AEATT_REFNO AS AttendanceId,
	O.ODPCD_REFNO AS DiagnosisSite,
	RIGHT(O.CODE,2) AS DiagnosisSide
FROM
	AE_ATTENDANCES A
	JOIN DIAGNOSIS_PROCEDURES DP ON A.AEATT_REFNO=DP.SORCE_REFNO
	JOIN [dbo].[ODPCD_CODES] O ON DP.ODPCD_REFNO = O.ODPCD_REFNO 
	JOIN dbo.REFERENCE_VALUES RV ON RV.RFVAL_REFNO=DP.MPLEV_REFNO
WHERE
	DP.SORCE_CODE=''AEATT'' AND
	DP.CCSXT_CODE=''AESIT'' AND
	DP.DPTYP_CODE=''DIAGN'' AND
	CAST(A.ARRIVED_DTTM AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(A.ARRIVED_DTTM AS DATE) < '''+@DateToString+''' AND
	ISNULL(A.ARCHV_FLAG,''N'')=''N'' AND
	ISNULL(DP.ARCHV_FLAG,''N'')=''N''
) AS SiteAndSide

DECLARE @Treatment AS TABLE(
	RowNumber			INT,
	AttendanceId		NUMERIC(10,0),
	TreatmentType		NUMERIC(10,0),
	TreatmentDate		DATE,
	TreatmentTime		TIME
)

INSERT INTO @Treatment
SELECT * FROM(
SELECT
	ROW_NUMBER() OVER (PARTITION BY A.AEATT_REFNO ORDER BY DP.CREATE_DTTM ASC) AS RowNumber,
	A.AEATT_REFNO AS AttendanceId,
	O.ODPCD_REFNO AS TreatmentType,
	CAST(DP.CREATE_DTTM AS DATE) AS TreatmentDate,
	CAST(DP.CREATE_DTTM AS TIME) AS TreatmentTime
FROM
	AE_ATTENDANCES A
	JOIN DIAGNOSIS_PROCEDURES DP ON A.AEATT_REFNO=DP.SORCE_REFNO
	JOIN [dbo].[ODPCD_CODES] O ON DP.ODPCD_REFNO = O.ODPCD_REFNO 
	JOIN dbo.REFERENCE_VALUES RV ON RV.RFVAL_REFNO=DP.MPLEV_REFNO
WHERE
	DP.SORCE_CODE=''AEATT'' AND
	DP.CCSXT_CODE=''AETRE'' AND
	CAST(A.ARRIVED_DTTM AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(A.ARRIVED_DTTM AS DATE) < '''+@DateToString+''' AND
	ISNULL(A.ARCHV_FLAG,''N'')=''N'' AND
	ISNULL(DP.ARCHV_FLAG,''N'')=''N''
) AS Treatment

DECLARE @Results AS TABLE(
	Area					CHAR(4),
	Source					CHAR(4),
	AttendanceIdentifier	NUMERIC(10,0),
	LocalPatientIdentifier	VARCHAR(20),
	NHSNumber				VARCHAR(20),
	RegisteredGP			VARCHAR(14),
	RegisteredPractice		VARCHAR(14),
	PatientPostcode			VARCHAR(10),
	DHA				VARCHAR(10),
	ReferringGP				VARCHAR(14),
	ReferringPractice		VARCHAR(14),
	IncidentDate			DATE,
	IncidentTime			TIME,
	ArrivalDate				DATE,
	ArrivalTime				TIME,
	AmbulanceHandoverDate	DATE,
	AmbulanceHandoverTime	TIME,
	RegisteredDate			DATE,
	RegisteredTime			TIME,
	TriageStartDate			DATE,
	TriageStartTime			TIME,
	TriageEndDate			DATE,
	TriageEndTime			TIME,
	EDClinicianSeenDate		DATE,
	EDClinicianSeenTime		TIME,
	TreatmentStartDate		DATE,
	TreatmentStartTime		TIME,
	TreatmentCompleteDate	DATE,
	TreatmentCompleteTime	TIME,
	DecisionToAdmitDate		DATE,
	DecisionToAdmitTime		TIME,
	--BreachEndDate			DATE,
	--BreachEndTime			TIME,
	DischargeDate			DATE,
	DischargeTime			TIME,
	DepartureDate			DATE,
	DepartureTime			TIME,
	--ConsultationRequestDate	DATE,
	--ConsultationRequestTime	TIME,
	--ConsultationReponseDate	DATE,
	--ConsultationResponseTime	TIME,
	TransportRequestedDate	DATE,
	TransportRequestedTime	TIME,
	TransportArrivedDate	DATE,
	TransportArrivedTime	TIME,
	BedRequestedDate		DATE,
	BedRequestedTime		TIME,
	BedRequestedOutcomeDate	DATE,
	BedRequestedOutcomeTime	TIME,
	AmbulanceReference		VARCHAR(255),
	SiteCodeOfTreatment		varchar(20),
	PresentingComplaint		VARCHAR(255),
	ReferralSource				NUMERIC(10,0),
	ArrivalMode				NUMERIC(10,0),
	PatientGroup			NUMERIC(10,0),
	AccompaniedBy1			INT,
	AccompaniedBy2			INT,
	IncidentLocation		NUMERIC(10,0),
	IncidentActivity		NUMERIC(10,0),
	TriageCategory			NUMERIC(10,0),
	TriageComplaint			NUMERIC(10,0),
	TriageTreatment			INT,
	TriageTreatment1		INT,
	TriageTreatment2		INT,
	TriageTreatment3		INT,
	TriageTreatment4		INT,
	TriageTreatment5		INT,
	TriageTreatment6		INT,
	TriageTreatment7		INT,
	TriageTreatment8		INT,
	TriageTreatment9		INT,
	TriageTreatment10		INT,
	TriageDiscriminator		NUMERIC(10,0),
	Immunisation			INT,
	School					NUMERIC(10,0),
	DischargeOutcome		NUMERIC(10,0),
	DischargeDestination	NUMERIC(10,0),
	AlcoholRelated			CHAR(2),
	TimeSinceIncident		INT,
	BedRequestedWard		INT,
	BedRequestedConsultant	INT,
	BedRequestedSpecialty	INT,
	BedRequestedOutcome		INT,
	EDClinicianSeen			NUMERIC(10,0),
	SeeAndTreat				INT,
	AttendanceCategory		NUMERIC(10,0),
	AppropriateAttendance	INT,
	RoadUser				INT,
	MechanismOfInjury		INT,
	Diagnosis1DiagnosisType	NUMERIC(10,0),
	Diagnosis1DiagnosisDate	DATE,
	Diagnosis1DiagnosisTime	TIME,
	Diagnosis1DiagnosisSite	NUMERIC(10,0),
	Diagnosis1DiagnosisSide	VARCHAR(2),
	Diagnosis2DiagnosisType	NUMERIC(10,0),
	Diagnosis2DiagnosisDate	DATE,
	Diagnosis2DiagnosisTime	TIME,
	Diagnosis2DiagnosisSite	NUMERIC(10,0),
	Diagnosis2DiagnosisSide	VARCHAR(2),
	Diagnosis3DiagnosisType	NUMERIC(10,0),
	Diagnosis3DiagnosisDate	DATE,
	Diagnosis3DiagnosisTime	TIME,
	Diagnosis3DiagnosisSite	NUMERIC(10,0),
	Diagnosis3DiagnosisSide	VARCHAR(2),
	Diagnosis4DiagnosisType	NUMERIC(10,0),
	Diagnosis4DiagnosisDate	DATE,
	Diagnosis4DiagnosisTime	TIME,
	Diagnosis4DiagnosisSite	NUMERIC(10,0),
	Diagnosis4DiagnosisSide	VARCHAR(2),
	Diagnosis5DiagnosisType	NUMERIC(10,0),
	Diagnosis5DiagnosisDate	DATE,
	Diagnosis5DiagnosisTime	TIME,
	Diagnosis5DiagnosisSite	NUMERIC(10,0),
	Diagnosis5DiagnosisSide	VARCHAR(2),
	Diagnosis6DiagnosisType	NUMERIC(10,0),
	Diagnosis6DiagnosisDate	DATE,
	Diagnosis6DiagnosisTime	TIME,
	Diagnosis6DiagnosisSite	NUMERIC(10,0),
	Diagnosis6DiagnosisSide	VARCHAR(2),
	Xray1RequestType		NUMERIC(10,0),
	Xray1RequestDate		DATE,
	Xray1RequestTime		TIME,
	XRay1RequestSite		NUMERIC(10,0),
	Xray1RequestSide		VARCHAR(2),
	Xray2RequestType		NUMERIC(10,0),
	Xray2RequestDate		DATE,
	Xray2RequestTime		TIME,
	XRay2RequestSite		NUMERIC(10,0),
	Xray2RequestSide		VARCHAR(2),
	Xray3RequestType		NUMERIC(10,0),
	Xray3RequestDate		DATE,
	Xray3RequestTime		TIME,
	XRay3RequestSite		NUMERIC(10,0),
	Xray3RequestSide		VARCHAR(2),
	Xray4RequestType		NUMERIC(10,0),
	Xray4RequestDate		DATE,
	Xray4RequestTime		TIME,
	XRay4RequestSite		NUMERIC(10,0),
	Xray4RequestSide		VARCHAR(2),
	Xray5RequestType		NUMERIC(10,0),
	Xray5RequestDate		DATE,
	Xray5RequestTime		TIME,
	XRay5RequestSite		NUMERIC(10,0),
	Xray5RequestSide		VARCHAR(2),
	Xray6RequestType		NUMERIC(10,0),
	Xray6RequestDate		DATE,
	Xray6RequestTime		TIME,
	XRay6RequestSite		NUMERIC(10,0),
	Xray6RequestSide		VARCHAR(2),
	Investigation1RequestType	NUMERIC(10,0),
	Investigation1RequestDate	DATE,
	Investigation1RequestTime	TIME,
	Investigation2RequestType	NUMERIC(10,0),
	Investigation2RequestDate	DATE,
	Investigation2RequestTime	TIME,
	Investigation3RequestType	NUMERIC(10,0),
	Investigation3RequestDate	DATE,
	Investigation3RequestTime	TIME,
	Investigation4RequestType	NUMERIC(10,0),
	Investigation4RequestDate	DATE,
	Investigation4RequestTime	TIME,
	Investigation5RequestType	NUMERIC(10,0),
	Investigation5RequestDate	DATE,
	Investigation5RequestTime	TIME,
	Investigation6RequestType	NUMERIC(10,0),
	Investigation6RequestDate	DATE,
	Investigation6RequestTime	TIME,
	Treatment1TreatmentType	NUMERIC(10,0),
	Treatment1TreatmentDate	DATE,
	Treatment1TreatmentTime	TIME,
	Treatment2TreatmentType	NUMERIC(10,0),
	Treatment2TreatmentDate	DATE,
	Treatment2TreatmentTime	TIME,
	Treatment3TreatmentType	NUMERIC(10,0),
	Treatment3TreatmentDate	DATE,
	Treatment3TreatmentTime	TIME,
	Treatment4TreatmentType	NUMERIC(10,0),
	Treatment4TreatmentDate	DATE,
	Treatment4TreatmentTime	TIME,
	Treatment5TreatmentType	NUMERIC(10,0),
	Treatment5TreatmentDate	DATE,
	Treatment5TreatmentTime	TIME,
	Treatment6TreatmentType	NUMERIC(10,0),
	Treatment6TreatmentDate	DATE,
	Treatment6TreatmentTime	TIME,
	SportsActivity			NUMERIC(10,0),
	LeftWithoutSeen			CHAR(1),
	CascardNumber			VARCHAR(20),
	PatientRefNo			NUMERIC(10,0)
	--BreachReason			VARCHAR(5)
)

INSERT INTO @Results
SELECT DISTINCT
	''West''  AS Area,
	''Pims'' AS Source,	
	A.AEATT_REFNO AS AttendanceIdentifier,
	P.PASID AS LocalPatientIdentifer,
	NULLIF(P.NHS_IDENTIFIER,'''') AS NHSNumber,
	NULL AS RegisteredGP,
	NULL AS RegisteredPractice,
	--GP.MAIN_IDENT AS RegisteredGP,
	--GPPRAC.MAIN_IDENT AS RegisteredPractice,
	NULL AS PatientPostcode,
	NULL AS DHA,
	--ADDS.PCODE AS PatientPostcode,
	--ADDS.PCG_CODE AS DHA,
	--REFGP.MAIN_IDENT AS ReferringGP,
	REFGP.IDENTIFIER AS ReferringGP,
	--REFGPPRAC.MAIN_IDENT AS ReferringPractice,
	REFPRACTICE.IDENTIFIER AS ReferringPractice,
	CAST(A.INCIDENT_DTTM AS DATE) AS IncidentDate,
	CAST(A.INCIDENT_DTTM AS TIME) AS IncidentTime,
	CAST(A.ARRIVED_DTTM AS DATE) AS ArrivalDate,
	CAST(A.ARRIVED_DTTM AS TIME) AS ArrivalTime,
	NULL AS AmbulanceHandoverDate,
	NULL AS AmbulanceHandoverTime,
	CAST(A.CREATE_DTTM AS DATE) AS RegisteredDate,
	CAST(A.CREATE_DTTM AS TIME) AS RegisteredTime,
	CAST(AR.TRIAG_START_DTTM AS DATE) AS TriageStartDate,
	CAST(AR.TRIAG_START_DTTM AS TIME) AS TriageStartTime,
	CAST(AR.TRIAG_END_DTTM AS DATE) AS TriageEndDate,
	CAST(AR.TRIAG_END_DTTM AS TIME) AS TriageEndTime,
	CAST(A.SEEN_DTTM AS DATE) AS EDClinicianSeenDate,
	CAST(A.SEEN_DTTM AS TIME) AS EDClinicianSeenTime,
	CAST(A.TREATED_DTTM AS DATE) AS TreatmentStartDate,
	CAST(A.TREATED_DTTM AS TIME) AS TreatmentStartTime,
	CAST(A.MED_DISCH_DTTM AS DATE) AS TreatmentCompleteDate,
	CAST(A.MED_DISCH_DTTM AS TIME) AS TreatmentCompleteTime,
	NULL AS DecisionToAdmitDate,
	NULL AS DecisionToAdmitTime,
	--NULL AS BreachEndDate,
	--NULL AS BreachEndTime,
	CAST(A.DEPARTED_DTTM AS DATE) AS DischargeDate,
	CAST(A.DEPARTED_DTTM AS TIME) AS DischargeTime,
	CAST(A.DEPARTED_DTTM AS DATE) AS DepartureDate,
	CAST(A.DEPARTED_DTTM AS TIME) AS DepartureTime,
	--NULL AS ConsultationRequestDate,
	--NULL AS ConsultationRequestTime,
	--NULL AS ConsultationResponseDate,
	--NULL AS ConsultationResponseTime,
	NULL AS TransportRequestedDate,
	NULL AS TransportRequestedTime,
	--CAST(PT.CREATE_DTTM AS DATE) AS TransportRequestedDate,
	--CAST(PT.CREATE_DTTM AS TIME) AS TransportRequestedTime,
	NULL AS TransportArrivedDate,
	NULL AS TransportArrivedTime,
	NULL AS BedRequestedDate,
	NULL AS BedRequestedTime,
	NULL AS BedRequestedOutcomeDate,
	NULL AS BedRequestedOutcomeTime,
	A.AMBULANCE_CALLED_BY AS AmbulanceReference,
	'''' AS SiteCodeOfTreatment, --SITECOD.Identifier AS SiteCodeOfTreatment,
	dbo.NWW_GetAeprcDetailStr(''ATROL'',AR.atrol_refno,''AEPRW'',''AEPRC'',''SECND'',6,3,''C'') AS PresentingComplaint, --NULL AS PresentingComplaint,
	R.SORRF_REFNO AS ReferralSource,
	A.ARMOD_REFNO AS ArrivalMode,
	A.AEPGR_REFNO AS PatientGroup,
	NULL AS AccompaniedBy1,
	NULL AS AccompaniedBy2,
	A.INLOC_REFNO AS IncidentLocation,
	NULL AS IncidentActivity,
	AR.TRCAT_REFNO AS TriageCategory,
	NULL AS TriageComplaint,		
	NULL AS TriageTreatment,
	NULL AS TriageTreatment1,
	NULL AS TriageTreatment2,
	NULL AS TriageTreatment3,
	NULL AS TriageTreatment4,
	NULL AS TriageTreatment5,
	NULL AS TriageTreatment6,
	NULL AS TriageTreatment7,
	NULL AS TriageTreatment8,
	NULL AS TriageTreatment9,
	NULL AS TriageTreatment10,
	NULL AS TriageDiscriminator,
	NULL AS Immunisation,
	A.SCHOOL_HEORG_REFNO AS School,
	A.ATDIS_REFNO as DischargeOutcome,
	A.DISDE_REFNO AS DischargeDestination,
	CASE
		WHEN A.ATCAT_REFNO IN (''202158'',''202159'') THEN ''04''
		ELSE ''03''
	END AS AlcoholRelated,	--X
	NULL AS TimeSinceIncident,
	NULL AS BedRequestedWard,
	NULL AS BedRequestedConsultant,
	NULL AS BedRequestedSpecialty,
	NULL AS BedRequestedOutcome,
	NULL AS EDClinicianSeen, --Not recorded electronically, so it would be the responsible clinician or nothing (RESP_PROCA_REFNO), not discharging  --ISNULL(A.RESP_PROCA_REFNO,A.DISCH_PROCA_REFNO) AS ClinicianSeen,
	NULL AS SeeAndTreat,
	A.ATCAT_REFNO AS AttendanceCategory,
	CASE
		WHEN A.ATCAT_REFNO=''202158'' THEN 3
		ELSE 1 
	END AS AppropriateAttendance,
	NULL AS RTAPatientType,
	NULL AS MechanismOfInjury,
	/*****************************************************************************
	DIAGNOSIS
	*****************************************************************************/
	Diagnosis1.DiagnosisType AS Diagnosis1DiagnosisType,
	Diagnosis1.DiagnosisDate AS Diagnosis1DiagnosisDate,
	Diagnosis1.DiagnosisTime AS Diagnosis1DiagnosisTime,
	SiteAndSide1.DiagnosisSite AS Diagnosis1DiagnosisSite,
	SiteAndSide1.DiagnosisSide AS Diagnosis1DiagnosisSide,
	Diagnosis2.DiagnosisType AS Diagnosis2DiagnosisType,
	Diagnosis2.DiagnosisDate AS Diagnosis2DiagnosisDate,
	Diagnosis2.DiagnosisTime AS Diagnosis2DiagnosisTime,
	SiteAndSide2.DiagnosisSite AS Diagnosis2DiagnosisSite,
	SiteAndSide2.DiagnosisSide AS Diagnosis2DiagnosisSide,
	Diagnosis3.DiagnosisType AS Diagnosis3DiagnosisType,
	Diagnosis3.DiagnosisDate AS Diagnosis3DiagnosisDate,
	Diagnosis3.DiagnosisTime AS Diagnosis3DiagnosisTime,
	SiteAndSide3.DiagnosisSite AS Diagnosis3DiagnosisSite,
	SiteAndSide3.DiagnosisSide AS Diagnosis3DiagnosisSide,
	Diagnosis4.DiagnosisType AS Diagnosis4DiagnosisType,
	Diagnosis4.DiagnosisDate AS Diagnosis4DiagnosisDate,
	Diagnosis4.DiagnosisTime AS Diagnosis4DiagnosisTime,
	SiteAndSide4.DiagnosisSite AS Diagnosis4DiagnosisSite,
	SiteAndSide4.DiagnosisSide AS Diagnosis4DiagnosisSide,
	Diagnosis5.DiagnosisType AS Diagnosis5DiagnosisType,
	Diagnosis5.DiagnosisDate AS Diagnosis5DiagnosisDate,
	Diagnosis5.DiagnosisTime AS Diagnosis5DiagnosisTime,
	SiteAndSide5.DiagnosisSite AS Diagnosis5DiagnosisSite,
	SiteAndSide5.DiagnosisSide AS Diagnosis5DiagnosisSide,
	Diagnosis6.DiagnosisType AS Diagnosis6DiagnosisType,
	Diagnosis6.DiagnosisDate AS Diagnosis6DiagnosisDate,
	Diagnosis6.DiagnosisTime AS Diagnosis6DiagnosisTime,
	SiteAndSide6.DiagnosisSite AS Diagnosis6DiagnosisSite,
	SiteAndSide6.DiagnosisSide AS Diagnosis6DiagnosisSide,
	/*****************************************************************************
	IMAGING REQUESTS
	*****************************************************************************/
	NULL AS Xray1RequestType,
	NULL AS Xray1RequestDate,
	NULL AS Xray1RequestTime,
	NULL AS Xray1RequestSite,
	NULL AS Xray1RequestSide,
	NULL AS Xray2RequestType,
	NULL AS Xray2RequestDate,
	NULL AS Xray2RequestTime,
	NULL AS Xray2RequestSite,
	NULL AS Xray2RequestSide,
	NULL AS Xray3RequestType,
	NULL AS Xray3RequestDate,
	NULL AS Xray3RequestTime,
	NULL AS Xray3RequestSite,
	NULL AS Xray3RequestSide,
	NULL AS Xray4RequestType,
	NULL AS Xray4RequestDate,
	NULL AS Xray4RequestTime,
	NULL AS Xray4RequestSite,
	NULL AS Xray4RequestSide,
	NULL AS Xray5RequestType,
	NULL AS Xray5RequestDate,
	NULL AS Xray5RequestTime,
	NULL AS Xray5RequestSite,
	NULL AS Xray5RequestSide,
	NULL AS Xray6RequestType,
	NULL AS Xray6RequestDate,
	NULL AS Xray6RequestTime,
	NULL AS Xray6RequestSite,
	NULL AS Xray6RequestSide,
	/*****************************************************************************
	PATHOLOGY REQUESTS
	*****************************************************************************/
	NULL AS Investigation1RequestType,
	NULL AS Investigation1RequestDate,
	NULL AS Investigation1RequestTime,
	NULL AS Investigation2RequestType,
	NULL AS Investigation2RequestDate,
	NULL AS Investigation2RequestTime,
	NULL AS Investigation3RequestType,
	NULL AS Investigation3RequestDate,
	NULL AS Investigation3RequestTime,
	NULL AS Investigation4RequestType,
	NULL AS Investigation4RequestDate,
	NULL AS Investigation4RequestTime,
	NULL AS Investigation5RequestType,
	NULL AS Investigation5RequestDate,
	NULL AS Investigation5RequestTime,
	NULL AS Investigation6RequestType,
	NULL AS Investigation6RequestDate,
	NULL AS Investigation6RequestTime,
	/*****************************************************************************
	TREATMENTS
	*****************************************************************************/
	Treatment1.TreatmentType AS Treatment1TreatmentType,
	Treatment1.TreatmentDate AS Treatment1TreatmentDate,
	Treatment1.TreatmentTime AS Treatment1TreatmentTime,
	Treatment2.TreatmentType AS Treatment2TreatmentType,
	Treatment2.TreatmentDate AS Treatment2TreatmentDate,
	Treatment2.TreatmentTime AS Treatment2TreatmentTime,
	Treatment3.TreatmentType AS Treatment3TreatmentType,
	Treatment3.TreatmentDate AS Treatment3TreatmentDate,
	Treatment3.TreatmentTime AS Treatment3TreatmentTime,
	Treatment4.TreatmentType AS Treatment4TreatmentType,
	Treatment4.TreatmentDate AS Treatment4TreatmentDate,
	Treatment4.TreatmentTime AS Treatment4TreatmentTime,
	Treatment5.TreatmentType AS Treatment5TreatmentType,
	Treatment5.TreatmentDate AS Treatment5TreatmentDate,
	Treatment5.TreatmentTime AS Treatment5TreatmentTime,
	Treatment6.TreatmentType AS Treatment6TreatmentType,
	Treatment6.TreatmentDate AS Treatment6TreatmentDate,
	Treatment6.TreatmentTime AS Treatment6TreatmentTime,
	NULL AS SportsActivity,
	CASE 
		WHEN a.atdis_Refno = 212089 then ''Y'' 
		ELSE NULL
	END AS LeftWithoutSeen,
	A.Identifier AS CascardNumber,
	P.PATNT_REFNO AS PatientRefNo
	--'''' AS BreachReason
FROM 	
	AE_ATTENDANCES A
	INNER JOIN HEALTH_ORGANISATIONS HO ON A.HEORG_REFNO = HO.HEORG_REFNO
	INNER JOIN PATIENTS P ON A.PATNT_REFNO = P.PATNT_REFNO
	INNER JOIN REFERRALS R ON A.REFRL_REFNO = R.REFRL_REFNO
	INNER JOIN AE_ATTENDANCE_ROLES AR ON A.AEATT_REFNO = AR.AEATT_REFNO
	
	--LEFT JOIN HEALTH_ORGANISATIONS SITECOD on SITECOD.heorg_Refno = ho.parnt_Refno

	LEFT JOIN prof_carer_ids REFGP ON 
		REFGP.PROCA_REFNO=R.REFBY_PROCA_REFNO AND
		REFGP.CITYP_REFNO=@cityp_natgp AND
		REFGP.END_DTTM IS NULL AND
		ISNULL(REFGP.ARCHV_FLAG,''N'')=''N''
	--LEFT JOIN PROF_CARERS REFGP ON 
	--	R.REFBY_PROCA_REFNO = REFGP.PROCA_REFNO AND 
	--	REFGP.PRTYP_REFNO = 4054 AND 
	--	ISNULL(REFGP.ARCHV_FLAG,''N'')=''N'' AND 
	--	REFGP.END_DTTM IS NULL

	LEFT JOIN HEALTH_ORGANISATION_IDS REFPRACTICE ON 
		REFPRACTICE.HEORG_REFNO=R.REFBY_HEORG_REFNO AND
		REFPRACTICE.HITYP_REFNO=@hityp_natnl AND
		REFPRACTICE.END_DTTM IS NULL AND
		ISNULL(REFPRACTICE.ARCHV_FLAG,''N'')=''N''
	--LEFT JOIN HEALTH_ORGANISATIONS REFGPPRAC ON 
	--	R.REFBY_HEORG_REFNO = REFGPPRAC.HEORG_REFNO AND 
	--	ISNULL(REFGPPRAC.ARCHV_FLAG,''N'') = ''N'' AND 
	--	REFGPPRAC.END_DTTM IS NULL


	--LEFT JOIN PATIENT_PROF_CARERS PPC ON PPC.PATNT_REFNO = P.PATNT_REFNO AND 
	--	PPC.PRTYP_REFNO = 4054 AND
	--	CAST(A.ARRIVED_DTTM AS DATE) BETWEEN CAST(PPC.START_DTTM AS DATE) AND ISNULL(CAST(PPC.END_DTTM AS DATE),CAST(A.ARRIVED_DTTM AS DATE)) AND
	--	ISNULL(PPC.ARCHV_FLAG,''N'') = ''N'' AND
	--	PPC.END_DTTM IS NULL AND 
	--	PPC.START_DTTM=(SELECT MAX(START_DTTM) FROM PATIENT_PROF_CARERS innerPPC WHERE innerPPC.PATNT_REFNO=P.PATNT_REFNO)
		

	

	--LEFT JOIN PROF_CARERS GP ON 
	--	GP.PROCA_REFNO = PPC.PROCA_REFNO AND 
	--	GP.PRTYP_REFNO = 4054 AND 
	--	ISNULL(GP.ARCHV_FLAG,''N'') = ''N'' AND 
	--	GP.END_DTTM IS NULL
	--LEFT JOIN HEALTH_ORGANISATIONS GPPRAC ON GPPRAC.HEORG_REFNO = PPC.HEORG_REFNO AND ISNULL(GPPRAC.ARCHV_FLAG,''N'') = ''N'' AND GPPRAC.END_DTTM IS NULL
	--LEFT JOIN ADDRESS_ROLES ADDR ON 
	--	P.PATNT_REFNO = ADDR.PATNT_REFNO AND 
	--	ADDR.ROTYP_CODE = ''HOME'' 
	--	AND ISNULL(ADDR.ARCHV_FLAG,''N'') = ''N'' AND 
	--	A.ARRIVED_DTTM BETWEEN ADDR.START_DTTM AND ISNULL(ADDR.END_DTTM,'''+@DateToString+''')

	--LEFT JOIN ADDRESSES ADDS ON 
	--	ADDR.ADDSS_REFNO = ADDS.ADDSS_REFNO AND	
	--	ADDS.ADTYP_CODE= ''POSTL'' AND 
	--	ISNULL(ADDS.ARCHV_FLAG,''N'') = ''N''

	--JOIN [iPMProduction].dbo.AE_STAYS aes on AEATT_REFNO = aeatt.AEATT_REFNO
	
	LEFT JOIN @Diagnosis Diagnosis1 ON A.aeatt_refno=Diagnosis1.AttendanceId AND Diagnosis1.RowNumber=1
	LEFT JOIN @Diagnosis Diagnosis2 ON A.aeatt_refno=Diagnosis2.AttendanceId AND Diagnosis2.RowNumber=2
	LEFT JOIN @Diagnosis Diagnosis3 ON A.aeatt_refno=Diagnosis3.AttendanceId AND Diagnosis3.RowNumber=3
	LEFT JOIN @Diagnosis Diagnosis4 ON A.aeatt_refno=Diagnosis4.AttendanceId AND Diagnosis4.RowNumber=4
	LEFT JOIN @Diagnosis Diagnosis5 ON A.aeatt_refno=Diagnosis5.AttendanceId AND Diagnosis5.RowNumber=5
	LEFT JOIN @Diagnosis Diagnosis6 ON A.aeatt_refno=Diagnosis6.AttendanceId AND Diagnosis6.RowNumber=6
	LEFT JOIN @SiteAndSide SiteAndSide1 ON A.aeatt_refno=SiteAndSide1.AttendanceId AND SiteAndSide1.RowNumber=1
	LEFT JOIN @SiteAndSide SiteAndSide2 ON A.aeatt_refno=SiteAndSide2.AttendanceId AND SiteAndSide2.RowNumber=2
	LEFT JOIN @SiteAndSide SiteAndSide3 ON A.aeatt_refno=SiteAndSide3.AttendanceId AND SiteAndSide3.RowNumber=3
	LEFT JOIN @SiteAndSide SiteAndSide4 ON A.aeatt_refno=SiteAndSide4.AttendanceId AND SiteAndSide4.RowNumber=4
	LEFT JOIN @SiteAndSide SiteAndSide5 ON A.aeatt_refno=SiteAndSide5.AttendanceId AND SiteAndSide5.RowNumber=5
	LEFT JOIN @SiteAndSide SiteAndSide6 ON A.aeatt_refno=SiteAndSide6.AttendanceId AND SiteAndSide6.RowNumber=6
	LEFT JOIN @Treatment Treatment1 ON A.aeatt_refno=Treatment1.AttendanceId AND Treatment1.RowNumber=1
	LEFT JOIN @Treatment Treatment2 ON A.aeatt_refno=Treatment2.AttendanceId AND Treatment2.RowNumber=2
	LEFT JOIN @Treatment Treatment3 ON A.aeatt_refno=Treatment3.AttendanceId AND Treatment3.RowNumber=3
	LEFT JOIN @Treatment Treatment4 ON A.aeatt_refno=Treatment4.AttendanceId AND Treatment4.RowNumber=4
	LEFT JOIN @Treatment Treatment5 ON A.aeatt_refno=Treatment5.AttendanceId AND Treatment5.RowNumber=5
	LEFT JOIN @Treatment Treatment6 ON A.aeatt_refno=Treatment6.AttendanceId AND Treatment6.RowNumber=6
	--LEFT JOIN [PATIENT_TRANSPORTATIONS] PT ON A.AEATT_REFNO=PT.SORCE_REFNO AND SORCE_CODE=''AEATT'' 
WHERE	
	ISNULL(A.archv_flag, ''N'') = ''N'' AND	
	CAST(A.ARRIVED_DTTM AS DATE)> '''+@LastAttendanceDateString+''' AND CAST(A.ARRIVED_DTTM AS DATE) < '''+@DateToString+''' AND	
	AR.ATROL_REFNO = (
		SELECT	
			MAX(ATROL.ATROL_REFNO)
		FROM	
			AE_ATTENDANCE_ROLES ATROL
		WHERE	
			ATROL.AEATT_REFNO = A.AEATT_REFNO AND
			ISNULL(ATROL.ARCHV_FLAG, ''N'') = ''N'')



--Patient address details
UPDATE 	
	@Results
SET 	
	PatientPostcode=ADDS.PCODE,
	DHA=ADDS.PCG_CODE
FROM
	@Results R
	INNER JOIN ADDRESS_ROLES ADDR ON R.PatientRefNo = ADDR.PATNT_REFNO AND
		ADDR.ADDSS_REFNO = 
			(
				SELECT 
					TOP 1 innerR.ADDSS_REFNO 
				FROM 
					ADDRESS_ROLES innerR INNER JOIN ADDRESSES innerA ON innerR.ADDSS_REFNO=innerA.ADDSS_REFNO 
				WHERE 
					innerR.PATNT_REFNO= R.PatientRefNo AND
					CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN innerR.START_DTTM AND ISNULL(innerR.END_DTTM,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND 
					ISNULL(innerR.ARCHV_FLAG,''N'') = ''N'' AND 
					innerR.ROTYP_CODE = ''HOME'' AND
					innerA.ADTYP_CODE=''POSTL'' AND
					ISNULL(innerA.ARCHV_FLAG,''N'') = ''N''
				ORDER BY
					innerR.START_DTTM DESC,
					innerR.MODIF_DTTM DESC, 
					innerR.ROLES_REFNO DESC)
	INNER JOIN ADDRESSES ADDS ON ADDR.ADDSS_REFNO = ADDS.ADDSS_REFNO
--WHERE
	--ADDR.ROTYP_CODE = ''HOME'' AND
	--ADDS.ADTYP_CODE = ''POSTL'' AND
	--R.ArrivalDate BETWEEN ADDR.START_DTTM AND ISNULL(ADDR.END_DTTM,'''+@DateToString+''') AND
	--CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN ADDR.START_DTTM AND ISNULL(ADDR.END_DTTM,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND
	--ISNULL(ADDR.ARCHV_FLAG,''N'') = ''N'' AND
	--ISNULL(ADDS.ARCHV_FLAG,''N'') = ''N''
--ORDER BY
--	ADDR.START_DTTM DESC,
--	ADDR.MODIF_DTTM DESC,
--	ADDR.ROLES_REFNO DESC


--REGISTERED GP - 14 March 2019
UPDATE @Results 
SET 
	RegisteredGP=PCI.IDENTIFIER,
	RegisteredPractice=HOI.IDENTIFIER
FROM
	@Results R
	LEFT JOIN PATIENT_PROF_CARERS PATPC ON R.PatientRefNo = PATPC.PATNT_REFNO AND
		PATPC.PATPC_REFNO=
							(
								SELECT 
									TOP 1 innerp.PATPC_REFNO 
								FROM 
									PATIENT_PROF_CARERS innerp 
								WHERE 
									innerp.PATNT_REFNO=R.PatientRefNo AND 
									CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN innerp.START_DTTM AND ISNULL(innerp.END_DTTM,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND
									innerp.PRTYP_REFNO=4054 AND
									ISNULL(innerp.ARCHV_FLAG,''N'') = ''N''
								ORDER BY 
									innerP.START_DTTM DESC, 
									innerP.MODIF_DTTM DESC, 
									innerP.PATPC_REFNO DESC
							)
	LEFT JOIN PROF_CARER_IDS PCI ON PATPC.PROCA_REFNO=PCI.PROCA_REFNO AND
		PRCAI_REFNO=
			(
				SELECT 
					TOP 1 innerPCI.PRCAI_REFNO 
				FROM 
					PROF_CARER_IDS innerPCI
				WHERE
					innerPCI.PROCA_REFNO=PATPC.PROCA_REFNO AND
					CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN innerPCI.START_DTTM AND ISNULL(innerPCI.END_DTTM,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND
					innerPCI.CITYP_REFNO IN (8,4045) AND
					ISNULL(innerPCI.ARCHV_FLAG,''N'')=''N''
				ORDER BY
					innerPCI.START_DTTM DESC,
					innerPCI.MODIF_DTTM DESC,
					innerPCI.PRCAI_REFNO DESC
			)
	LEFT JOIN HEALTH_ORGANISATION_IDS HOI ON PATPC.HEORG_REFNO=HOI.HEORG_REFNO AND
		HOI.HEOID_REFNO=(
				SELECT TOP 1 innerHOI.HEOID_REFNO
				FROM
					HEALTH_ORGANISATION_IDS innerHOI
				WHERE
					innerHOI.HEORG_REFNO=PATPC.HEORG_REFNO AND
					CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN innerHOI.START_DTTM AND ISNULL(innerHOI.END_DTTM,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND
					innerHOI.HITYP_REFNO=4050 AND
					ISNULL(innerHOI.ARCHV_FLAG,''N'')=''N''
				ORDER BY
					innerHOI.START_DTTM DESC,
					innerHOI.MODIF_DTTM DESC,
					innerHOI.HEOID_REFNO DESC
			)


----Registered GP - fix taken from [NWW_Get_PAS_Data_OutpatientWest]
--UPDATE
--	@Results
--SET    
--	RegisteredGP = prcai.identifier,
--    RegisteredPractice = heoid.identifier
--FROM   
--	@Results R
--	INNER JOIN patient_prof_carers patpc ON R.PatientRefNo = patpc.patnt_refno
--    INNER JOIN prof_carer_ids prcai ON patpc.proca_refno = prcai.proca_refno
--    INNER JOIN health_organisation_ids heoid ON patpc.heorg_refno = heoid.heorg_refno
--WHERE  
--	patpc.prtyp_refno = @prtyp_gmprc AND  
--	--prcai.cityp_refno = @cityp_natgp AND  --Removed after testing 30-10-2018
--	heoid.hityp_refno = @hityp_natnl AND  
--	--R.ArrivalDate BETWEEN patpc.start_dttm AND ISNULL(patpc.end_dttm,R.ArrivalDate) AND  
--	CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN patpc.start_dttm AND ISNULL(patpc.end_dttm,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND  
--	--R.ArrivalDate BETWEEN heoid.start_dttm AND ISNULL(heoid.end_dttm,R.ArrivalDate) AND  
--	CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME) BETWEEN heoid.start_dttm AND ISNULL(heoid.end_dttm,CAST(R.ArrivalDate AS DATETIME)+CAST(R.ArrivalTime AS DATETIME)) AND  
--	ISNULL(patpc.archv_flag,''N'') = ''N'' AND  
--	ISNULL(prcai.archv_flag,''N'') = ''N'' AND  
--	ISNULL(heoid.archv_flag,''N'') = ''N''


--Site Code of Treatment
UPDATE 	
	@Results
SET 	
	SiteCodeOfTreatment= hsite.identifier
FROM    
	@Results R
	INNER JOIN AE_Attendances A ON R.AttendanceIdentifier=A.AEATT_REFNO
	INNER JOIN health_organisations heorg ON A.heorg_refno = heorg.heorg_refno
	INNER JOIN health_organisation_ids hsite ON heorg.parnt_refno = hsite.heorg_refno
WHERE   
	hsite.hityp_refno = @hityp_natnl AND   
	R.ArrivalDate BETWEEN CAST(hsite.start_dttm AS DATE) AND CAST(ISNULL(hsite.end_dttm,GETDATE()) AS DATE) AND   
	ISNULL(hsite.archv_flag,''N'') = ''N'' 



--Triage discriminator
--CHANGED ON 12 DCEMBER 2018 AFTER TESTING
--UPDATE
--	@Results
--SET
--	TriageDiscriminator=TD.ODPCD_REFNO
--FROM
--	@Results tmp
--	LEFT JOIN [iPMProduction].dbo.DIAGNOSIS_PROCEDURES DP ON tmp.AttendanceIdentifier=DP.SORCE_REFNO AND DP.CCSXT_CODE=''AEDIG'' AND ISNULL(DP.ARCHV_FLAG,''N'')=''N''
--	INNER JOIN ODPCD_CODES TD ON DP.ODPCD_REFNO=TD.ODPCD_REFNO

UPDATE
	@Results
SET
	TriageDiscriminator=TD.ODPCD_REFNO
FROM
	@Results tmp
	LEFT JOIN [iPMProduction].dbo.DIAGNOSIS_PROCEDURES DP ON tmp.AttendanceIdentifier=DP.SORCE_REFNO AND 
		DP.CCSXT_CODE=''AEDIG'' AND 
		ISNULL(DP.ARCHV_FLAG,''N'')=''N'' and 
		dp.MPLEV_REFNO = 200723
	INNER JOIN ODPCD_CODES TD ON DP.ODPCD_REFNO=TD.ODPCD_REFNO 


--Triage complaint
--CHANGED ON 12 DCEMBER 2018 AFTER TESTING
--UPDATE
--	@Results
--SET
--	TriageComplaint=DP.ODPCD_REFNO
--FROM
--	@Results tmp
--	LEFT JOIN [iPMProduction].dbo.DIAGNOSIS_PROCEDURES DP ON tmp.AttendanceIdentifier=DP.SORCE_REFNO AND 
--		DP.SORCE_CODE=''ATROL'' AND
--		DP.DPTYP_CODE=''AEPRW'' AND
--		ISNULL(DP.ARCHV_FLAG,''N'')=''N''
--	INNER JOIN ODPCD_CODES O ON DP.ODPCD_REFNO=O.ODPCD_REFNO AND 
--		O.CCSXT_CODE=''AEPRC''

UPDATE
	@Results
SET
	TriageComplaint = (select top 1 DP.ODPCD_REFNO
FROM
	@Results tmp
	left JOIN [iPMProduction].dbo.AE_ATTENDANCE_ROLES ar on ar.AEATT_REFNO = tmp.AttendanceIdentifier 
	LEFT JOIN [iPMProduction].dbo.DIAGNOSIS_PROCEDURES DP ON ar.ATROL_REFNO =DP.SORCE_REFNO AND 
		DP.SORCE_CODE=''ATROL'' AND
		DP.DPTYP_CODE=''AEPRW'' AND
		ISNULL(DP.ARCHV_FLAG,''N'')=''N''
	INNER JOIN ODPCD_CODES O ON DP.ODPCD_REFNO=O.ODPCD_REFNO AND 
		O.CCSXT_CODE=''AEPRC''
		where outtemp.AttendanceIdentifier = tmp.AttendanceIdentifier
		order by dp.create_dttm asc)
from 
	@Results outtemp 


	

--Alcohol indicator
UPDATE
	@Results 
SET
	AlcoholRelated=''01''
FROM
	@Results tmp
WHERE
	EXISTS
		(
			SELECT 
				ATROL_REFNO
			FROM	
				AE_ATTENDANCE_ROLES ATROL
				JOIN DIAGNOSIS_PROCEDURES DP ON ATROL.ATROL_REFNO = DP.SORCE_REFNO
				JOIN ODPCD_CODES AR ON DP.ODPCD_REFNO = AR.ODPCD_REFNO
			WHERE
				tmp.AttendanceIdentifier=ATROL.AEATT_REFNO AND 
				DP.SORCE_CODE = ''ATROL'' AND	
				AR.CODE IN (''AEA6'',''AEA3'') AND
				AR.CCSXT_CODE = ''AEPRC'' AND	
				ISNULL(DP.ARCHV_FLAG,''N'') = ''N'' AND 
				ISNULL(ATROL.ARCHV_FLAG,''N'')=''N''
		)

-- Appropriateness of Attendance
UPDATE	
	@Results
SET		
	AppropriateAttendance = 2
FROM	
	@Results tmp
WHERE 
	EXISTS 
		(
			SELECT 
				ATROL_REFNO
			FROM
				AE_ATTENDANCE_ROLES ATROL
				JOIN DIAGNOSIS_PROCEDURES DP ON ATROL.ATROL_REFNO = DP.SORCE_REFNO
				JOIN ODPCD_CODES O ON DP.ODPCD_REFNO = O.ODPCD_REFNO
			WHERE
				tmp.AttendanceIdentifier = ATROL.AEATT_REFNO AND
				DP.SORCE_CODE = ''ATROL'' AND
				O.CODE =''AEI2'' AND
				O.CCSXT_CODE = ''AEPRC'' AND
				ISNULL(ATROL.ARCHV_FLAG,''N'') = ''N'' AND
				ISNULL(DP.ARCHV_FLAG,''N'') = ''N'')

-- Presenting Complaint
UPDATE	
	@Results
SET		
	--Changed after testing 30-10-2018
	PresentingComplaint= 
		SUBSTRING(
			PresentingComplaint +
				CASE 
					WHEN LEN(PresentingComplaint) < 1 OR N.note IS NULL THEN '''' 
					ELSE '', '' 
				END + 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(CAST(N.note AS VARCHAR(255)), CHAR(0x0D), ''''), 
							CHAR(0x0A), ''''),
						CHAR(0x09), ''''),
					''"'',''''),
				''|'','''')
		,1,255) 
	--PresentingComplaint += REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CAST(N.NOTE AS VARCHAR(255)), CHAR(0x0D), ''''), CHAR(0x0A), ''''), CHAR(0x09), ''''),''"'',''''),''|'','''')
FROM	
	@Results tmp
	JOIN AE_ATTENDANCE_ROLES ATROL ON tmp.AttendanceIdentifier=ATROL.AEATT_REFNO
	JOIN NOTE_ROLES NR ON ATROL.ATROL_REFNO = NR.SORCE_REFNO
	JOIN NOTES N ON NR.NOTES_REFNO = N.NOTES_REFNO
WHERE	
	ISNULL(NR.ARCHV_FLAG,''N'') = ''N'' AND
	ISNULL(N.ARCHV_FLAG,''N'') = ''N'' AND
	NR.SORCE_CODE = ''AEPWI''
	
--Sports activity
UPDATE
	@Results
SET
	SportsActivity=IA.ODPCD_REFNO
FROM
	@Results tmp
	LEFT JOIN [iPMProduction].dbo.DIAGNOSIS_PROCEDURES DP1 ON tmp.AttendanceIdentifier=DP1.SORCE_REFNO AND DP1.CCSXT_CODE=''AESP'' AND ISNULL(DP1.ARCHV_FLAG,''N'')=''N''
	INNER JOIN ODPCD_CODES IA ON DP1.ODPCD_REFNO=IA.ODPCD_REFNO


SELECT *,
	NULL AS BREACHKEY1,
	NULL AS BREACHREASON1,
	NULL AS BREACHSTARTDATE1,
	NULL AS BREACHSTARTTIME1,
	NULL AS BREACHENDDATE1,
	NULL AS BREACHENDTIME1,
	NULL AS BREACHKEY2,
	NULL AS BREACHREASON2,
	NULL AS BREACHSTARTDATE2,
	NULL AS BREACHSTARTTIME2,
	NULL AS BREACHENDDATE2,
	NULL AS BREACHENDTIME2,
	NULL AS BREACHKEY3,
	NULL AS BREACHREASON3,
	NULL AS BREACHSTARTDATE3,
	NULL AS BREACHSTARTTIME3,
	NULL AS BREACHENDDATE3,
	NULL AS BREACHENDTIME3,
	NULL AS BREACHKEY4,
	NULL AS BREACHREASON4,
	NULL AS BREACHSTARTDATE4,
	NULL AS BREACHSTARTTIME4,
	NULL AS BREACHENDDATE4,
	NULL AS BREACHENDTIME4,
	NULL AS BREACHKEY5,
	NULL AS BREACHREASON5,
	NULL AS BREACHSTARTDATE5,
	NULL AS BREACHSTARTTIME5,
	NULL AS BREACHENDDATE5,
	NULL AS BREACHENDTIME5,
	NULL AS BREACHKEY6,
	NULL AS BREACHREASON6,
	NULL AS BREACHSTARTDATE6,
	NULL AS BREACHSTARTTIME,
	NULL AS BREACHENDDATE6,
	NULL AS BREACHENDTIME6,
	NULL AS ConsultationRequestDate1,
	NULL AS ConsultationRequestTime1,
	NULL AS ConsultationRequestCompletedDate1,
	NULL AS ConsultationRequestCompletedTime1,
	NULL AS ConsultationRequestSpecialty1,
	NULL AS ConsultationRequestDate2,
	NULL AS ConsultationRequestTime2,
	NULL AS ConsultationRequestCompletedDate2,
	NULL AS ConsultationRequestCompletedTime2,
	NULL AS ConsultationRequestSpecialty2,
	NULL AS ConsultationRequestDate3,
	NULL AS ConsultationRequestTime3,
	NULL AS ConsultationRequestCompletedDate3,
	NULL AS ConsultationRequestCompletedTime3,
	NULL AS ConsultationRequestSpecialty3,
	NULL AS ConsultationRequestDate4,
	NULL AS ConsultationRequestTime4,
	NULL AS ConsultationRequestCompletedDate4,
	NULL AS ConsultationRequestCompletedTime4,
	NULL AS ConsultationRequestSpecialty4,
	NULL AS ConsultationRequestDate5,
	NULL AS ConsultationRequestTime5,
	NULL AS ConsultationRequestCompletedDate5,
	NULL AS ConsultationRequestCompletedTime5,
	NULL AS ConsultationRequestSpecialty5,
	NULL AS ConsultationRequestDate6,
	NULL AS ConsultationRequestTime6,
	NULL AS ConsultationRequestCompletedDate6,
	NULL AS ConsultationRequestCompletedTime6,
	NULL AS ConsultationRequestSpecialty6,
	NULL AS AttendanceNumber
FROM 
	@Results
	
'
)  AT [7A1AUSRVIPMSQL];--AT [7A1AUSRVIPMSQLR\REPORTS];





END
GO
