SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_PAS_Ref_Patient_OutpatientWestResch]
AS
BEGIN
SET NOCOUNT ON;
/*
NOTE: this data is loaded using a merge process, this means if the patients changes from being an outpatient then any records picked up in the process will remain in the patients table, resulting in extra patient in the patients table.
This issue will be looked at and an automated process put in place to delete these records.  KR 07/04/2020
*/

--declare @lastattendancedate as date = '2019-03-01'

DECLARE @LastAttendanceDate AS DATE = (SELECT 
	case	when max(LoadDate) = convert(date, getdate()) then (select min(AppointmentDate) from [Foundation].[dbo].[PAS_Data_Outpatient] group by LoadDate having max(LoadDate) = convert(date, getdate()) )	
			else  ISNULL(max(AppointmentDate),'2010-01-01') 
			end
	FROM [Foundation].[dbo].[PAS_Data_Outpatient] WHERE source='pims' and ActNoteKey LIKE '%RESCH%' and AppointmentDate <> '2999-12-31' and AppointmentDate < CONVERT(date,getdate()))

DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)
DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())
EXEC('
USE [iPMProduction]

DECLARE 
	@cityp_natgp numeric(10,0),
	@hityp_natnl numeric(10,0),
	@prtyp_gmprc numeric(10,0)

set @cityp_natgp = (	
					select RFVAL_REFNO
					from REFERENCE_VALUES
					where 
						RFVDM_CODE=''CITYP''
					and MAIN_CODE=''NATGP''
					and isnull(ARCHV_FLAG,''N'')=''N''
					)

set @hityp_natnl = (	
					select RFVAL_REFNO
					from REFERENCE_VALUES
					where 
						RFVDM_CODE=''HITYP''
					and MAIN_CODE=''NATNL''
					and isnull(ARCHV_FLAG,''N'')=''N''
					)
	
set @prtyp_gmprc = (	
					select RFVAL_REFNO
					from REFERENCE_VALUES
					where 
						RFVDM_CODE=''PRTYP''
					and MAIN_CODE=''GMPRC''
					and isnull(ARCHV_FLAG,''N'')=''N''
					)

-- ****************************************************************************************************
-- Create table and extract non activity date dependent data from Pims
-- ****************************************************************************************************

DECLARE @Results AS TABLE(
	AttendanceIdentifier	VARCHAR(20),
	LocalPatientIdentifier	VARCHAR(30),
	NHSNumber				VARCHAR(30),
	Surname					VARCHAR(50),
	Forename				VARCHAR(50),
	DateOfBirth				DATE,
	Gender					VARCHAR(10),
	Title					VARCHAR(20),
	Address1				VARCHAR(100),
	Address2				VARCHAR(100),
	Address3				VARCHAR(100),
	Address4				VARCHAR(100),
	Address5				VARCHAR(100),
	Postcode				VARCHAR(10),
	RegisteredGP			VARCHAR(20),
	RegisteredPractice		VARCHAR(20),
	PatientRefNo			VARCHAR(50),
	ArrivalDate				DATE,
	NHSNumberStatus			VARCHAR(5),
	LHBofResidence			varchar(5),
	Ethnicity				varchar(5)
)

INSERT INTO @Results(
	AttendanceIdentifier,
	LocalPatientIdentifier,
	NHSNumber,
	Surname,
	Forename,
	DateOfBirth,
	Gender,
	Title,
	PatientRefNo,
	ArrivalDate,
	NHSNumberStatus,
	LHBofResidence,
	Ethnicity 
)

SELECT distinct
	--p.PATNT_REFNO,
	--sch.REFRL_REFNO,
	sch.schdl_refno,
	P.PASID,
	P.NHS_IDENTIFIER,
	P.SURNAME,
	P.FORENAME,
	P.DATE_OF_BIRTH,
	S.MAIN_CODE,
	T.DESCRIPTION,
	P.PATNT_REFNO,
	CAST(sch.start_Dttm AS DATE),
	NNNTS_code,								--Added by JH 28 Jan 2020
	NULL,									--Added by JH 28 Jan 2020
	dbo.IS_GetRefValID(''NHS'',ethgr_refno)	--Added by JH 28 Jan 2020



FROM
	schedules sch
	LEFT JOIN PATIENTS P ON sch.patnt_Refno = P.PATNT_REFNO
	LEFT JOIN REFERENCE_VALUES S ON P.SEXXX_REFNO = S.RFVAL_REFNO
	LEFT JOIN REFERENCE_VALUES T ON P.TITLE_REFNO = T.RFVAL_REFNO
	left join SCHEDULE_HISTORIES sh on sch.SCHDL_REFNO = sh.SCHDL_REFNO 

where
--to match reschdules extract
(
ISNULL(sh.ARCHV_FLAG,''N'') = ''N''
and sh.EXTERNAL_KEY in ( ''Manual Move'',''Reschedule'')
and sch.SCTYP_REFNO = 12186
and ISNULL(sch.archv_flag,''N'') = ''N''
and sh.old_start_Dttm > '''+ @LastAttendanceDate +'''
--and sh.old_start_Dttm >= ''01 January 2010''
and sch.SATYP_REFNO <> 205912
)


-- ****************************************************************************************************
-- Update address details
-- ****************************************************************************************************

UPDATE 
	@Results
SET
	Address1 = A.LINE1,
	Address2=A.LINE2,
	Address3=A.LINE3,
	Address4=A.LINE4,
	Postcode=A.PCODE
FROM
	@Results R
	INNER JOIN ADDRESS_ROLES AR ON R.PatientRefNo=	AR.PATNT_REFNO
	INNER JOIN ADDRESSES A ON AR.ADDSS_REFNO = A.ADDSS_REFNO
WHERE
	AR.ROTYP_CODE = ''HOME'' AND
	A.ADTYP_CODE = ''POSTL'' AND 
	(R.ArrivalDate between AR.START_DTTM AND ISNULL(AR.END_DTTM,R.ArrivalDate)) AND
	ISNULL(AR.ARCHV_FLAG,''N'')=''N'' AND
	ISNULL(A.ARCHV_FLAG,''N'')=''N''

-- ****************************************************************************************************
-- Update GP details
-- ****************************************************************************************************

UPDATE
	@Results
SET
	RegisteredGP = proca.identifier,
	RegisteredPractice = heorg.identifier
FROM
	@Results R
	INNER JOIN patient_prof_carers patproca ON R.PatientRefNo = patproca.PATNT_REFNO
	INNER JOIN prof_carer_ids proca ON patproca.PROCA_REFNO = proca.PROCA_REFNO
	INNER JOIN health_organisation_ids heorg ON patproca.HEORG_REFNO = heorg.HEORG_REFNO
WHERE
	patproca.PRTYP_REFNO = @prtyp_gmprc AND
	proca.CITYP_REFNO = @cityp_natgp AND
	heorg.HITYP_REFNO = @hityp_natnl AND
	(R.ArrivalDate between patproca.START_DTTM AND ISNULL(patproca.END_DTTM,R.ArrivalDate)) AND
	(R.ArrivalDate between proca.START_DTTM AND ISNULL(proca.END_DTTM,R.ArrivalDate)) AND
	(R.ArrivalDate between heorg.START_DTTM AND ISNULL(heorg.END_DTTM,R.ArrivalDate)) AND
	ISNULL(patproca.ARCHV_FLAG,''N'')=''N'' AND
	ISNULL(proca.ARCHV_FLAG,''N'')=''N'' AND
	ISNULL(heorg.ARCHV_FLAG,''N'')=''N''

-- ****************************************************************************************************
-- Update LHB of Residence
-- ****************************************************************************************************
--Added by JH 28 Jan 2020
UPDATE  @Results
	SET 	LHBofResidence = 
			CASE
			WHEN ArrivalDate < ''2013-04-01 00:00:00.000'' THEN
			pcode.state_code ELSE pcode.pcg_code END
	FROM 	@Results tmp
		INNER JOIN postcodes pcode
			ON REPLACE(tmp.Postcode,'' '','''') = pcode.pcode
	WHERE	ISNULL(pcode.archv_flag,''N'') = ''N''



-- ****************************************************************************************************
-- Update AttendanceIdentifier to make it unique
-- ****************************************************************************************************
UPDATE @Results
SET AttendanceIdentifier = ''RESCH-'' + AttendanceIdentifier


-- ****************************************************************************************************
-- Final Patient dataset
-- ****************************************************************************************************

SELECT distinct
	AttendanceIdentifier,
	LocalPatientIdentifier,
	NHSNumber,
	Surname,
	Forename,
	DateOfBirth,
	Gender,
	Title,
	NULL AS [Address],
	Address1,
	Address2,
	Address3,
	Address4,
	Address5,
	Postcode,
	RegisteredGP,
	RegisteredPractice,
	''West'' AS Area,
	''Pims'' AS Source,
	''OP'' AS Dataset,
	AttendanceIdentifier+''|Pims|OP'' AS PatientLinkId,
	NHSNumberStatus,
	LHBofResidence AS DHA,
	Ethnicity,
	null as DateOfDeath,
	LHBofResidence,
	null as TelephoneDaytime,
	null as TelephoneNighttime,
	null as TelephoneNightTime2,
	null as TelephoneMobile,
	null as EmailAddress,
	null as OverseasPatient,
	null as MaritalStatus,
	null as Disability,
	null as Religion,
	null as PreferredLanguage,
	null as Certified,
	null as CarerSupport,
	null AS RegisteredDentist,
	null AS RegisteredDentalPractice,
	null as AliasForename,
	null as AliasSurname,
	null as MaidenName,
	null as ConsentToInform,
	null as ConsentToInformOther,
	null AS LegalStatus
FROM
	@Results

')AT [7A1AUSRVIPMSQL];

END
GO
