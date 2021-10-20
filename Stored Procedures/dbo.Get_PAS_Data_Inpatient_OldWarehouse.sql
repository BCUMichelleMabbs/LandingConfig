SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_PAS_Data_Inpatient_OldWarehouse]
as
begin
SELECT 

		nullif(rtrim(g.CommissionerCode), '') as Commissioner,
	    null as CommissionerType,
	    null AS GpRefNo,
		nullif(rtrim(g.NHSNumberNew), '') as NHSNumber,
		nullif(rtrim(g.PostCodeUsualAddress), '') as PostcodeAtTimeOfActivity,
		nullif(rtrim(g.LocalAuthority), '') as LHBOfResidence,
		nullif(rtrim(g.RegGPCode), '') as GPAtTimeOfActivity,
		nullif(rtrim(g.PatientIdentifier), '') as LocalPatientIdentifier,
		nullif(rtrim(g.ReferrerCode), '') as Referrer,
		nullif(rtrim(g.ReferrerOrgCode), '') as ReferringOrganisation,
		nullif(rtrim(g.spellnumber), '') as ProviderSpellNumber,
		nullif(rtrim(g.PatientCategory), '') as AdministrativeCategory,
		nullif(rtrim(cast(g.SpellStartDate as date)), '') as DateAdmitted,
		nullif(rtrim(g.AdmissionMethod), '') as AdmissionMethod,
		nullif(rtrim(g.IntendedManagement), '') as IntendedManagement,
		nullif(rtrim(g.AdmissionSource), '') as AdmissionSource,
		nullif(rtrim(cast(g.DischargeDate as date)), '') as DateDischarged,
		nullif(rtrim(g.DischargeMethod), '') as DischargeMethod,
		nullif(rtrim(g.DischargeDestination), '') as DischargeDestination,
		nullif(rtrim(g.PatientClassification), '') as PatientClassification,
		nullif(rtrim(g.Derived_HRG), '') as HealthcareResourceGroup,
		nullif(rtrim(g.EpisodeOrder), '') as EpisodeNumber,
		nullif(rtrim(g.LastEpisodeInSpell), '') AS LastEpisodeInSpellIndicator,
		nullif(rtrim(g.TreatmentSiteCode), '') as SiteCode,
		nullif(ltrim(rtrim(g.StartWardType)), '') as WardTypeAtStartOfEpisode,
		nullif(rtrim(cast(g.EpisodeStartDate as date)), '') as DateEpisodeStarted,
		nullif(rtrim(cast(g.EpisodeEndDate as date)), '') as DateEpisodeEnded,
		nullif(rtrim(g.SpecialtyCode++g.LocalSubSpecialty), '') as SpecialtyOfEpisode,
		nullif(rtrim(g.ConsultantCode), '') as HCPOfEpisode,
		nullif(rtrim(d1.ICD10DiagnosisCode), '') as Diagnosis1,
		nullif(rtrim(d2.ICD10DiagnosisCode), '') as Diagnosis2,
		nullif(rtrim(d3.ICD10DiagnosisCode), '') as Diagnosis3,
		nullif(rtrim(d4.ICD10DiagnosisCode), '') as Diagnosis4,
		nullif(rtrim(d5.ICD10DiagnosisCode), '') as Diagnosis5,
		nullif(rtrim(d6.ICD10DiagnosisCode), '') as Diagnosis6,
		nullif(rtrim(d7.ICD10DiagnosisCode), '') as Diagnosis7,
		nullif(rtrim(d8.ICD10DiagnosisCode), '') as Diagnosis8,
		nullif(rtrim(d9.ICD10DiagnosisCode), '') as Diagnosis9,
		nullif(rtrim(d10.ICD10DiagnosisCode), '') as Diagnosis10,
		nullif(rtrim(d11.ICD10DiagnosisCode), '') as Diagnosis11,
		nullif(rtrim(d12.ICD10DiagnosisCode), '') as Diagnosis12,
		null as Diagnosis13,
		null as Diagnosis14,
		nullif(ltrim(rtrim(l.HistologicalDiagnosis)), '') as HistologicalDiagnosis,
		nullif(rtrim(l.sourceofhistologicaldiagnosis), '') as HistologicalDiagnosisSource,

		nullif(rtrim(p1.OPCS4ProcedureCode), '') as Procedure1,
		nullif(rtrim(cast(p1.OPCS4ProcedureDate as date)), '') as DateOfProcedure1,
		nullif(rtrim(p2.OPCS4ProcedureCode), '') as Procedure2,
		nullif(rtrim(cast(p2.OPCS4ProcedureDate as Date)), '') as DateOfProcedure2,
		nullif(rtrim(p3.OPCS4ProcedureCode), '') as Procedure3,
		nullif(rtrim(cast(p3.OPCS4ProcedureDate as date)), '') as DateOfProcedure3,
		nullif(rtrim(p4.OPCS4ProcedureCode), '') as Procedure4,
		nullif(rtrim(cast(p4.OPCS4ProcedureDate as date)), '') as DateOfProcedure4,
		nullif(rtrim(p5.OPCS4ProcedureCode), '') as Procedure5,
		nullif(rtrim(cast(p5.OPCS4ProcedureDate as date)), '') as DateOfProcedure5,
		nullif(rtrim(p6.OPCS4ProcedureCode), '') as Procedure6,
		nullif(rtrim(cast(p6.OPCS4ProcedureDate as date)), '') as DateOfProcedure6,
		nullif(rtrim(p7.OPCS4ProcedureCode), '') as Procedure7,
		nullif(rtrim(cast(p7.OPCS4ProcedureDate as date)), '') as DateOfProcedure7,
		nullif(rtrim(p8.OPCS4ProcedureCode), '') as Procedure8,
		nullif(rtrim(cast(p8.OPCS4ProcedureDate as date)), '') as DateOfProcedure8,
		nullif(rtrim(p9.OPCS4ProcedureCode), '') as Procedure9,
		nullif(rtrim(cast(p9.OPCS4ProcedureDate as date)), '') as DateOfProcedure9,
		nullif(rtrim(p10.OPCS4ProcedureCode), '') as Procedure10,
		nullif(rtrim(cast(p10.OPCS4ProcedureDate as date)), '') as DateOfProcedure10,
		nullif(rtrim(p11.OPCS4ProcedureCode), '') as Procedure11,
		nullif(rtrim(cast(p11.OPCS4ProcedureDate as date)), '') as DateOfProcedure11,
		nullif(rtrim(p12.OPCS4ProcedureCode), '') as Procedure12,
		nullif(rtrim(cast(p12.OPCS4ProcedureDate as date)), '') as DateOfProcedure12,

		case when l.dateonlist = '' then null
		else
		nullif(rtrim(try_cast(l.DateOnList as date)), '')
		end  as DateOnSystem,
		
		nullif(rtrim(g.RegPracticeCode), '') as GPPracticeAtTimeOfActivity,
		nullif(rtrim(cast(g.DecidedToAdmitDate as date)), '') as DateReferred,
		null as DateOfNextApproximateAppointment,
		nullif(rtrim(cast(g.DischargeReadyDate as date)), '') as DateEstimatedOfDischarge,
		nullif(rtrim(l.WLPriorityCode), '') as PriorityOfHCP,
		nullif(rtrim(l.AdmittingWard), '') as WardOnAdmission,
		nullif(rtrim(l.WardCode), '') as Ward,
		null AS TimeOfArrival,
		nullif(rtrim(cast(l.DischargeTime as time)), '') AS TimeLeft,
		null as OutcomeOfAdmission,
		nullif(rtrim(g.PathwayID), '') as UniquePathwayIdentifier,
		null as SystemLinkID,
		nullif(rtrim(cast(l.AdmissionTime as time)), '') AS TimeOfAdmission,
		null as HCPOnAdmission,
		nullif(rtrim(g.ConsultantCode), '') as HCP,
		null as SpecialtyOnAdmission,
		nullif(rtrim(g.SpecialtyCode++g.LocalSubSpecialty), '') as Specialty,
		null as TreatmentType,
		nullif(rtrim(l.LocalOutcomeCode), '') as OutcomeOfAdmissionLocal,
		null as EventType,
		null as EventSource,
		null as Actnotekey,
		'Central' as Area,
		'OldWH' as Source,
		nullif(rtrim(l.DischargeActualLocation), '') as SiteDischargedTo,
		null as LHBOfGP,
		null as DateNotified,
		null as DateAmendedOutcome,
		null as UserAmendedOutcome,
		null as CancelReasonTheatre,
		null as OutcomeOfReferral,
		null as OffListReason,
		null as OffListReasonLocal,
		null as SubsidiaryDiagnosis,
		nullif(rtrim(g.legalstatus), '') as LegalStatus,
		
		floor(datediff(dd, g.birthdate, g.spellstartdate)/365.25) as AgeOnAdmission,
		
		case when g.dischargedate is not null then floor(datediff(dd, g.birthdate, g.dischargedate)/365.25) 
		else null end as AgeOnDischarge,
		
		Case when g.dischargedate is not null then datediff(dd, g.spellstartdate, g.dischargedate )
		else null 
		end as DaysInSpell,

		case 
		 when g.episodeenddate = '31 december 2999' then null
		 when g.episodeenddate is not null then datediff(dd, g.episodestartdate, g.episodeenddate)
		 else  null
		end as DaysInEpisode,

		case 
		when g.dischargedate is null  then null
		when g.spellstartdate is null then null
		when len(l.dischargetime) < 4 then 
				case when datediff(dd, g.spellstartdate, g.dischargedate) <= 1 then 'Y'
				else 'N' End
		when l.admissiontime is null then 
				case when datediff(dd, g.spellstartdate, g.dischargedate) <= 1 then 'Y'
				else 'N' End
		when datediff(dd, (g.spellstartdate +' '+ l.admissiontime), (g.dischargedate +' '+ l.dischargetime))  <= 1 then 'Y' 
		else 'N'
		end as DischargedWithin24Hrs,

		null as PDDBreach,
		null AS PDD,
		null  as OPDD,
		null as MFD ,
		NULL AS DayCaseCleansed


  FROM [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].[dbo].apc_general g left join
	[7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].[dbo].apc_Locals l on l.APCJoinKey = g.APCJoinKey  left join
	[7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d1 ON g.APCJoinKey = d1.APCJoinKey AND d1.DiagnosisOrder = 1 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d2 ON g.APCJoinKey = d2.APCJoinKey AND d2.DiagnosisOrder = 2 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d3 ON g.APCJoinKey = d3.APCJoinKey AND d3.DiagnosisOrder = 3 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d4 ON g.APCJoinKey = d4.APCJoinKey AND d4.DiagnosisOrder = 4 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d5 ON g.APCJoinKey = d5.APCJoinKey AND d5.DiagnosisOrder = 5 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d6 ON g.APCJoinKey = d6.APCJoinKey AND d6.DiagnosisOrder = 6 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d7 ON g.APCJoinKey = d7.APCJoinKey AND d7.DiagnosisOrder = 7 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d8 ON g.APCJoinKey = d8.APCJoinKey AND d8.DiagnosisOrder = 8 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d9 ON g.APCJoinKey = d9.APCJoinKey AND d9.DiagnosisOrder = 9 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d10 ON g.APCJoinKey = d10.APCJoinKey AND d10.DiagnosisOrder = 10 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d11 ON g.APCJoinKey = d11.APCJoinKey AND d11.DiagnosisOrder = 11 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Diagnoses AS d12 ON g.APCJoinKey = d12.APCJoinKey AND d12.DiagnosisOrder = 12 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p1 ON g.APCJoinKey = p1.APCJoinKey AND p1.ProcedureOrder = 1 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p2 ON g.APCJoinKey = p2.APCJoinKey AND p2.ProcedureOrder = 2 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p3 ON g.APCJoinKey = p3.APCJoinKey AND p3.ProcedureOrder = 3 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p4 ON g.APCJoinKey = p4.APCJoinKey AND p4.ProcedureOrder = 4 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p5 ON g.APCJoinKey = p5.APCJoinKey AND p5.ProcedureOrder = 5 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p6 ON g.APCJoinKey = p6.APCJoinKey AND p6.ProcedureOrder = 6 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p7 ON g.APCJoinKey = p7.APCJoinKey AND p7.ProcedureOrder = 7 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p8 ON g.APCJoinKey = p8.APCJoinKey AND p8.ProcedureOrder = 8 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p9 ON g.APCJoinKey = p9.APCJoinKey AND p9.ProcedureOrder = 9 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p10 ON g.APCJoinKey = p10.APCJoinKey AND p10.ProcedureOrder = 10 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p11 ON g.APCJoinKey = p11.APCJoinKey AND p11.ProcedureOrder = 11 LEFT JOIN
    [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.APC_Procedures AS p12 ON g.APCJoinKey = p12.APCJoinKey AND p12.ProcedureOrder = 12 


  where g.Research1 = 'Cent'
    and cast(g.EpisodeEndDate as date) between '01 January 2014' and '16 November 2016'
  --and g.episodeenddate between '01 january 2015' and '31 december 2015'

  end
GO
