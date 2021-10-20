SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_Patient_InpatientCentral]
	
AS
BEGIN
	
	SET NOCOUNT ON;

/*
NOTE: this data is loaded using a merge process, this means if the patients changes from being an inpatient then any records picked up in the process will remain in the patients table, resulting in extra patient in the patients table.
This issue will be looked at and an automated process put in place to delete these records.  KR 07/04/2020

*/


--DECLARE @LastAttendanceDate AS DATE = '01 january 2010'

DECLARE @LastAttendanceDate AS DATE = (SELECT 
													case	when max(LoadDate) = convert(date, getdate()) then (select min(DateEpisodeEnded) from [Foundation].[dbo].[PAS_Data_Inpatient] group by LoadDate having max(LoadDate) = convert(date, getdate()) )
															else  ISNULL(max(DateEpisodeEnded),'01 January 2010') 
															end
													FROM [Foundation].[dbo].[PAS_Data_Inpatient] WHERE source='wpas' and area = 'central')
DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)


--Episodes and Discharged Patients unioned with admissions

EXEC( '

		SELECT DISTINCT
		T.actnotekey AS AttendanceIdentifier,
		T.CASENO AS LocalPatientIdentifier,
		NULLIF(P.NHS,'''') AS NHSNumber,
		P.SURNAME AS Surname,
		P.FORENAME AS Forename,
		CAST(P.BIRTHDATE AS DATE) AS DateOfBirth,
		P.SEX AS Gender,
		P.TITLE AS Title,
		CASE 
			WHEN t.disdate >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.ADDRESS
			WHEN e.end_date = ''31 December 2999'' THEN P.ADDRESS
			when ah.caseno is null then P.ADDRESS
			ELSE (SELECT FIRST 1 ADDRESS FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND e.end_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Address,
		NULL AS Address1,
		NULL AS Address2,
		NULL AS Address3,
		NULL AS Address4,
		NULL AS Address5,
		CASE 
			WHEN t.disdate >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.POSTCODE
			WHEN e.end_date =  ''31 December 2999'' THEN P.POSTCODE
			when ah.caseno is null then P.POSTCODE
			ELSE (SELECT FIRST 1 POSTCODE FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND e.end_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Postcode,
		
		CASE 
			WHEN t.disdate >= CAST(p.GP_ChanDate AS DATE) THEN P.Registered_GP
			WHEN e.end_date = ''31 December 2999'' THEN P.Registered_GP
			when gp.caseno is null then P.Registered_GP
			ELSE (SELECT FIRST 1 P.Registered_GP FROM PATIENT_GPHISTORY GPH WHERE GPH.CASENO=T.CASENO AND e.end_date BETWEEN GPH.STARTDATE AND GPH.ENDDATE ORDER BY SEQNO DESC)
		END AS RegisteredGP,

				CASE 
			WHEN t.disdate >= CAST(p.GP_ChanDate AS DATE) THEN p.GP_Practice
			WHEN e.end_date = ''31 December 2999'' THEN p.GP_Practice
			when gp.caseno is null then p.GP_Practice
			ELSE (SELECT FIRST 1 p.GP_Practice FROM PATIENT_GPHISTORY GPH WHERE GPH.CASENO=T.CASENO AND e.end_date BETWEEN GPH.STARTDATE AND GPH.ENDDATE ORDER BY SEQNO DESC)
		END AS RegisteredPractice,
		''Central'' AS Area,
		''WPAS'' AS Source,
		''IPE'' AS Dataset,
		T.actnotekey||''|Central|''||  		Case
		when e.episodeno is not null then cast(e.episodeno as int)
				else ''0''
				end ||''|WPAS|IPE'' AS PatientLinkId,
		NULLIF(P.CERTIFIED,'''') AS NHSNumberStatus,
		NULLIF(T.DHA_CODE,'''') AS DHA,
		P.ETHNIC_ORIGIN AS Ethnicity ,

		
		
		p.DeathDate as DateOfDeath,

		CASE 
			WHEN t.disdate >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.DHA_CODE
			WHEN e.end_date =  ''31 December 2999'' THEN P.DHA_CODE
			when ah.caseno is null then P.DHA_CODE
			ELSE (SELECT FIRST 1 pah.DHA_CODE FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND e.end_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
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
			WHEN t.disdate >= CAST(p.Dentist_ChanDate AS DATE) THEN P.Dentist
			WHEN e.end_date = ''31 December 2999'' THEN P.Dentist
			when d.caseno is null then P.Dentist
			ELSE (SELECT FIRST 1 dh.registered_Dentist FROM PATIENT_DentalHISTORY DH WHERE DH.CASENO=T.CASENO AND e.end_date BETWEEN DH.STARTDATE AND DH.ENDDATE ORDER BY StartDate DESC)
		END AS RegisteredDentist,

		CASE 
			WHEN t.disdate >= CAST(p.Dentist_ChanDate AS DATE) THEN p.Dental_Practice
			WHEN e.end_date = ''31 December 2999'' THEN p.Dental_Practice
			when gp.caseno is null then p.GP_Practice
			ELSE (SELECT FIRST 1 dh.dental_practice FROM PATIENT_DentalHISTORY DH WHERE DH.CASENO=T.CASENO AND e.end_date BETWEEN DH.STARTDATE AND DH.ENDDATE ORDER BY StartDate DESC)
		END AS RegisteredDentalPractice,

		pm.Alias as AliasForename,
		pm.Alias_Surname as AliasSurname,
		pm.Maiden_Name as MaidenName,


		pm.Consent_to_inform as ConsentToInform,
		pm.Other_consent_to_Inform,

		CASE 
			WHEN  l.legalstatus is null then null
			else (SELECT FIRST 1 ls.legalstatus FROM legalstatus ls WHERE ls.CASENO=T.CASENO AND e.end_date BETWEEN ls.STARTDATE AND ls.ENDDATE ORDER BY StartDate DESC)
		END AS LegalStatus
		

	FROM 
		TREATMNT T
		LEFT JOIN PATIENT P ON T.CASENO = P.CASENO
		left join episode e on e.linkid = t.linkid and t.trt_Type like ''A%''
		left join patient_addresshistory ah on ah.caseno = t.caseno and ah.caseno is null
		left join PATIENT_GPHISTORY GP on gp.caseno = t.caseno and gp.caseno is null
		left Join Patient_DentalHistory D on d.caseno = t.caseno and d.caseno is null
		left join patient_misc pm on t.caseno = pm.caseno and pm.caseno is null
		left join legalstatus l on l.caseno = t.caseno and l.caseno is null 

		
	WHERE

		t.trt_Type like ''A%'' and 
		(e.end_date >=   ''' +@LastAttendanceDateString + '''   or		e.end_date is null 	)
	


Union




SELECT DISTINCT
		T.actnotekey AS AttendanceIdentifier,
		T.CASENO AS LocalPatientIdentifier,
		NULLIF(P.NHS,'''') AS NHSNumber,
		P.SURNAME AS Surname,
		P.FORENAME AS Forename,
		CAST(P.BIRTHDATE AS DATE) AS DateOfBirth,
		P.SEX AS Gender,
		P.TITLE AS Title,
		CASE 
			--WHEN t.trt_date >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.ADDRESS
			--WHEN e.end_date = ''31 December 2999'' THEN P.ADDRESS
			when ah.caseno is null then P.ADDRESS
			ELSE (SELECT FIRST 1 ADDRESS FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND t.trt_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Address,
		NULL AS Address1,
		NULL AS Address2,
		NULL AS Address3,
		NULL AS Address4,
		NULL AS Address5,
		CASE 
			--WHEN t.trt_date >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.POSTCODE
			--WHEN e.end_date =  ''31 December 2999'' THEN P.POSTCODE
			when ah.caseno is null then P.POSTCODE
			ELSE (SELECT FIRST 1 POSTCODE FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND t.trt_date BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Postcode,
		
		CASE 
			--WHEN t.trt_date >= CAST(p.GP_ChanDate AS DATE) THEN P.Registered_GP
			--WHEN e.end_date = ''31 December 2999'' THEN P.Registered_GP
			when gp.caseno is null then P.Registered_GP
			ELSE (SELECT FIRST 1 P.Registered_GP FROM PATIENT_GPHISTORY GPH WHERE GPH.CASENO=T.CASENO AND t.trt_date BETWEEN GPH.STARTDATE AND GPH.ENDDATE ORDER BY SEQNO DESC)
		END AS RegisteredGP,

				CASE 
			--WHEN t.trt_date >= CAST(p.GP_ChanDate AS DATE) THEN p.GP_Practice
			--WHEN e.end_date = ''31 December 2999'' THEN p.GP_Practice
			when gp.caseno is null then p.GP_Practice
			ELSE (SELECT FIRST 1 p.GP_Practice FROM PATIENT_GPHISTORY GPH WHERE GPH.CASENO=T.CASENO AND t.trt_date BETWEEN GPH.STARTDATE AND GPH.ENDDATE ORDER BY SEQNO DESC)
		END AS RegisteredPractice,
		''Central'' AS Area,
		''WPAS'' AS Source,
		''IPA'' AS Dataset,
		T.actnotekey||''|Central|''||  		Case
		when e.episodeno is not null then cast(e.episodeno as int)
				else ''0''
				end ||''|WPAS|IPA'' AS PatientLinkId,
		NULLIF(P.CERTIFIED,'''') AS NHSNumberStatus,
		NULLIF(T.DHA_CODE,'''') AS DHA,
		P.ETHNIC_ORIGIN AS Ethnicity ,
		
		

				DeathDate as DateOfDeath,

		CASE 
			--WHEN t.disdate >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.DHA_CODE
			--WHEN e.end_date =  ''31 December 2999'' THEN P.DHA_CODE
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
			--WHEN t.disdate >= CAST(p.Dentist_ChanDate AS DATE) THEN P.Dentist
			--WHEN e.end_date = ''31 December 2999'' THEN P.Dentist
			when d.caseno is null then P.Dentist
			ELSE (SELECT FIRST 1 dh.registered_Dentist FROM PATIENT_DentalHISTORY DH WHERE DH.CASENO=T.CASENO AND t.trt_date BETWEEN DH.STARTDATE AND DH.ENDDATE ORDER BY StartDate DESC)
		END AS RegisteredDentist,



		CASE 
			--WHEN t.disdate >= CAST(p.Dentist_ChanDate AS DATE) THEN p.Dental_Practice
			--WHEN e.end_date = ''31 December 2999'' THEN p.Dental_Practice
			when gp.caseno is null then p.Dental_Practice
			ELSE (SELECT FIRST 1 dh.dental_practice FROM PATIENT_DentalHISTORY DH WHERE DH.CASENO=T.CASENO AND t.trt_date BETWEEN DH.STARTDATE AND DH.ENDDATE ORDER BY StartDate DESC)
		END AS RegisteredDentalPractice,

		pm.Alias as AliasForename,
		pm.Alias_Surname as AliasSurname,
		pm.Maiden_Name as MaidenName,

		pm.Consent_to_inform as ConsentToInform,
		pm.Other_consent_to_Inform,

		CASE 
			WHEN  l.legalstatus is null then null
			else (SELECT FIRST 1 ls.legalstatus FROM legalstatus ls WHERE ls.CASENO=T.CASENO AND e.end_date BETWEEN ls.STARTDATE AND ls.ENDDATE ORDER BY StartDate DESC)
		END AS LegalStatus

	

	FROM 
		TREATMNT T
		LEFT JOIN PATIENT P ON T.CASENO = P.CASENO
		left join episode e on e.linkid = t.linkid and t.trt_Type like ''A%''
		left join patient_addresshistory ah on ah.caseno = t.caseno and ah.caseno is null
		left join PATIENT_GPHISTORY GP on gp.caseno = t.caseno and gp.caseno is null
		
		left Join Patient_DentalHistory D on d.caseno = t.caseno and d.caseno is null
		left join patient_misc pm on t.caseno = pm.caseno and pm.caseno is null
		left join legalstatus l on l.caseno = t.caseno and l.caseno is null 
		
		
	WHERE

		t.trt_Type like ''A%'' and 
		(e.end_date >=   ''' +@LastAttendanceDateString + '''   or		e.end_date is null )
		and e.episodeno = ''1''





		



' )AT [WPAS_Central];
END

GO
