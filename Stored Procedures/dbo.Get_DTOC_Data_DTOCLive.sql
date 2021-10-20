SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_DTOC_Data_DTOCLive] 

as begin 

Declare 
@Server varchar(100) = (Select Top 1 '['+[Server]+']' FROM [Foundation].[dbo].[Common_Ref_Server] WHERE Dataset = 'DTOC' ORDER BY Date desc, Time Desc), --Select the working server for that day (job runs to check each morning)
@Server1 varchar(100) = (Select Top 1 '['+[Server]+']' FROM [Foundation].[dbo].[Common_Ref_Server] WHERE Dataset = 'DTOC'  ORDER BY Date desc, Time Desc), --Duplicate server name for use in join query
@Join varchar(300),
@Join2 varchar(300)

Set @Server += '.[DTOCS].[dbo].[VW_Healthboard_CurrentDelays] d'   -- Concatinate server name with table into one parameter
Set @Join = ' LEFT JOIN ' + @Server1 + '.[DTOCS].[dbo].[VW_Healthboard_CurrentDelayReasons] r on r.DelayID = d.DelayID and r.FinishDate is null' -- Concatinate server name with joining table
Set @Join2 = ' LEFT JOIN [BCUINFO\BCUDATAWAREHOUSE].[Dimension].[dbo].[Common_Location_NA_WillBeDeleted] m on d.ORG_WARD = m.DTOC and CASE ORG_CODE 	WHEN ''7A1ZY'' THEN ''BHU''	WHEN ''7A1ZZ'' THEN ''7A1A4''	ELSE ORG_CODE END = m.NationalHospitalCode'


Declare @SQL as Varchar(max) = --Select all fields and rename them to plain english
'SELECT 
ACTUAL_DISCHARGE_DATE as DischargeDate,
cast([ADMISSION_DATE] as date) as AdmissionDate,
ADMISSION_METHOD as AdmissionMethod,
ADMISSION_SOURCE as AdmissionSource,
ADMISSION_SPECIALITY as AdmissionSpecialty,
COMMENTS as Comments,
CURRENT_SPECIALITY as CurrentSpecialty,
d.DELAYID as DelayID,
DISCHARGE_REASON as DischargeReason,
cast(INSERTDATE as Date) as InsertDate,
LAREF as LocalAuthorityReference,
CASE ORG_CODE 
		WHEN ''7A1ZY'' THEN ''BHU''
		WHEN ''7A1ZZ'' THEN ''7A1A4''
	ELSE ORG_CODE
END as HospitalCode,
ORG_WARD as Ward,
ORG_WARD_TYPE as WardType,
PAT_ADDRESS as PatientAddress,
PAT_CONSULTANT as ConsultantName,
cast([PAT_DOB] as Date) as DateOfBirth,
PAT_GPNAME as GPName,
PAT_NHSNO as NHSNumber,
PAT_PAS as PatientIdentifier,
REPLACE(PAT_PC,'' '','''') as PostCode,
PAT_UACODE as PatientUnitaryAuthority,
[READY_DISCHARGE_DATE] as ReadyForDischargeDate,
REQ_VALIDATION as RequireValidation,
RES_POST_DISCHARGE as DischargeDestination,
cast(GetDate() as date) as SnapshotDate,
[SS_REFERAL_DATE] as SocialServicesReferralDate,
SS_WORKER as SocialServicesWorker,
TRUSTCODE as TrustCode,
UACODE as UnitaryAuthority,
cast(UPDATEDATE as date) as UpdateDate,
VALIDATE as Validated,
VALIDATEBY as ValidatedBy,
VALIDATEBYSS as ValidatedBySocialServices,
VALIDATENOREASON as ReasonForNoValidation,
r.PREASON as ReasonCode,
cast(left(Convert(Time,Getdate()),5) as Time) as SnapshotTime,
cast(left(Convert(Time,UPDATEDATE),5) as Time) as UpdateTime,
cast(left(Convert(Time,InsertDate),5) as Time) as InsertTime,
m.PASWardCode as WardCode,
''DTOC'' as Source

FROM ' +

@Server   
+
@Join
+
@Join2

exec (@SQL)  --Execute the whole query and display results


END
GO
