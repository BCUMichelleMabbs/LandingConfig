SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Heather Lewis                         
-- Create date: 6/10/2020
-- Description:	Centre - Extract of all Waiters (OP/DC/IP/FU/PP/TF/TO)
--              This version created to fix error "Unable to Execute an Execute"
--              Data succesfully loads into foundation   
--  Amend Date: 12/01/2021 x4 new fields added
--              22/06/2021 Risk Stratification fields not in Wpas SP
--              28/07/2021 Commented out nullif check for VirtualContactDetails - Issue identified for FU dataset
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Central_z1_TO2]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)

DECLARE @LastDateWaitingListCensus AS DATE = (SELECT ISNULL(MAX(DateWaitingListCensus),'01 January 2018') FROM [Foundation].[dbo].[PAS_Data_WaitingList] where Area='Central')
DECLARE @LastDateWaitingListCensusString AS VARCHAR(30) = DATENAME(DAY,@LastDateWaitingListCensus) + ' ' + DATENAME(MONTH,@LastDateWaitingListCensus) + ' ' + DATENAME(YEAR,@LastDateWaitingListCensus)

EXEC('




Select distinct

nullif(rtrim(wl.LOS),'''') AS DaysWait,
nullif(rtrim(wl.NHS),'''')AS NHSNumber,
nullif(rtrim(wl.CaseNo),'''') as LocalPatientIdentifier,
nullif(rtrim(wl.dat_ref),'''')as DateReferred,
nullif(rtrim(wl.LinkID),'''') as SystemLinkID,
nullif(rtrim(wl.INTENT_REFER),'''')AS ReferralIntent,
nullif(rtrim(wl.GP_REF),'''')as Referrer,
nullif(rtrim(wl.GP_PRAC),'''')AS ReferringOrganisation,
nullif(rtrim(wl.Reg_GP),'''')as GPAtTimeOfActivity,
nullif(rtrim(wl.Reg_Prac),'''')as GPPracticeAtTimeOfActivity,
nullif(rtrim(wl.Postcode),'''')as PostcodeAtTimeOfActivity,
nullif(rtrim(wl.DHA_CODE),'''')as Commissioner,
nullif(rtrim(wl.Source_Refer),'''')as ReferralSource,
nullif(rtrim(wl.LTTR_PRTY),'''')AS PriorityOnLetter,
nullif(rtrim(wl.Ref_Outcome),'''')as Outcome,
nullif(rtrim(wl.Datonsys),'''')as DateOnWaitingList,
nullif(rtrim(wl.Loc),'''')as Location,
nullif(rtrim(wl.Category),'''')as PatientCategory,
nullif(rtrim(wl.Cons_Prty),'''')as PriorityOfHCP,
nullif(rtrim(wl.trt_type),'''')as TreatmentType,
nullif(rtrim(wl.Date_Booked),'''')as DateBooked,
nullif(rtrim(wl.Reason_Booked),'''')as ReasonBooked,
nullif(rtrim(wl.GPREFNO),'''')as GpRefNo,
nullif(rtrim(wl.Clinical_Condition),'''')as ClinicalCondition,
nullif(rtrim(wl.Charged_To),'''')as CommissionerType,
nullif(rtrim(wl.TRT_DATE),'''')as DateOfAppointment, 
nullif(rtrim(wl.Deferred_Date),'''')as DateDeferred,
nullif(rtrim(wl.Spec),'''')as Specialty,
nullif(rtrim(wl.List_Outcome),'''')as ListStatus,    
nullif(rtrim(wl.Contracts_Authorised),'''')as ContractsAuthorised,
wl.origtext as Comments,
nullif(rtrim(wl.AgeInDays),'''')as AgeInDays,
nullif(rtrim(wl.Suspended),'''')as Suspended, 
nullif(rtrim(wl.Orig_Diag_description),'''')as OriginalDiagnosis,
nullif(rtrim(wl.Exclude_PPO1W),'''')as ExcludeFromWLReporting,
nullif(rtrim(wl.ACTNOTEKEY),'''')as ActNoteKey,
nullif(rtrim(wl.RTT_UPI),'''')as UniquePathwayIdentifier,
nullif(rtrim(wl.RTT_Start_Date),'''')as DateRTTStart,
nullif(rtrim(wl.RTT_Stop_Date),'''')as DateRTTStop,
nullif(rtrim(wl.RTT_LOW),'''')AS RTTWait,
nullif(rtrim(wl.RTT_Adjusted_LOW),'''')as RTTWaitAdjusted,
nullif(rtrim(wl.RTT_Spec),'''')AS RTTSpecialty,
nullif(rtrim(wl.RTT_ACTNOTEKEY_Start),'''')as RTTActNotekeyAtStart,
nullif(rtrim(wl.RTT_Exclude),'''')AS RTTExcludedSpecialty,
nullif(rtrim(wl.Planned_OP_Date),'''')as DatePlanned,
nullif(rtrim(wl.RTT_Start_Source),'''')as RTTSourceAtStart,
nullif(rtrim(wl.RTT_Start_Type),'''')as RTTTypeAtStart,
nullif(rtrim(wl.RTT_Target_Date),'''')as DateRTTTarget,
nullif(rtrim(wl.RTT_TARGET),'''')AS RTTTargetDays,
nullif(rtrim(wl.Pathway_Stage),'''') as RTTStage,
NULL as DateOfLastDNAOrPatientCancelled,
NULL as CommentsFromWaitingList,
NULL as WaitingListRefNo,
NULL as ScheduleRefNo,
NULL as ReferralRefNo





	from REF_WAIT_LEN_VIEW_ENH (''TO'',''12/31/2999'','''','''','''','''') as wl


		
'


) at [WPAS_Central];
END



GO
