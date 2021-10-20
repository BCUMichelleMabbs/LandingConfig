SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Radiology_Ref_Patient]
	
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT 
Address1
,Address2
,Address3
,Address4
,Address5
,Alias
,AlternatePhone as AlternatePhoneNumber
,DataProtectionFlag
,DataSharingFlag
,DataSource
,DateCreated
,DateFilmsCulled
,DateMerged
,DateOfBirth
,DeathDate as DeathDate
,DeceasedPatientFlag
,ElectronicallyValidated
,EmailAddress
,FilmsCulledFlag
,lan.Description as LanguagueDescription
,fk_Pregnancy_ID AS PregnancyID
,preg.PregnancyNumber
--,preg.fk_Patient_ID  --remove 
,prst.Description AS PregnancyStatus
,Forename
,HospitalNumber
,IncompleteDetailsFlag
,IsDummy
,LastUpdated
,LibraryFilingReference
,MaritalStatus
,MergedPatientStatus
,MobilePhoneNumber
,NHSNumber
,NHSNumberFormatted
,NHSNumberStatus
,NHSNumberStatusIndicator
,NHSNumberValidated
,PASCheckDigit
,pk_Patient_ID AS LocalPatientIdentifier
,Postcode
,RadisNumber
,SameNameFlag
,SameNameType
,Sex
,SpecialRequirements
,Surname
,SurnameSoundex
,TelephoneNumber
,TimeMerged
,Title
,TranslatorRequired
,P.RadisNumber+'|'+pk_Patient_ID +'|'+'Central'+'|'+'Radis' as PatientLinkID

 from [RADIS_CENTRAL].Radis.dbo.Patient P 	
             LEFT OUTER JOIN [RADIS_CENTRAL].Radis.dbo.Pregnancy AS preg  ON p.fk_Pregnancy_ID = preg.pk_Pregnancy_ID
            LEFT OUTER JOIN [RADIS_CENTRAL].Radis.dbo.PregnancyStatus AS prst ON preg.fk_PregnancyStatus_ID = prst.pk_PregnancyStatus_ID
			            LEFT OUTER JOIN [RADIS_CENTRAL].Radis.dbo.Language AS lan WITH ( NOLOCK ) ON p.fk_Language_ID = lan.pk_Language_ID



union all 



	SELECT 
Address1
,Address2
,Address3
,Address4
,Address5
,Alias
,AlternatePhone as AlternatePhoneNumber
,DataProtectionFlag
,DataSharingFlag
,DataSource
,DateCreated
,DateFilmsCulled
,DateMerged
,DateOfBirth
,DeathDate as DeathDate
,DeceasedPatientFlag
,ElectronicallyValidated
,EmailAddress
,FilmsCulledFlag
,lan.Description as LanguagueDescription
,fk_Pregnancy_ID AS PregnancyID
,preg.PregnancyNumber
--,preg.fk_Patient_ID  --remove 
,prst.Description AS PregnancyStatus
,Forename
,HospitalNumber
,IncompleteDetailsFlag
,IsDummy
,LastUpdated
,LibraryFilingReference
,MaritalStatus
,MergedPatientStatus
,MobilePhoneNumber
,NHSNumber
,NHSNumberFormatted
,NHSNumberStatus
,NHSNumberStatusIndicator
,NHSNumberValidated
,PASCheckDigit
,pk_Patient_ID AS LocalPatientIdentifier
,Postcode
,RadisNumber
,SameNameFlag
,SameNameType
,Sex
,SpecialRequirements
,Surname
,SurnameSoundex
,TelephoneNumber
,TimeMerged
,Title
,TranslatorRequired
,P.RadisNumber+'|'+pk_Patient_ID +'|'+'East'+'|'+'Radis' as PatientLinkID

 from [RADIS_East].Radis.dbo.Patient P 	
             LEFT OUTER JOIN [RADIS_East].Radis.dbo.Pregnancy AS preg  ON p.fk_Pregnancy_ID = preg.pk_Pregnancy_ID
            LEFT OUTER JOIN [RADIS_East].Radis.dbo.PregnancyStatus AS prst ON preg.fk_PregnancyStatus_ID = prst.pk_PregnancyStatus_ID
			            LEFT OUTER JOIN [RADIS_East].Radis.dbo.Language AS lan WITH ( NOLOCK ) ON p.fk_Language_ID = lan.pk_Language_ID


union all 



	SELECT 
Address1
,Address2
,Address3
,Address4
,Address5
,Alias
,AlternatePhone as AlternatePhoneNumber
,DataProtectionFlag
,DataSharingFlag
,DataSource
,DateCreated
,DateFilmsCulled
,DateMerged
,DateOfBirth
,DeathDate as DeathDate
,DeceasedPatientFlag
,ElectronicallyValidated
,EmailAddress
,FilmsCulledFlag
,lan.Description as LanguagueDescription
,fk_Pregnancy_ID AS PregnancyID
,preg.PregnancyNumber
--,preg.fk_Patient_ID  --remove 
,prst.Description AS PregnancyStatus
,Forename
,HospitalNumber
,IncompleteDetailsFlag
,IsDummy
,LastUpdated
,LibraryFilingReference
,MaritalStatus
,MergedPatientStatus
,MobilePhoneNumber
,NHSNumber
,NHSNumberFormatted
,NHSNumberStatus
,NHSNumberStatusIndicator
,NHSNumberValidated
,PASCheckDigit
,pk_Patient_ID AS LocalPatientIdentifier
,Postcode
,RadisNumber
,SameNameFlag
,SameNameType
,Sex
,SpecialRequirements
,Surname
,SurnameSoundex
,TelephoneNumber
,TimeMerged
,Title
,TranslatorRequired
,P.RadisNumber+'|'+pk_Patient_ID +'|'+'West'+'|'+'Radis' as PatientLinkID

 from [RADIS_West].Radis.dbo.Patient P 	
             LEFT OUTER JOIN [RADIS_West].Radis.dbo.Pregnancy AS preg  ON p.fk_Pregnancy_ID = preg.pk_Pregnancy_ID
            LEFT OUTER JOIN [RADIS_West].Radis.dbo.PregnancyStatus AS prst ON preg.fk_PregnancyStatus_ID = prst.pk_PregnancyStatus_ID
			            LEFT OUTER JOIN [RADIS_West].Radis.dbo.Language AS lan WITH ( NOLOCK ) ON p.fk_Language_ID = lan.pk_Language_ID

end
GO
