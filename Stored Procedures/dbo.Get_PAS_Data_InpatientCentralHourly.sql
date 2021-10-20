SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientCentralHourly]
	
AS
BEGIN
	
SET NOCOUNT ON;

--DROP TABLE IF EXISTS @PASCurrentInpatient

declare @sql as varchar(max)

set fmtonly off;


--create the table
Declare @results table

(
Area							varchar(7),
Source							varchar(7),
LocalPatientIdentifier			varchar(30),
NHSNumber						varchar(30),
Surname							varchar(50),
DateOfBirth						Date,
Sex								varchar(10),
Postcode						varchar(10),
RegisteredGP					varchar(10),
RegisteredPractice				varchar(10),
AdmissionDate					Date,
PDD								Date,
OPDD							Date,
RetentionReason					varchar(20),
Ward							varchar(10),				
GMC								varchar(10),
LocalConsultantCode				varchar(10),
Specialty						varchar(20),
SpellNumber						varchar(10),
IntendedManagement				varchar(10),
AdmissionMethod					varchar(10),
HomeLeave						varchar(10),
MFDDate							Date,
MFDTime							Time,
Site							varchar(10),
PatientClassification			varchar(5),
Forename						varchar(50),
Linkid							varchar(20),
SnapshotDateTime				Date,
HospitalDischargedTo			varchar(100),
LocationOfPatient				varchar(100),
TransferredTo					varchar(100),
IsolationRequired				varchar(2),
IsolationReasonPrevious			varchar(2),
DateIsolationIdentified			Date,
IsolationCurrent				varchar(2),
IsolationReasonCurrent			varchar(2),
IsolationRiskAssessmentPrevious	varchar(2),
IsolationRiskAssessmentCurrent	varchar(2)
)

--Insert the pas data into the table
Insert into @results (


	Area,
	Source,
	LocalPatientIdentifier,
	NHSNumber,
	SURNAME,
	DateOfBirth,
	Sex,
	Postcode,
	RegisteredGP,
	RegisteredPractice,
	AdmissionDate,
	PDD,
	OPDD,
	RetentionReason,
	Ward,
	GMC,
	LocalConsultantCode,
	Specialty,
	SpellNumber,
	IntendedManagement,
	AdmissionMethod,
	HomeLeave,
	MFDDate,
	MFDTime,
	Site,
	PatientClassification,
	FORENAME,
	LinkID,
	SnapshotDateTime,
	--added below kr 07102021
	HospitalDischargedTo ,
	LocationOfPatient,
	TransferredTo,
	IsolationRequired,
	IsolationReasonPrevious	,
	DateIsolationIdentified,
	IsolationCurrent,
	IsolationReasonCurrent,
	IsolationRiskAssessmentPrevious,
	IsolationRiskAssessmentCurrent

)
--Get the data
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
Select distinct
	''Central'' AS Area,
	''WPAS'' AS Source,
	PATIENT.CASENO,
	PATIENT.NHS,
	trim(PATIENT.SURNAME) as Surname,
	PATIENT.BIRTHDATE,
	PATIENT.SEX,
	PATIENT.POSTCODE,
	PATIENT.Registered_GP,
	PATIENT.GP_Practice,
	MASTER_TRT.TRT_DATE,
    (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%'' order by 1 desc)  AS PDD,
    (select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) not like ''%MFD%''order by 1 asc) as OPDD, 
	Null AS RetentionReason,
	MASTER_TRT.CLOC ,
	GP2.GP_CODE ,
	MASTER_TRT.CCONS ,
	MASTER_TRT.CSPEC,
	MASTER_TRT.ACTNOTEKEY as Actnotekey,
	MASTER_TRT.TRT_INTENT,
	MASTER_TRT.ADMIT_METHOD,
	null AS HomeLeave,
	(select first 1 estimated_discharge_date from est_disch where est_disch.linkid = master_trt.linkid and UPPER(reason) like ''%MFD%''order by 1 asc) as MFD,
	null as MFDTime,
	PADLOC.BELONGS_TO,
	--PADLOC.BASE_DESC,
	RTRIM(MASTER_TRT.REAL_MANAGEMENT) AS PatientClassification,
	trim(PATIENT.FORENAME),
   MASTER_TRT.LINKID AS LinkId,
	CURRENT_TIMESTAMP as SnapshotDateTime,
	null as HospitalDischargedTo ,
	null as LocationOfPatient,
	null as TransferredTo,
	null as IsolationRequired,
	null as IsolationReasonPrevious	,
	null as DateIsolationIdentified,
	null as IsolationCurrent,
	null as IsolationReasonCurrent,
	null as IsolationRiskAssessmentPrevious,
	null as IsolationRiskAssessmentCurrent
from 
	MASTER_TRT 
	LEFT join PATIENT on MASTER_TRT.CASENO = PATIENT.CASENO 
	LEFT join PADLOC on MASTER_TRT.CLOC = PADLOC.LOCCODE
	LEFT join GP2 on MASTER_TRT.CCONS = GP2.PRACTICE
where 
	MASTER_TRT.TRT_TYPE IN (''AC'',''AL'',''AE'')

')




exec (@sql)



--------Update Script for PDD Entry------

Update @results
Set PDD =
		case 
			when ca.PredictedDischargeDate is not null then ca.PredictedDischargeDate
			--when ha.PredictedDischargeDate is not null then ha.PredictedDischargeDate
			Else i.pdd
		end

from
 @results i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
--left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.LinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)



------OLD VERSION Update Script for PDD Entry------

----;with cte (PatientID,AdmissionID,PredictedDischargeDate,UpdateDateTime,RowNum, area) 
----as ( select * from ( select 
----		PatientID
----		,AdmissionID
----		,PredictedDischargeDate
----		,UpdateDateTime
----		,ROW_NUMBER() over(PARTITION by PatientID,AdmissionID order by UpdateDateTime desc) as rn,
----		Area
----		from @Stream 
----	) t
----where t.rn = 1
----) 
----update @PASCurrentInpatient set PDD = PredictedDischargeDate from cte p 
----inner join @PASCurrentInpatient r on  r.LocalPatientIdentifier = p.PatientID and r.LinkID = p.AdmissionID  and r.Area = p.area

------Update Script for MFD Entry------

Update @results  
Set MFDDate =
case 
		when ca.MedicallyFitDate is not null then ca.MedicallyFitDate
		--when ha.MedicallyFitDate is not null and ca.MedicallyFitDate is null then ha.MedicallyFitDate
		Else i.MFDDate
		end

from
 @results i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
--left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.LinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)

------OLD VERSION Update Script for MFD Entry------

----;with cte (PatientID,AdmissionID,MedicallyFitDate,UpdateDateTime,RowNum, area) 
----as ( select * from ( select 
----	PatientID
----	,AdmissionID
----	,MedicallyFitDate
----	,UpdateDateTime
----	,ROW_NUMBER() over(PARTITION by PatientID,AdmissionID order by UpdateDateTime desc) as rn,
----	Area
----from @Stream
----) t

----where t.rn = 1
----) 
----update @PASCurrentInpatient set MFDDate = MedicallyFitDate from cte p 
----inner join @PASCurrentInpatient r on r.LocalPatientIdentifier = p.PatientID and r.LinkID = p.AdmissionID  and r.Area = p.area


------Update Script for OPDD Entry------
Update @results 
Set OPDD =
		case 
			when ca.PredictedDischargeDate is not null then ca.PredictedDischargeDate
			--when ha.PredictedDischargeDate is not null then ha.PredictedDischargeDate
			Else i.pdd
		end
from
 @results i
left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
--left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[AdmissionExtrasHistory] ha on (ha.admissionid = i.LinkID and ha.patientid = i.LocalPatientIdentifier and ha.area = i.area)

------OLD VERSION Update Script for OPDD Entry------

----;with cte (PatientID,AdmissionID,PredictedDischargeDate,UpdateDateTime,RowNum, area) 
----as ( select * from ( select 
----		PatientID
----		,AdmissionID
----		,PredictedDischargeDate
----		,UpdateDateTime
----		,ROW_NUMBER() over(PARTITION by PatientID,AdmissionID order by UpdateDateTime asc) as rn,
----		area
----from @Stream
----) t

----where t.rn = 1
----) 

----update @PASCurrentInpatient set OPDD = PredictedDischargeDate from cte p 
----inner join @PASCurrentInpatient r on  r.LocalPatientIdentifier  = p.PatientID and r.LinkID = p.AdmissionID and r.Area = p.area




UPDATE @results SET HospitalDischargedTo = ca.TransferBedType FROM  @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET LocationOfPatient = ca.PatientLocation FROM  @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET TransferredTo = ca.TransferRequired FROM   @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET IsolationRequired = ca.IsolationRequired FROM   @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET IsolationReasonPrevious = ca.IsolationReason FROM   @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET DateIsolationIdentified = ca.DateIdentified FROM   @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results SET IsolationCurrent = ca.CurrentlyIsolated FROM   @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET IsolationReasonCurrent = ca.CurrentIsolationReason FROM  @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET IsolationRiskAssessmentPrevious = ca.RiskAssessed FROM  @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)
UPDATE @results  SET IsolationRiskAssessmentCurrent = ca.CurrentRiskAssessment FROM   @results i left join [7A1AUSRVSQL0003].[WardBoards].[dbo].[CurrentAdmissionExtras] ca on (ca.admissionid = i.LinkID and ca.patientid = i.LocalPatientIdentifier and ca.area = i.area)







select  
	Area,
	Source,
	LocalPatientIdentifier,
	NHSNumber,
	SURNAME,
	DateOfBirth,
	Sex,
	Postcode,
	RegisteredGP,
	RegisteredPractice,
	AdmissionDate,
	PDD,
	OPDD,
	RetentionReason,
	Ward,
	GMC,
	LocalConsultantCode,
	Specialty,
	SpellNumber,
	IntendedManagement,
	AdmissionMethod,
	HomeLeave,
	MFDDate,
	MFDTime,
	Site,
	PatientClassification,
	FORENAME,
	LinkID,
	SnapshotDateTime,
	--added below kr 07102021
	HospitalDischargedTo ,
	LocationOfPatient,
	TransferredTo,
	IsolationRequired,
	IsolationReasonPrevious	,
	DateIsolationIdentified,
	IsolationCurrent,
	IsolationReasonCurrent,
	IsolationRiskAssessmentPrevious,
	IsolationRiskAssessmentCurrent

from @results
--drop table @PASCurrentInpatient 

END

GO
