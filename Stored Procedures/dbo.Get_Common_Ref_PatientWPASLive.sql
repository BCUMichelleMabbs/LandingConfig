SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientWPASLive]
AS
BEGIN
SET NOCOUNT ON;

Create TABLE #Results(
	LocalPatientIdentifier varchar(50)
	,Forename varchar(100)
	,Surname varchar(100)
	,DateOfBirth date
	,NHSNumber varchar(20)
	,Title varchar(10)
	,Sex varchar(10)
	,EthnicGroup varchar(50)
	,Address1 varchar(200)
	,Address2 varchar(100)
	,Address3 varchar(100)
	,Address4 varchar(100)
	,Postcode varchar(200)
	,StartDate date
	,EndDate date
	,Source varchar(50)
	,Type varchar(50)
	,[NursingHomeFlag] varchar(1)
	,[NursingHomeType] varchar(50)
	,[EMIFlag] varchar(1)
	,[NursingHomeName] varchar(200)
)

INSERT INTO #Results
(LocalPatientIdentifier
	,Forename
	,Surname
	,DateOfBirth
	,NHSNumber
	,Title
	,Sex
	,EthnicGroup
	,Address1
	,Address2
	,Address3
	,Address4
	,Postcode
	,StartDate 
	,EndDate 
	,Source 
	,Type
	,[NursingHomeFlag]
	,[NursingHomeType]
	,[EMIFlag]
	,[NursingHomeName]
	)


SELECT 
LocalPatientIdentifier
	,CASE WHEN Forename = ' ' then Null else Forename END as Forename
	,CASE WHEN surname = ' ' then null else Surname  END as Surname
	,CASE WHEN CONVERT(Date,DateOfBirth) is null then '1800-01-01' else CONVERT(Date,DateOfBirth) END  as DateOfBirth
	,CASE WHEN NHSNumber = ' ' then null else NHSNumber END AS NHSNumber
		,CASE WHEN Title = ' ' then null else Title END as Title
	,Sex
	,EthnicGroup
	,CASE WHEN CONVERT(varchar,Address1) = ' ' then null else Address1 END as Address1
	,CASE WHEN CONVERT(varchar,Address2) = ' ' then null else Address2 END as Address2
	,CASE WHEN CONVERT(varchar,Address3) = ' ' then null else Address3 END as Address3
	,CASE WHEN CONVERT(varchar,Address4) = ' ' then null else Address4 END as Address4
	,CASE WHEN CONVERT(varchar,Postcode) = ' ' then null else Postcode END as Postcode
	,CONVERT(date,StartDate) as StartDate
	,Null as EndDate
	,Source
	,Type
	,NULL AS [NursingHomeFlag]
	,NULL AS [NursingHomeType]
	,NULL AS [EMIFlag]
	,NULL AS [NursingHomeName]

 FROM OPENQUERY(WPAS_CENTRAL,'
SELECT DISTINCT
	Patient.caseno as LocalPatientIdentifier 
	,Patient.Forename as Forename
	,Patient.Surname as Surname 
	,Patient.Birthdate as DateOfBirth 
	,Patient.NHS as NHSNumber 
	,Patient.title as Title 
	,PATIENT.SEX as Sex 
	,e.descript as EthnicGroup 
	,Patient.Address as Address1 
	,'''' as Address2 
	,'''' as Address3 
	,'''' as Address4 
	,Patient.Postcode as Postcode 
	,Patient.Postcode_chandate as StartDate
	,'''' as EndDate
	,''WPAS'' as Source 
	,''EDAttendance'' AS Type

FROM 
	Patient patient
	JOIN TREATMNT T	on patient.caseno = t.caseno
	LEFT JOIN AANDE_DATA ED ON T.LINKID = ED.LINKID
	LEFT JOIN Ethnic e	on e.ethnic_code = patient.ethnic_origin

WHERE
	T.TRT_TYPE IN (''EC'',''ED'') 
	AND ED.ARRIVAL_DATE IS NOT NULL 
	AND (ED.DISCHARGE_DATE IS NULL or ED.Discharge_Date > Current_Timestamp -7) 
	AND t.disdate is null 
	AND Patient.CASENO IS NOT NULL

UNION

SELECT DISTINCT
     Patient.caseno as LocalPatientIdentifier 
    ,Patient.Forename as Forename
    ,Patient.Surname as Surname 
    ,Patient.Birthdate as DateOfBirth 
    ,Patient.NHS as NHSNumber 
    ,Patient.title as Title 
    ,PATIENT.SEX as Sex 
    ,e.descript as EthnicGroup 
    ,Patient.Address as Address1
	,'''' as Address2 
	,'''' as Address3 
	,'''' as Address4 
	,Patient.Postcode as Postcode 
	,Patient.Postcode_chandate as StartDate
	,'''' as EndDate
	,''WPAS'' as Source 
	,''InpatientLive'' AS Type

FROM master_trt t
LEFT JOIN PATIENT patient on MASTER_TRT.CASENO = PATIENT.CASENO
LEFT JOIN Ethnic e	on e.ethnic_code = patient.ethnic_origin 

WHERE MASTER_TRT.TRT_TYPE IN (''AC'',''AL'',''AE'')

	')




--Address Issue to Split Cent & East into 5 lines

/* ADDRESS */
declare @PatientFullAddress varchar(1000)
DECLARE addressCursor CURSOR FOR SELECT Address1 FROM #results where Source in ('WPAS','Myrddin')
	
OPEN addressCursor
FETCH NEXT FROM addressCursor INTO @PatientFullAddress

WHILE @@FETCH_STATUS=0
	BEGIN
		update #results set
		Address1 = PatAddress1,
		Address2 = PatAddress2,
		Address3 = PatAddress3,
		Address4 = PatAddress4
	
		FROM #results, SplitAddress(@PatientFullAddress) 
		WHERE CURRENT OF addressCursor

		FETCH NEXT FROM addressCursor INTO @PatientFullAddress
	END

CLOSE addressCursor
DEALLOCATE addressCursor


SELECT 
LocalPatientIdentifier
	,Forename
	,Surname
	,DateOfBirth
	,NHSNumber
	,Title
	,Sex
	,CASE WHEN EthnicGroup = ' ' then NULL else EthnicGroup END As EthnicGroup
	,CASE WHEN Address1 = ' ' then NULL else Address1 END As Address1
	,CASE WHEN Address2 = ' ' then NULL else Address2 END As Address2
	,CASE WHEN Address3 = ' ' then NULL else Address3 END As Address3
	,CASE WHEN Address4 = ' ' then NULL else Address4 END As Address4
	,Postcode
	,StartDate 
	,EndDate 
	,Source 
	,Type
	,[NursingHomeFlag]
	,[NursingHomeType]
	,[EMIFlag]
	,[NursingHomeName]

 FROM #Results 
drop table #Results 
END
GO
