SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientMyrddinKR_DONOTUSE]
	
AS
BEGIN

SET NOCOUNT ON;

declare @sql as varchar(max)

-- KEYNOTE needs adding

 set @sql = 'SELECT * FROM OPENQUERY([WPAS_EAST], ''
 Select DISTINCT
 --Current Patient Detail
		P.caseno as LocalPatientIdentifier, 
		P.NHS as NHSNumber,
		p.Certified as NHSNumberStatus,
		P.title as Title, 
		P.Forename as Forename,
		P.Surname as Surname,
		p.Alias as ForenamePrevious,
		p.Maiden_Name as SurnameMaiden,
		p.Alias_Surname as SurnamePrevious,
		P.Birthdate as DateOfBirth, 
		p.deathdate, 
		P.SEX as Sex, 
		e.descript as EthnicGroup,
		Overseas as OverseasVisitor,
		p.address as Address1, 
		'''''''' as Address2, 
		'''''''' as Address3, 
		'''''''' as Address4, 
		p.postcode,
		p.dha_code as LHBOfResidence,
		case when p.postcode_ChanDate < p.GP_ChanDate then p.Registered_GP else gp.Registered_GP end as Gp,
		case when p.postcode_ChanDate < p.GP_ChanDate then p.GP_Practice else gp.Registered_GP end as GPPractice,
		p.Telephone_Day as TelephoneDaytime,
		p.Telephone_Night as TelephoneNighttime,
		p.MobileNo as TelephoneMobile,
		p.email as EmailAddress,
		p.Marital_Status as MartialStatus,
		p.Disabled as Disabled,
		p.Religion as Religion,
		p.Pref_Lang as PreferredLanguage,
		p.Carer_Sup as CarerSupportIndicator,
		p.Suppid as PreviousPatientIdentifier,
		case when p.postcode_ChanDate < p.GP_ChanDate then p.postcode_ChanDate else p.GP_ChanDate end as StartDate,
		case when p.GP_ChanDate > p.postcode_ChanDate then gp.EndDate else null end as EndDate,
		''''Myrddin'''' as Source,
		Case When p.GP_ChanDate > p.postcode_ChanDate then ''''Y'''' else ''''N'''' end as ActiveRecord 
FROM 
		Patient p
		left join Ethnic e on e.ethnic_code = p.ethnic_origin
		left join Patient_GPHistory gp on P.caseno = gp.caseno and gp.Registered_Gp = p.Registered_GP

Union Select DISTINCT
--Historic Patient Detail
		P.caseno as LocalPatientIdentifier, 
		P.NHS as NHSNumber,
		p.Certified as NHSNumberStatus,
		P.title as Title, 
		P.Forename as Forename,
		P.Surname as Surname,
		p.Alias as ForenamePrevious,
		p.Maiden_Name as SurnameMaiden,
		p.Alias_Surname as SurnamePrevious,
		P.Birthdate as DateOfBirth, 
		p.deathdate, 
		P.SEX as Sex, 
		e.descript as EthnicGroup,
		Overseas as OverseasVisitor,
		ph.address as Address1, 
		null as Address2, 
		null as Address3, 
		null as Address4, 
		ph.postcode,
		ph.dha_code as LHBOfResidence,
		case when p.postcode_ChanDate < p.GP_ChanDate then p.Registered_GP else gp.Registered_GP end as Gp,
		case when p.postcode_ChanDate < p.GP_ChanDate then p.GP_Practice else gp.Registered_GP end as GPPractice,
		p.Telephone_Day as TelephoneDaytime,
		p.Telephone_Night as TelephoneNighttime,
		p.MobileNo as TelephoneMobile,
		p.email as EmailAddress,
		p.Marital_Status as MartialStatus,
		p.Disabled as Disabled,
		p.Religion as Religion,
		p.Pref_Lang as PreferredLanguage,
		p.Carer_Sup as CarerSupportIndicator,
		p.Suppid as PreviousPatientIdentifier,
		Ph.StartDate as StartDate,
		ph.ENDDATE as EndDate,
		''''Myrddin'''' as Source,
		Case When p.GP_ChanDate < p.postcode_ChanDate then ''''Y'''' else ''''N'''' end as ActiveRecord 
	FROM 
		Patient p
		left join Ethnic e on e.ethnic_code = p.ethnic_origin
		left join Patient_AddressHistory ph on P.caseno = ph.caseno
		left join Patient_GPHistory gp on P.caseno = gp.caseno and gp.Registered_Gp <> p.Registered_GP
'' )'



	Declare @Results TABLE (
	LocalPatientIdentifier	varchar(50)
	,NHSNumber				varchar(20)
	,NHSNumberStatus		varchar(2)
	,Title					varchar(30)
	,Forename				varchar(80)
	,Surname				varchar(80)
	,ForenamePrevious		varchar(80)
	,SurnameMaiden			varchar(80)
	,SurnamePrevious		varchar(80)
	,DateOfBirth			date
	,DateOfDeath			date
	,Sex					varchar(30)
	,EthnicGroup			varchar(50)
	,OverseasVisitor		varchar(2)
	,Address1				varchar(255)
	,Address2				varchar(100)
	,Address3				varchar(100)
	,Address4				varchar(100)
	,Postcode				varchar(8)
	,LHBOfResidence			varchar(3)
	,GP						varchar(20)
	,GPPractice				varchar(20)
	,TelephoneDaytime		varchar(50)
	,TelephoneNighttime		varchar(50)
	,TelephoneMobile		varchar(50)
	,EmailAddress			varchar(50)
	,MaritalStatus			varchar(2)
	,Disabled				varchar(50)
	,Religion				varchar(2)
	,PreferredLanguage		varchar(2)
	,CarerSupportIndicator	varchar(50)
	,PreviousPatientIdentifier	varchar(255)
	,StartDate				date
	,EndDate				date
	,Source					varchar(20),
	Active					varchar(1)







)


Insert into @results(
	LocalPatientIdentifier	
	,NHSNumber				
	,NHSNumberStatus		
	,Title					
	,Forename				
	,Surname				
	,ForenamePrevious		
	,SurnameMaiden			
	,SurnamePrevious		
	,DateOfBirth			
	,DateOfDeath			
	,Sex					
	,EthnicGroup			
	,OverseasVisitor		
	,Address1				
	,Address2				
	,Address3				
	,Address4				
	,Postcode				
	,LHBOfResidence			
	,GP						
	,GPPractice				
	,TelephoneDaytime		
	,TelephoneNighttime		
	,TelephoneMobile		
	,EmailAddress			
	,MaritalStatus			
	,Disabled				
	,Religion				
	,PreferredLanguage		
	,CarerSupportIndicator	
	,PreviousPatientIdentifier
	,StartDate				
	,EndDate				
	,Source,
	Active					
	)

	exec (@sql)



--Address Issue to Split Cent & East into 5 lines

/* ADDRESS */
declare @PatientFullAddress varchar(1000)
DECLARE addressCursor CURSOR FOR SELECT Address1 FROM @Results where Source in ('Myrddin')
	
OPEN addressCursor
FETCH NEXT FROM addressCursor INTO @PatientFullAddress

WHILE @@FETCH_STATUS=0
	BEGIN
		update @Results set
		Address1 = PatAddress1,
		Address2 = PatAddress2,
		Address3 = PatAddress3,
		Address4 = PatAddress4
	
		FROM @Results, SplitAddress(@PatientFullAddress) 
		WHERE CURRENT OF addressCursor

		FETCH NEXT FROM addressCursor INTO @PatientFullAddress
	END

CLOSE addressCursor
DEALLOCATE addressCursor

SELECT 
	
	LocalPatientIdentifier
	,CASE WHEN NHSNumber = ' ' then null else NHSNumber END AS NHSNumber
	,NHSNumberStatus
	,CASE WHEN Title = ' ' then null else Title END as Title
	,CASE WHEN Forename = ' ' then Null else Forename END as Forename
	,CASE WHEN surname = ' ' then null else Surname  END as Surname
	,ForenamePrevious		
	,SurnameMaiden			
	,SurnamePrevious
	,CASE WHEN CONVERT(Date,DateOfBirth) is null then '1800-01-01' else CONVERT(Date,DateOfBirth) END  as DateOfBirth
	,DateOfDeath
	,CASE WHEN Title = ' ' then null else Title END as Title
	,Sex
	,EthnicGroup
	,OverseasVisitor		
	,CASE WHEN CONVERT(varchar,Address1) = ' ' then null else Address1 END as Address1
	,CASE WHEN CONVERT(varchar,Address2) = ' ' then null else Address2 END as Address2
	,CASE WHEN CONVERT(varchar,Address3) = ' ' then null else Address3 END as Address3
	,CASE WHEN CONVERT(varchar,Address4) = ' ' then null else Address4 END as Address4
	,CASE WHEN CONVERT(varchar,Postcode) = ' ' then null else Postcode END as Postcode
	,LHBOfResidence			
	,GP						
	,GPPractice				
	,TelephoneDaytime		
	,TelephoneNighttime		
	,TelephoneMobile		
	,EmailAddress			
	,MaritalStatus			
	,Disabled				
	,Religion				
	,PreferredLanguage		
	,CarerSupportIndicator	
	,PreviousPatientIdentifier
	,CONVERT(date,StartDate) as StartDate
	,EndDate
	,Source,
	Active

FROM @Results 

where NHSNumber = '4963497778'
END
GO
