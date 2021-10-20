SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Common_Ref_Location]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
MainCode varchar(200)--
,MainName varchar(200)--
,NationalHospitalCode varchar(200) --
,SiteDescription varchar(200)  --
,LocalCode varchar(200)
,LocalName varchar(200)
,LocalHospitalCode varchar(200)
,LocalHospitalName varchar(200)
,Area varchar(200)
,Source varchar(200)
,SortOrder varchar(200)
,WardTelephoneNumber varchar(200) --
,SiteAddress varchar(300) --
,SitePostcode varchar(200) --
,LocationType varchar(200) --
,WardType varchar(200) --
,Organisation  varchar(200)
,DatixHospitalCode varchar(200)
  ,LiveDataHospitalCode varchar(200)
  ,OldLiveDataHospitalCode varchar(200)
  ,ICNETHospitalCode varchar(200)
  ,HospitalShortName varchar(200)
  ,HospitalCodeName varchar(200)
  ,HospitalNameCode varchar(200)
  ,CommunityHospital varchar(200)
  ,DatixWardCode varchar(200)
  ,WardCodeName varchar(200)
  ,WardNameCode varchar(200)
  ,HCMSWardCode varchar(200)
  ,ICNETWardCode varchar(200)
  ,ESR varchar(200)
  ,ESROrg varchar(200)
  ,DTOCWardCode varchar(200)
  ,Active varchar(200)
  ,Location varchar(200)
  ,LocationCode varchar(200)
  ,Specialty varchar(200)
  ,ERostering varchar(200)
	
)


INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		rtrim(LOCCODE) as LocalCode,
		LOCDESC as LocalName,
		Provider_code as LocalHosptialCode,
		base_desc as LocalHospitalName,
		''East'' as Area,
		''Myrddin'' as Source,
		''3'' as SortOrder
	FROM 
		PADLOC
		where loccode is not null
		
	')
)


--INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
--(
--SELECT * FROM OPENQUERY(WPAS_EAST,'
--	SELECT DISTINCT
--		Provider_code as LocalCode,
--		base_desc as LocalName,
--		Provider_code as LocalHosptialCode,
--		base_desc as LocalHospitalName,
--		''East'' as Area,
--		''Myrddin'' as Source,
--		''3'' as SortOrder
--	FROM 
--		PADLOC
--		where Provider_code is not null
--		and provider_code <> ''''
--		and loctype = ''H''
		
--	')
--)



INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		rtrim(ORG_CODE) as LocalCode,
		ORG_NAME as LocalName,
		'''' as LocalHosptialCode,
		'''' as LocalHospitalName,
		''East'' as Area,
		''Myrddin'' as Source,
		''3'' as SortOrder
	FROM 
		ORGCODES
		where ORG_CODE is not null
		
	')
)

INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		rtrim(Provider_CODE) as LocalCode,
		LOCDESC as LocalName,
		Provider_code as LocalHosptialCode,
		base_desc as LocalHospitalName,
		''East'' as Area,
		''Myrddin'' as Source,
		''3'' as SortOrder
	FROM 
		PADLOC
		where loccode is not null
		--and loccode <> ''CA1FA''
		and loctype = ''H''
				and where_used = ''RO''
		
	')

		where Localcode not in (select Localcode from @Results where source = 'Myrddin')


	)



INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT * FROM OPENQUERY(WPAS_Central,'
	SELECT DISTINCT
		rtrim(LOCCODE) as LocalCode,
		LOCDESC as LocalName,
		Provider_code as LocalHosptialCode,
		base_desc as LocalHospitalName,
		''Central'' as Area,
		''WPAS'' as Source,
		''2'' as SortOrder
	FROM 
		PADLOC
		where loccode is not null
		--and loccode <> ''CA1FA''
		
		
	')
)



--INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
--(
--SELECT * FROM OPENQUERY(WPAS_Central,'
--	SELECT DISTINCT
--		Provider_code as LocalCode,
--		base_desc as LocalName,
--		Provider_code as LocalHosptialCode,
--		base_desc as LocalHospitalName,
--		''Central'' as Area,
--		''WPAS'' as Source,
--		''2'' as SortOrder
--	FROM 
--		PADLOC
--		where Provider_code is not null
--		and provider_code <> ''''
--		and loctype = ''H''
		
--	')
--)



INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT * FROM OPENQUERY(WPAS_Central,'
	SELECT DISTINCT
		rtrim(ORG_CODE) as LocalCode,
		ORG_NAME as LocalName,
		'''' as LocalHosptialCode,
		'''' as LocalHospitalName,
		''Central'' as Area,
		''WPAS'' as Source,
		''3'' as SortOrder
	FROM 
		ORGCODES
		where ORG_CODE is not null
		and org_code not like ''%"%''
		
	')
)

INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT * FROM OPENQUERY(WPAS_Central,'
	SELECT DISTINCT
		rtrim(Provider_CODE) as LocalCode,
		LOCDESC as LocalName,
		Provider_code as LocalHosptialCode,
		base_desc as LocalHospitalName,
		''Central'' as Area,
		''WPAS'' as Source,
		''2'' as SortOrder
	FROM 
		PADLOC
		where loccode is not null
		--and loccode <> ''CA1FA''
		and loctype = ''H''
				and where_used = ''RO''
		
	')

	where Localcode not in (select Localcode from @Results where source = 'WPAS')


	)






INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT DISTINCT

		rtrim(hi.identifier)  as LocalCode,
		ho.description as LocalName,
		CASE WHEN ho.HOTYP_REFNO = 6006 then ho.MAIN_IDENT else ho2.MAIN_IDENT END as LocalHosptialCode,
		CASE WHEN ho.HOTYP_REFNO = 6006  then ho.DESCRIPTION else ho2.DESCRIPTION END as LocalHospitalName,
		'West' as Area,
		'Pims' as Source,
		'1' as SortOrder

	FROM 
		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].health_organisations ho
		join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS ho2
		on ho2.HEORG_REFNO = ho.PARNT_REFNO 
		join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].Health_Organisation_ids hi
		on hi.heorg_refno = ho.heorg_refno
		and hi.hityp_Refno = 4050

		where ho.MAIN_IDENT is not null 
		and ho.HOTYP_REFNO in (6006,6007,6008,207043,6009,200920,6012)
		and not ho.MAIN_IDENT in ('HHENORSAF')
		and ho.description not like  '%Comm Paeds - Y Lawnt%'
				and hi.heoid_Refno not in (145465,145450,145466,145434,145435)
		)




INSERT INTO @Results(LocalCode,LocalName,Source,Area)
  	SELECT
		CAST(Lkp_ID AS VARCHAR(10)) AS LocalCode,
		Lkp_Name AS LocalName,
		'Symphony' AS Source,
		'East' AS Area
	FROM
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Reports].dbo.Lookups
	WHERE
		Lkp_ParentID=5828

			
--(



--	SELECT DISTINCT

--		rtrim(ho.MAIN_IDENT)  as LocalCode,
--		ho.description as LocalName,
--		CASE WHEN ho.HOTYP_REFNO = 6006 then ho.MAIN_IDENT else ho2.MAIN_IDENT END as LocalHosptialCode,
--		CASE WHEN ho.HOTYP_REFNO = 6006  then ho.DESCRIPTION else ho2.DESCRIPTION END as LocalHospitalName,
		
--		'West' as Area,
--		'Pims' as Source,
--		'1' as SortOrder
--	FROM 
--		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].health_organisations ho
--		join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS ho2
--		on ho2.HEORG_REFNO = ho.PARNT_REFNO 

--		where ho.MAIN_IDENT is not null 
--		and ho.HOTYP_REFNO in (6006,6007,6008,207043)
--		and not ho.MAIN_IDENT in ('HHENORSAF')
	
--	)



/*
------------------------------------------------------------------------------------------------------------
-- Therapy Manager
--

INSERT INTO @Results(LocalCode,LocalName,LocalHospitalCode,LocalHospitalName,Area,Source,SortOrder)
(
SELECT DISTINCT

ID  as  LocalCode,
Text as LocalName,
'TherMan' as Source,
'1' as SortOrder
from [SQL4\SQL4].[physio].[dbo].Lists  where type = '10'

)

*/

INSERT INTO @Results(LocalCode,LocalName,Source,Area) Select '7A1A4' as LocalCode, 'Wrexham Maelor Hospital' as LocalName, 'Symphony' as Source,'East' AS Area where not exists (select * from @Results where localcode = '7A1A4'  and source = 'Symphony')

INSERT INTO @Results(LocalCode,LocalName,Source,Area) Select 'NT325' as LocalCode, 'Spire Murrayfield Hospital' as LocalName, 'WPAS' as Source,'Central' AS Area  where not exists (select * from @Results where localcode = 'NT325'  and source = 'wpas')
INSERT INTO @Results(LocalCode,LocalName,Source,Area) Select '7A1AV' as LocalCode, 'Llandudno Hospital' as LocalName, 'WPAS' as Source,'Central' AS Area  where not exists (select * from @Results where localcode = '7A1AV'  and source = 'wpas')
INSERT INTO @Results(LocalCode,LocalName,Source,Area) Select '7A1F8' as LocalCode, 'Bryn Hesketh' as LocalName, 'WPAS' as Source,'Central' AS Area  where not exists (select * from @Results where localcode = '7A1F8'  and source = 'wpas')

INSERT INTO @Results(LocalCode,LocalName,Source,Area) Select 'RT7AU' as LocalCode, 'Ysbyty Gwynedd' as LocalName, 'Pims' as Source,'West' AS Area  where not exists (select * from @Results where localcode = 'RT7AU'  and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source,Area) Select 'RT7AV' as LocalCode, 'Llandudno Hospital' as LocalName, 'Pims' as Source,'West' AS Area  where not exists (select * from @Results where localcode = 'RT7AV'  and source = 'pims')


UPDATE @Results SET
	R.MainCode = S.MainCode,
	R.MainName = S.MainName,
	--R.NationalHospitalCode = S.NationalHospitalCode,
	--R.SiteDescription = S.SiteDescription,
	--R.WardTelephoneNumber = S.WardTelephoneNumber,
	--R.SiteAddress = S.SiteAddress,
	--R.SitePostcode = S.SitePostcode,
	R.LocationType = S.LocationType


FROM
	@Results R
	INNER JOIN Mapping.dbo.Common_Location_Map SM ON ltrim(rtrim(R.LocalCode))=ltrim(rtrim(SM.LocalCode)) AND ltrim(rtrim(R.Source))=ltrim(rtrim(SM.Source)) AND LTRIM(RTRIM(R.Area))=SM.Area
	INNER JOIN Mapping.dbo.Common_Location S ON ltrim(rtrim(SM.MainCode))=ltrim(rtrim(S.MainCode))

SELECT distinct * FROM @Results
--where maincode is null
where LocalCode is not null 
order by MainCode
END
GO
