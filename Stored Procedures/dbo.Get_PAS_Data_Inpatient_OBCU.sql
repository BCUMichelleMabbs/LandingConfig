SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Get_PAS_Data_Inpatient_OBCU]
as
begin
SELECT 

'' as removeonceconnected

		--nullif(rtrim(PurchaserCode), '''') as Commissioner,
	 --   null as CommissionerType,
	 --   null AS GpRefNo,
		--nullif(rtrim(NHSno), '''') as NHSNumber,
		--Postcode as PostcodeAtTimeOfActivity,
		--LHBofResident as LHBOfResidence,
		--RegisteredGPCode as GPAtTimeOfActivity,
		--CRN as LocalPatientIdentifier,
		--ReferrerCode as Referrer,
		--ReferringOrganisation as ReferringOrganisation,
		--SpellNo as ProviderSpellNumber,
		--AdministrativeCategory as AdministrativeCategory,
		--AdmissionDate as DateAdmitted,
		--AdmissionMethod as AdmissionMethod,
		--IntendedManagement as IntendedManagement,
		--AdmissionSource as AdmissionSource,
		--DischargeDate as DateDischarged,
		--DischargeMethod as DischargeMethod,
		--DischargeDestination as DischargeDestination,
		--SubmittedPatClass as PatientClassification,
		--HRG as HealthcareResourceGroup,
		--Episodeno as EpisodeNumber,
		--LastEpiinSpell AS LastEpisodeInSpellIndicator,
		--ProvSiteCodeofTreatment as SiteCode,
		--WardType as WardTypeAtStartOfEpisode,
		--EpisodeStartDate as DateEpisodeStarted,
		--EpisodeEndDate as DateEpisodeEnded,
		--ConSpecCodeTreatment++LocalSpec as SpecialtyOfEpisode,
		--GMCConsultantCode as HCPOfEpisode,
		--PrincipalDiag as Diagnosis1,
		--SecondaryDiag1 as Diagnosis2,
		--SecondaryDiag2 as Diagnosis3,
		--SecondaryDiag3 as Diagnosis4,
		--SecondaryDiag4 as Diagnosis5,
		--SecondaryDiag5 as Diagnosis6,
		--SecondaryDiag6 as Diagnosis7,
		--SecondaryDiag7 as Diagnosis8,
		--SecondaryDiag8 as Diagnosis9,
		--SecondaryDiag9 as Diagnosis10,
		--SecondaryDiag10 as Diagnosis11,
		--SecondaryDiag11 as Diagnosis12,
		--SecondaryDiag12 as Diagnosis13,
		--'' as Diagnosis14,
		--HistDiag as HistologicalDiagnosis,
		--SourceofHistDiag as HistologicalDiagnosisSource,
		--PrinicipalOper as Procedure1,
		--DateOP1 as DateOfProcedure1,
		--Oper2 as Procedure2,
		--DateOP2 as DateOfProcedure2,
		--Oper3 as Procedure3,
		--DateOP3 as DateOfProcedure3,
		--Oper4 as Procedure4,
		--DateOP4 as DateOfProcedure4,
		--Oper5 as Procedure5,
		--DateOP5 as DateOfProcedure5,
		--Oper6 as Procedure6,
		--DateOP6 as DateOfProcedure6,
		--Oper7 as Procedure7,
		--DateOP7 as DateOfProcedure7,
		--Oper8 as Procedure8,
		--DateOP8 as DateOfProcedure8,
		--Oper9 as Procedure9,
		--DateOP9 as DateOfProcedure9,
		--Oper10 as Procedure10,
		--DateOP10 as DateOfProcedure10,
		--Oper11 as Procedure11,
		--DateOP11 as DateOfProcedure11,
		--Oper12 as Procedure12,
		--DateOP12 as DateOfProcedure12,
		--'' as DateOnSystem,
		--RegisteredGPPractice as GPPracticeAtTimeOfActivity,
		--'' as DateReferred,
		--'' as DateOfNextApproximateAppointment,
		--'' as DateEstimatedOfDischarge,
		--'' as PriorityOfHCP,
		--'' as WardOnAdmission,
		--'' as Ward,
		--'' AS TimeOfArrival,
		--'' AS TimeLeft,
		--'' as OutcomeOfAdmission,
		--'' as UniquePathwayIdentifier,
		--'' as SystemLinkID,
		--'' AS TimeOfAdmission,
		--'' as HCPOnAdmission,
		--GMCConsultantCode as HCP,
		--'' as SpecialtyOnAdmission,
		--ConSpecCodeTreatment++LocalSpec as Specialty,
		--'' as TreatmentType,
		--'' as OutcomeOfAdmissionLocal,
		--'' as EventType,
		--'' as EventSource,
		--'' as Actnotekey,
		--'OBCU' as Area,


		--case 
		--	when ProviderUnitCode in ('7A1', '7A100', 'RT7', 'RT8', 'RT9', 'RYP') then 'BCU'
		--	when ProviderUnitCode in ('7A2', '7A200', 'RYN') then 'HywelDda'
		--	when ProviderUnitCode in ('7A3', '7A300') then 'ABMU'
		--	when ProviderUnitCode in ('7A4', '7A400') then 'Carddiff'
		--	when ProviderUnitCode in ('7A5', '7A500') then 'CwmTaf'
		--	when ProviderUnitCode in ('7A6', '7A600') then 'AneurinBevan'
		--	when ProviderUnitCode in ('7A7', '7A700') then 'Powys'
		--	when ProviderUnitCode in ('RJR', 'RJR00') then 'Chester'
		--	when ProviderUnitCode in ('R1D') then 'Shropshire'
		--	when ProviderUnitCode in ('RL1') then 'RJAH'
		--	when ProviderUnitCode in ('RBS') then 'Alderhey'
		--	when ProviderUnitCode in ('RET', 'REP') then 'Liverpool'
		--	when ProviderUnitCode in ('RQ6') then 'Broadgreen'
		--	when ProviderUnitCode in ('RBN') then 'StHelens'
		--	when ProviderUnitCode in ('RBL') then 'Wirral'
		--	when ProviderUnitCode in ('REM') then 'Aintree'
		--	when ProviderUnitCode in ('RXW') then 'Shrewsbury'
		--	when ProviderUnitCode in ('RW3', 'RM2') then 'Manchester'
		--	when ProviderUnitCode in ('RBV') then 'Christie'
		--	when ProviderUnitCode in ('REN') then 'Clatterbridge'
		--	when ProviderUnitCode in ('RJE') then 'Midlands'
		--	when ProviderUnitCode in ('RM3') then 'Salford'
		--	when ProviderUnitCode in ('RM3', 'TAH') then 'Sheffield'
		--	when ProviderUnitCode in ('RWW') then 'Warrington'
		--	when ProviderUnitCode in ('RRK') then 'Birmingham'
		--	when ProviderUnitCode in ('RBT') then 'Cheshire'

		--else 'OBCU'
		--end as Area,



		--'NWIS' as Source,
		--'' as SiteDischargedTo,
		--LHBofPractice as LHBOfGP,
		--'' as DateNotified,
		--'' as DateAmendedOutcome,
		--'' as UserAmendedOutcome,
		--'' as CancelReasonTheatre,
		--'' as OutcomeOfReferral,
		--'' as OffListReason,
		--'' as OffListReasonLocal,
		--SubsidiaryDiag as SubsidiaryDiagnosis



  
--from         [GIG06CLSSQL4003\nationaldb].[DW_Extracts].[grp07].[APC_Extract]

----Where        EpisodeEndDate between @Datestart and @DateEnd
------ Where        EpisodeEndDate between '01 Apr 2014 00:00:00' and '31 Jan 2015 23:59:59'
----and          (PatientResidentProvidedElsewhereFlag = 1 or PatientRegisteredProvidedElsewhereFlag = 1)
----and          ProvUnitCode Not Like '7A1%'

 FROM [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].[dbo].apc_general g
  where g.Research1 = 'Cent'
  and g.EpisodeEndDate < '21 Nov 2016'
  and g.EpisodeEndDate >='01 Jan 2010'

  end


  

	
GO
