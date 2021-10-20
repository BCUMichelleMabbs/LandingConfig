SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientMyrddin]
	
AS
BEGIN
	
	SET NOCOUNT ON;

Create TABLE #Results(
	LocalPatientIdentifier varchar(50)
	,Forename varchar(80)
	,Surname varchar(80)
	,DateOfBirth date
	,NHSNumber varchar(20)
		,Title varchar(30)
	,Sex varchar(30)
	,EthnicGroup varchar(50)
	,Address1 varchar(255)
	,Address2 varchar(100)
	,Address3 varchar(100)
	,Address4 varchar(100)
	,Postcode varchar(20)
	,StartDate date
	,EndDate date
	,Source varchar(20)
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
	,[Source]
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
	,NULL AS [NursingHomeFlag]
	,NULL AS [NursingHomeType]
	,NULL AS [EMIFlag]
	,NULL AS [NursingHomeName]


 FROM OPENQUERY([WPAS_EAST_SECONDARY],'
	SELECT
	DISTINCT
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
,''Myrddin'' as Source 

	

	FROM 
		Patient patient
		left outer join Ethnic e
		on e.ethnic_code = patient.ethnic_origin

				UNION 

		select 
			DISTINCT
	Patient.caseno as LocalPatientIdentifier 
	,Patient.Forename as Forename
	,Patient.Surname as Surname 
	,Patient.Birthdate as DateOfBirth 
	,Patient.NHS as NHSNumber 
		,Patient.title as Title 
	,PATIENT.SEX as Sex 
	,e.descript as EthnicGroup 
	,Ph.Address as Address1 
	,'''' as Address2 
	,'''' as Address3 
	,'''' as Address4 
	,Ph.Postcode as Postcode 
	,Ph.startdate as StartDate
	,ph.enddate as EndDate
,''Myrddin'' as Source 

	FROM 
		Patient patient
		left outer join Ethnic e
		on e.ethnic_code = patient.ethnic_origin
		left outer join Patient_AddressHistory ph
		on ph.caseno = patient.caseno

	')

	
--INSERT INTO #Results
--(LocalPatientIdentifier
--	,Forename
--	,Surname
--	,DateOfBirth
--	,NHSNumber
--	,Title
--	,Sex
--	,EthnicGroup
--	,Address1
--	,Address2
--	,Address3
--	,Address4
--	,Postcode
--	,StartDate 
--	,EndDate 
--	,Source 
--	)


--SELECT 
--LocalPatientIdentifier
--	,Forename
--	,Surname
--	,CONVERT(Date,DateOfBirth) as DateOfBirth
--	,NHSNumber
--		,Title
--	,Sex
--	,EthnicGroup
--	,Address1
--	,Address2
--	,Address3
--	,Address4
--	,Postcode
--	,CONVERT(date,StartDate) as StartDate
--	,Null as EndDate
--	,Source

--	---
-- FROM OPENQUERY(WPAS_East,'
--	SELECT
--	DISTINCT
--	Patient.caseno as LocalPatientIdentifier 
--	,Patient.Forename as Forename
--	,Patient.Surname as Surname 
--	,Patient.Birthdate as DateOfBirth 
--	,Patient.NHS as NHSNumber 
--		,Patient.title as Title 
--	,PATIENT.SEX as Sex 
--	,e.descript as EthnicGroup 
--	,Ph.Address as Address1 
--	,'''' as Address2 
--	,'''' as Address3 
--	,'''' as Address4 
--	,Ph.Postcode as Postcode 
--	,Ph.STARTDATE as StartDate
--	,ph.ENDDATE as EndDate
--,''MYRDDIN'' as Source 

	
--	FROM 
--		Patient patient
--		left outer join Ethnic e
--		on e.ethnic_code = patient.ethnic_origin
--		left outer join Patient_AddressHistory ph
--		on Patient.caseno = ph.caseno
--	')



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




SELECT * FROM #Results 

drop table #Results 

END
GO
