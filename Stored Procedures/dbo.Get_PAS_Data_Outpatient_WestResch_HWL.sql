SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatient_WestResch_HWL]
	
AS
BEGIN
	
	

-----------------------------------------------------------------------------------------------
-- Original Version: NWW_Get_PAS_Data_OutpatientWestResch
--
--      Description: Extracts ALL Re-Scheduled Appointments from Schedule History
--
--  02/09/2021 Amended By: Heather Lewis (HWL)- Version for dataset 1311 format
--
--IDS -- (some used in updates)
--SystemLinkID	    refrl_refno
--PatientLinkId	    patnt_refno
--ActNoteKey	    schdl_refno
--PathwayUPI        refrl_refno
--WaitingListLinkID wlist_refno
------------------------------------------------------------------------------------------------


EXEC('
use [iPMReports]
	
SET NOCOUNT ON;

DECLARE		

@cityp_natgp	numeric(10,0),
@cityp_gmc	    numeric(10,0),
@cityp_dent	    numeric(10,0),
@hityp_natnl	numeric(10,0),
@prtyp_gmprc    numeric(10,0),
@StartDate date

-- DECLARE @LastTreatmentDate AS DATE = (SELECT ISNULL(MAX(TreatmentDate),''1 April 2017'') FROM [Foundation].[dbo].[PAS_Data_Outpatient] WHERE Area=''West'')
-- DECLARE @LastTreatmentDateString AS VARCHAR(30) = DATENAME(DAY,@LastTreatmentDate) + '' '' + DATENAME(MONTH,@LastTreatmentDate) + '' '' + DATENAME(YEAR,@LastTreatmentDate)

-- ****************************************************************************************************
-- Set initial values for variables
-- ****************************************************************************************************
---set @StartDate = (SELECT ISNULL(MAX(AppointmentDate),''1 January 2010'') FROM [BCUFOUNDATION].[Foundation].[dbo].[PAS_Data_Outpatient] WHERE Source =''PIMS'')

set @StartDate = (SELECT ISNULL(MAX(AppointmentDate),''1 January 2010'') FROM [BCUFOUNDATION].[Foundation].[dbo].[PAS_Data_Outpatient] WHERE Source =''PIMS'' and AppointmentDate < CONVERT(date,getdate()) and LocalOutcome in (''MM-Hosp'',''MM-Pat'',''RESCH-Pat'',''RESCH-Hosp''))

--set @StartDate = DATEADD(mm,-12,getdate())

SET @cityp_natgp = (	select	rfval_refno
	from	reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''NATGP''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @cityp_gmc = (	select	rfval_refno
	from	reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''GMC''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @cityp_dent = (	select	rfval_refno
	from	reference_values
	where	rfvdm_code = ''CITYP''
	and	main_code = ''NATDP''    		
		and	ISNULL(archv_flag,''N'') = ''N'' )


SET @hityp_natnl = (	select	rfval_refno
	from	reference_values
	where	rfvdm_code = ''HITYP''
	 	and	main_code = ''NATNL''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @prtyp_gmprc = ( select rfval_refno
                     from   reference_values
                     where  rfvdm_code = ''PRTYP''
                      and  main_code = ''GMPRC''
                       and  ISNULL(archv_flag,''N'') = ''N'')

------------------------------------------------------------------------------

select DISTINCT

pat.NHS_IDENTIFIER as [NHSNumber],
pat.pasid as [LocalPatientIdentifier],
CONVERT(date,sh.old_start_Dttm) as[DateOfAppointment],
CONVERT(time,sh.old_start_Dttm) as [TimeOfAppointment],
sch.refrl_refno as [SystemLinkID],
CASE WHEN sh.old_start_Dttm < getdate() then ''OA'' else ''OT'' END as [TreatmentType],
CASE WHEN sch.visit_Refno = 213695 then ''P'' else ''6'' END as [IntendedManagement],
prity2.main_code as [PriorityOfHCP],

--pro.main_ident as [HCPAtAppointment],  --old schdl 
(
SELECT TOP 1 proca.Identifier
FROM prof_carer_ids proca
WHERE proca.proca_refno = sch.proca_refno
and cityp_refno = 200921                  --Telepath - why not national? 
and proca.end_dttm IS NULL
and ISNULL(proca.archv_flag,''N'') = ''N''
ORDER BY proca.Create_dttm desc
) as [HCPAtAppointment],


CASE WHEN 
(	select top 1 heoid.identifier
from    
service_point_Sessions sps,
service_points spont,
health_organisations heorg,
health_organisation_ids heoid
where  sh.spssn_Refno = sps.spssn_Refno
and spont.spont_refno = sps.spont_refno
and	spont.heorg_refno = heorg.heorg_refno 
and	heorg.parnt_refno = heoid.heorg_refno
and   heoid.hityp_refno = @hityp_natnl
and   sh.old_start_Dttm between heoid.start_dttm
and isnull(heoid.end_dttm,sh.old_start_Dttm )
and   ISNULL(heoid.archv_flag,''N'') = ''N''
) = ''7A1'' then 

(SELECt top 1 HEOID.IDENTIFIER 
from HEALTH_ORGANISATION_IDS heoid
join HEALTH_ORGANISATIONS ho
on ho.HEORG_REFNO = heoid.HEORG_REFNO 
and   heoid.hityp_refno = @hityp_natnl
and   sh.old_start_Dttm between heoid.start_dttm
and isnull(heoid.end_dttm,sh.old_start_Dttm )
where ho.MAIN_IDENT = ho1.MAIN_IDENT 
)

else 
(	select top 1 heoid.identifier
from    
service_point_Sessions sps,
service_points spont,
health_organisations heorg,
health_organisation_ids heoid
where sps.spssn_Refno = sh.SPSSN_refno    
and spont.spont_refno = sps.spont_refno
and	spont.heorg_refno = heorg.heorg_refno 
and	heorg.parnt_refno = heoid.heorg_refno
and   heoid.hityp_refno = @hityp_natnl
and   sh.old_start_Dttm between heoid.start_dttm
and isnull(heoid.end_dttm,sh.old_start_Dttm )
and   ISNULL(heoid.archv_flag,''N'') = ''N''
)
 END
as LocationOfAppointment,

null as [TypeOfAppointment],


CASE WHEN sh.EXTERNAL_KEY = ''Manual Move''
		THEN 
		  Case when sh.murqb_refno in (208170,213840,212935,205025) then ''MM-Hosp''
             when sh.MURQB_REFNO in (208526) then ''MM-Pat'' 
             WHEN sh.MURQB_REFNO = 208546 then 
                                 CASE WHEN sh.MOVRN_REFNO in (201475,213732,213733,214466,213890) then ''MM-Pat'' 
                                      else ''MM-Hosp''
                                      END
                                  else ''0''
            END
         when sh.EXTERNAL_KEY = ''Reschedule'' 
	     Then Case when sh.murqb_refno in (208170,213840,212935,205025) then ''RESCH-Hosp''
                   when sh.MURQB_REFNO in (208526) then ''RESCH-Pat'' 
                   WHEN sh.MURQB_REFNO = 208546 then 
                                       CASE WHEN sh.MOVRN_REFNO in (201475,213732,213733,214466,213890) then ''RESCH-Pat'' 
                                            else ''RESCH-Hosp''
                                        END
                    else ''0''
              END
		END as [OutcomeOfAppointment],


referrer.MAIN_IDENT  as [Referrer],
heorg.MAIN_IDENT  as [ReferringOrganisation],

CAST('''' as varchar(50)) as [GPAtTimeOfActivity],        -- updated later
CAST('''' as varchar(50)) as [GPPracticeAtTimeOfActivity],-- updated later
CAST('''' as varchar(10)) as [PostcodeAtTimeOfActivity],  -- updated later
CAST('''' as varchar(5)) as [LHBOfResidence],             -- updated later

dbo.IS_GetRefValID(''NHS'',sch.adcat_refno) as [PatientCategory],
null as [CommissionerType],
null as [GPRefNoOnTreatment],
sp.spont_Refno as [ClinicNumber],
CONVERT(time,sh.old_start_Dttm) as [TimeOfTreatment],
null as [TimeLeftAppointment],
null as [StaffGrade],
null as [ReasonForDNA],
CASE WHEN ISNUMERIC(schspec.main_ident) = ''1'' then schspec.main_ident + ''00'' else schspec.main_ident end as [SpecialtyOfAppointment],
null as [TimeHCPReady],
null as [Commissioner],
null as [PatientClassification],
null as [ClinicSlotKey],

sch.start_dttm as HWL_SchDate,
sch.attnd_refno as HWL_attend,

(select top 1 CONVERT(date,sch1.start_Dttm)
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc)
as [DateOfNextApproxAppointment],

sch.create_dttm as [DateAppointmentCreated],
sch.modif_dttm  as [DateAppointmentLastModified],
null as [IsNextAppointmentNeeded],
null as [NextAppointmentDue],

(select top 1 pro1.main_ident
from prof_Carers pro1
join SCHEDULES sch1
on sch1.proca_Refno=pro1.proca_Refno
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
as [HCPOfNextAppointment],

null as [AppointmentConfirmed],
sch.comments as [OtherInformation],

(select top 1 heoid.identifier
from service_points sp1
join SCHEDULES sch1
on sch1.spont_Refno = sp1.spont_Refno
join health_organisations heorg
on heorg.heorg_refno = sp1.heorg_refno
join health_organisation_ids heoid
on heoid.heorg_refno = heorg.parnt_Refno
and   heoid.hityp_refno = @hityp_natnl
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc)
as [LocationOfNextAppointment],

CAST(sch.schdl_refno AS VARCHAR(20) ) as [ActNoteKey],
ref.MAIN_CODE as [OutcomeReason],
null as [IgnorePartialBooking],
CAST('''' as varchar(100)) as [AppointmentDirective],
null as [FutureAppointmentDirective],
CONVERT(date,sh.CREATE_DTTM) as [DateNotified], -- as original
null as [ClinicCode],

(select top 1 heoid.identifier
from service_points sp1
join SCHEDULES sch1
on sch1.spont_Refno = sp1.spont_Refno
join health_organisations heorg
on heorg.heorg_refno = sp1.heorg_refno
join health_organisation_ids heoid
on heoid.heorg_refno = heorg.parnt_Refno
and   heoid.hityp_refno = @hityp_natnl
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc)
as [NextAppointmentPreferredClinic],


(select top 1 pro1.main_ident
from prof_Carers pro1
join SCHEDULES sch1
on sch1.proca_Refno=pro1.proca_Refno
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
as [HCPAtNextAppointment],


null as [AppointmentType],
null as [ReasonForRemoval],

(select top 1 CONVERT(date,sch1.start_Dttm)
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
as [DateOfNextAppointment],


(select top 1 sch1.schdl_refno
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
 as [NextAppointmentActNoteKey],


nullif(rtrim(prity2.main_code), '''') AS [HealthRiskFactor], -- defaulted as this is OP dataset and this is priority as set by consultant HWL
null as [NextHealthRiskFactor],
null as [PathwayEventDate],
null as [PathwayEventType],
refrl.refrl_Refno as [PathwayUPI],
null as [PathwayEventSource],
null as [PathwayKey],
null as [PathwayCreateDate],
null as [PathwayModifyDate],
''West'' as [Area],
''Pims'' as [Source],
convert(date,ISNULL(refrl.ordta_dttm,refrl.recvd_dttm)) as [DateReferred],
convert(date,refrl.recvd_dttm) as [DateClinicallyReferred],
null as [DateOnSystem],
CASE WHEN ISNUMERIC(refspec.main_ident) = ''1'' then refspec.main_ident + ''00'' else refspec.main_ident END as  [SpecialtyOnReferral],
dbo.IS_GetRefValID(''NHS'',refrl.sorrf_refno) as [SourceOfReferral],
null as [ClinicalCondition],
CAST('''' as varchar(8000)) as [NotesOnReferral],      -- updated later
null as [GPRefNoOnReferral],
null as [ClinicScheduleID],
null as [ClinicSessionType],
sp.description as [ClinicSessionLocation],
null as [Procedure1],
null as [Procedure2],
null as [Procedure3],
null as [Procedure4],
null as [Procedure5],
null as [Procedure6],
null as [Procedure7],
null as [Procedure8],
null as [Procedure9],
null as [Procedure10],
null as [Procedure11],
null as [Procedure12],

CAST('''' as varchar(8000)) as [OtherInformationPrevious],  --updated later
CAST('''' as varchar(20)) as [ActNoteKeyPrevious],          --updated later
CAST('''' as date) as [DateOfLastAppointment],              --updated later
null as [GPRefNoPrevious],

CASE WHEN CONVERT(date,sch.create_dttm) is null then null 
     else DATEDIFF(dd,CONVERT(date,sch.create_dttm) ,CONVERT(date,sch.start_Dttm)) 
     END AS [DaysNotifiedBeforeAppointment],

null as [DatePatientInitiatedFollowUp],
null as [ConsultationMethod],        -- updated later
null as [VirtualContactType],        -- updated later
null as [NextConsultationMethod],    -- updated later
null as [NextVirtualContactType],    -- updated later
null as [ContactDetailsForVirtualAppointment],
null as [UnsuccessfulAttemptToContact1],
null as [UnsuccessfulAttemptToContact2],
SCH.PATNT_REFNO as [PatientLinkId],
CONVERT(time,sch.arrived_Dttm) as [TimeArrivedAtAppointment],

(select top 1 spec1.main_ident
from SPECIALTIES spec1
join SCHEDULES sch1
on sch1.spect_Refno = spec1.spect_Refno
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
 as [SpecialtyOfNextAppointment],

sch.wlist_refno as [WaitingListLinkID]


----------------------------------------- End -- 1311 format 


-- these not in 1311 format 
-- want visit & atttend status & these below want as is?
-- kerry do you want the trauma subspec flag
--

/*
prity.main_code as [ReferrerPriority],

CASE WHEN ISNUMERIC(prospec.MAIN_IDENT) = ''1'' then prospec.main_ident + ''00'' else prospec.main_ident end as [HCPSpecialty],

Case when sh.murqb_refno in (208170,213840,212935,205025) then ''4''
     when sh.MURQB_REFNO in (208526) then ''2'' 
     WHEN sh.MURQB_REFNO = 208546 then 
                         CASE WHEN 
                              sh.MOVRN_REFNO in (201475,213732,213733,214466,213890) then ''2''
                              else ''4''
                         END
     else ''0''
END as [AttendedorDNA],


CASE 
		when sch.visit_Refno = 11388 then ''1''
		WHEN sch.visit_Refno = 11389 then ''2''
		when sch.visit_Refno = 213695 then ''3'' 
		when sch.visit_Refno = 201040 then ''4''
		when sch.visit_refno = 201041 then ''5''
		
		else null END as AttendanceCategory,
	


CONVERT(date,wl.WLIST_DTTM) as [WaitingListDate],

		

Case
   When LEFT(schspec.main_ident,3) in (''110'',''130'') and sps.DESCRIPTION like ''%#%'' then ''1''
   When LEFT(schspec.main_ident,3) in (''110'',''130'') and sps.DESCRIPTION like ''%FRAC%'' then ''1''
   When LEFT(schspec.main_ident,3) in (''110'',''130'') and refrl.SORRF_REFNO =200941 then ''1''
   Else ''0''
End as TraumaSubSpec


*/


	

into #op_Table

from SCHEDULE_HISTORIES sh
join SCHEDULES sch
on sch.SCHDL_REFNO = sh.SCHDL_REFNO 

join patients pat	on pat.patnt_Refno = sch.patnt_Refno
join REFERENCE_VALUES ref	on ref.RFVAL_REFNO = sh.movrn_Refno
left join prof_Carers pro	on pro.proca_Refno = sh.OLD_PROCA_REFNO
left join service_point_Sessions sps	on sps.spssn_Refno = sh.spssn_Refno
left join service_points sp	on sp.spont_Refno = sps.spont_refno
left join REFERRALS refrl	on refrl.REFRL_REFNO = sch.REFRL_REFNO 
left join SPECIALTIES refspec	on refspec.spect_Refno = refrl.REFTO_SPECT_REFNO 
left join SPECIALTIES schspec	on schspec.SPECT_REFNO = sh.old_SPECT_REFNO 
left join PROF_CARER_SPECIALTIES prospeclink	on prospeclink.PROCA_REFNO = pro.PROCA_REFNO 
	                                                                                     and prospeclink.END_DTTM is null
	                                                                                     and ISNULL(prospeclink.archv_flag,''N'') = ''N''
	                                                                                     and prospeclink.CSTYP_REFNO = 12143
left join SPECIALTIES prospec on prospec.SPECT_REFNO = prospeclink.SPECT_REFNO 
left join PROF_CARERS referrer on referrer.PROCA_REFNO = refrl.REFBY_PROCA_REFNO 
left join HEALTH_ORGANISATIONS heorg on heorg.HEORG_REFNO = refrl.REFBY_HEORG_REFNO 

join reference_Values sorrf on sorrf.rfval_Refno = refrl.sorrf_refno
join reference_Values scocm on scocm.rfval_Refno = sch.scocm_refno
join reference_Values prity on prity.rfval_Refno = refrl.prity_refno
join reference_Values prity2 on prity2.rfval_Refno = sch.prity_refno
join reference_Values adcat on adcat.rfval_Refno = sch.adcat_refno
join HEALTH_ORGANISATIONS ho1 on ho1.HEORG_REFNO = sp.HEORG_REFNO 
join HEALTH_ORGANISATIONS ho2 on ho2.HEORG_REFNO = ho1.PARNT_REFNO 
left join Waiting_list_entries wl on wl.WLIST_REFNO = sch.WLIST_REFNO 
	

where 

ISNULL(sh.ARCHV_FLAG,''N'') = ''N''
and sh.EXTERNAL_KEY in (''Manual Move'',''Reschedule'')
and sch.SCTYP_REFNO = 12186                    -- Outpatient schedule
and ISNULL(sch.archv_flag,''N'') = ''N''

and sh.old_start_Dttm > @StartDate
--and sh.old_start_Dttm >''1 January 2010''


and sch.SATYP_REFNO <> 205912                 ---  Not Ward
--and sch.patnt_refno=2240405   -- hwl track patient

---------------------------------------------------------------------------------------
-- Updates 
---------------------------------------------------------------------------------------

-- Registerd GP At Time of Activity 
       UPDATE        #op_table
       SET    GPAtTimeOfActivity = prcai.identifier,
              GPPracticeAtTimeOfActivity = heoid.identifier
       FROM   #op_table tmp
              INNER JOIN patient_prof_carers patpc ON tmp.PatientLinkId = patpc.patnt_refno
              INNER JOIN prof_carer_ids prcai ON patpc.proca_refno = prcai.proca_refno
              INNER JOIN health_organisation_ids heoid ON patpc.heorg_refno = heoid.heorg_refno
       WHERE  patpc.prtyp_refno = @prtyp_gmprc
         AND  prcai.cityp_refno = @cityp_natgp
         AND  heoid.hityp_refno = @hityp_natnl
         --AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN patpc.start_dttm AND ISNULL(patpc.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         --AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN prcai.start_dttm AND ISNULL(prcai.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         and  tmp.DateOfAppointment between patpc.start_dttm and isnull(patpc.end_dttm, getdate())
		 and  tmp.DateOfAppointment between prcai.start_dttm and isnull(prcai.end_dttm, getdate())
		 AND  ISNULL(patpc.archv_flag,''N'') = ''N''
         AND  ISNULL(prcai.archv_flag,''N'') = ''N''
         AND  ISNULL(heoid.archv_flag,''N'') = ''N''
	
-- Registerd GP At Time of Activity  - for future appointments  - default to current GP
       UPDATE        #op_table
       SET    GPAtTimeOfActivity = prcai.identifier,
              GPPracticeAtTimeOfActivity = heoid.identifier
       FROM   #op_table tmp
              INNER JOIN patient_prof_carers patpc ON tmp.PatientLinkId = patpc.patnt_refno
              INNER JOIN prof_carer_ids prcai ON patpc.proca_refno = prcai.proca_refno
              INNER JOIN health_organisation_ids heoid ON patpc.heorg_refno = heoid.heorg_refno
       WHERE  patpc.prtyp_refno = @prtyp_gmprc
         AND  prcai.cityp_refno = @cityp_natgp
         AND  heoid.hityp_refno = @hityp_natnl
         --AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN patpc.start_dttm AND ISNULL(patpc.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         --AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN prcai.start_dttm AND ISNULL(prcai.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         and  tmp.DateOfAppointment > getdate() and patpc.end_dttm is null 
		 and  tmp.DateOfAppointment > getdate()and prcai.end_dttm is null
		 AND  ISNULL(patpc.archv_flag,''N'') = ''N''
         AND  ISNULL(prcai.archv_flag,''N'') = ''N''
         AND  ISNULL(heoid.archv_flag,''N'') = ''N''	


		
/*

--HWL CHECK version 
select 
s1.patnt_refno,
prcai.identifier,
heoid.identifier
       FROM   schedules s1
              INNER JOIN patient_prof_carers patpc ON s1.patnt_refno = patpc.patnt_refno
              INNER JOIN prof_carer_ids prcai ON patpc.proca_refno = prcai.proca_refno
              INNER JOIN health_organisation_ids heoid ON patpc.heorg_refno = heoid.heorg_refno
       WHERE  patpc.prtyp_refno = 4054
         AND  prcai.cityp_refno = 8
         AND  heoid.hityp_refno = 4050
         --AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN patpc.start_dttm AND ISNULL(patpc.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         --AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN prcai.start_dttm AND ISNULL(prcai.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         and  S1.START_DTTM between patpc.start_dttm and isnull(patpc.end_dttm, getdate())
		 and  S1.START_DTTM between prcai.start_dttm and isnull(prcai.end_dttm, getdate())
		 AND  ISNULL(patpc.archv_flag,''N'') = ''N''
         AND  ISNULL(prcai.archv_flag,''N'') = ''N''
         AND  ISNULL(heoid.archv_flag,''N'') = ''N''
		 and S1.PATNT_REFNO=304640


*/





-- PostCode At Time of Activity

              UPDATE        #op_table
       SET    PostcodeAtTimeOfActivity = REPLACE(addss.pcode,'' '','''')
       FROM   #op_table tmp
              INNER JOIN address_roles roles ON tmp.PatientLinkId= roles.patnt_refno
              INNER JOIN addresses addss     ON roles.addss_refno = addss.addss_refno
       WHERE  roles.rotyp_code = ''HOME''
         AND  addss.adtyp_code = ''POSTL''
 --        AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN roles.start_dttm AND ISNULL(roles.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         AND  DateOfAppointment BETWEEN roles.start_dttm and isnull(roles.end_dttm, getdate())
         AND  ISNULL(roles.archv_flag,''N'') = ''N''
         AND  ISNULL(addss.archv_flag,''N'') = ''N''


-- PostCode At Time of Activity  - Future Appointment - Default to current

              UPDATE        #op_table
       SET    PostcodeAtTimeOfActivity = REPLACE(addss.pcode,'' '','''')
       FROM   #op_table tmp
              INNER JOIN address_roles roles ON tmp.PatientLinkId= roles.patnt_refno
              INNER JOIN addresses addss     ON roles.addss_refno = addss.addss_refno
       WHERE  roles.rotyp_code = ''HOME''
         AND  addss.adtyp_code = ''POSTL''
 --        AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN roles.start_dttm AND ISNULL(roles.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         AND  DateOfAppointment > getdate() and roles.end_dttm is null
         AND  ISNULL(roles.archv_flag,''N'') = ''N''
         AND  ISNULL(addss.archv_flag,''N'') = ''N''



 -- Patient Local Health Board of Residence

       UPDATE        #op_table
       SET  LHBOfResidence   = 
                     CASE
                     WHEN tmp.DateOfAppointment < ''2013-04-01 00:00:00.000'' THEN pcode.state_code 
					 ELSE pcode.pcg_code 
					 END
       FROM   #op_table tmp
              INNER JOIN postcodes pcode  ON tmp.PostcodeAtTimeOfActivity = pcode.pcode
       WHERE  ISNULL(pcode.archv_flag,''N'') = ''N''


--Update Key to make it unique from OP script
	   UPDATE #op_Table
	   SET ActNoteKey = ''RESCH-'' + ActNoteKey




-- Referral Notes

UPDATE #op_table
       SET NotesOnReferral = left(convert(varchar(max),notes2.note),250)
FROM #op_table tmp
     INNER JOIN note_roles notrl2 on SystemLinkID = notrl2.sorce_refno
     INNER JOIN notes notes2 ON notes2.notes_refno = notrl2.notes_refno
WHERE isnull(notrl2.archv_flag,''N'')= ''N''
AND notrl2.sorce_code = ''RFCMT''



--  Appointment Directive 
--
--  as per FUWL SP on Production: NWW_IS_XTR_FUWL
--  No Reference data - users select text from drop down

--get text
UPDATE #op_table
SET AppointmentDirective= n99.note
from notes n99
join note_roles as nr on nr.notes_refno = n99.notes_refno
where nr.sorce_refno = #op_table.WaitingListLinkID
and nr.sorce_code = ''WLPHN''
and n99.notes_refno = (select max(nr2.notes_refno)
                     from note_roles nr2
					 where nr2.sorce_refno = #op_table.WaitingListLinkID
					 and isnull(nr2.archv_flag,''N'')=''N''
					 and nr2.notes_refno in (select (n100.notes_refno)
                                             from notes n100
					                         where n100.note like ''Valid%''
                                             and isnull(n100.archv_flag,''N'')=''N''))
and isnull(n99.archv_flag,''N'')=''N''
and isnull(nr.archv_flag,''N'')=''N''


-- update text to code
-- drop down text for users to select from on screen only / no reference table exists
-- as per PRODUCTION: Get_Pas_data_Waiters_west_FUFB_21  (Foundation Get_Pas_Data_Waiters_West_FUFB)

 UPDATE #op_table
 SET AppointmentDirective = ''VA'' 
 FROM #op_table
 WHERE AppointmentDirective = ''Validated by Admin'' 
 OR AppointmentDirective =''Validated by AdminValidated by Admin''

 UPDATE #op_table
 SET AppointmentDirective= ''VA1'' 
 FROM #op_table
 WHERE AppointmentDirective = ''Validated by Admin - both YGC/YG appointments needed''

 UPDATE #op_table
 SET AppointmentDirective = ''VC1'' 
 FROM #op_table
 WHERE AppointmentDirective = ''validated in backlog rv and needs appt with IT Validated by Clinician Appointment Required''

 UPDATE #op_table
 SET AppointmentDirective = ''VC'' 
 FROM #op_table
 WHERE AppointmentDirective = ''Validated by Clinician Appointment Required''

 UPDATE #op_table
 SET AppointmentDirective = ''VR'' 
 FROM #op_table
 WHERE AppointmentDirective = ''Validate - Notes Requested''














/*
--operand clash error - text incomp with int


--HealthRiskFactor
-- West Waiting List - Eye Care Priority Codes included in this , was changed as previously taken from referral.prity!
-- as per West IP/DC/OP Wlist SP : nww_sp_eis_wlist_hwl

UPDATE #op_table
SET HealthRiskFactor= dbo.IS_GetRefValID(''NHS'',wl.prity_refno) 
from #op_table
join Waiting_List_Entries wl on wl.wlist_refno = #op_table.WaitingListLinkID


-- Previous Appointment Group 
-- Extracting the Last Attended 

UPDATE        #op_table
set 
   DateOfLastAppointment = CONVERT(date,LastAppt.start_dttm),
	  ActNoteKeyPrevious = LastAppt.schdl_refno,
OtherInformationPrevious = LastAppt.comments

FROM   #op_table tmp
 join schedules LastAppt on tmp.PatientLinkId = LastAppt.patnt_refno and tmp.SystemLinkID = LastAppt.refrl_refno 
                           and LastAppt.schdl_refno = (select max(s2.schdl_refno)
                                                       from schedules s2
							                           where ISNULL(s2.archv_flag,''N'') = ''N''
						                               and s2.attnd_refno in (''11306'',''203905'',''203906'')  
						                               and s2.start_dttm < tmp.DateOfAppointment
						                               and s2.refrl_refno = tmp.SystemLinkID)


*/

select *
from #op_Table 
drop table #op_Table 



	'
	) AT [7A1AUSRVIPMSQLR\REPORTS];

END
GO
