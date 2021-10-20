SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Data_NonContact_West_HWL]
	
AS
BEGIN

-- =============================================
-- Original Version :NWW_Get_PAS_Data_NonContact_West		
--  
-- Description:	Extracts Non Contact 'Community Contacts'
-- Amended By : Heather Lewis (HWL) - for Dataset=1311
--      
-- 01/09/2021 : HWL NEED TO CONFIRM CONSULT / VIRTUAL TYPE FIELDS
--
--IDS -- (some used in updates) 
--SystemLinkID	    refrl_refno
--PatientLinkId	    patnt_refno
--ActNoteKey	    schdl_refno
--PathwayUPI        refrl_refno
--WaitingListLinkID wlist_refno
--
-- n.b.
-- SCTYP=100207 SCHEDULES -These are the appointments which appear when right click on Pasid then 'Contact' 
-- Community Contacts in Patient Record Enquiry/ Community Contacts screen - will have been extracted as part of the Outpatient dataset where sctyp=12186 
-- East & Center Non Contact data do not appear to contain 'Shared Care Contacts', records which have >1 contact per appmnt/time appear to be DQ issues
-- So to be consistant West SP does not need to link to the parnt_refno for shared care. (HWL)
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
@StartDate      date

-- Set initial values for variables
SET @StartDate = (SELECT ISNULL(MAX(AppointmentDate),''1 January 2010'') FROM [BCUFOUNDATION].[Foundation].[dbo].[PAS_Data_NonContact] WHERE Source =''PIMS'' AND AppointmentDate < CONVERT(date,getdate()))
--SET @StartDate = ''01 Jan 2018''

SET @cityp_natgp = 
	(
	SELECT rfval_refno
	FROM	reference_values
	WHERE	rfvdm_code = ''CITYP''
	AND	main_code = ''NATGP''
	AND	ISNULL(archv_flag,''N'') = ''N''
	)

SET @cityp_gmc = 
	(
	SELECT rfval_refno
	FROM	reference_values
	WHERE	rfvdm_code = ''CITYP''
	AND	main_code = ''GMC''
	AND	ISNULL(archv_flag,''N'') = ''N''
	)

SET @cityp_dent = 
	(
	SELECT rfval_refno
	FROM	reference_values
	WHERE	rfvdm_code = ''CITYP''
	AND	main_code = ''NATDP''
	AND	ISNULL(archv_flag,''N'') = ''N''
	)


SET @hityp_natnl = 
	(
	SELECT rfval_refno
	FROM	reference_values
	WHERE	rfvdm_code = ''HITYP''
	AND	main_code = ''NATNL''
	AND	ISNULL(archv_flag,''N'') = ''N''
	)

SET @prtyp_gmprc = 
	(
	SELECT rfval_refno
	FROM   reference_values
	WHERE  rfvdm_code = ''PRTYP''
	AND  main_code = ''GMPRC''
	AND  ISNULL(archv_flag,''N'') = ''N''
	)


SELECT DISTINCT

pat.NHS_IDENTIFIER as [NHSNumber],
pat.pasid AS [LocalPatientIdentifier],
CONVERT(date,sch.start_Dttm) AS [DateOfAppointment],
CONVERT(time,sch.start_Dttm) AS [TimeOfAppointment],
sch.refrl_refno as [SystemLinkID],
''ON'' AS [TreatmentType],
CASE WHEN sch.visit_Refno = 213695 THEN ''P'' ELSE  ''6'' END AS [IntendedManagement],
prity2.main_code AS [PriorityOfHCP],


--(SELECT TOP 1 proca.Identifier
--FROM prof_carer_ids proca
--WHERE proca.proca_refno = sch.proca_refno
--and cityp_refno = 200921              -- Telepath Why not National code? HWL 
--and proca.end_dttm IS NULL
--and ISNULL(proca.archv_flag,''N'') = ''N''
--ORDER BY proca.Create_dttm desc
--) as [HCPAtAppointment],

pro.main_ident AS [HCPAtAppointment],   -- Leave this alone - Note on join below stating had to be changed - HWL

ho2.MAIN_IDENT AS [LocationOfAppointment],

''NC'' as [TypeOfAppointment],  -- -- oa oc or ot   - what should it be? - dupli  Non Contact AppointmentType also exists  - HWL

dbo.IS_GetRefValID(''NHS'',sch.scocm_refno) AS [OutcomeOfAppointment],--dbo.IS_GetRefValID(''PIMS'',sch.scocm_refno) AS [LocalOutcome],

referrer.MAIN_IDENT  AS [Referrer],
heorg.MAIN_IDENT AS [ReferrerOrganisation],
CAST('''' AS varchar(50)) AS [GPAtTimeOfActivity],          -- updated field
CAST('''' AS varchar(50)) AS [GPPracticeAtTimeOfActivity],  -- updated field
CAST('''' AS varchar(10)) AS [PostcodeAtTimeOfActivity],    -- updated field
CAST('''' AS varchar(5)) AS [LHBOfResidence],               -- updated field
dbo.IS_GetRefValID(''NHS'',sch.adcat_refno) AS [PatientCategory],
null as [CommissionerType],
null as [GPRefNoOnTreatment],
sp.spont_Refno AS [ClinicNumber],
CONVERT(time,sch.start_dttm) AS [TimeOfTreatment],

CONVERT(Time,''00:00'') as [TimeLeftAppointment],
null as [StaffGrade],
null as [ReasonForDNA],

-- majority of spect_refno is null where sctyp=100207 get specialty via proca_refno
CASE WHEN ISNUMERIC(prospec.main_ident) = ''1'' THEN prospec.main_ident + ''00'' ELSE  prospec.main_ident END AS [SpecialtyOfAppointment], 

CONVERT(Time,''00:00'') AS [TimeHCPReady],
null as [Commissioner],
null as [PatientClassification],
null as [ClinicSlotKey],


(select top 1 CONVERT(date,sch1.start_Dttm)
from SCHEDULES sch1
where sch.patnt_Refno=sch1.patnt_refno
and sch1.start_dttm>sch.start_dttm
--and sch1.start_dttm>getdate()
and sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc)
as [DateOfNextApproxAppointment],


CONVERT(date,sch.create_Dttm) AS [DateAppointmentCreated],
CONVERT(date,sch.modif_Dttm) as [DateAppointmentLastModified],
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


sch.schdl_refno as [ActNoteKey],
dbo.IS_GetRefValMainID(sch.cancr_refno) AS [OutcomeReason],  -- original

null as [IgnorePartialBooking],
CAST('''' AS varchar(100)) as [AppointmentDirective],                --- get from wlist? check this
null as [FutureAppointmentDirective],
CONVERT(date,sch.cancr_dttm) AS [DateNotified], ---Date Appt Created?  - Changed to CANCR_DTTM (26/3/20) VLH
sps.code AS [ClinicCode],

  
(select top 1 pro1.code
from service_points pro1
join SCHEDULES sch1
on sch1.spont_Refno=pro1.spont_Refno
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


''NC'' as [AppointmentType],  -- Non Contact - what should be here ? TypeOfAppointment & TreatmentType also in dataset
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
null as [PathwayUPI],
null as [PathwayEventSource],
null as [PathwayKey],
null as [PathwayCreateDate],
null as [PathwayModifyDate],
''West'' as [Area],
''Pims'' as [Source],

convert(date,refrl.recvd_dttm) AS [DateReferred],
convert(date,refrl.recvd_dttm) AS [DateClinicallyReferred],
convert(date,sch.create_dttm) AS [DateOnSystem],   -- or should be wlist.create_dttm - but if use that not necessarily a schedule yet-may cause user confusion
CASE WHEN ISNUMERIC(refspec.main_ident) = ''1'' THEN refspec.main_ident + ''00'' ELSE  refspec.main_ident END AS [SpecialtyOnReferral],
dbo.IS_GetRefValID(''NHS'',refrl.sorrf_refno) AS [SourceOfReferral],
null as [ClinicalCondition],
CAST('''' as varchar(8000)) as [NotesOnReferral],       -- updated later
null as [GPRefNoOnReferral],
sch.schdl_refno as [ClinicScheduleID],
null as [ClinicSessionType],     -- do case? - waiting to know Consultation / Virtual Type codes
ho2.MAIN_IDENT as [ClinicSessionLocation], --  as for LocationOfAppointment

-- Non Contact - n/a
NULLIF(LEFT(dbo.IS_GetDiagProc(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''PRIME''),10),'' '') AS [Procedure1],
NULLIF(LEFT(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),4),'' '') AS [Procedure2],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),5,4) AS [Procedure3],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),9,4) AS [Procedure4],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),13,4) AS [Procedure5],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),17,4) AS [Procedure6],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),21,4) AS [Procedure7],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),25,4) AS [Procedure8],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),29,4) AS [Procedure9],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),34,4) AS [Procedure10],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),37,4) AS [Procedure11],
SUBSTRING(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''PROCE'',''OPCS4'',''SECND'',12,4,''C''),41,4) AS [Procedure12],

CAST('''' AS varchar(8000)) as [OtherInformationPrevious],
CAST('''' AS varchar(20)) as [ActNoteKeyPrevious],              -- Previous Group update
CAST('''' AS date) as [DateOfLastAppointment],           -- Previous Group update

null as [GPRefNoPrevious],
CASE WHEN CONVERT(date,sch.create_dttm) is NULL THEN NULL ELSE DATEDIFF(dd,CONVERT(date,sch.create_dttm) ,CONVERT(date,sch.start_Dttm)) END AS [DaysNotifiedBeforeAppointment],

null as [DatePatientInitiatedFollowUp],

sch.conty_refno as [ConsultationMethod], ---CONTY_REFNO X6 USED FOR SCTYP=100207
--- 1=FACE TO FACE  2=TELEPHONE 3=OFFICE BASED DECISION (FRONT END SCREEN - FOR TRACKED PATS)

''NC'' as [VirtualContactType],

   
CAST('''' as varchar(20)) as [NextConsultationMethod],  --- updated later
CAST('''' as varchar(20)) as [NextVirtualContactType],  --- updated later

null as [ContactDetailsForVirtualAppointment],
null as [UnsuccessfulAttemptToContact1],
null as [UnsuccessfulAttemptToContact2],
sch.patnt_refno as [PatientLinkId],
CONVERT(time,sch.arrived_Dttm) AS [TimeArrivedAtAppointment],

(SELECT top 1 spec1.main_ident
FROM SPECIALTIES spec1
JOIN SCHEDULES sch1
on sch1.spect_Refno = spec1.spect_Refno
WHERE sch.patnt_Refno=sch1.patnt_refno
AND sch1.start_dttm>sch.start_dttm
AND sch1.REFRL_REFNO  = sch.REFRL_REFNO 
and ISNULL(sch1.archv_flag,''N'') = ''N''
--and sch1.attnd_refno =11540
order by sch1.start_dttm asc) 
 AS [SpecialtyOfNextAppointment],


sch.wlist_refno  as [WaitingListLinkID],     
NULLIF(LEFT(dbo.IS_GetDiagProc(''SCHDL'',sch.schdl_Refno,''DIAGN'',''I10'',''PRIME''),10),'''') AS [Diagnosis1],
NULLIF(LEFT(dbo.IS_GetDiagProcStr(''SCHDL'',sch.schdl_Refno,''DIAGN'',''I10'',''SECND'',12,4,''C''),4),'''') AS [Diagnosis2],
CAST('''' as varchar(50)) as [DiagnosisLocal1],      --updated later   
CAST('''' as varchar(50)) as [DiagnosisLocal2]      --updated later 




INTO #op_Table



FROM schedules sch
LEFT JOIN patients pat on pat.patnt_Refno = sch.patnt_Refno
LEFT JOIN service_points sp on sp.spont_Refno = sch.spont_Refno
LEFT JOIN REFERRALS refrl on refrl.REFRL_REFNO = sch.REFRL_REFNO 
LEFT JOIN prof_Carers pro on pro.proca_Refno = refrl.REFTO_PROCA_REFNO --DJ 12/4/21 : CHANGED FROM sch.proca_refno DUE TO FIELD NOT BEING POPULATED
LEFT JOIN SPECIALTIES refspec on refspec.spect_Refno = refrl.REFTO_SPECT_REFNO 
LEFT JOIN SPECIALTIES schspec on schspec.SPECT_REFNO = sch.SPECT_REFNO 
LEFT JOIN PROF_CARER_SPECIALTIES prospeclink on prospeclink.PROCA_REFNO = pro.PROCA_REFNO 	AND prospeclink.END_DTTM is null	AND ISNULL(prospeclink.archv_flag,''N'') = ''N''	AND prospeclink.CSTYP_REFNO = 12143
LEFT JOIN SPECIALTIES prospec on prospec.SPECT_REFNO = prospeclink.SPECT_REFNO 
LEFT JOIN PROF_CARERS referrer on referrer.PROCA_REFNO = refrl.REFBY_PROCA_REFNO 
LEFT JOIN HEALTH_ORGANISATIONS heorg on heorg.HEORG_REFNO = refrl.REFBY_HEORG_REFNO 
LEFT JOIN HEALTH_ORGANISATIONS ho2 on ho2.HEORG_REFNO = sp.HEORG_REFNO 
LEFT JOIN service_point_Sessions sps on sps.SPSSN_REFNO = sch.SPSSN_REFNO 
LEFT JOIN reference_Values sorrf on sorrf.rfval_Refno = refrl.sorrf_refno
LEFT JOIN reference_Values scocm on scocm.rfval_Refno = sch.scocm_refno
LEFT JOIN reference_Values prity on prity.rfval_Refno = refrl.prity_refno
LEFT JOIN reference_Values prity2 on prity2.rfval_Refno = sch.prity_refno
LEFT JOIN reference_Values adcat on adcat.rfval_Refno = sch.adcat_refno
LEFT JOIN Waiting_list_entries wl on wl.WLIST_REFNO = sch.WLIST_REFNO 


/* 
WPAS West Data Migration – PiMS Contacts
Author - Richard Westwood
"It is subsequently suggested that all historical contact activity is migrated AS HCP/AHP (H%) activity."
*/

WHERE 
sch.SCTYP_REFNO = 100207 --Community Contact
AND ISNULL(sch.archv_flag,''N'') = ''N''
AND CONVERT(Date,sch.start_Dttm)> @StartDate 
--AND CONVERT(Date,sch.start_Dttm)> ''01 Jan 2021''


-----------------------------------------------------------------
-- Updates 
-----------------------------------------------------------------

-- Registered GP At Time of Activity
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
         -- this SP extracts future Non Contact 
		 and  patpc.end_dttm is null
		 and  prcai.end_dttm is null 
		 AND  ISNULL(patpc.archv_flag,''N'') = ''N''
         AND  ISNULL(prcai.archv_flag,''N'') = ''N''
         AND  ISNULL(heoid.archv_flag,''N'') = ''N''

-- Address Postcode At Time of Activity
              UPDATE        #op_table
       SET    PostcodeAtTimeOfActivity = REPLACE(addss.pcode,'' '','''')
       FROM   #op_table tmp
              INNER JOIN address_roles roles ON tmp.PatientLinkId= roles.patnt_refno
              INNER JOIN addresses addss     ON roles.addss_refno = addss.addss_refno
       WHERE  roles.rotyp_code = ''HOME''
         AND  addss.adtyp_code = ''POSTL''
 --        AND  CONVERT(DATETIME, CONVERT(CHAR(8), tmp.DateOfAppointment, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)) BETWEEN roles.start_dttm AND ISNULL(roles.end_dttm,CONVERT(DATETIME, CONVERT(CHAR(8), tmp.AppointmentDate, 112) + '' '' + CONVERT(CHAR(8), tmp.AppointmentTime ,108)))
         AND  roles.end_dttm is null
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


-- Previous Appointment Group

UPDATE        #op_table
set 
   DateOfLastAppointment = CONVERT(date,LastAppt.start_dttm),
	  ActNoteKeyPrevious = LastAppt.schdl_refno

FROM   #op_table tmp
 join schedules LastAppt on tmp.PatientLinkId = LastAppt.patnt_refno and tmp.SystemLinkID = LastAppt.refrl_refno 
                           and LastAppt.schdl_refno = (select max(s2.schdl_refno)
                                                       from schedules s2
							                           where ISNULL(s2.archv_flag,''N'') = ''N''
						                               and s2.attnd_refno =11540
						                               and s2.start_dttm < tmp.DateOfAppointment
						                               and s2.refrl_refno = tmp.SystemLinkID)


-- Notes On Referral

UPDATE #op_table
       SET NotesOnReferral = left(convert(varchar(max),notes2.note),250)
FROM #op_table tmp
     INNER JOIN note_roles notrl2 on SystemLinkID = notrl2.sorce_refno
     INNER JOIN notes notes2 ON notes2.notes_refno = notrl2.notes_refno
WHERE isnull(notrl2.archv_flag,''N'')= ''N''
AND notrl2.sorce_code = ''RFCMT''




--  Appointment Directive 
--  as per FUWL SP on Production: NWW_IS_XTR_FUWL
--  currently n/a for sctyp=100207  Community Contact

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








----------------------------------------------------------------------------------------------------
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








SELECT * FROM #op_Table 

DROP TABLE #op_Table 

'
	) AT [7A1AUSRVIPMSQLR\REPORTS];


END
GO
