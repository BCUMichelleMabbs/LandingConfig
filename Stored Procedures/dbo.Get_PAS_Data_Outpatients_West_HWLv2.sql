SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatients_West_HWLv2]
	
AS
BEGIN

-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: May 2020
-- Description:	Extract of all Outpatient Data
-- 25/08/2021 : Heather Amended Version for Dataset=1311          
-- 01/09/2021 : NEED TO CONFIRM CONSULT / VIRTUAL TYPE FIELDS
--
--IDS --   (some used in updates)
--SystemLinkID	    refrl_refno
--PatientLinkId	    patnt_refno
--ActNoteKey	    schdl_refno
--PathwayUPI        refrl_refno
--WaitingListLinkID wlist_refno
-- =============================================


EXEC('
USE [iPMReports]


	SET NOCOUNT ON;

---- Declare required variables
DECLARE
@cityp_natgp	numeric(10,0),
@cityp_gmc	    numeric(10,0),
@cityp_dent	    numeric(10,0),
@hityp_natnl	numeric(10,0),
@prtyp_gmprc    numeric(10,0),
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





select DISTINCT
				
nullif(rtrim(pat.NHS_IDENTIFIER), '''') AS [NHSNumber],
nullif(rtrim(pat.pasid), '''') AS [LocalPatientIdentifier],
CONVERT(date,sch.start_Dttm) as [DateOfAppointment],
CONVERT(time,sch.start_Dttm) as [TimeOfAppointment],
nullif(rtrim(sch.refrl_refno), '''') AS [SystemLinkId], 
			
CASE 
   WHEN sch.start_dttm < getdate() then ''OA'' 
   else ''OT'' 
END AS [TreatmentType],

CASE 
	WHEN sch.visit_Refno = 213695 then ''P'' 
	else ''6'' 
END as [IntendedManagement],
nullif(rtrim(prity2.main_code), '''') AS [PriorityOfHCP],

(
SELECT TOP 1 proca.Identifier
FROM prof_carer_ids proca
WHERE proca.proca_refno = sch.proca_refno
		and cityp_refno = 200921
		and proca.end_dttm IS NULL
		and ISNULL(proca.archv_flag,''N'') = ''N''
		ORDER BY proca.Create_dttm desc
)  AS [HCPatAppointment],
	
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
END as [LocationOfAppointment],

			dbo.IS_GetRefValID(''NHS'',
				CASE 
						WHEN sch.ATTND_REFNO = 209676 and sch.CANCB_REFNO = 205025 THEN 203907
						WHEN sch.ATTND_REFNO = 209676 and  sch.cancb_Refno =206843 then 201049
						WHEN dbo.IS_GetRefValID(''PIMS'',sch.scocm_refno) = ''DIED'' then 201049
				ELSE 	sch.attnd_refno 
				END) as [TypeofAppointment] ,


nullif(rtrim(dbo.IS_GetRefValID(''NHS'',sch.scocm_refno)), '''') as [OutcomeOfAppointment], 
nullif(rtrim(referrer.MAIN_IDENT), '''') as [Referrer], 
nullif(rtrim(heorg.MAIN_IDENT), '''') as [ReferringOrganisation], 

CAST('''' as varchar(20)) as [GPAtTimeOfActivity],          -- updated later
CAST('''' as varchar(20)) as [GPPracticeAtTimeOfActivity],  -- updated later
CAST('''' as varchar(8)) as [PostcodeAtTimeOfActivity],     -- updated later
CAST('''' as varchar(20)) as [LHBOfResidence],              -- updated later


nullif(rtrim(dbo.IS_GetRefValID(''NHS'',sch.adcat_refno)), '''') as [PatientCategory],
null as [CommissionerType], 
null as [GPRefNoOnTreatment],
nullif(rtrim(sp.spont_Refno), '''') as [ClinicNumber],
CONVERT(time,sch.start_dttm) AS [TimeOfTreatment],
CONVERT(time,sch.DEPARTED_DTTM) AS [TimeLeftAppointment],
null as [StaffGrade],
null as [ReasonForDNA],
CASE WHEN ISNUMERIC(schspec.main_ident) = ''1'' then schspec.main_ident + ''00'' else schspec.main_ident end as [SpecialtyOfAppointment],
null AS [TimeHCPReady],
null as [Commissioner],
null AS [PatientClassification],
sp.spont_Refno AS [ClinicSlotKey],


(select top 1 CONVERT(date,sch1.start_Dttm)
from  SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
order by sch1.start_dttm asc)
as [DateOfNextApproxAppointment],

sch.create_dttm as [DateAppointmentCreated],
sch.modif_dttm as [DateAppointmentLastModified],
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
sch.comments AS [OtherInformation],

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

sch.schdl_refno as [Actnotekey],                  
nullif(rtrim(dbo.IS_GetRefValMainID(sch.cancr_refno)), '''')  as [OutcomeReason],
null AS [IgnorePartialBooking],
CAST('''' as varchar(100)) AS [AppointmentDirective],      -- updated later
null AS [FutureAppointmentDirective],

CONVERT(date,sch.cancr_dttm)  as [DateNotified],
sps.code as [ClinicCode],

(select top 1 heoid.identifier
from dbo.service_points sp1
join dbo.SCHEDULES sch1
on sch1.spont_Refno = sp1.spont_Refno
join dbo.health_organisations heorg
on heorg.heorg_refno = sp1.heorg_refno
join dbo.health_organisation_ids heoid
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


nullif(rtrim(dbo.IS_GetRefValMainID(sch.visit_refno)), '''')  as [AppointmentType],
dbo.IS_GetRefValID(''PIMS'',sch.scocm_refno) as [ReasonForRemoval],


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

-- HealthRiskFactor - Outpatient dataset -- default to consultant set priority for the appointment
--wl.prity_refno as [HealthRiskFactor],                        -- West from wlist , but there could be a discrepancy between wlist V appmnt prity
--CAST('''' as varchar(10)) as [HealthRiskFactor]              
nullif(rtrim(prity2.main_code), '''') AS [HealthRiskFactor],

null as [NextHealthRiskFactor],
null as [PathwayEventDate],
null as [PathwayEventType],
sch.refrl_refno as [PathwayUPI],
null as [PathwayEventSource],
null as [PathwayKey],
null as [PathwayCreateDate],
null as [PathwayModifyDate],
''West'' as [Area],
''Pims'' AS [Source],
convert(date,ISNULL(refrl.ordta_dttm,refrl.recvd_dttm)) as [DateReferred],   --ordta not used really HWL
convert(date,refrl.recvd_dttm) as [DateClinicallyReferred],
CONVERT(date,wl.WLIST_DTTM) as [DateOnSystem],                               

CASE 
   WHEN ISNUMERIC(refspec.main_ident) = ''1'' then refspec.main_ident + ''00'' 
   else refspec.main_ident 
END AS [SpecialtyOnReferral],

nullif(rtrim(dbo.IS_GetRefValID(''NHS'',refrl.sorrf_refno)), '''') as [SourceOfReferal],
NULL as [ClinicalCondition],
CAST('''' as varchar(8000)) as [NotesOnReferral],        -- updated field
null as [GPRefNoOnReferral],
null as [ClinicScheduleID],
null AS [ClinicSessionType],
nullif(rtrim(sp.description), '''') AS [ClinicSessionLocation],


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


CAST('''' as varchar(8000)) as [OtherInformationPrevious],  --updated later
CAST('''' as varchar(20)) as [ActNoteKeyPrevious],          --updated later   
CAST('''' as date) as [DateOfLastAppointment],              --updated later
null as [GPRefNoPrevious],

CASE 
   WHEN CONVERT(date,sch.create_dttm) is null then null 
   else DATEDIFF(dd,CONVERT(date,sch.create_dttm) ,CONVERT(date,sch.start_Dttm)) 
END AS [DaysNotifiedBeforeAppointment],
		
null as [DatePatientInitiatedFollowUp],

--null as [ConsultationMethod],          ----------- Outpatient schedules Includes tel and video contacts case 1/2/3
case 
   when sp.description like ''%video%'' then ''V'' 
   when sp.description like ''%tele%'' then ''T''
   ELSE ''F''
   END as [ConsultationMethod],

--- 1=FACE TO FACE  2=TELEPHONE 3=OFFICE BASED DECISION (FRONT END SCREEN - FOR TRACKED PATS)


--null as [VirtualContactType],          ----------- case 1/2/3/4
case 
   when sp.description like ''%video%'' then ''V'' 
   when sp.description like ''%tele%'' then ''T''
   ELSE ''F''
   END as [VirtualContactType],

   	 


CAST('''' as varchar(20)) as [NextConsultationMethod],  --- updated later
CAST('''' as varchar(20)) as [NextVirtualContactType],  --- updated later

null as [ContactDetailsForVirtualAppointment],
null as [UnsuccessfulAttemptToContactPatient1],
null as [UnsuccessfulAttemptToContactPatient2],
sch.patnt_refno  as [PatientLinkId],    
CONVERT(time,sch.arrived_Dttm)  AS [TimeArrivedAtAppointment],

(select top 1 pro1.main_ident
from Specialties pro1
join SCHEDULES sch1
on sch1.spect_Refno=pro1.spect_Refno
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
order by sch1.start_dttm asc) 
as [SpecialtyOfNextAppointment],

sch.wlist_refno as [WaitingListLinkID],


-- DIAGNOSIS CODES 
-- I10 / CAMHS / DIETD EXISTS --- e.g. technically possible for patient to have both i10 and local camhs diagnosis 
--

NULLIF(LEFT(dbo.IS_GetDiagProc(''SCHDL'',sch.schdl_Refno,''DIAGN'',''I10'',''PRIME''),10),'''') AS [Diagnosis1],
NULLIF(LEFT(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''DIAGN'',''I10'',''SECND'',12,4,''C''),4),'''') AS [Diagnosis2],


--CAST('''' as varchar(20)) as [Diagnosis11],           --updated later 
--CAST('''' as varchar(20)) as [Diagnosis22],           --updated later 
CAST('''' as varchar(50)) as [DiagnosisLocal1],      --updated later   
CAST('''' as varchar(50)) as [DiagnosisLocal2]      --updated later   




into #op_Table


from dbo.schedules sch
join dbo.patients pat on pat.patnt_Refno = sch.patnt_Refno and ISNULL(pat.archv_flag,''N'') = ''N''
left join dbo.prof_Carers pro 	on pro.proca_Refno = sch.proca_refno and ISNULL(pro.archv_flag,''N'') = ''N''
left join dbo.service_points sp on sp.spont_Refno = sch.spont_Refno and ISNULL(sp.archv_flag,''N'') = ''N''
left join dbo.REFERRALS refrl on refrl.REFRL_REFNO = sch.REFRL_REFNO and ISNULL(refrl.archv_flag,''N'') = ''N''
left join dbo.SPECIALTIES refspec on refspec.spect_Refno = refrl.REFTO_SPECT_REFNO and ISNULL(refspec.archv_flag,''N'') = ''N''
left join dbo.SPECIALTIES schspec on schspec.SPECT_REFNO = sch.SPECT_REFNO and ISNULL(schspec.archv_flag,''N'') = ''N''
left join dbo.PROF_CARER_SPECIALTIES prospeclink 	on prospeclink.PROCA_REFNO = pro.PROCA_REFNO and prospeclink.END_DTTM is null and ISNULL(prospeclink.archv_flag,''N'') = ''N'' 	and prospeclink.CSTYP_REFNO = 12143
left join dbo.SPECIALTIES prospec on prospec.SPECT_REFNO = prospeclink.SPECT_REFNO and ISNULL(prospec.archv_flag,''N'') = ''N''
left join PROF_CARERS referrer 	on referrer.PROCA_REFNO = refrl.REFBY_PROCA_REFNO and ISNULL(referrer.archv_flag,''N'') = ''N''
left join HEALTH_ORGANISATIONS heorg 	on heorg.HEORG_REFNO = refrl.REFBY_HEORG_REFNO and ISNULL(heorg.archv_flag,''N'') = ''N''
left join dbo.service_point_Sessions sps 	on sps.SPSSN_REFNO = sch.SPSSN_REFNO and ISNULL(sps.archv_flag,''N'') = ''N''
join dbo.reference_Values sorrf on sorrf.rfval_Refno = refrl.sorrf_refno and ISNULL(sorrf.archv_flag,''N'') = ''N''
join dbo.reference_Values scocm on scocm.rfval_Refno = sch.scocm_refno and ISNULL(scocm.archv_flag,''N'') = ''N''
join dbo.reference_Values prity on prity.rfval_Refno = refrl.prity_refno and ISNULL(prity.archv_flag,''N'') = ''N''
join dbo.reference_Values prity2 on prity2.rfval_Refno = sch.prity_refno and ISNULL(prity2.archv_flag,''N'') = ''N''
join dbo.reference_Values adcat on adcat.rfval_Refno = sch.adcat_refno and ISNULL(adcat.archv_flag,''N'') = ''N''
join dbo.HEALTH_ORGANISATIONS ho1 on ho1.HEORG_REFNO = sp.HEORG_REFNO and ISNULL(ho1.archv_flag,''N'') = ''N''
join dbo.HEALTH_ORGANISATIONS ho2 on ho2.HEORG_REFNO = ho1.PARNT_REFNO and ISNULL(ho2.archv_flag,''N'') = ''N''
left join dbo.Waiting_list_entries wl on sch.WLIST_REFNO =  wl.WLIST_REFNO and ISNULL(wl.archv_flag,''N'') = ''N''
	

where sch.SCTYP_REFNO = 12186
and ISNULL(sch.archv_flag,''N'') = ''N''
and CONVERT(Date,sch.start_Dttm)> @DateOfAppointment 
and sch.SATYP_REFNO <> 205912




	   	  


-----------------------------------------------------------------------------------------
--  UPDATES
------------------------------------------------------------------------------------------



-- Registerd GP At Time of Activity 
       UPDATE #op_table
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
       UPDATE #op_table
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


		 
-- do update for blanks !!
-- and future appointments 

 
-- PostcodeAtTimeOfActivity

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
       SET    LHBOfResidence = 
                     CASE
                     WHEN tmp.DateOfAppointment < ''2013-04-01'' THEN
                     pcode.state_code ELSE pcode.pcg_code END
       FROM #op_table tmp 
				INNER JOIN postcodes pcode ON tmp.PostcodeAtTimeOfActivity = pcode.pcode
       WHERE  ISNULL(pcode.archv_flag,''N'') = ''N''


-- Notes On Referral

UPDATE #op_table
       SET NotesOnReferral = left(convert(varchar(max),notes2.note),250)
FROM #op_table tmp
     INNER JOIN note_roles notrl2 on tmp.SystemLinkID = notrl2.sorce_refno
     INNER JOIN notes notes2 ON notes2.notes_refno = notrl2.notes_refno
WHERE isnull(notrl2.archv_flag,''N'')= ''N''
AND notrl2.sorce_code = ''RFCMT''



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





--  Appointment Directive 
--
--  as per FUWL SP on Production: NWW_IS_XTR_FUWL

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



-- Diagnosis - Local

UPDATE #op_table
set DiagnosisLocal1 = d.code
from #op_table tmp
join diagnosis_procedures d on d.sorce_refno = tmp.actnotekey and d.patnt_refno = tmp.PatientLinkID
where d.sorce_code = ''SCHDL''
and   d.dptyp_code = ''DIAGN''
and   d.ccsxt_code = ''CAMHS''
and   d.mplev_refno= ''200723''
and   isnull(d.archv_flag,''N'')=''N''

UPDATE #op_table 
set DiagnosisLocal2 = d.code
from #op_table tmp
join diagnosis_procedures d on d.sorce_refno = tmp.actnotekey and d.patnt_refno = tmp.PatientLinkID
where d.sorce_code = ''SCHDL''
and   d.dptyp_code = ''DIAGN''
and   d.ccsxt_code = ''CAMHS''
and   d.mplev_refno= ''200724''
and   isnull(d.archv_flag,''N'')=''N''

UPDATE #op_table
set DiagnosisLocal1 = d.code
from #op_table tmp
join diagnosis_procedures d on d.sorce_refno = tmp.actnotekey and d.patnt_refno = tmp.PatientLinkID
where d.sorce_code = ''SCHDL'' 
and   d.dptyp_code = ''DIAGN''
and   d.ccsxt_code = ''DIETD''
and   d.mplev_refno= ''200723''
and   isnull(d.archv_flag,''N'')=''N''

UPDATE #op_table
set DiagnosisLocal2 = d.code
from #op_table tmp
join diagnosis_procedures d on d.sorce_refno = tmp.actnotekey and d.patnt_refno = tmp.PatientLinkID
where d.sorce_code = ''SCHDL''
and   d.dptyp_code = ''DIAGN''
and   d.ccsxt_code = ''DIETD''
and   d.mplev_refno= ''200724''
and   isnull(d.archv_flag,''N'')=''N''



-----------------------------------
-- Next Appointment Group -     
-- No restriction placed on sctyp inorder to capture all future appointments where attnd_refno has not been cancelled already

UPDATE #op_table
set       NextConsultationMethod = case  
                                    when NextApptSpont.description like ''%video%'' then ''V'' 
                                    when NextApptSpont.description like ''%tele%'' then ''T''
                                    ELSE ''F''
                                   END,
          NextVirtualContactType = case  
                                    when NextApptSpont.description like ''%video%'' then ''V'' 
                                    when NextApptSpont.description like ''%tele%'' then ''T''
                                    ELSE ''F''
                                   END
from #op_table temp
join schedules NextAppt on NextAppt.patnt_refno = temp.PatientLinkID   and NextAppt.refrl_refno = temp.SystemLinkID
left join service_points as NextApptSpont on NextAppt.spont_refno = NextApptSpont.spont_refno and ISNULL(NextApptSpont.archv_flag,''N'') = ''N''
and NextAppt.schdl_refno = (select min(s2.schdl_refno)
                            from schedules s2
							 where ISNULL(s2.archv_flag,''N'') = ''N''
						     and s2.attnd_refno =11540
						     and s2.start_dttm > temp.DateOfAppointment
							 and s2.start_dttm = (select min(s3.start_dttm)
													from schedules s3 
													where ISNULL(s3.archv_flag,''N'') = ''N''
						                            and s3.attnd_refno =11540
						                            and s3.refrl_refno = s2.refrl_refno
													and s3.start_dttm > temp.DateOfAppointment
													 and s3.cancr_dttm is null)
							and s2.refrl_refno =temp.SystemLinkID)






/*
--Next Appointment Group 

 --DateOfNextApproxAppointment = NextAppt.Start_dttm,
   --       HCPOfNextAppointment = NextApptHCP.main_ident,
--NextAppointmentPreferredClinic = NextApptSpont.main_ident,
   --  NextAppointmentActNoteKey = NextAppt.schdl_refno,
    -- LocationOfNextAppointment = NextApptSpont.main_ident,
          NextConsultationMethod = case  
left join prof_carers NextApptHCP on NextAppt.proca_refno = NextApptHCP.proca_refno and ISNULL(NextApptHCP.archv_flag,''N'') = ''N''
left join Specialties NextApptSpec on NextAppt.spect_refno = NextApptSpec.spect_refno and ISNULL(NextApptSpec.archv_flag,''N'') = ''N''


-- CONSULTATION METHOD  & VITUAL TYPE
--ConsultationMethod,          
--VirtualContactType,          
--NextConsultationMethod,
--NextVirtualContactType,


--- BLOCKED ACCESS TO WPAS CONSULT_METHOD TABLE
--- CONSULT_METHOD VALUES 1/2/3

--ConsultationMethod      DEFAULTED TO VTF UNTIL CODES CONFIRMED 

UPDATE #op_table
SET ConsultationMethod
FROM #op_table tmp
INNER JOIN service_points sp on tmp.spont_refno = sp.spont_refno
case 
   when sp.description like ''%video%'' then ''V'' 
   when sp.description like ''%tele%'' then ''T''
   ELSE ''F''
   END 
WHERE isnull(SP.archv_flag,''N'')= ''N''

--- 1=FACE TO FACE  2=TELEPHONE 3=OFFICE BASED DECISION (FRONT END SCREEN - FOR TRACKED PATS)

--VirtualContactType, 

UPDATE #op_table
SET VirtualContactType
FROM #op_table tmp
INNER JOIN service_points sp on tmp.spont_refno = sp.spont_refno
case 
   when sp.description like ''%video%'' then ''V'' 
   when sp.description like ''%tele%'' then ''T''
   ELSE ''F''
   END 
WHERE isnull(SP.archv_flag,''N'')= ''N''

-- 1= TEL  2=TEL 3 = FACE TO FACE  4=FACE TO FACE (FRONT END SCREEN - FOR TRACKED PATS)




-- DIAGNOSIS I10 -  only a few being coded , function in select for I10 above does work

UPDATE #op_table
set Diagnosis11 = d.code
from #op_table tmp
join diagnosis_procedures d on d.sorce_refno = tmp.actnotekey and d.patnt_refno = tmp.PatientLinkID
where d.sorce_code = ''SCHDL'' 
and   d.dptyp_code = ''DIAGN''
and   d.ccsxt_code = ''I10''
and   d.mplev_refno= ''200723''
and   isnull(d.archv_flag,''N'')=''N''

UPDATE #op_table
set Diagnosis22 = d.code
from #op_table tmp
join diagnosis_procedures d on d.sorce_refno = tmp.actnotekey and d.patnt_refno = tmp.PatientLinkID
where d.sorce_code = ''SCHDL''
and   d.dptyp_code = ''DIAGN''
and   d.ccsxt_code = ''I10''
and   d.mplev_refno= ''200724''
and   isnull(d.archv_flag,''N'')=''N''


*/
-----------------------------------------

select *
from #op_Table 
drop table #op_Table 



')AT [7A1AUSRVIPMSQLR\REPORTS]


END



GO
