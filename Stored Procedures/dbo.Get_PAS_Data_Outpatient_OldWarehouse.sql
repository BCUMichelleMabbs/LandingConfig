SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_PAS_Data_Outpatient_OldWarehouse]
as
begin
SELECT 

NHSNumberNew as NHSNumber
,PatientIdentifier as LocalPersonIdentifier
,CONVERT(date,AttendanceDate) as AppointmentDate
,CONVERT(time,AppointmentTime) as AppointmentTime
,PathwayId as LinkId
,'OA' as [TreatmentType]
,' ' as [TreatmentIntent]
,PriorityType as [HCPPriority]
,ConsultantCode as [AttendanceHCP]
,TreatmentSiteCode as [AttendanceLocation]
,'Old Warehouse' as Source
,Outcomeofattendance as RTTOutcome
,ReferrerCode as Referrer
,ReferrerOrgCode as ReferrerOrganisation
,RegGPCode as GPAtTimeOfActivity
,RegPracticeCode as GPPracticeAtTimeOfActivity
,PostCodeUsualAddress as PostcodeAtTimeOfActivity
,CommissionerCode as [DHA]
,AdministrativeCategory as [PatientCategory]
,ClinicCode as [ClinicNumber]
,SpecialtyCode + g.localsubspecialty as [AdmittingSpecialty]
,ClinicCode as [ClinicCode]
,CONVERT(Time,ArrivalTime) as [ArrivalTime]
,null as LeavingTime
,null as SlotKey
,null as NextApptConsultant
,null as NextApptSpecialty
,null as NextApptLocation
,null as NextApptTreatmentDate
,null as NextApptActNoteKey
,null as CPTFlag
,null as GPRefNo
,null as RealManagement
,null as NextApproxAppt
,null as ActNoteKey
,Convert(date,DateOfPatientReferral) as PatientReferralDate
,CONVERT(date,ReferralDate) as ClinicalReferralDate
,PriorityType as ReferrerPriority
,ReferralSource as ReferralSource
,null as HCPSpecialty
,ConsultantCode as HCPCode
,null as ReferralIntention
,null as PathwayEventType
,null as PathwayEventSource
,null as ExcludePathway
,PathwayId as UniquePathwayID
,null as SessionType
,null as SessionLocation
,convert(date,ReferralDate) as DateNotified
,SpecialtyCode + g.localsubspecialty as ReferralSpecialty
,null as [HCPReadyTime]
,CONVERT(time,AppointmentTime) as TreatmentTime
,null as OtherInfo
,null as AppointmentDirective
,AttendedOrDNA as AttendedorDNA
,AttendanceCategory as AttendanceCategory
,StaffProfessionalGroup as StaffGrade
,null as Procedure1
,null as Procedure2
,null as Procedure3
,null as Procedure4
,null as Procedure5
,null as Procedure6
,null as Procedure7
,null as Procedure8
,null as Procedure9
,null as Procedure10
,null as Procedure11
,null as Procedure12
,null as WaitingListDate
,L.LocalOutcomeCode as LocalOutcome
,null as LocalOutcomeReason
,NULL as ActivityType,
		NULL as TraumaSubSpec,
		NULL as SessionBookings,
		null AS DaysNotice


  FROM [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].[dbo].opa_general g
  join [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].[dbo].OPA_Locals l
  on l.OPAJoinKey = g.OPAJoinKey 


  where SenderOrganisation = 'Cent'
  and ISNULL(LocalApptType,'OT') <> 'ON'
  --and AttendanceDate < '21 Nov 2016'
  --and AttendanceDate >='1 January 2010'
  and AttendanceDate between '01 january 2010' and '20 Nov 2016'
  end
GO
