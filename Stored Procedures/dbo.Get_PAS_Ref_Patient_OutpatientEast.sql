SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_Patient_OutpatientEast]
	
AS
BEGIN
	
	SET NOCOUNT ON;

/*
NOTE: this data is loaded using a merge process, this means if the patients changes from being an outpatient then any records picked up in the process will remain in the patients table, resulting in extra patient in the patients table.
This issue will be looked at and an automated process put in place to delete these records.  KR 07/04/2020

*/


--declare @lastattendancedate as date = '01 january 2018'
DECLARE @LastAttendanceDate AS DATE =(SELECT 
													case	when max(LoadDate) = convert(date, getdate()) then (select min(AppointmentDate) from [Foundation].[dbo].[PAS_Data_Outpatient] group by LoadDate having max(LoadDate) = convert(date, getdate()) )	
															else  ISNULL(max(AppointmentDate),'01 January 2010') 
															end
													FROM [Foundation].[dbo].[PAS_Data_Outpatient] WHERE source='myrddin' and AppointmentDate <> '2999-12-31' and AppointmentDate < CONVERT(date,getdate()))
DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)
DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())

DECLARE @SQL AS NVARCHAR(MAX)
SET @SQL='SELECT * from OPENQUERY(WPAS_East,
''
	SELECT DISTINCT
		T.actnotekey AS AttendanceIdentifier,
		T.CASENO AS LocalPatientIdentifier,
		NULLIF(P.NHS,'''''''') AS NHSNumber,
		P.SURNAME AS Surname,
		P.FORENAME AS Forename,
		CAST(P.BIRTHDATE AS DATE) AS DateOfBirth,
		P.SEX AS Gender,
		P.TITLE AS Title,
		CASE 
			WHEN T.TRT_DATE >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.ADDRESS
			ELSE (SELECT FIRST 1 ADDRESS FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND T.trt_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Address,
		NULL AS Address1,
		NULL AS Address2,
		NULL AS Address3,
		NULL AS Address4,
		NULL AS Address5,
		CASE 
			WHEN T.TRT_DATE >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.POSTCODE
			ELSE (SELECT FIRST 1 POSTCODE FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND T.trt_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Postcode,

		--T.GP_TRT AS RegisteredGP,
		--T.GP_PRAC AS RegisteredPractice,

		CASE 
			WHEN T.trt_date >= CAST(p.GP_ChanDate AS DATE) THEN P.Registered_GP
			WHEN T.trt_date = ''''31 December 2999'''' THEN P.Registered_GP
			when gp.caseno is null then P.Registered_GP
			ELSE (SELECT FIRST 1 P.Registered_GP FROM PATIENT_GPHISTORY GPH WHERE GPH.CASENO=T.CASENO AND T.trt_date BETWEEN GPH.STARTDATE AND GPH.ENDDATE ORDER BY SEQNO DESC)
		END AS RegisteredGP,

				CASE 
			WHEN T.trt_date >= CAST(p.GP_ChanDate AS DATE) THEN p.GP_Practice
			WHEN T.trt_date = ''''31 December 2999'''' THEN p.GP_Practice
			when gp.caseno is null then p.GP_Practice
			ELSE (SELECT FIRST 1 p.GP_Practice FROM PATIENT_GPHISTORY GPH WHERE GPH.CASENO=T.CASENO AND T.trt_date BETWEEN GPH.STARTDATE AND GPH.ENDDATE ORDER BY SEQNO DESC)
		END AS RegisteredPractice,
		''''East'''' AS Area,
		''''Myrddin'''' AS Source,
		''''OP'''' AS Dataset,
		T.actnotekey||''''|Myrddin|OP'''' AS PatientLinkId,
		NULLIF(P.CERTIFIED,'''''''') AS NHSNumberStatus,
		NULLIF(T.DHA_CODE,'''''''') AS DHA,
		P.ETHNIC_ORIGIN AS Ethnicity,
		
		DeathDate as DateOfDeath,


		CASE 
			WHEN T.trt_date >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.DHA_CODE
			WHEN T.trt_date =  ''''31 December 2999'''' THEN P.DHA_CODE
			when ah.caseno is null then P.DHA_CODE
			ELSE (SELECT FIRST 1 pah.DHA_CODE FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND t.trt_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS LHBOfResidence,
		
		p.Telephone_Day as TelephoneDaytime,
		p.Telephone_Night as TelephoneNighttime,
		p.Pat_tel_night as TelephoneNightTime2,
		p.MobileNo as TelephoneMobile,
		p.Email as EmailAddress,
		p.Overseas as OverseasPatient,
		p.Marital_Status as MaritalStatus,
		p.Disabled as Disability,
		p.Religion as Religion,
		p.Pref_lang as PreferredLanguage,
		p.Certified as Certified,
		p.Carer_Sup as CarerSupport,

		CASE 
			WHEN T.trt_date >= CAST(p.Dentist_ChanDate AS DATE) THEN P.Dentist
			WHEN T.trt_date = ''''31 December 2999'''' THEN P.Dentist
			when d.caseno is null then P.Dentist
			ELSE (SELECT FIRST 1 dh.registered_Dentist FROM PATIENT_DentalHISTORY DH WHERE DH.CASENO=T.CASENO AND t.trt_date BETWEEN DH.STARTDATE AND DH.ENDDATE ORDER BY StartDate DESC)
		END AS RegisteredDentist,



		CASE 
			WHEN T.trt_date >= CAST(p.Dentist_ChanDate AS DATE) THEN p.Dental_Practice
			WHEN T.trt_date = ''''31 December 2999'''' THEN p.Dental_Practice
			when gp.caseno is null then p.Dental_Practice
			ELSE (SELECT FIRST 1 dh.dental_practice FROM PATIENT_DentalHISTORY DH WHERE DH.CASENO=T.CASENO AND t.trt_date BETWEEN DH.STARTDATE AND DH.ENDDATE ORDER BY StartDate DESC)
		END AS RegisteredDentalPractice,

		pm.Alias as AliasForename,
		pm.Alias_Surname as AliasSurname,
		pm.Maiden_Name as MaidenName,

		pm.Consent_to_inform as ConsentToInform,
		pm.Other_consent_to_Inform as ConsentToInformOther,

		CASE 
			WHEN  l.legalstatus is null then null
			else (SELECT FIRST 1 ls.legalstatus FROM legalstatus ls WHERE ls.CASENO=T.CASENO AND T.trt_date BETWEEN ls.STARTDATE AND ls.ENDDATE ORDER BY StartDate DESC)
		END AS LegalStatus
	FROM 
		TREATMNT T
		LEFT JOIN PATIENT P ON T.CASENO = P.CASENO
		left join patient_addresshistory ah on ah.caseno = t.caseno and ah.caseno is null
		left join PATIENT_GPHISTORY GP on gp.caseno = t.caseno and gp.caseno is null
		
		left Join Patient_DentalHistory D on d.caseno = t.caseno and d.caseno is null
		left join patient_misc pm on t.caseno = pm.caseno and pm.caseno is null
		left join legalstatus l on l.caseno = t.caseno and l.caseno is null 
		
		
	WHERE
			T.TRT_DATE > ''''' +  @LastAttendanceDateString + '''''
			--T.TRT_DATE >= '''' 01 January 2010 ''''
			and TREATMNT.TRT_TYPE LIKE ''''O%''''
			and TREATMNT.TRT_TYPE <> ''''ON''''
			
'')'


exec sp_executesql @sql
END
GO
