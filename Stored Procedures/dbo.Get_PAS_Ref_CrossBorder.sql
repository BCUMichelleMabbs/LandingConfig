SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_CrossBorder]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	PostcodeAtTimeOfActivity		VARCHAR(20),
	GPPracticeAtTimeOfActivity		VARCHAR(20),
	PatientLinkIdEpisode			VARCHAR(100),
	OrganisationOfPostcode			varchar(20),
	OrganisationOfGP				varchar(20),
	OrganisationCode				VARCHAR(20),
	Responsibility					varchar(50)
	
)



INSERT INTO @Results(postcodeattimeofactivity, GPPracticeAtTimeOfActivity, PatientLinkIdEpisode, ORGANISATIONOfPostcode, OrganisationOfGP, OrganisationCode, Responsibility)	
SELECT	I.PostcodeAtTimeOfActivity, 
		I.GPPracticeAtTimeOfActivity, 
		I.PatientLinkIdEpisode,
		CBP.Organisation as OrganisationOfPostcode,
		CBG.Organisation as OrganisationOfGP,
		Null as OrganisationCode,
		Null as Responsibility
from foundation.dbo.pas_data_Inpatient I
left join [mapping].[dbo].[common_crossborder] cbp on replace(cbp.postcode, ' ', '') = replace(i.postcodeattimeofactivity, ' ', '')
left join [mapping].[dbo].[common_crossborder] cbg on cbg.postcode = i.GPPracticeAtTimeOfActivity

where I.DateDischarged = '01 april 2019'




	UPDATE @Results SET OrganisationCode =
	case 

	when OrganisationOfPostcode like '7%' and OrganisationOfGP like '7%'  then OrganisationOfPostcode
	when OrganisationOfPostcode like '7%' and OrganisationOfGP not like '7%'  then OrganisationOfPostcode
	when OrganisationOfPostcode like '7%' and OrganisationOfGP is null  then OrganisationOfPostcode

	when OrganisationOfPostcode not like '7%' and OrganisationOfGP like '7%'  then OrganisationOfPostcode
		when OrganisationOfPostcode not like '7%' and OrganisationOfGP not like '7%'  then OrganisationOfGP
	when OrganisationOfPostcode not like '7%' and OrganisationOfGP is null  then OrganisationOfPostcode

	when OrganisationOfPostcode is null and OrganisationOfGP like '7%'  then OrganisationOfGP
	when OrganisationOfPostcode is null and OrganisationOfGP  not like '7%'  then OrganisationOfGP

	when OrganisationOfPostcode is null and OrganisationOfGP is null  then Null
			

	else null
	end 


	UPDATE @Results SET Responsibility =
	case 

	when OrganisationOfPostcode like '7%' and OrganisationOfGP like '7%'  then 'Welsh Postcode and Welsh GP'
	when OrganisationOfPostcode like '7%' and OrganisationOfGP not like '7%'  then 'Welsh Postcode and English GP'
	when OrganisationOfPostcode like '7%' and OrganisationOfGP is null  then 'Welsh Postcode No GP'

	when OrganisationOfPostcode not like '7%' and OrganisationOfGP like '7%'  then 'English Postcode and Welsh GP'
	when OrganisationOfPostcode not like '7%' and OrganisationOfGP not like '7%'  then 'English Postcode and English GP'
	when OrganisationOfPostcode not like '7%' and OrganisationOfGP is null  then 'English Postcode No GP'

	when OrganisationOfPostcode is null and OrganisationOfGP like '7%'  then 'No Postcode and Welsh GP'
	when OrganisationOfPostcode is null and OrganisationOfGP  not like '7%'  then 'No Postcode and English GP'

	when OrganisationOfPostcode is null and OrganisationOfGP is null  then 'No Postcode and No GP'
	
			

	else null
	end 


FROM
	@Results R
	--INNER JOIN Mapping.dbo.PAS_Session_Map SM ON R.LocalCode=SM.LocalCode AND R.Source=SM.Source
	--INNER JOIN Mapping.dbo.PAS_OtherInformation S ON RTRIM(r.MainCode)=rtrim(S.MainCode)


SELECT distinct * FROM @Results
--where organisationofPostcode is not null
--where organisationOfGP is not null
--where OrganisationCode is not null
--where Responsibility is null

--order by LocalCode
END
GO
