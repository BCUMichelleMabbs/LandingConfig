SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: May 2020
-- Description:	Extract of all Outpatient Data
-- 25/08/2021 : Heather Amended Version for Dataset=1311
-- field list 1311 as create table
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatients_West_HWL]
	
AS
BEGIN

EXEC('
USE [iPMProduction]


	SET NOCOUNT ON;

---- Declare required variables
DECLARE
@cityp_natgp	numeric(10,0),
@cityp_gmc	    numeric(10,0),
@cityp_dent	    numeric(10,0),
@hityp_natnl	numeric(10,0),
@prtyp_gmprc    numeric(10,0),

GPAtTimeOfActivity             varchar(8),
GPPracticeAtTimeOfActivity     varchar(10),
PostcodeAtTimeOfActivity       varchar(8),
LHBOfResidence                 varchar(5),


@StartDate      date,
@DateOfAppointment AS DATE = ''01 April 2021''
	
--DECLARE @DateOfAppointment AS DATE = (SELECT ISNULL(MAX(DateOfAppointment),''1 September 2020'') FROM [Foundation].[dbo].[PAS_Data_Outpatients] WHERE Source =''pims'' and area = ''west'' )
  


SET @cityp_natgp = (	select	rfval_refno
	from	dbo.reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''NATGP''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @cityp_gmc = (	select	rfval_refno
	from	dbo.reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''GMC''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @cityp_dent = (	select	rfval_refno
	from	dbo.reference_values
	where	rfvdm_code = ''CITYP''
	 	and	main_code = ''NATDP''
		and	ISNULL(archv_flag,''N'') = ''N'' )


SET @hityp_natnl = (	select	rfval_refno
	from	dbo.reference_values
	where	rfvdm_code = ''HITYP''
	 	and	main_code = ''NATNL''
		and	ISNULL(archv_flag,''N'') = ''N'' )

SET @prtyp_gmprc = ( select rfval_refno
    from   reference_values
    where  rfvdm_code = ''PRTYP''
    and  main_code = ''GMPRC''
    and  ISNULL(archv_flag,''N'') = ''N'' )


create Table #op_Table (

NHSNumber                      varchar(10),
LocalPatientIdentifier         varchar(8),
DateOfAppointment              datetime,
TimeOfAppointment              datetime,
SystemLinkID                   varchar(20),
TreatmentType                  varchar(2),
IntendedManagement             varchar(2),
PriorityOfHCP                  varchar(2),
HCPAtAppointment               varchar(8),
LocationOfAppointment          varchar(10),
TypeOfAppointment              varchar(2),
OutcomeOfAppointment           varchar(2),
Referrer                       varchar(8),
ReferringOrganisation          varchar(10),
GPAtTimeOfActivity             varchar(8),
GPPracticeAtTimeOfActivity     varchar(10),
PostcodeAtTimeOfActivity       varchar(8),
LHBOfResidence                 varchar(5),
PatientCategory                varchar(10),
CommissionerType               varchar(2),
GPRefNoOnTreatment             varchar(100),
ClinicNumber                   varchar(20),
TimeOfTreatment                datetime,
TimeLeftAppointment            datetime,
StaffGrade                     varchar(10),
ReasonForDNA                   varchar(10),
SpecialtyOfAppointment         varchar(6),
TimeHCPReady                   datetime,
Commissioner                   varchar(5),
PatientClassification          varchar(2),
ClinicSlotKey                  varchar(100),
DateOfNextApproxAppointment    datetime,
DateAppointmentCreated         datetime,
DateAppointmentLastModified    datetime,
IsNextAppointmentNeeded        varchar(2),
NextAppointmentDue             varchar(6),
HCPOfNextAppointment           varchar(8),
AppointmentConfirmed           varchar(2),
OtherInformation               varchar(8000),
LocationOfNextAppointment      varchar(8),
ActNoteKey                     varchar(10),
OutcomeReason                  varchar(4),
IgnorePartialBooking           varchar(2),
AppointmentDirective           varchar(4),
FutureAppointmentDirective     varchar(4),
DateNotified                   datetime,
ClinicCode                     varchar(20),
NextAppointmentPreferredClinic varchar(10),
HCPAtNextAppointment           varchar(10),
AppointmentType                varchar(2),
ReasonForRemoval               varchar(2),
DateOfNextAppointment          datetime,
NextAppointmentActNoteKey      varchar(10),
HealthRiskFactor               varchar(4),
NextHealthRiskFactor           varchar(4),
PathwayEventDate               datetime,
PathwayEventType               varchar(4),
PathwayUPI                     varchar(20),
PathwayEventSource             varchar(2),
PathwayKey                     varchar(20),
PathwayCreateDate              datetime,
PathwayModifyDate              datetime,
Area                           varchar(10),
Source                         varchar(10),
DateReferred                   datetime,
DateClinicallyReferred         datetime,
DateOnSystem                   datetime,
SpecialtyOnReferral            varchar(6),
SourceOfReferral               varchar(3),
ClinicalCondition              varchar(10),
NotesOnReferral                varchar(8000),
GPRefNoOnReferral              varchar(100),
ClinicScheduleID               varchar(20),
ClinicSessionType              varchar(2),
ClinicSessionLocation          varchar(6),
Procedure1                     varchar(6),
Procedure2                     varchar(6),
Procedure3                     varchar(6),
Procedure4                     varchar(6),
Procedure5                     varchar(6),
Procedure6                     varchar(6),
Procedure7                     varchar(6),
Procedure8                     varchar(6),
Procedure9                     varchar(6),
Procedure10                    varchar(6),
Procedure11                    varchar(6),
Procedure12                    varchar(6),
OtherInformationPrevious       varchar(8000),
ActNoteKeyPrevious             varchar(10),
DateOfLastAppointment          datetime,
GPRefNoPrevious                varchar(100),
DaysNotifiedBeforeAppointment  int,
DatePatientInitiatedFollowUp   datetime,
ConsultationMethod             varchar(2),
VirtualContactType             varchar(2),
NextConsultationMethod         varchar(2),
NextVirtualContactType         varchar(2),
ContactDetailsForVirtualAppointment varchar(2000),
UnsuccessfulAttemptToContact1       varchar(10),
UnsuccessfulAttemptToContact2       varchar(10),
PatientLinkId                       varchar(50),
TimeArrivedAtAppointment            datetime,
SpecialtyOfNextAppointment          varchar(6),
refrl_refno                         numeric(10,0)

)


insert into #op_Table

select DISTINCT
				
			nullif(rtrim(pat.NHS_IDENTIFIER), '''') AS NHSNumber,
			nullif(rtrim(pat.pasid), '''') AS LocalPatientIdentifier,
			CONVERT(date,sch.start_Dttm) as DateOfAppointment,
			CONVERT(time,sch.start_Dttm) as TimeOfAppointment,
			nullif(rtrim(sch.schdl_refno), '''') AS SystemLinkId,
			CASE 
				WHEN sch.start_dttm < getdate() then ''OA'' 
				else ''OT'' 
			END AS TreatmentType,

			CASE 
				WHEN sch.visit_Refno = 213695 then ''P'' 
				else ''6'' 
			END as IntendedManagement,
			nullif(rtrim(prity2.main_code), '''') AS PriorityOfHCP,
		(
			SELECT TOP 1 proca.Identifier
			FROM prof_carer_ids proca
			WHERE proca.proca_refno = sch.proca_refno
				and cityp_refno = 200921
				and proca.end_dttm IS NULL
				and ISNULL(proca.archv_flag,''N'') = ''N''
			ORDER BY proca.Create_dttm desc
		)  AS HCPatAppointment,
	
			CASE 
				when (select top 1 heoid.identifier 
						from	service_points spont, health_organisations heorg, health_organisation_ids heoid
						where spont.spont_refno = sch.spont_refno
							and spont.heorg_refno = heorg.heorg_refno 
							and heorg.parnt_refno = heoid.heorg_refno
							and heoid.hityp_refno = @hityp_natnl
							and sch.start_dttm between heoid.start_dttm
							and isnull(heoid.end_dttm,sch.START_DTTM )
							and ISNULL(heoid.archv_flag,''N'') = ''N''
						) = ''7A1'' then 
								(
									SELECt top 1 HEOID.IDENTIFIER 
									from HEALTH_ORGANISATION_IDS heoid
									join HEALTH_ORGANISATIONS ho on ho.HEORG_REFNO = heoid.HEORG_REFNO 
										and heoid.hityp_refno = @hityp_natnl
										and sch.start_dttm between heoid.start_dttm
										and isnull(heoid.end_dttm,sch.START_DTTM )
									where ho.MAIN_IDENT = ho1.MAIN_IDENT 
								)
				else	(select top 1 heoid.identifier
						from	service_points spont, health_organisations heorg, health_organisation_ids heoid
						where spont.spont_refno = sch.spont_refno
							and	spont.heorg_refno = heorg.heorg_refno 
							and	heorg.parnt_refno = heoid.heorg_refno
							and   heoid.hityp_refno = @hityp_natnl
							and   (sch.start_dttm between heoid.start_dttm and isnull(heoid.end_dttm,sch.START_DTTM ))
							and   ISNULL(heoid.archv_flag,''N'') = ''N''
						)
			END as LocationOfAppointment,

			dbo.IS_GetRefValID(''NHS'',
				CASE 
						WHEN sch.ATTND_REFNO = 209676 and sch.CANCB_REFNO = 205025 THEN 203907
						WHEN sch.ATTND_REFNO = 209676 and  sch.cancb_Refno =206843 then 201049
						WHEN dbo.IS_GetRefValID(''PIMS'',sch.scocm_refno) = ''DIED'' then 201049
				ELSE 	sch.attnd_refno 
				END) as TypeofAppointment ,

			nullif(rtrim(dbo.IS_GetRefValID(''NHS'',sch.scocm_refno)), '''') as OutcomeOfAppointment, 
			nullif(rtrim(referrer.MAIN_IDENT), '''') as Referrer, 
			nullif(rtrim(heorg.MAIN_IDENT), '''') as ReferringOrganisation, 
			null as GPAtTimeOfActivity,         --updated field
			null as GPPracticeAtTimeOfActivity, --updated field
			null as PostcodeAtTimeOfActivity,   --updated field
			null as LHBOfResidence,             --updated field
			nullif(rtrim(dbo.IS_GetRefValID(''NHS'',sch.adcat_refno)), '''') as PatientCategory,
			null as CommissionerType, 
			null as GPRefNoOnTreatment,
			nullif(rtrim(sp.spont_Refno), '''') as ClinicNumber,
			CONVERT(time,sch.start_dttm) AS TimeOfTreatment,
			CONVERT(time,sch.DEPARTED_DTTM) AS TimeLeftAppointment,
			null as staffgrade,
			null as ReasonForDNA,
			CASE WHEN ISNUMERIC(schspec.main_ident) = ''1'' then schspec.main_ident + ''00'' else schspec.main_ident end as SpecialtyOfAppointment,
			null AS TimeHCPReady,
			null as Commissioner,
			null AS PatientClassification,
			sp.spont_Refno AS ClinicSlotKey,


(select top 1 CONVERT(date,sch1.start_Dttm)
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
order by sch1.start_dttm asc)
as DateOfNextApproxAppointment,

sch.create_dttm as DateAppointmentCreated,
sch.modif_dttm as DateAppointmentLastModified,
null as IsNextAppointmentNeeded,
null as NextAppointmentDue,

(select top 1 pro1.main_ident
from prof_Carers pro1
join SCHEDULES sch1
on sch1.proca_Refno=pro1.proca_Refno
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
---                                                      get next appointment =Not Specified - dont want archived or cancelled no?- HEATHER
and ISNULL(sch1.archv_flag,''N'') = ''N''
and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
as HCPOfNextAppointment,



null as AppointmentConfirmed,
null AS OtherInformation,

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
and sch1.attnd_refno =11540
order by sch1.start_dttm asc)
as LocationOfNextAppointment,

sch.schdl_refno as Actnotekey,                  


nullif(rtrim(dbo.IS_GetRefValMainID(sch.cancr_refno)), '''')  as OutcomeReason,
null AS IgnorePartialBooking,
null AS AppointmentDirective,
null AS FutureAppointmentDirective,

CONVERT(date,sch.cancr_dttm)  as DateNotified,
sps.code as ClinicCode,
null as NextAppointmentPreferredClinic,
null as HCPAtNextAppointment,
------------------------------------------------- also have HCPOfNextAppointment

nullif(rtrim(dbo.IS_GetRefValMainID(sch.visit_refno)), '''')  as AppointmentType,
dbo.IS_GetRefValID(''PIMS'',sch.scocm_refno) as ReasonForRemoval,
	                    		----------------- why want default pims??- not really removal - all outcome 


(select top 1 CONVERT(date,sch1.start_Dttm)   
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
as DateOfNextAppointment,


(select top 1 sch1.schdl_refno
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
 as NextAppointmentActNoteKey,



null as HealthRiskFactor,
null as NextHealthRiskFactor,
null as PathwayEventDate,
null as PathwayEventType,
null as PathwayUPI,
null as PathwayEventSource,
null as PathwayKey,
null as PathwayCreateDate,
null as PathwayModifyDate,
''West'' as Area,
''Pims'' AS Source,
convert(date,ISNULL(refrl.ordta_dttm,refrl.recvd_dttm)) as DateReferred,
convert(date,refrl.recvd_dttm) as DateClinicallyReferred,
CONVERT(date,wl.WLIST_DTTM) as DateOnSystem,

CASE 
   WHEN ISNUMERIC(refspec.main_ident) = ''1'' then refspec.main_ident + ''00'' 
   else refspec.main_ident 
END AS SpecialtyOnReferral,

nullif(rtrim(dbo.IS_GetRefValID(''NHS'',refrl.sorrf_refno)), '''') as SourceOfReferal,
NULL as ClinicalCondition,
null as NotesOnReferral,        -- updated field
null as GPRefNoOnReferral,
null as ClinicScheduleID,
null AS ClinicSessionType,
nullif(rtrim(sp.description), '''') AS ClinicSessionLocation,

		--null as ReferralLinkId, -- added into the foundation table as a computed field
		--null as OutpatientLinkId,-- added into the foundation table as a computed field
		--null as InpatientLinkId,-- added into the foundation table as a computed field
		--null as patientlinkid,  -- added into the foundation table as a computed field    


NULLIF(LEFT(dbo.IS_GetDiagProc(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''PRIME''),10),'''') AS Procedure1,
NULLIF(LEFT(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),4),'''') AS Procedure2,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),5,4) AS Procedure3,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),9,4) AS Procedure4,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),13,4) AS Procedure5,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),17,4) AS Procedure6,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),21,4) AS Procedure7,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),25,4) AS Procedure8,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),29,4) AS Procedure9,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),34,4) AS Procedure10,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),37,4) AS Procedure11,
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),41,4) AS Procedure12,
null as OtherInformationPrevious,
null as ActNoteKeyPrevious,
null as DateOfLastAppointment,
null as GPRefNoPrevious,

CASE 
   WHEN CONVERT(date,sch.create_dttm) is null then null 
   else DATEDIFF(dd,CONVERT(date,sch.create_dttm) ,CONVERT(date,sch.start_Dttm)) 
END AS DaysNotifiedBeforeAppointment,
		
null as DatePatientInitiatedFollowUp,
null as ConsultationMethod,
null as VirtualContactType,
null as NextConsultationMethod,
null as NextVirtualContactType,
null as ContactDetailsForVirtualAppointment,
null as UnsuccessfulAttemptToContactPatient1,
null as UnsuccessfulAttemptToContactPatient2,
sch.patnt_refno  as PatientLinkId,    ----------------------------- Hwl reinstated want this inorder to be able to do updates
CONVERT(time,sch.arrived_Dttm)  AS TimeArrivedAtAppointment,
null  as SpecialtyOfNextAppointment,
sch.refrl_refno as refrl_refno


from dbo.schedules sch
join dbo.patients pat 	on pat.patnt_Refno = sch.patnt_Refno
left join dbo.prof_Carers pro 	on pro.proca_Refno = sch.proca_refno
left join dbo.service_points sp on sp.spont_Refno = sch.spont_Refno
left join dbo.REFERRALS refrl 	on refrl.REFRL_REFNO = sch.REFRL_REFNO 
left join dbo.SPECIALTIES refspec 	on refspec.spect_Refno = refrl.REFTO_SPECT_REFNO 
left join dbo.SPECIALTIES schspec 	on schspec.SPECT_REFNO = sch.SPECT_REFNO 
left join dbo.PROF_CARER_SPECIALTIES prospeclink 	on prospeclink.PROCA_REFNO = pro.PROCA_REFNO and prospeclink.END_DTTM is null and ISNULL(prospeclink.archv_flag,''N'') = ''N'' 	and prospeclink.CSTYP_REFNO = 12143
left join dbo.SPECIALTIES prospec 	on prospec.SPECT_REFNO = prospeclink.SPECT_REFNO 
left join PROF_CARERS referrer 	on referrer.PROCA_REFNO = refrl.REFBY_PROCA_REFNO 
left join HEALTH_ORGANISATIONS heorg 	on heorg.HEORG_REFNO = refrl.REFBY_HEORG_REFNO 
left join dbo.service_point_Sessions sps 	on sps.SPSSN_REFNO = sch.SPSSN_REFNO 
join dbo.reference_Values sorrf on sorrf.rfval_Refno = refrl.sorrf_refno
join dbo.reference_Values scocm on scocm.rfval_Refno = sch.scocm_refno
join dbo.reference_Values prity on prity.rfval_Refno = refrl.prity_refno
join dbo.reference_Values prity2 on prity2.rfval_Refno = sch.prity_refno
join dbo.reference_Values adcat on adcat.rfval_Refno = sch.adcat_refno
join dbo.HEALTH_ORGANISATIONS ho1 on ho1.HEORG_REFNO = sp.HEORG_REFNO 
join dbo.HEALTH_ORGANISATIONS ho2 on ho2.HEORG_REFNO = ho1.PARNT_REFNO 
left join dbo.Waiting_list_entries wl on wl.WLIST_REFNO = sch.WLIST_REFNO 
	

where sch.SCTYP_REFNO = 12186
and ISNULL(sch.archv_flag,''N'') = ''N''
and CONVERT(Date,sch.start_Dttm)> @DateOfAppointment 
and sch.SATYP_REFNO <> 205912






--UPDATES ------------------------------------------------------------------------------

/*

-- Reg gp details

       UPDATE #op_table
       SET    GPAtTimeOfActivity = pc.main_ident,
              GPPracticeAtTimeOfActivity = ho.main_ident
       FROM   #op_table tmp
              INNER JOIN patient_prof_carers patpc ON tmp.PatientLinkId = patpc.patnt_refno
              INNER JOIN prof_carers pc ON patpc.proca_refno = pc.proca_refno
              INNER JOIN health_organisations ho ON patpc.heorg_refno = ho.heorg_refno
       WHERE  patpc.prtyp_refno = @prtyp_gmprc

         AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.TimeOfAppointment ,108)) BETWEEN patpc.start_dttm AND ISNULL(patpc.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.TimeOfAppointment ,108)))
         AND  ISNULL(patpc.archv_flag,''N'') = ''N''
         AND  ISNULL(ho.archv_flag,''N'') = ''N''
		 AND  ISNULL(pc.archv_flag,''N'') = ''N''





 
-- Address / pcode

       UPDATE #op_table
       SET    PostcodeAtTimeOfActivity = REPLACE(addss.pcode,'' '','''')
       FROM   #op_table tmp
              INNER JOIN address_roles roles ON tmp.PatientLinkId = roles.patnt_refno
              INNER JOIN addresses addss ON roles.addss_refno = addss.addss_refno
       WHERE  roles.rotyp_code = ''HOME''
         AND  addss.adtyp_code = ''POSTL''
         AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.TimeOfAppointment ,108)) BETWEEN roles.start_dttm AND ISNULL(roles.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.TimeOfAppointment ,108)))
         AND  ISNULL(roles.archv_flag,''N'') = ''N''
         AND  ISNULL(addss.archv_flag,''N'') = ''N''


-- Patient Local Health Board of Residence

       UPDATE #op_table
       SET    Commissioner = 
                     CASE
                     WHEN tmp.DateOfAppointment < ''2013-04-01'' THEN
                     pcode.state_code ELSE pcode.pcg_code END
       FROM #op_table tmp 
				INNER JOIN postcodes pcode ON tmp.PostcodeAtTimeOfActivity = pcode.pcode
       WHERE  ISNULL(pcode.archv_flag,''N'') = ''N''




UPDATE #op_table
SET    GPAtTimeOfActivity = ''HWL1'',
       GPPracticeAtTimeOfActivity = ''hwl1''
FROM #op_table tmp 
where GPAtTimeOfActivity is null 


-- Referral Notes

UPDATE #op_table
       SET NotesOnReferral = left(convert(varchar(max),notes2.note),250)
FROM #op_table tmp
     INNER JOIN note_roles notrl2 on tmp.refrl_refno = notrl2.sorce_refno
     INNER JOIN notes notes2 ON notes2.notes_refno = notrl2.notes_refno
WHERE isnull(notrl2.archv_flag,''N'')= ''N''
AND notrl2.sorce_code = ''RFCMT''


*/
-----------------------------------------

select *
from #op_Table 
drop table #op_Table 



')AT [7A1AUSRVIPMSQL]


END



GO
