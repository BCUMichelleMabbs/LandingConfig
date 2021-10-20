SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: 25th April 2017
-- Description:	Extract of all Inpatient and Daycase Data from Myrddin
-- =============================================


--NOTES
--Should be placed on the 1 month or null replacement plan otherwise those with a null episiode end date won't be removed.

CREATE PROCEDURE [dbo].[Get_PAS_Data_Inpatient_Central]
	
AS
BEGIN

SET NOCOUNT ON;





DECLARE @LastEpisodeEndDate AS DATE = (SELECT ISNULL(MAX(DateEpisodeEnded),'01 January 2018') FROM [Foundation].[dbo].[PAS_Data_Inpatient] where Area = 'Central')
DECLARE @LastEpisodeEndDateString AS VARCHAR(30) = DATENAME(DAY,@LastEpisodeEndDate) + ' ' + DATENAME(MONTH,@LastEpisodeEndDate) + ' ' + DATENAME(YEAR,@LastEpisodeEndDate)

--DECLARE @DateAdmitted AS DATE = (SELECT ISNULL(MAX(DateAdmitted),'1 January 2019') FROM [Foundation].[dbo].[PAS_Data_Inpatient] where Area = 'Central')
--DECLARE @DateAdmittedString AS VARCHAR(30) = DATENAME(DAY,@DateAdmitted) + ' ' + DATENAME(MONTH,@DateAdmitted) + ' ' + DATENAME(YEAR,@DateAdmitted)

--declare @Date as Date = '01 january 2018'

EXEC( 'SELECT DISTINCT 
		nullif(rtrim(t.purchaser), '''') as Commissioner,
	    nullif(rtrim(t.charged_to), '''') as CommissionerType,
	    nullif(rtrim(upper(r.GPREFNO)), '''') AS GpRefNo,
		nullif(rtrim(p.nhs), '''') as NHSNumber,
		nullif(rtrim(replace(t.postcode, '' '', '''')), '''') as PostcodeAtTimeOfActivity,
		nullif(rtrim(t.dha_code), '''') as LHBOfResidence,
		nullif(rtrim(t.reg_gp), '''') as GPAtTimeOfActivity,
		p.caseno as LocalPatientIdentifier,
		nullif(rtrim(t.gp_trt), '''') as Referrer,
		nullif(rtrim(t.gp_prac), '''') as ReferringOrganisation,
		nullif(rtrim(t.actnotekey), '''') as ProviderSpellNumber,
		nullif(rtrim(t.category), '''') as AdministrativeCategory,
		cast(t.trt_date as date) as DateAdmitted,
		nullif(rtrim(t.admit_method), '''') as AdmissionMethod,
		nullif(rtrim(t.trt_intent), '''') as IntendedManagement,
		nullif(rtrim(t.source), '''') as AdmissionSource,
		cast(t.disdate as date) as DateDischarged,
		nullif(rtrim(t.dismethod), '''') as DischargeMethod,
		nullif(rtrim(t.destination), '''') as DischargeDestination,
		nullif(rtrim(t.real_management), '''') as PatientClassification,
		nullif(rtrim(h.thecode), '''') as HealthcareResourceGroup,

		Case
				when e.episodeno is not null then cast(e.episodeno as int)
				else ''0''
				end as EpisodeNumber,

		CASE
			WHEN t.disdate IS NULL THEN ''0''
			WHEN e.EpisodeNo = (
				SELECT FIRST 1 innerE.EpisodeNo 
				FROM EPISODE innerE 
				LEFT JOIN TREATMNT innerT ON innerE.LINKID=innerT.LINKID 
				WHERE 
					innerE.LINKID=e.LINKID
				ORDER BY innerE.EpisodeNo DESC) then ''1''
			ELSE ''0''
		END AS LastEpisodeInSpellIndicator,
		
		nullif(rtrim(l.provider_code), '''') as SiteCode,
		nullif(rtrim(l.ward_type), '''') as WardTypeAtStartOfEpisode,
		cast(e.start_date as date) as DateEpisodeStarted,
		
		case 
				when e.end_date = ''31 December 2999'' then null
				ELSE cast(e.end_date as date) 
		END as DateEpisodeEnded,

		

		nullif(rtrim(e.spec), '''') AS SpecialtyOfEpisode,
		nullif(rtrim(e.cons), '''') as HCPOfEpisode,
		nullif(rtrim(d1.thecode), '''') as Diagnosis1,
		nullif(rtrim(d2.thecode), '''') as Diagnosis2,
		nullif(rtrim(d3.thecode), '''') as Diagnosis3,
		nullif(rtrim(d4.thecode), '''') as Diagnosis4,
		nullif(rtrim(d5.thecode), '''') as Diagnosis5,
		nullif(rtrim(d6.thecode), '''') as Diagnosis6,
		nullif(rtrim(d7.thecode), '''') as Diagnosis7,
		nullif(rtrim(d8.thecode), '''') as Diagnosis8,
		nullif(rtrim(d9.thecode), '''') as Diagnosis9,
		nullif(rtrim(d10.thecode), '''') as Diagnosis10,
		nullif(rtrim(d11.thecode), '''') as Diagnosis11,
		nullif(rtrim(d12.thecode), '''') as Diagnosis12,
		nullif(rtrim(d13.thecode), '''') as Diagnosis13,
		nullif(rtrim(d14.thecode), '''') as Diagnosis14,
		nullif(rtrim(h1.thecode), '''') as HistologicalDiagnosis,
		nullif(rtrim(h1.source_of_hist), '''') as HistologicalDiagnosisSource,
		nullif(rtrim(c1.thecode), '''') as Procedure1,
		cast(c1.thedate as date) as DateOfProcedure1,
		nullif(rtrim(c2.thecode), '''') as Procedure2,
		cast(c2.thedate as date) as DateOfProcedure2,
		nullif(rtrim(c3.thecode), '''') as Procedure3,
		cast(c3.thedate as date) as DateOfProcedure3,
		nullif(rtrim(c4.thecode), '''') as Procedure4,
		cast(c4.thedate as date) as DateOfProcedure4,
		nullif(rtrim(c5.thecode), '''') as Procedure5,
		cast(c5.thedate as date) as DateOfProcedure5,
		nullif(rtrim(c6.thecode), '''') as Procedure6,
		cast(c6.thedate as date) as DateOfProcedure6,
		nullif(rtrim(c7.thecode), '''') as Procedure7,
		cast(c7.thedate as date) as DateOfProcedure7,
		nullif(rtrim(c8.thecode), '''') as Procedure8,
		cast(c8.thedate as date) as DateOfProcedure8,
		nullif(rtrim(c9.thecode), '''') as Procedure9,
		cast(c9.thedate as date) as DateOfProcedure9,
		nullif(rtrim(c10.thecode), '''') as Procedure10,
		cast(c10.thedate as date) as DateOfProcedure10,
		nullif(rtrim(c11.thecode), '''') as Procedure11,
		cast(c11.thedate as date) as DateOfProcedure11,
		nullif(rtrim(c12.thecode), '''') as Procedure12,
		cast(c12.thedate as date) as DateOfProcedure12,
		cast(r.datonsys as date) as DateOnSystem,
		nullif(rtrim(t.reg_Prac), '''') as GPPracticeAtTimeOfActivity,
		cast(r.Dat_ref as date) as DateReferred,
		cast(t.next_approx_appt as date) as DateOfNextApproximateAppointment,
		cast(t.est_disdate as date) as DateEstimatedDischarge,
		nullif(rtrim(t.priority), '''') as PriorityOfHCP,
		nullif(rtrim(t.aloc), '''') as WardOnAdmission,
		nullif(rtrim(t.cloc), '''') as Ward,
		
		CASE
				WHEN t.arrival_time IS NULL THEN NULL
				WHEN TRIM(t.arrival_time)='':'' THEN null
				WHEN TRIM(t.arrival_time)='''' THEN null
				WHEN TRIM(t.arrival_time)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(t.arrival_time FROM 1 FOR 2)||'':''||SUBSTRING(t.arrival_time FROM 3 FOR 2) 
			END AS TimeOfArrival,
		
				CASE
				WHEN t.Leaving_time IS NULL THEN NULL
				WHEN TRIM(t.Leaving_time)='':'' THEN null
				WHEN TRIM(t.Leaving_time)='''' THEN null
				WHEN TRIM(t.Leaving_time)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(t.Leaving_time FROM 1 FOR 2)||'':''||SUBSTRING(t.Leaving_time FROM 3 FOR 2) 
			END AS TimeLeft,
		nullif(rtrim(t.outcome), '''') as OutcomeOfAdmission,
		nullif(rtrim(pm.UPI), '''') as UniquePathwayIdentifier,
		nullif(rtrim(t.linkid), '''') as SystemLinkID,
		CASE
				WHEN T.APPOINTMENT_TIME IS NULL THEN NULL
				WHEN TRIM(T.APPOINTMENT_TIME)='':'' THEN null
				WHEN TRIM(T.APPOINTMENT_TIME)='''' THEN null
				WHEN TRIM(T.APPOINTMENT_TIME)=''0000'' THEN ''00:00''
				ELSE SUBSTRING(T.APPOINTMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.APPOINTMENT_TIME FROM 3 FOR 2) 
			END AS TimeOfAdmission,
		nullif(rtrim(t.acons), '''') as HCPOnAdmission,
		nullif(rtrim(t.ccons), '''') as HCPOnDischarge,

		--cant use below as its both current and discharging
		--CASE WHEN cast(t.disdate as date) is null then NULL else t.ccons END as HCPOnDischarge,
		nullif(rtrim(t.aspec), '''') as SpecialtyOnAdmission,
		nullif(rtrim(t.cspec), '''') as Specialty,
		nullif(rtrim(t.trt_type), '''') as TreatmentType,
		nullif(rtrim(t.Outcome_Reason), '''') as OutcomeOfAdmissionLocal,
		nullif(rtrim(Pm.EVENT_TYPE), '''') as EventType,
		nullif(rtrim(Pm.EVENT_SOURCE), '''') as EventSource,
		nullif(rtrim(t.actnotekey), '''') as Actnotekey,
		''Central'' as Area,
		''WPAS'' as Source,
		nullif(rtrim(t.hosp_dest), '''') as SiteDischargedTo,
		NULL as LHBOfGP,
		nullif(rtrim(t.Date_Notified), '''') as DateNotified,
		null as DateAmendedOutcome,
		NULL as UserAmendedOutcome,
		NULL as CancelReasonTheatre,
		NULL as OutcomeOfReferral,
		NULL as OffListReason,
		NULL as OffListReasonLocal,
		NULL as SubsidiaryDiagnosis,
		nullif(rtrim(ls.legalstatus), '''') as LegalStatus,
		
		
		--floor((cast(t.trt_date as date) - cast(p.birthdate as date)) / 365.25) as AgeOnAdmission,
		
		--case when t.disdate is not null then floor((cast(t.disdate as date) - cast(p.birthdate as date)) / 365.25) else null end as AgeOnDischarge,

		Coalesce(CASE WHEN Extract(Month from P.BIRTHDATE) < Extract(MONTH from T.TRT_DATE) THEN DATEDIFF(year, P.BIRTHDATE, T.TRT_DATE)
                    WHEN Extract(Month from P.BIRTHDATE) = Extract(Month from T.TRT_DATE) AND Extract(Day from P.BIRTHDATE) <= Extract(Day from T.TRT_DATE) THEN DATEDIFF(year, P.BIRTHDATE, T.TRT_DATE)
                    ELSE (DATEDIFF(year, P.BIRTHDATE, T.TRT_DATE) - 1) 
                    END,0) as AgeOnAdmission,
		

		Coalesce(CASE WHEN Extract(Month from P.BIRTHDATE) < Extract(Month from T.DISDATE) THEN DATEDIFF(year, P.BIRTHDATE, T.DISDATE)
                    WHEN Extract(Month from P.BIRTHDATE) = Extract(Month from T.DISDATE) AND Extract(Day from P.BIRTHDATE) <= Extract(Day from T.DISDATE) THEN DATEDIFF(year, P.BIRTHDATE, T.DISDATE)
                    ELSE (DATEDIFF(year, P.BIRTHDATE, T.DISDATE) - 1) 
                    END,0) as  AgeOnDischarge,


		
		Case when t.disdate is not null then (cast(t.disdate as date) - cast(t.trt_date as date))
		else null 
		end as DaysInSpell,

		case 
		 when e.end_date = ''31 december 2999'' then null
		 when e.end_date is not null then (cast(e.end_date as date) - cast(e.start_date as date))
		 else  null
		end as DaysInEpisode,

		case 
		when t.disdate is null  then null
		when t.trt_date is null then null
		when char_length(t.leaving_time) < 4 then 
				case when (cast(extract(YEAR from t.disdate)||''-''||extract(month from t.disdate)||''-''||extract(DAY from t.disdate) as date )) - (cast(extract(YEAR from t.trt_date)||''-''||extract(month from t.trt_date)||''-''||extract(DAY from t.trt_date) as date ))< 1 then ''Y''
				else ''N'' End
		when t.arrival_time is null then 
				case when (cast(extract(YEAR from t.disdate)||''-''||extract(month from t.disdate)||''-''||extract(DAY from t.disdate) as date )) - (cast(extract(YEAR from t.trt_date)||''-''||extract(month from t.trt_date)||''-''||extract(DAY from t.trt_date)as date))< 1 then ''Y''
				else ''N'' End
		when (cast(extract(YEAR from t.disdate)||''-''||extract(month from t.disdate)||''-''||extract(DAY from t.disdate)||'' ''||SUBSTRING(T.Leaving_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.leaving_TIME FROM 3 FOR 2) as timestamp )) - 
		(cast(extract(YEAR from t.trt_date)||''-''||extract(month from t.trt_date)||''-''||extract(DAY from t.trt_date)||'' ''||SUBSTRING(T.arrival_TIME FROM 1 FOR 2)||'':''||SUBSTRING(T.arrival_TIME FROM 3 FOR 2) as timestamp ))  < 1 then ''Y'' 
		else ''N''
		end as DischargedWithin24Hrs,

		case 
		when t.est_disdate is null then null
		when (cast(t.disdate as date) > (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 desc)) then ''Y'' 
				when t.disdate is null and (''today'' > (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 desc)) then ''Y''
		else ''N'' end as PDDBreach,

	 (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 desc) AS PDD,
	
	(select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 asc)  as OPDD,

	(select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) like ''%MFD%'' order by 1 asc) as MFD,


	 NULL AS DayCaseCleansed,
		
	c1.Create_date as Procedure1CodedDate,
	 c1.Create_user as Procedure1CodedBy,
	 c1.Last_Modify_Date as Procedure1LastModifiedDate,
	 c1.Last_modify_user as Procedure1LastModifiedBy,
	 d1.Create_date as Diagnosis1CodedDate,
	 d1.Create_user as Diagnosis1CodedBy,
	 d1.Last_Modify_Date as Diagnosis1LastModifiedDate,
	 d1.Last_modify_user as Diagnosis1LastModifiedBy,
	 CAST(SUBSTRING(t.OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000)) as OtherInformation

FROM
	treatmnt t 
	left join master_trt on master_trt.linkid = t.linkid
	left join episode e on e.linkid = t.linkid and t.trt_Type like ''A%''
	left join refer r on t.linkid = r.linkid
	left join srefer s on r.source_refer = s.referral_code
	left join padloc l on e.loc = l.loccode
	left join patient p on t.caseno = p.caseno
	left join cons x on ((e.cons = x.consultant_initials) and (x.main <> ''''))
	--left join gp2 g on e.cons = g.practice
	--left join gp2 ac on t.acons = ac.practice
	--left join gp2 cc on t.ccons = cc.practice
	left join gp2 j on t.gp_trt = j.gp_code and t.gp_prac = j.practice
	left join legalstatus ls on t.caseno = ls.caseno and t.disdate = ls.enddate
	left join coding h on h.linkid = e.linkid and h.episodeno = e.episodeno and h.Code_Type = ''H5'' and h.ITEMNO = ''1''
	left join coding c1 on c1.linkid = e.linkid and c1.episodeno = e.episodeno and c1.Code_Type = ''OP'' and c1.ITEMNO = ''1''
	left join coding c2 on c2.linkid = e.linkid and c2.episodeno = e.episodeno and c2.Code_Type = ''OP'' and c2.ITEMNO = ''2''
	left join coding c3 on c3.linkid = e.linkid and c3.episodeno = e.episodeno and c3.Code_Type = ''OP'' and c3.ITEMNO = ''3''
	left join coding c4 on c4.linkid = e.linkid and c4.episodeno = e.episodeno and c4.Code_Type = ''OP'' and c4.ITEMNO = ''4''
	left join coding c5 on c5.linkid = e.linkid and c5.episodeno = e.episodeno and c5.Code_Type = ''OP'' and c5.ITEMNO = ''5''
	left join coding c6 on c6.linkid = e.linkid and c6.episodeno = e.episodeno and c6.Code_Type = ''OP'' and c6.ITEMNO = ''6''
	left join coding c7 on c7.linkid = e.linkid and c7.episodeno = e.episodeno and c7.Code_Type = ''OP'' and c7.ITEMNO = ''7''
	left join coding c8 on c8.linkid = e.linkid and c8.episodeno = e.episodeno and c8.Code_Type = ''OP'' and c8.ITEMNO = ''8''
	left join coding c9 on c9.linkid = e.linkid and c9.episodeno = e.episodeno and c9.Code_Type = ''OP'' and c9.ITEMNO = ''9''
	left join coding c10 on c10.linkid = e.linkid and c10.episodeno = e.episodeno and c10.Code_Type = ''OP'' and c10.ITEMNO = ''10''
	left join coding c11 on c11.linkid = e.linkid and c11.episodeno = e.episodeno and c11.Code_Type = ''OP'' and c11.ITEMNO = ''11''
	left join coding c12 on c12.linkid = e.linkid and c12.episodeno = e.episodeno and c12.Code_Type = ''OP'' and c12.ITEMNO = ''12''
	left join coding d1 on d1.linkid = e.linkid and d1.episodeno = e.episodeno and d1.Code_Type = ''10'' and d1.ITEMNO = ''1''
	left join coding d2 on d2.linkid = e.linkid and d2.episodeno = e.episodeno and d2.Code_Type = ''10'' and d2.ITEMNO = ''2''
	left join coding d3 on d3.linkid = e.linkid and d3.episodeno = e.episodeno and d3.Code_Type = ''10'' and d3.ITEMNO = ''3''
	left join coding d4 on d4.linkid = e.linkid and d4.episodeno = e.episodeno and d4.Code_Type = ''10'' and d4.ITEMNO = ''4''
	left join coding d5 on d5.linkid = e.linkid and d5.episodeno = e.episodeno and d5.Code_Type = ''10'' and d5.ITEMNO = ''5''
	left join coding d6 on d6.linkid = e.linkid and d6.episodeno = e.episodeno and d6.Code_Type = ''10'' and d6.ITEMNO = ''6''
	left join coding d7 on d7.linkid = e.linkid and d7.episodeno = e.episodeno and d7.Code_Type = ''10'' and d7.ITEMNO = ''7''
	left join coding d8 on d8.linkid = e.linkid and d8.episodeno = e.episodeno and d8.Code_Type = ''10'' and d8.ITEMNO = ''8''
	left join coding d9 on d9.linkid = e.linkid and d9.episodeno = e.episodeno and d9.Code_Type = ''10'' and d9.ITEMNO = ''9''
	left join coding d10 on d10.linkid = e.linkid and d10.episodeno = e.episodeno and d10.Code_Type = ''10'' and d10.ITEMNO = ''10''
	left join coding d11 on d11.linkid = e.linkid and d11.episodeno = e.episodeno and d11.Code_Type = ''10'' and d11.ITEMNO = ''11''
	left join coding d12 on d12.linkid = e.linkid and d12.episodeno = e.episodeno and d12.Code_Type = ''10'' and d12.ITEMNO = ''12''
	left join coding d13 on d13.linkid = e.linkid and d13.episodeno = e.episodeno and d13.Code_Type = ''10'' and d13.ITEMNO = ''13''
	left join coding d14 on d14.linkid = e.linkid and d14.episodeno = e.episodeno and d14.Code_Type = ''10'' and d14.ITEMNO = ''14''
	left join histol h1 on e.linkid = h1.linkid and e.episodeno = h1.episodeno and h1.ITEMNO = ''1''
	left join PATHWAYMGT pm ON pm.ActNoteKey = t.actnotekey and (coalesce (pm.event_Source, ''MA'') = ''MA'' and pm.pwaykey = (select first 1 pm2.pwaykey from pathwaymgt pm2 where pm2.actnotekey = t.actnotekey and coalesce(pm2.event_source, ''MA'') = ''MA''))

WHERE

(
	(
		T.TRT_TYPE IN(''AC'',''AL'',''AD'', ''AN'') AND 
		(
			NULLIF(E.END_DATE,''31 DECEMBER 2999'') IS NULL OR 
		
		E.END_DATE > '''+@LastEpisodeEndDateString+'''

			
		)
	)
	

	OR

	(
		T.TRT_TYPE IN (''AT'',''AE'')
	)
)	


	

')AT [WPAS_Central_Newport];
end

--E.END_DATE > '''+@LastEpisodeEndDateString+'''
--	E.END_DATE BETWEEN ''1 JANUARY 2013'' AND ''31 DECEMBER 2014''


	-- AND T.TRT_DATE > '''+@LastEpisodeEndDateString+''')


	--(T.TRT_TYPE in (''AC'',''AD'',''AL'') and (e.End_Date >= '''+ @DateEpisodeEndedString + ''' or e.end_date is null or e.END_DATE = ''31 December 2999''))
	--or 
	-- (t.trt_type in (''AT'',''AE'') and t.trt_date >= '''+ @DateAdmittedString + ''')

--and p.caseno = ''G428292''

/*
--needed for cancellation testing

		--a.datdone as DateAmendedOutcome,
		--a.who as UserAmendedOutcome,
		--(Select first 1 tl.item_code from thr_patient_op tpo join thr_lookups tl on tpo.cancel_reason = tl.item_code and tl.group_code = ''10'' where tpo.linkid = t.linkid and actual_visit = ''Y'') as CancelReasonTheatre,
		--R.REF_OUTCOME AS OutcomeOfReferral,
		--R.REASON_BOOKED AS OffListReason,
		--R.LOCAL_REASON_BOOKED AS OffListReasonLocal


--left join Audit a on (a.linkid = t.linkid and a.caseno = t.caseno and t.TRT_Type = a.files )

--(t.trt_type in (''AN'', ''AT'',''AE'') and t.trt_date >= '''+ @Date + ''')
--and a.text like '',Type=%''


*/


GO
