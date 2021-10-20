SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[Get_Datix_Data_Incident] AS BEGIN 

SELECT DISTINCT 
	NULLIF(m.Recordid,'') as RecordId
--	,NULLIF(inc_name,'') as AffectedPerson
	,NULLIF(inc_unit,'') as Unit
	,NULLIF(inc_type,'') as [Type]
	,NULLIF(inc_directorate,'') as Directorate
	,NULLIF(inc_specialty,'') as Specialty
	,NULLIF(inc_mgr,'') as Manager
	,NULLIF(inc_loctype,'') as LocationType
	,NULLIF(inc_locactual,'') as LocationActual
	,NULLIF(inc_category,'') as Category
	,NULLIF(inc_subcategory,'') as SubCategory
	,NULLIF(CONVERT(date,inc_dincident),'') as IncidentDate
	,NULLIF(CONVERT(date,inc_dopened),'')  as OpenedDate
	,NULLIF(CONVERT(date,inc_dsched),'')  as ScheduledDate
	,NULLIF(inc_severity,'') as Severity
	,NULLIF(CASE WHEN LEN(REPLACE(REPLACE(inc_time,'.',''),':','')) = 4  AND REPLACE(REPLACE(inc_time,'.',''),':','') NOT LIKE '%[^0-9]%' THEN CAST(STUFF(REPLACE(REPLACE(inc_time,'.',''),':',''),3,0,':') AS TIME)ELSE NULL END,'') as IncidentTime
	,NULLIF(CONVERT(date,inc_dreported),'')  as ReportedDate
	,NULLIF(inc_reportedby,'') as ReporterJobTitle
	,NULLIF(inc_repname,'') as ReporterName
	,NULLIF(inc_result,'') as Result
	,NULLIF(inc_investigator,'') as Investigator
	,NULLIF(CONVERT(date,inc_inv_dcomp),'')  as InvestigationCompleteDate
	,NULLIF(inc_inv_outcome,'') as InvestigationOutcome
	,NULLIF(LEFT(inc_notify, CASE WHEN charindex(' ', inc_notify) = 0 THEN LEN(inc_notify) ELSE charindex(' ', inc_notify) - 1 END),'') as Notified
	,NULLIF(inc_equipment,'') as Equipment
	,NULLIF(inc_manufacturer,'') as Manufacturer
	,NULLIF(inc_supplier,'') as Supplier
	,NULLIF(inc_serialno,'') as SerialNumber
	,NULLIF(inc_servrecords,'') as ServiceRecords
	,NULLIF(inc_ridloc,'') as RIDDORLocation
	,NULLIF(inc_address,'') as [Address]
	,NULLIF(inc_localauth,'') as LocalAuthority
	,NULLIF(inc_riddorno,'') as RIDDORNumber
	,NULLIF(inc_acctype,'') as AccidentType
	,NULLIF(inc_is_riddor,'') as IsRIDDOR
	,NULLIF(CONVERT(date,inc_inv_dstart),'')  as InvestigationStartDate
	,NULLIF(LEFT(inc_cnstitype, CASE WHEN charindex(' ', inc_cnstitype) = 0 THEN LEN(inc_cnstitype) ELSE charindex(' ', inc_cnstitype) - 1 END),'') as ContributoryFactors
	,NULLIF(inc_eqpt_type,'') as EquipmentType
	,NULLIF(m.rep_approved,'') as ApprovalStatus
	,NULLIF(m.updateddate,'') as UpdatedDate
	,NULLIF(m.updatedby,'') as UpdatedBy
	,NULLIF(inc_batchno,'') as BatchNo
	,NULLIF(inc_model,'') as Model
	,NULLIF(CONVERT(date,inc_dmanu),'') as ManufactureDate
	,NULLIF(CONVERT(date,inc_dputinuse),'') as PutInUse
	,NULLIF(inc_location,'') as [Location]
	,NULLIF(inc_cemarking,'') as CEMarking
	,NULLIF(inc_outcomecode,'') as OutcomeCode
	,NULLIF(inc_consequence,'') as Consequence
	,NULLIF(inc_likelihood,'') as Likelihood
	,NULLIF(inc_rating,'') as Rating
	,NULLIF(inc_grade,'') as IncidentGrade
	,NULLIF(inc_colour,'') as Colour
	,NULLIF(inc_root_causes,'') as RootCause
	,NULLIF(inc_carestage,'') as CareStage
	,NULLIF(inc_organisation,'') as Organisation
	,NULLIF(inc_clingroup,'') as ClinicalGroup
	,NULLIF(inc_clintype,'') as AdverseEvent
	,NULLIF(LEFT(inc_action_code, CASE WHEN charindex(' ', inc_action_code) = 0 THEN LEN(inc_action_code) ELSE charindex(' ', inc_action_code) - 1 END),'') as [Action]
	,NULLIF(LEFT(inc_lessons_code, CASE WHEN charindex(' ', inc_lessons_code) = 0 THEN LEN(inc_lessons_code) ELSE charindex(' ', inc_lessons_code) - 1 END),'') as Lesson
	,NULLIF(inc_unit_type,'') as UnitType
	,NULLIF(inc_clin_detail,'') as SubType
	,inc_cost as Cost
	,NULLIF(inc_med_stage,'') as MedicationStage
	,NULLIF(inc_med_error,'') as MedicationError
	,NULLIF(inc_med_drug,'') as MedicationDrug
	,NULLIF(inc_med_drug_rt,'') as MedicationDrugRT
	,NULLIF(inc_med_form,'') as MedicationForm
	,NULLIF(inc_med_form_rt,'') as MedicationFormRT
	,NULLIF(inc_med_dose,'') as MedicationDose
	,NULLIF(inc_med_dose_rt,'') as MedicationDoseRT
	,NULLIF(inc_med_route,'') as MedicationRoute
	,NULLIF(inc_med_route_rt,'') as MedicationRouteRT
	,NULLIF(inc_clinical,'') as Clinical
	,NULLIF(inc_further_inv,'') as FurtherInvestigation
	,NULLIF(inc_report_npsa,'') as ReporterNPSA
	,NULLIF(inc_agg_issues,'') as AggIssues
	,NULLIF(inc_pol_call_time,'') as PoliceCalledTime
	,NULLIF(inc_pol_attend,'') as PoliceAttended
	,NULLIF(inc_pol_att_time,'') as PoliceAttendedTime
	,NULLIF(inc_pol_action,'') as PoliceAction
	,NULLIF(inc_pol_crime_no,'') as PoliceCrimeNumber
	,NULLIF(LEFT(inc_user_action, CASE WHEN charindex(' ', inc_user_action) = 0 THEN LEN(inc_user_action) ELSE charindex(' ', inc_user_action) - 1 END),'') as UserAction
	,NULLIF(inc_pol_called,'') as PoliceCalled
	,NULLIF(inc_rep_tel,'') as ReporterPhone
	,NULLIF(inc_rep_email,'') as ReporterEmail
	,NULLIF(inc_postcode,'') as Postcode
	,NULLIF(submit_login,'') as SubmitLogin
	,NULLIF(inc_riddor_ref,'') as RIDDORReference
	,NULLIF(m.createdby,'') as CreatedBy
	,NULLIF(show_person,'') as ShowPerson
	,NULLIF(show_witness,'') as ShowWitness
	,NULLIF(show_employee,'') as ShowEmployee
	,NULLIF(show_other_contacts,'') as ShowOtherContacts
	,NULLIF(show_equipment,'') as ShowEquipment
	,NULLIF(show_medication,'') as ShowMedication
	,NULLIF(show_pars,'') as ShowPars
	,NULLIF(m.show_document,'') as ShowDocument
	,NULLIF(show_assailant,'') as ShowAssailant
	,NULLIF(inc_consequence_initial,'') as InitialConsequence
	,NULLIF(inc_likelihood_initial,'') as InitialLikelihood
	,NULLIF(inc_grade_initial,'') as InitialGrade
	,NULLIF(inc_time_band,'') as IncidentTimeBand
	--,NULLIF(LEFT(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(m.inc_notes))),CHAR(13),''), CHAR(10),''),8000), '')  as Notes
	,NULLIF(INC_ACTIONTAKEN,'') as ActionTaken
	,NULLIF(INC_RECOMMEND,'') as Recommend
	,NULLIF(INC_INV_ACTION,'') as InvestigationAction
	,NULLIF(INC_EQPT_DESCR,'') as EquipmentDescription
	,NULLIF(INC_DEFECT,'') as Defect
	,NULLIF(INC_OUTCOME,'') as Outcome
	,NULLIF(INC_DESCRIPTION,'') as [Description]
	,NULLIF(INC_EXTRAINFO,'') as ExtraInformation
	,NULLIF(inc_inv_lessons,'') as InvestigationLessons
	,NULLIF(inc_submittedtime,'') as SubmittedTime
	,NULLIF(CONVERT(varchar,v.udv_string),'') as UlcerGrade
	,CASE WHEN NULLIF(CONVERT(Varchar,v2.udv_string),'') = 'Y' AND inc_clin_detail = 'ULCER' THEN 'Y' WHEN NULLIF(CONVERT(Varchar,v2.udv_string),'') = 'N' AND inc_clin_detail = 'ULCER' THEN 'N' ELSE NULL END as HAPU 
	,ISNULL(CONVERT(varchar,v3.udv_string),'N')  as WGReportable
	,CASE WHEN v4.udv_string = 'SENSIT' then 'Y' else 'N' END as SensitiveIssue
	,getdate() as LastUpdated
	,CASE WHEN NULLIF(CONVERT(Varchar,v2.udv_string),'') = 'Y' AND inc_clin_detail = 'ULCER' THEN 1 ELSE NULL END as HAPUCount
	,case when inc_clin_detail = 'FALLS' then 1 else null end as FallCount
	,Case when inc_carestage = 'MEDIC' then 1 else null end as MedErrorCount
	,NULLIF(inc_dmda,'') as [ReportedToMHRA]
	,NULLIF(inc_qdef,'') as [QuantityDefective]
	,NULLIF(CONVERT(DATE,inc_dnpsa),'') as [DateExported]
	,NULLIF(inc_n_effect,'') as [EffectOnPatient]
	,NULLIF(inc_n_paedspec,'') as [PaediatricSpecialty]
	,NULLIF(inc_n_paedward,'') as [DedicatedPaediatricWard]
	,CASE WHEN (NULLIF(inc_severity,'') IN ('CATA','HIGH','MEDIUM') Or NULLIF(CONVERT(varchar,v.udv_string),'') in ('DEEPT','GRADE3','GRADE4','UNCLAS'))  THEN 'Yes' ELSE 'No' END as [PatientHarmed]
	,NULLIF(inc_n_nearmiss,'') as [NearMiss]
	,NULLIF(inc_n_actmin,'') as [ImpactMinimised]
	,NULLIF(inc_rc_required,'') as [RemediableCauseAnalysis]
	,NULLIF(inc_n_clindir,'') as [CPG]
	,NULLIF(inc_n_clinspec,'') as [ClinicalSpecialty]
	,NULLIF(inc_pars_clinical,'') as [ClinicalFactorsInvolved]
	,NULLIF(inc_pars_dexport,'') as [LastExportDate]
	,NULLIF(inc_pars_address,'') as [AddressSecondary]
	,NULLIF(inc_tprop_damaged,'') as [TrustPropertyDamaged]
	,NULLIF(inc_pars_first_dexport,'') as [InitialExportDate]
	,NULLIF(INC_IMPRSTRATS,'') as [ImprovementStrategy]
	,NULLIF(inc_ourref,'')  as [BCURefId]
	,ISNULL(CONVERT(Varchar,v5.udv_string),'N') as POVA 
	,ISNULL(CONVERT(Varchar,v8.udv_string),'N') as POVAatRiskReferral 
	,ISNULL(CONVERT(Varchar,v6.udv_string),'N') as ChildProtection 
	,ISNULL(CONVERT(Varchar,v7.udv_string),'N') as DomesticAbuse 
	,'Datix' as [Source]
	,CASE WHEN NULLIF(CONVERT(Varchar,v2.udv_string),'') = 'Y' AND inc_clin_detail = 'ULCER' THEN 'HAPU'
		  WHEN inc_carestage = 'MEDIC' THEN 'Medication Errors'
		  WHEN inc_clin_detail = 'FALLS' THEN 'Falls'
		  ELSE 'Other' END as [HarmType]
		  --Safeguarding
	,ISNULL(CONVERT(Varchar,v9.udv_string),'N') as [IndependentCheck]
	,ISNULL(CONVERT(varchar,v10.udv_string),'N')  as [Radiation]
	,NULLIF(CONVERT(Varchar,v11.udv_string),'') as WGType
	,ISNULL(CONVERT(Varchar,v12.udv_string),'N') as  AvoidableHAPU
	,ISNULL(CONVERT(Varchar,v13.udv_string),'N') as  IPSTApproved
	,ISNULL(CONVERT(Varchar,v14.udv_string),'N') as  SafeguardingIncident
	,ISNULL(CONVERT(Varchar,v15.udv_string),'N') as  AtRiskAdultHarmed
	,ISNULL(CONVERT(Varchar,v16.udv_string),'N') as  AtRiskChildHarmed
	,ISNULL(CONVERT(Varchar,v17.udv_string),'N') as  LinkedToDomesticAbuse
	,ISNULL(CONVERT(Varchar,v18.udv_string),'N') as  AdultAtRiskReportCompleted
	,ISNULL(CONVERT(Varchar,v19.udv_string),'N') as  ChildAtRiskReportCompleted
	--Restraint
	,ISNULL(CONVERT(Varchar,v20.udv_string),'N') as RPI
	,ISNULL(CONVERT(Varchar,v21.udv_string),'N') as LegalStatus
	,ISNULL(CONVERT(Varchar,v22.udv_string),'N') as AuthorisingRestraint
	,ISNULL(CONVERT(Varchar,v23.udv_string),'N') as PriorInterventions
	,ISNULL(CONVERT(Varchar,v24.udv_string),'N') as RestraintCommenced
	,ISNULL(CONVERT(Varchar,v25.udv_string),'N') as TimeConcluded
	,ISNULL(CONVERT(Varchar,v26.udv_string),'N') as TotalDuration
	,ISNULL(CONVERT(Varchar,v27.udv_string),'N') as MultipleEpisodesRPI
	,ISNULL(CONVERT(Varchar,v28.udv_string),'N') as RestraintPosition
	,ISNULL(CONVERT(Varchar,v29.udv_string),'N') as MultipleRestraintPosition
	,ISNULL(CONVERT(Varchar,v30.udv_text),'N') as BodyPartsRestrained
	,ISNULL(CONVERT(Varchar,v31.udv_string),'N') as RestraintReason
	,ISNULL(CONVERT(Varchar,v32.udv_string),'N') as Seclusion
	,ISNULL(CONVERT(Varchar,v33.udv_text),'N') as RestraintConcluded
	,ISNULL(CONVERT(Varchar,v34.udv_string),'N') as VitalSigns
	,ISNULL(CONVERT(Varchar,v35.udv_string),'N') as PatientDebrief
	,ISNULL(CONVERT(Varchar,v36.udv_string),'N') as StaffDebrief
	,ISNULL(CONVERT(Varchar,v37.udv_string),'N') as PBS

FROM [7a1ausrvdtxsql2].[Datixcrm].dbo.incidents_main m
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v on v.cas_id = m.recordid and v.field_id = 1 and v.group_id = 10
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v2 on v2.cas_id = m.recordid and v2.field_id = 11
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v3 on v3.cas_id = m.recordid and v3.field_id = 85
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v4 on v4.cas_id = m.recordid and v4.field_id = 171
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v5 on v5.cas_id = m.recordid and v5.field_id = 3 and v5.group_id = 12
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v6 on v6.cas_id = m.recordid and v6.field_id = 2 and v6.group_id = 12
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v7 on v7.cas_id = m.recordid and v7.field_id = 31 
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v8 on v8.cas_id = m.recordid and v8.field_id = 203
	--Safeguarding
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v9 on v9.cas_id = m.recordid and v9.field_id = 488
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v10 on v10.cas_id = m.recordid and v10.field_id = 7
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v11 on v11.cas_id = m.recordid and v11.field_id = 87
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v12 on v12.cas_id = m.recordid and v12.field_id = 276
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v13 on v13.cas_id = m.recordid and v13.field_id = 74
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v14 on v14.cas_id = m.recordid and v14.field_id = 519
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v15 on v15.cas_id = m.recordid and v15.field_id = 3
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v16 on v16.cas_id = m.recordid and v16.field_id = 2
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v17 on v17.cas_id = m.recordid and v17.field_id = 522
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v18 on v18.cas_id = m.recordid and v18.field_id = 523
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v19 on v19.cas_id = m.recordid and v19.field_id = 525
--Restraint Module
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v20 on v20.cas_id = m.recordid and v20.field_id = 331
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v21 on v21.cas_id = m.recordid and v21.field_id = 332
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v22 on v22.cas_id = m.recordid and v22.field_id = 333
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v23 on v23.cas_id = m.recordid and v23.field_id = 334
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v24 on v24.cas_id = m.recordid and v24.field_id = 336
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v25 on v25.cas_id = m.recordid and v25.field_id = 337
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v26 on v26.cas_id = m.recordid and v26.field_id = 338
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v27 on v27.cas_id = m.recordid and v27.field_id = 339
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v28 on v28.cas_id = m.recordid and v28.field_id = 341
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v29 on v29.cas_id = m.recordid and v29.field_id = 342
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v30 on v30.cas_id = m.recordid and v30.field_id = 344
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v31 on v31.cas_id = m.recordid and v31.field_id = 371
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v32 on v32.cas_id = m.recordid and v32.field_id = 348
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v33 on v33.cas_id = m.recordid and v33.field_id = 346
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v34 on v34.cas_id = m.recordid and v34.field_id = 353
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v35 on v35.cas_id = m.recordid and v35.field_id = 361
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v36 on v36.cas_id = m.recordid and v36.field_id = 464
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v37 on v37.cas_id = m.recordid and v37.field_id = 357

END
GO
