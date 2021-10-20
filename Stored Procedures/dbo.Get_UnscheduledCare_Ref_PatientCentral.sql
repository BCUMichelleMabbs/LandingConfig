SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_PatientCentral]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @LastAttendanceDate AS DATE = (SELECT ISNULL(MAX(ArrivalDate),'31 December 2010') FROM [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] WHERE Area='Central')
DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)
DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())
--DECLARE @DateToString AS VARCHAR(30) = '28 february 2021'


DECLARE @SQL AS NVARCHAR(MAX)
SET @SQL='SELECT * FROM (
SELECT * FROM OPENQUERY(WPAS_CENTRAL_Newport,''
	SELECT DISTINCT
		T.LINKID AS AttendanceIdentifier,
		T.CASENO AS LocalPatientIdentifier,
		NULLIF(P.NHS,'''''''') AS NHSNumber,
		P.SURNAME AS Surname,
		P.FORENAME AS Forename,
		CAST(P.BIRTHDATE AS DATE) AS DateOfBirth,
		P.SEX AS Gender,
		P.TITLE AS Title,
		CASE 
			WHEN T.TRT_DATE >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.ADDRESS
			ELSE (SELECT FIRST 1 ADDRESS FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND ED.ARRIVAL_DATE BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Address,
		NULL AS Address1,
		NULL AS Address2,
		NULL AS Address3,
		NULL AS Address4,
		NULL AS Address5,
		CASE 
			WHEN T.TRT_DATE >= CAST(P.POSTCODE_CHANDATE AS DATE) THEN P.POSTCODE
			ELSE (SELECT FIRST 1 POSTCODE FROM PATIENT_ADDRESSHISTORY PAH WHERE PAH.CASENO=T.CASENO AND ED.ARRIVAL_DATE BETWEEN PAH.STARTDATE AND PAH.ENDDATE ORDER BY SEQNO DESC)
		END AS Postcode,
		T.GP_TRT AS RegisteredGP,
		T.GP_PRAC AS RegisteredPractice,
		''''Central'''' AS Area,
		''''WPAS'''' AS Source,
		''''EDA'''' AS Dataset,
		T.LINKID||''''|Central|WPAS|EDA'''' AS PatientLinkId,
		NULLIF(P.CERTIFIED,'''''''') AS NHSNumberStatus,
		NULLIF(T.DHA_CODE,'''''''') AS DHA,
		P.ETHNIC_ORIGIN AS Ethnicity
	FROM 
		TREATMNT T
		LEFT JOIN AANDE_DATA ED ON T.LINKID=ED.LINKID
		LEFT JOIN PATIENT P ON T.CASENO = P.CASENO
		--LEFT JOIN PATIENT_ADDRESSHISTORY PAH ON T.CASENO=PAH.CASENO AND T.TRT_DATE BETWEEN PAH.STARTDATE AND PAH.ENDDATE
	WHERE
		T.TRT_TYPE IN(''''EC'''',''''ED'''') AND
		LEFT(ED.LINKID,2)!=''''XE'''' AND 
		ED.ARRIVAL_DATE >'''''+ @LastAttendanceDateString +''''' AND
		ED.ARRIVAL_DATE < '''''+@DateToString +'''''
'')M1
UNION ALL
SELECT 
	'''' AS AttendanceIdentifier,
	'''' AS LocalPatientIdentifier,
	'''' AS NHSNumber,
	'''' AS Surname,
	'''' AS Forename,
	'''' AS DateOfBirth,
	'''' AS Gender,
	'''' AS Title,
	'''' AS Address,
	'''' AS Address1,
	'''' AS Address2,
	'''' AS Address3,
	'''' AS Address4,
	'''' AS Address5,
	'''' AS Postcode,
	'''' AS RegisteredGP,
	'''' AS RegisteredPractice,
	'''' AS Area,
	'''' AS Source,
	'''' AS Dataset,
	'''' AS PatientLinkId,
	'''' AS NHSNumberStatus,
	'''' AS DHA,
	'''' AS Ethnicity
)M2
WHERE AttendanceIdentifier!='''''

EXEC SP_EXECUTESQL @SQL

END

GO
