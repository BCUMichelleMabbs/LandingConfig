SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientPIMS]
	
AS
BEGIN
	
	SET NOCOUNT ON;

Create TABLE #Results(
	LocalPatientIdentifier varchar(50)
	,Forename varchar(80)
	,Surname varchar(80)
	,DateOfBirth date
	,NHSNumber varchar(20)
		,Title varchar(30)
	,Sex varchar(30)
	,EthnicGroup varchar(50)
	,Address1 varchar(255)
	,Address2 varchar(100)
	,Address3 varchar(100)
	,Address4 varchar(100)
	,Postcode varchar(20)
	,StartDate date
	,EndDate date
	,Source varchar(20)
	,[NursingHomeFlag] varchar(1)
	,[NursingHomeType] varchar(50)
	,[EMIFlag] varchar(1)
	,[NursingHomeName] varchar(200)
)

INSERT INTO #Results
(LocalPatientIdentifier
	,Forename
	,Surname
	,DateOfBirth
	,NHSNumber
	,Title
	,Sex
	,EthnicGroup
	,Address1
	,Address2
	,Address3
	,Address4
	,Postcode
	,StartDate 
	,EndDate 
	,Source 
	,[NursingHomeFlag]
	,[NursingHomeType]
	,[EMIFlag]
	,[NursingHomeName] 
	)

	(
select 
p.pasid as LocalPatientIdentifier
,p.forename as Forename
,p.SURNAME as Surname
,p.DATE_OF_BIRTH as DateOfBirth
,p.NHS_IDENTIFIER as NHSNumber
,title.description as Title
,s.DESCRIPTION as Sex
,eth.DESCRIPTION as EthnicGroup
,a.line1 as Address1
,a.line2 as Address2 
,a.line3 as Address3
,a.line4 as Address4
,a.pcode as Postcode 
,CONVERT(Date,ar.START_DTTM) as StartDate
,CONVERT(Date,ar.END_DTTM) as EndDate
,'PIMS' as Source
,NULL AS [NursingHomeFlag]
,NULL AS [NursingHomeType]
,NULL AS [EMIFlag]
,NULL AS [NursingHomeName] 

from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].patients p
	join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES title on title.RFVAL_REFNO = p.TITLE_REFNO 
	join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES s on s.RFVAL_REFNO = p.SEXXX_REFNO 
	join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES eth on eth.RFVAL_REFNO = p.ETHGR_REFNO 
	left join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].ADDRESS_ROLES ar on ar.PATNT_REFNO = p.PATNT_REFNO and ar.ROTYP_CODE = 'HOME' and ISNULL(ar.archv_flag,'N') = 'N'
	left join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].ADDRESSES a on a.ADDSS_REFNO = ar.ADDSS_REFNO and a.ADTYP_CODE = 'POSTL' and ISNULL(a.archv_flag,'N')= 'N'

where ISNULL(p.archv_flag,'N') = 'N'

)

SELECT * FROM #Results 

drop table #Results 

END
GO
