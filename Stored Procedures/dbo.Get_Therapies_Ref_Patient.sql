SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Therapies_Ref_Patient]
	
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
	,Postcode varchar(20)
	,Source varchar(20)
	,PhoneWork varchar(20)
    ,PhoneHome varchar(20)
    ,PhoneMobile varchar(20)

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
	,Postcode
	,Source 
    ,PhoneWork
    ,PhoneHome
    ,PhoneMobile
	)


	(

select 
P.HOSPITALNUMBER as LocalPatientIdentifier
,P.FirstName as Forename
,P.Surname as Surname
,P.DATEOFFBIRTH as DateOfBirth
,p.NHSNUMBER as NHSNumber
,P.Title as Title
,P.Gender as Sex
,P.ETHNIC_ORIGIN as EthnicGroup
,P.ADDRESS as Address1
,P.Postcode as Postcode 
,'TherapyManager' as Source
,P.WORKPHONE as PhoneWork
,P.HOMEPHONE as PhoneHome
,P.MOBILEPHONE as PhoneMobile

from [SQL4\SQL4].[physio].[dbo].PATIENT p


)



SELECT * FROM #Results 
--drop table #Results 
END
GO
