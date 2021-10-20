SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Cadan Walker (CW)
-- Create date: 30th January 2020
-- Description:	Add DayCase Cleansed 'Flag' to inpatients
-- =============================================
/*
[Landing_Config].[dbo].[Update_PAS_Data_Inpatient_DayCaseCleansed]
*/
CREATE PROCEDURE [dbo].[Update_PAS_Data_Inpatient_DayCaseCleansed]
@LoadGUID varchar(38)
AS
BEGIN
SET NOCOUNT ON;

	UPDATE [Foundation].[dbo].[PAS_Data_Inpatient]
	SET [DayCaseCleansed] =
	CASE
		WHEN RTRIM([PatientClassification]) = '2' OR (RTRIM([PatientClassification]) IN ('D', 'E', 'O', 'U') AND [IntendedManagement] = '2') THEN
		CASE
			WHEN ISNULL(RTRIM([Procedure1]), '') IN ('ZUKP', '') AND ISNULL(RTRIM([Diagnosis1]), '') IN ('ZUKD', '') THEN 'Step 1'
			WHEN RTRIM([Procedure1]) NOT BETWEEN 'A011' AND 'X979' AND ISNULL([Diagnosis1], '')+ISNULL([Diagnosis3], '')+ISNULL([Diagnosis4], '')+ISNULL([Diagnosis5], '')+ISNULL([Diagnosis6], '')+ISNULL([Diagnosis7], '')+ISNULL([Diagnosis8], '')+ISNULL([Diagnosis9], '')+ISNULL([Diagnosis10], '')+ISNULL([Diagnosis11], '')+ISNULL([Diagnosis12], '') NOT LIKE '%Z53%' THEN 'Step 1'
			WHEN (RTRIM([Procedure1]) IN ('ZUKP', '') OR [Procedure1] IS NULL) AND ISNULL([Diagnosis1], '')+ISNULL([Diagnosis3], '')+ISNULL([Diagnosis4], '')+ISNULL([Diagnosis5], '')+ISNULL([Diagnosis6], '')+ISNULL([Diagnosis7], '')+ISNULL([Diagnosis8], '')+ISNULL([Diagnosis9], '')+ISNULL([Diagnosis10], '')+ISNULL([Diagnosis11], '')+ISNULL([Diagnosis12], '') NOT LIKE '%Z53%' THEN 'Step 1'
			WHEN RTRIM([Procedure1]) IN ('W901', 'W902', 'W903', 'W904', 'W908', 'W909', 'H281', 'H288', 'H289', 'H701', 'H702', 'H703', 'H704', 'H708', 'H709', 'P271', 'P272', 'P273', 'P278', 'P279', 'B371', 'B372', 'B373', 'B374', 'B378', 'B379', 'X381', 'X382', 'X383', 'X384', 'X385', 'X386', 'X387', 'X388', 'X389', 'S521', 'S522', 'S523', 'S525', 'S528', 'S529', 'X301', 'X302', 'X303', 'X304', 'X305', 'X306', 'X308', 'X309', 'T744', 'X371', 'X372', 'X373', 'X374', 'X375', 'X376', 'X378', 'X379', 'X311', 'X312', 'X313', 'X318', 'X319', 'R101', 'R102', 'R103', 'R104', 'R105', 'R108', 'R109', 'R072', 'C861', 'C862', 'C863', 'C864', 'C865', 'C866', 'C867', 'C868', 'C869', 'C891', 'C892', 'C893', 'C898', 'C899', 'M701', 'M702', 'M703', 'M704', 'M705', 'M706', 'M707', 'M708', 'M709', 'E051', 'E052', 'E053', 'E054', 'E058', 'E059', 'S451', 'S452', 'S453', 'S454', 'S455', 'S456', 'S458', 'S459', 'G211', 'G212', 'G213', 'G214', 'G218', 'G219', 'K661', 'K668', 'K669', 'L931', 'L932', 'L933', 'L934', 'L935', 'L936', 'L938', 'L939', 'S571', 'S572', 'S573', 'S574', 'S575', 'S576', 'S578', 'S579', 'S431', 'S432', 'S433', 'S434', 'S438', 'S439', 'X483', 'S061', 'S062', 'S063', 'S064', 'S065', 'S068', 'S069', 'S081', 'S082', 'S083', 'S088', 'S089', 'S091', 'S092', 'S093', 'S098', 'S099', 'S111', 'S112', 'S113', 'S114', 'S118', 'S119', 'F101', 'F102', 'F103', 'F104', 'F108', 'F109', 'Q031', 'Q032', 'Q033', 'Q034', 'Q035', 'Q038', 'Q039', 'X331', 'Z332', 'X333', 'X338', 'X339', 'Y331', 'Y332', 'Y338', 'Y339', 'S141', 'S142', 'S148', 'S149', 'Q131', 'Q132', 'Q133', 'Q134', 'Q135', 'Q136', 'Q137', 'Q138', 'Q139', 'X491', 'X492', 'X493', 'X494', 'X495', 'X496', 'X497', 'X498', 'X499', 'D031', 'D032', 'D033', 'D034', 'D038', 'D039', 'S561', 'S562', 'S563', 'S564', 'S565', 'S566', 'S568', 'S569', 'C481', 'C482', 'C488', 'C489', 'C171', 'C178', 'C179', 'N341', 'N342', 'N343', 'N344', 'N345', 'N346', 'N348', 'N349', 'P141', 'P142', 'P143', 'P148', 'P149', 'Y291', 'Y292', 'Y298', 'Y299', 'E061', 'E062', 'E063', 'E068', 'E069', 'H621', 'H622', 'H623', 'H624', 'H625', 'H628', 'H629', 'H311', 'H312', 'H313', 'H314', 'H315', 'H318', 'H319', 'F051', 'F052', 'F053', 'F054', 'F058', 'F059', 'A841', 'A842', 'A843', 'A844', 'A845', 'A846', 'A847', 'A848', 'A849', 'Q021', 'Q022', 'Q023', 'Q024', 'Q028', 'Q029', 'X361', 'X362', 'X363', 'X368', 'X369', 'Q551', 'Q552', 'Q553', 'Q554', 'Q555', 'Q556', 'Q558', 'Q559', 'Q121', 'Q122', 'Q123', 'Q124', 'Q128', 'Q129', 'U191', 'U202', 'C872') THEN
				CASE WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%Y80%' THEN NULL ELSE 'Step 2' END
			WHEN LEFT([Procedure1], 3) IN ('G45', 'G55', 'G19', 'G16', 'G65', 'G80', 'H22', 'H25', 'H68', 'H69') THEN 
				CASE
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G18%' THEN NULL
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G42%' THEN NULL
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G43%' THEN NULL
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G44%' THEN NULL
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G54%' THEN NULL
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G64%' THEN NULL
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%G79%' THEN NULL
					WHEN ISNULL(RTRIM([Procedure2]), '')+ISNULL(RTRIM([Procedure3]), '')+ISNULL(RTRIM([Procedure4]), '')+ISNULL(RTRIM([Procedure5]), '')+ISNULL(RTRIM([Procedure6]), '')+ISNULL(RTRIM([Procedure7]), '')+ISNULL(RTRIM([Procedure8]), '')+ISNULL(RTRIM([Procedure9]), '')+ISNULL(RTRIM([Procedure10]), '')+ISNULL(RTRIM([Procedure11]), '')+ISNULL(RTRIM([Procedure12]), '') LIKE '%Y805' THEN 'END'
					WHEN ISNULL([Procedure2], '')+ISNULL([Procedure3], '')+ISNULL([Procedure4], '')+ISNULL([Procedure5], '')+ISNULL([Procedure6], '')+ISNULL([Procedure7], '')+ISNULL([Procedure8], '')+ISNULL([Procedure9], '')+ISNULL([Procedure10], '')+ISNULL([Procedure11], '')+ISNULL([Procedure12], '') LIKE '%Y80%' THEN NULL
					ELSE 'Step 3'
				END
			WHEN LEFT([Procedure1], 3) IN ('D07', 'D08') THEN 
				CASE
					WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%D15%' THEN NULL
					WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%Y80%' THEN NULL
					ELSE 'Step 4'
				END
			WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%V451%' THEN 'Step 5'
			WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%V452%' THEN 'Step 5'
			WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%V453%' THEN 'Step 5'
			WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%V458%' THEN 'Step 5'
			WHEN ISNUll([Procedure2], '')+ISNUll([Procedure3], '')+ISNUll([Procedure4], '')+ISNUll([Procedure5], '')+ISNUll([Procedure6], '')+ISNUll([Procedure7], '')+ISNUll([Procedure8], '')+ISNUll([Procedure9], '')+ISNUll([Procedure10], '')+ISNUll([Procedure11], '')+ISNUll([Procedure12], '') LIKE '%V459%' THEN 'Step 5'
			WHEN LEFT([Procedure1], 3) IN ('X40', 'X41', 'X29') THEN 'Step 6'
			WHEN RTRIM([Procedure1]) = 'X352' THEN 'Step 6'
			ELSE NULL
		END
		ELSE NULL
	END
FROM [Foundation].[dbo].[PAS_Data_Inpatient] i
WHERE 1=1
	AND (
		RTRIM([PatientClassification]) = '2' OR (RTRIM([PatientClassification]) IN ('D', 'E', 'O', 'U') AND [IntendedManagement] = '2')
	)




UPDATE [Foundation].[dbo].[PAS_Data_Inpatient]
Set ProcedureAll = concat(coalesce(procedure1+', ', ''),  coalesce(procedure2 +', ', ''), coalesce(Procedure3 +', ', ''), coalesce(Procedure4 +', ', '') , coalesce(Procedure5 +', ', ''), coalesce(Procedure6 +', ', ''), coalesce(Procedure7 +', ', '') , coalesce(Procedure8 +', ', '') , coalesce(Procedure9 +', ', ''), coalesce(Procedure10 +', ', ''), coalesce(Procedure11 +', ', ''), coalesce(Procedure12, ''))
FROM [Foundation].[dbo].[PAS_Data_Inpatient]

		
UPDATE [Foundation].[dbo].[PAS_Data_Inpatient]
Set DiagnosisAll = concat(coalesce(Diagnosis1 +', ', ''),  coalesce(Diagnosis2 +', ', ''), coalesce(Diagnosis3 +', ', ''), coalesce(Diagnosis4 +', ', '') , coalesce(Diagnosis5 +', ', ''), coalesce(Diagnosis6 +', ', ''), coalesce(Diagnosis7 +', ', '') , coalesce(Diagnosis8 +', ', '') , coalesce(Diagnosis9 +', ', ''), coalesce(Diagnosis10 +', ', ''), coalesce(Diagnosis11 +', ', ''), coalesce(Diagnosis12 +', ', ''), coalesce(Diagnosis13 +', ', ''), coalesce(Diagnosis14, ''))
from [Foundation].[dbo].[PAS_Data_Inpatient]




--STREAM DATA -----------------------------------------------------------------------------------------------------------------------------
-- KR added 08/09/21 to gt PDD and MFD data from the Stream Database this data should take priority of the data on WPAS, as per the service.
Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set PDD =

		case 
			when ca.PredictedDischargeDate is not null then ca.PredictedDischargeDate
			when ha.PredictedDischargeDate is not null then ha.PredictedDischargeDate
			Else i.pdd
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)




Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set MFD =

		case 
		when ca.MedicallyFitDate is not null then ca.MedicallyFitDate
		when ha.MedicallyFitDate is not null and ca.MedicallyFitDate is null then ha.MedicallyFitDate
		Else i.mfd
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set HospitalDischargedTo =

		case 
		when ca.TransferBedType is not null then ca.TransferBedType
		when ha.TransferBedType is not null and ca.TransferBedType IS null then ha.TransferBedType
		Else i.HospitalDischargedTo
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set PDDBreach =

	case when  cast(getdate() as date) = cast(i.PDD as date) then 'N'
		when i.DateDischarged > cast(i.PDD as date) then 'Y'
		when i.DateDischarged < cast(i.PDD as date) then 'N'
		when i.DateDischarged is null and (getdate() > cast(i.PDD as date)) then 'Y'
		when i.DateDischarged is null and (getdate() < cast(i.PDD as date)) then 'N'
		else 'N'  end 

from
foundation.dbo.PAS_Data_Inpatient i



Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set LocationOfPatient =

		case 
		when ca.PatientLocation is not null then ca.PatientLocation
		Else ha.PatientLocation
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)


Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set TransferredTo =

		case 
		when ca.TransferRequired is not null then ca.TransferRequired
		Else ha.TransferRequired
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set IsolationRequired =

		case 
		when ca.IsolationRequired is not null then ca.IsolationRequired
		Else ha.IsolationRequired
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)

 

 Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set IsolationReasonPrevious =

		case 
		when ca.IsolationReason is not null then ca.IsolationReason
		Else ha.IsolationReason
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)


 Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set DateIsolationIdentified =

		case 
		when ca.DateIdentified is not null then ca.DateIdentified
		Else ha.DateIdentified
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



 Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set IsolationCurrent =

		case 
		when ca.CurrentlyIsolated is not null then ca.CurrentlyIsolated
		Else ha.CurrentlyIsolated
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)


Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set IsolationReasonCurrent =

		case 
		when ca.CurrentIsolationReason is not null then ca.CurrentIsolationReason
		Else ha.CurrentIsolationReason
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)

Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set IsolationRiskAssessmentPrevious =

		case 
		when ca.RiskAssessed is not null then ca.RiskAssessed
		Else ha.RiskAssessed
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



Update [Foundation].[dbo].[PAS_Data_Inpatient]
Set IsolationRiskAsessmentCurrent =

		case 
		when ca.CurrentRiskAssessment is not null then ca.CurrentRiskAssessment
		Else ha.CurrentRiskAssessment
		end

from
foundation.dbo.PAS_Data_Inpatient i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.SystemLinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.SystemLinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



END



GO
