SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_Referral_Central]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	Declare @LastReferralDateString as date = '1 January 2019'
	
   	--DECLARE @LastReferralDate AS DATE = (SELECT ISNULL(MAX(ReferralDate),'1 April 2017') FROM [Foundation].[dbo].[PAS_Data_Referral] WHERE Area='Central')
	--DECLARE @LastReferralDateString AS VARCHAR(30) = DATENAME(DAY,@LastReferralDate) + ' ' + DATENAME(MONTH,@LastReferralDate) + ' ' + DATENAME(YEAR,@LastReferralDate)

	EXEC('SELECT DISTINCT
		nullif(rtrim(REFER.NHS), '''') AS NHSNumber,
		nullif(rtrim(REFER.CASENO), '''') AS LocalPatientIdentifier,
		cast(REFER.DAT_REF as date) AS DateReferred,
		cast(REFER.DATONSYS as date) AS DateOnSystem,
		nullif(rtrim(REFER.INTENT_REFER), '''') AS ReferralIntent,
		nullif(rtrim(REFER.GP_REF), '''') AS Referrer,
		nullif(rtrim(REFER.GP_PRAC), '''') AS OrganisationOfReferrer,
		nullif(rtrim(REFER.REG_GP), '''') AS GPAtTimeOfActivity,
		nullif(rtrim(REFER.REG_PRAC), '''') AS GPPracticeAtTimeOfActivity, 
		nullif(rtrim(REFER.POSTCODE), '''') AS PostcodeAtTimeOfActivity,
		nullif(rtrim(REFER.DHA_CODE), '''') AS LHBOfResidence,
		nullif(rtrim(REFER.SOURCE_REFER), '''') AS ReferralSource,
		nullif(rtrim(REFER.LTTR_PRTY), '''') AS PriorityOnLetter,
		nullif(rtrim(REFER.REF_OUTCOME), '''') AS Outcome,
		nullif(rtrim(REFER.LINKID), '''') AS SystemLinkId,
		nullif(rtrim(GP.GP_CODE), '''') AS HCP,
		nullif(rtrim(REFER.LOC), '''') AS SiteCode,
		nullif(rtrim(REFER.CATEGORY), '''') AS PatientCategory,
		nullif(rtrim(REFER.CONS_PRTY), '''') AS PriorityOfHCP,
		nullif(rtrim(REFER.LIST_OUTCOME), '''') AS ListOutcome,
		nullif(rtrim(cast(REFER.TRT_DATE as date)), '''') AS DateOfAppointment,
		nullif(rtrim(REFER.REASON_BOOKED), '''') AS OffListReason,
		nullif(rtrim(REFER.GPREFNO), '''') AS GPRefNo,
		nullif(rtrim(REFER.CLINICAL_CONDITION), '''') AS ClinicalCondition,
		nullif(rtrim(REFER.CHARGED_TO), '''') AS CommissionerType,
		cast(REFER.DATE_BOOKED as date) AS DateBooked,
		nullif(rtrim(REFER.PURCHASER), '''') AS Commissioner,
		REFER.ACTNOTEKEY AS Actnotekey,
		nullif(rtrim(REFER.SPEC), '''') AS Specialty,
		nullif(rtrim(REFER.TRT_TYPE), '''') AS TreatmentType,
		nullif(rtrim(REFER.WLIST), '''') AS ReferralType,
		nullif(rtrim(PM.UPI), '''') AS UniquePathwayIdentifier,
		''Central'' AS Area,
		''WPAS'' as Source,
		nullif(rtrim(REFER.LOCAL_REASON_BOOKED), '''') as OffListLocalReason,
		nullif(rtrim(PADLOC_2.PROVIDER_CODE), '''') as SiteReferredTo, 
		nullif(rtrim(PADLOC_3.PROVIDER_CODE), '''') as SitePreferred,
		REFER.FTEXT as Comments,
		nullif(rtrim(REFER.PREF_SESSION), '''') as SessionPreferred,
		cast(REFER.PREOP_DATE as date) as DateOfPreOp,
		nullif(rtrim(PADLOC_4.PROVIDER_CODE), '''') as SiteOfPreOp,
		cast(REFER.DATPATAWARE as date) as DatePatientAware,
		nullif(rtrim(REFER.THR_TYPE), '''') as TheatreType,
		
		CASE
				WHEN REFER.EST_THR_TIME IS NULL THEN NULL
				WHEN TRIM(REFER.EST_THR_TIME)=''0000'' THEN ''00:00''
				WHEN TRIM(REFER.EST_THR_TIME)='':'' THEN ''00:00''
				WHEN TRIM(REFER.EST_THR_TIME)='''' THEN NULL
				ELSE SUBSTRING(REFER.EST_THR_TIME FROM 1 FOR 2)||'':''||SUBSTRING(REFER.EST_THR_TIME FROM 3 FOR 2) 
		END AS TimeEstimatedForTheatre,

		nullif(rtrim(REFER.REF_ANAES_TYPE), '''') as AnaestheticType,
		cast(REFER.PLANNED_OP_DATE as date) as DateOfPlannedOp,
		nullif(rtrim(REFER.ASA_Grade), '''') as ASAGrade,
		nullif(rtrim(REFER.ADMIT_Method), '''') as AdmissionMethod,
		NULL as LHBOfGP, --this is needed for OBCU Data
		nullif(rtrim(REFER.THEATRE_CODE), '''') as TheatreCode,
		REFER.FIRST_APPROX_APPT as DateOfFirstApproximateAppointment,
		nullif(rtrim(REFER.FIRST_APPROX_FREQ), '''') as FrequencyOfFirstApproximateAppointment,
		nullif(rtrim(REFER.Health_Risk_Factor), '''') as HealthRiskFactor,
		nullif(rtrim(REFER.Proms_Code), '''') as PatientRelatedOutcomeMeasureCode,
		null as ReferralRefno,
		null as WaitingListRefno,
		null as ScheduleRefNo,
		null as WaitingListRuleRefno,
		null as WaitingListInmgtRefno,
		null as WaitingListPrityRefno,
		null as WaitingListConsultCode,
		null as WaitingListSpecCode,
		null as DateWaitingListDTA,
		null as WaitingListSvtypRefno,
		null as DateOnWaitingList,
		''Y'' as ReferralFlag,
		floor((cast(REFER.DAT_REF as date) - cast(p.birthdate as date)) / 365.25) as AgeOnReferral,
		nullif(rtrim(c.thecode), '''') as ProposedProcedure1,
		nullif(rtrim(c2.thecode), '''') as ProposedProcedure2,
		nullif(rtrim(c3.thecode), '''') as ProposedProcedure3,
		nullif(rtrim(c4.thecode), '''') as ProposedProcedure4,
		nullif(rtrim(c5.thecode), '''') as ProposedProcedure5,
		nullif(rtrim(c6.thecode), '''') as ProposedProcedure6,

		-- this section is to be used for upgrading and downgrading of cancer referrals
		
		nullif(right(substring(a.text from position (''Spec'' in a.text) for 11),6), '''') as SpecialtyOriginal,
		--case
		--	when a.text is null then ''Merged Record''
		--	when right(substring(a.text from position (''Spec'' in a.text) for 11),6) = refer.spec then ''Same''
		--	when right(substring(a.text from position (''Spec'' in a.text) for 11),3) like ''99%'' and right(refer.spec,3) like ''99%'' then ''Same''
		--	when right(substring(a.text from position (''Spec'' in a.text) for 11),3) like ''99%''  then ''Upgraded''
		--	when right(refer.spec,3) like ''99%'' then ''Downgraded''
		--	else ''Altered''
		--	end as SpecialtyDifference,


		case
			when right(substring(a.text from position (''Spec'' in a.text) for 11),3) = RIGHT(refer.spec, 3) then null
			when right(substring(a.text from position (''Spec'' in a.text) for 11),3) like ''99%''  then ''Downgraded''
			when right(substring(a.text from position (''Spec'' in a.text) for 11),6) in (''101009'') then ''Downgraded''
			when right(refer.spec,3) in (''101009'') then ''Upgraded''
			when right(refer.spec,3) like ''99%'' then ''Upgraded''
			else null
			end as SpecialtyDifference,

		case 
			when right(substring(a.text from position (''Spec'' in a.text) for 11),3) = RIGHT(refer.spec, 3) then null
			when right(substring(a.text from position (''Spec'' in a.text) for 11),3) like ''99%''  then cast(a2.DatDone as date)
			when right(substring(a.text from position (''Spec'' in a.text) for 11),6) in (''101009'') then cast(a2.DatDone as date)
			when right(refer.spec,3) in (''101009'') then cast(a2.DatDone as date)
			when right(refer.spec,3) like ''99%'' then cast(a2.DatDone as date)
			else null
		end as DateSpecialtyChanged,
		
		nullif(rtrim(PADLOC_3.LOCCODE), '''') as WardOrClinicPreferred, 
		nullif(rtrim(refer.ESTLOS), '''') as EstimatedLengthOfStay

	FROM 
		REFER REFER
		Left Join patient p on p.caseno = refer.caseno
		LEFT JOIN GP2 GP ON (GP2.PRACTICE = REFER.CONS)
		LEFT JOIN PADLOC PADLOC_2 ON (PADLOC_2.LOCCODE = REFER.LOC)
		LEFT JOIN PADLOC PADLOC_3 ON (PADLOC_3.LOCCODE = REFER.PREF_WARD)
		LEFT JOIN PADLOC PADLOC_4 ON (PADLOC_4.LOCCODE = REFER.PREOP_LOC)
		left JOIN PATHWAYMGT pm ON pm.ActNoteKey = refer.actnotekey and (coalesce (pm.event_Source, ''MR'') = ''MR'' and pm.pwaykey = (select first 1 pm2.pwaykey from pathwaymgt pm2 where pm2.actnotekey = refer.actnotekey and coalesce(pm2.event_source, ''MR'') = ''MR''))	
	
		left join Audit a on (
                     a.linkid = refer.linkid and 
                     a.caseno = refer.caseno and 
                     a.files = ''RF'' and 
                     a.what = ''I'' and 
                     cast(a.datdone as date) >=  cast(refer.DAT_REF as date) and 
                     a.text like ''%Spec%''
              )      
        LEFT JOIN AUDIT A2 ON A2.AUDIT_KEY=(SELECT FIRST 1 AUDIT_KEY FROM AUDIT innerA WHERE 
                     innerA.linkid = REFER.linkid and 
                     innerA.caseno = REFER.caseno and 
                     innerA.files = ''RF'' and 
                     innerA.what = ''A'' and 
                     innerA.text like ''%Spec%''
                     order by AUDIT_KEY DESC
              )	

		left join coding c on c.linkid = refer.linkid and c.code_type = ''OP'' and c.itemno = ''1'' and c.episodeno = ''-1''
		left join coding c2 on c2.linkid = refer.linkid and c2.code_type = ''OP'' and c2.itemno = ''2'' and c2.episodeno = ''-1''
		left join coding c3 on c3.linkid = refer.linkid and c3.code_type = ''OP'' and c3.itemno = ''3'' and c3.episodeno = ''-1''
		left join coding c4 on c4.linkid = refer.linkid and c4.code_type = ''OP'' and c4.itemno = ''4'' and c4.episodeno = ''-1''
		left join coding c5 on c5.linkid = refer.linkid and c5.code_type = ''OP'' and c5.itemno = ''5'' and c5.episodeno = ''-1''
		left join coding c6 on c6.linkid = refer.linkid and c6.code_type = ''OP'' and c6.itemno = ''6'' and c6.episodeno = ''-1''
	
	WHERE 
			--REFER.DATONSYS >= '''+@LastReferralDateString+'''

			REFER.DATONSYS between ''01 january 2019'' and ''31 january 2019''
			and refer.caseno = ''B0518103''

		
	'
	) AT [WPAS];


END




/*
Need to investigate requested options and load into a seperate table as there could be any number of combinations of options chosen and there is no priority to them

		left join Act_Req_Options O on (o.actnotekey = refer.actnotekey and o.caseno = refer.caseno and o.req_type = ''RF'')
		left join Act_Req_Options O2 on (o2.actnotekey = refer.actnotekey and o2.caseno = refer.caseno and o2.req_type = ''RF'')
*/
GO
