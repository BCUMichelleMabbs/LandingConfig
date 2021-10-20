SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Common_Ref_Location_KR]
	
AS
BEGIN
	
SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode							varchar(10),	--Mapping
	Name								varchar(300),	--Mapping
	LocationDescription			varchar(300),
	
	SiteCode							varchar(5),		--Mapping
	SiteName							varchar(100),	--Mapping
	NationalGrouping				varchar(3),		--Mapping
	HighLevelHealthGeography	varchar(3),		--Mapping
	
	LocationType					varchar(20),	--Mapping
	LocationCategory				varchar(20),	--Mapping
	SortOrder						varchar(1),		--Mapping

	LocalCode						varchar(200),	--Local - from system
	LocalName						varchar(max),	--Local - from system
	LocalSiteCode					varchar(200),	--Local - from system
	LocalLocationType				varchar(200),	--Local - from system
	LocalCategory					varchar(200),	--Local - from system
	LocalParentCode				varchar(200),	--Local - from system
	Area								varchar(200),	--Local - from system
	Source							varchar(10),	--Local - from system
	GeographicalArea				varchar(10)
	)


INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,LocalLocationType,LocalCategory,LocalParentCode,Area,Source)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		rtrim(LOCCODE) as LocalCode,
		replace(replace(replace(replace(LOCDESC, '','', ''''), ''"'', ''''), ascii_char(10), ''''), ascii_char(13), '''') as LocalName,
		
		Provider_code as LocalSiteCode,
		
		Ward_Type as LocalLocationType,
		LocType as LocalCategory,
		Belongs_to as LocalParentCode,

		''East'' as Area,
		''Myrddin'' as Source
	FROM 
		PADLOC
		where loccode is not null
		and loccode not in (''743AA'')
	')
)




INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		rtrim(ORG_CODE) as LocalCode,
		replace(replace(replace(replace(ORG_NAME, '','', ''''), ''"'', ''''), ascii_char(10), ''''), ascii_char(13), '''') as LocalName,
		null as LocalSiteCode,
		null as LocalLocationType,
		null as LocalCategory,
		null as LocalParentCode,
		''East'' as Area,
		''Myrddin'' as Source
	FROM 
		ORGCODES
		where ORG_CODE is not null
		
	')
)





INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
SELECT * FROM OPENQUERY(WPAS_Central,'
	SELECT DISTINCT
		rtrim(LOCCODE) as LocalCode,
		replace(replace(replace(replace(LOCDESC, '','', ''''), ''"'', ''''), ascii_char(10), ''''), ascii_char(13), '''') as LocalName,

		Provider_code as LocalSiteCode,
		
		Ward_Type as LocalLocationType,
		LocType as LocalCategory,
		Belongs_to as LocalParentCode,

		''Central'' as Area,
		''WPAS'' as Source
	FROM 
		PADLOC
		where loccode is not null
		and loccode <> ''''
	
	')
)




INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
SELECT * FROM OPENQUERY(WPAS_Central,'
	SELECT DISTINCT
		rtrim(ORG_CODE) as LocalCode,
		replace(replace(replace(replace(ORG_NAME, '','', ''''), ''"'', ''''), ascii_char(10), ''''), ascii_char(13), '''') as LocalName,
		null as LocalSiteCode,
		null as LocalLocationType,
		null as LocalCategory,
		null as LocalParentCode,
		''Central'' as Area,
		''WPAS'' as Source
	FROM 
		ORGCODES
		where ORG_CODE is not null
		and org_code not like ''%"%''
		and org_code <> ''''
		and org_code in (''HNH'', ''PLW'')
		
	')
)


INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
SELECT DISTINCT

		rtrim(hi.identifier)  as LocalCode,
		ho.description as LocalName,
		CASE WHEN ho.HOTYP_REFNO = 6006 then ho.MAIN_IDENT else ho2.MAIN_IDENT END as LocalSiteCode,
		Null as LocalLocationType,
		Null as LocalCategory,
		Null as LocalParentCode,
		'West' as Area,
		'Pims' as Source

	FROM 
		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].health_organisations ho
		join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS ho2
		on ho2.HEORG_REFNO = ho.PARNT_REFNO 
		join [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].Health_Organisation_ids hi
		on hi.heorg_refno = ho.heorg_refno
		and 
		(
		(hi.hityp_Refno = 4050 and ho.hotyp_refno<> 6007)
		or
		(hi.hityp_Refno = 10015 and ho.hotyp_Refno  = 6007)
		)
		and ho.hotyp_refno not in (6010,6011,6012,6013)

		where ho.MAIN_IDENT is not null 
		and ho.HOTYP_REFNO in (6006,6007,6008,207043,6009,200920,6012)
		and not ho.MAIN_IDENT in ('HHENORSAF')
		and ho.description not like  '%Comm Paeds - Y Lawnt%'
				and hi.heoid_Refno not in (145465,145450,145466,145434,145435)
		
		)





		INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,SiteName,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
SELECT DISTINCT
		l2.code as LocalCode,
		l2.description as LocalName,
		null as LocalSiteCode,
		null as SiteName,
		NULL as LocalLocationType,
		NULL as LocalCategory,
		NULL as LocalParentCode,
		CASE inc_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'BCU' END as Area,
		'Datix' as Source

		FROM [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[incidents_main] i
LEFT JOIN [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_locactual] l2 on i.inc_locactual = l2.code
LEFT JOIN [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_unit] l1 on i.inc_unit = l1.code
WHERE l2.code IS NOT NULL

		)


INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
Select Distinct
	lm.LocalCode as LocalCode,
	i.HospitalDischargedTo as LocalName,
		null as LocalSiteCode,
		null as LocalLocationType,
		null as LocalCategory,
		null as LocalParentCode,
		i.Area as Area,
		i.Source as Source
From Foundation.dbo.PAS_Data_Inpatient I
left join mapping.dbo.Common_Location_Map_kr as lm on rtrim(ltrim(upper(lm.LocalName))) = ltrim(rtrim(upper(i.HospitalDischargedTo))) and lm.source = 'WPAS' 
where i.Source in ('OldWH')
and i.HospitalDischargedTo is not null
and i.HospitalDischargedTo not in ('ABERGELE HOSPITAL')

--order by i.HospitalDischargedTo
)


INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
Select Distinct
	i.sitecode as LocalCode,
	null as LocalName,
		null as LocalSiteCode,
		null as LocalLocationType,
		null as LocalCategory,
		null as LocalParentCode,
		i.Area as Area,
		i.Source as Source
From Foundation.dbo.PAS_Data_Inpatient I
left join mapping.dbo.Common_Location_Map_kr as lm on rtrim(ltrim(upper(lm.LocalCode))) = ltrim(rtrim(upper(i.SiteCode))) and lm.source = 'WPAS' 
where i.Source in ('OldWH')
and i.SiteCode is not null
)

INSERT INTO @Results(LocalCode,LocalName,LocalSiteCode,  LocalLocationType, LocalCategory, LocalParentCode, Area, Source)
(
Select Distinct
	i.Ward as LocalCode,
	null as LocalName,
		null as LocalSiteCode,
		null as LocalLocationType,
		null as LocalCategory,
		null as LocalParentCode,
		i.Area as Area,
		i.Source as Source
From Foundation.dbo.PAS_Data_Inpatient I
left join mapping.dbo.Common_Location_Map_kr as lm on rtrim(ltrim(upper(lm.LocalCode))) = ltrim(rtrim(upper(i.Ward))) and lm.source = 'WPAS' 
where i.Source in ('OldWH')
and i.Ward is not null
and i.ward not in ('7A1A2', 'CA4AA')
--and i.ward not like '7A1A2'
--order by LocalCode
)



INSERT INTO @Results(LocalCode,LocalName,Source,Area)
  	SELECT distinct
		CAST(Lkp_ID AS VARCHAR(10)) AS LocalCode,
		Lkp_Name AS LocalName,
		'Symphony' AS Source,
		'East' AS Area
	FROM
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Reports].dbo.Lookups
	WHERE
		Lkp_ParentID=5828



	INSERT INTO @Results(LocalCode,LocalName,Source,Area)
	values ('7A1A4', 'Wrexham Maelor Hospital', 'Symphony', 'East'),
			 ('7A1AU', 'Ysbyty Gwynedd', 'WEDS', 'West'),
			 ('7A1CA', 'Alltwen', 'WEDS', 'West'),
			 ('7A1AX', 'Bryn Beryl Hospital', 'WEDS', 'West'),
			 ('7A1AV', 'Llandudno General Hospital', 'WEDS', 'West'),
			 ('7A1B2', 'Tywyn & District War Memorial Hospital', 'WEDS', 'West'),
			 ('7A1DC', 'Penrhos Stanley Hospital', 'WEDS', 'West'),
			 ('7A1AY', 'Dolgellau Hospital', 'WEDS', 'West'),
			('7A1A1', 'Ysbyty Gwynedd', 'WPAS', 'Central')

		
INSERT INTO @Results(LocalCode,LocalName,Source,Area)
  	SELECT Distinct
		CAST(LtnNbr AS VARCHAR(10)) AS LocalCode,
		convert(varchar(max), LtnNme) AS LocalName,
		'Viewpoint' AS Source,
		'BCU' AS Area
	FROM
		[SSIS_Loading].[PatientExperience].[dbo].[AgeBand]
	where
		convert(varchar(max), LtnNme) not in ('Medical Assessment Unit now AMU ÔÇô Assessment Unit ', 'ward 11', 'Acute Medical Unit (AMU)', 'Rapid Assessment Unit (RAU)', 'Francon Ward', 'Pain Management - Specialist Nurse and Physiotherapist', 'Llynfor Ward', 'Pharmacy Dispensary' , 'Oncology Clinics')
		and convert(varchar(max), LtnNme) is not null
		order by CAST(LtnNbr AS VARCHAR(10))


INSERT INTO @Results(LocalCode,LocalName,Source, LocationCategory, MainCode, Area) Select 'East' as LocalCode, 'East' as LocalName, 'Myrddin' as Source, LocationCategory = 'Area', Maincode = 'East', Area = 'East' where not exists (select * from foundation.dbo.Common_Ref_Location_KR where localcode = 'East'  and source = 'Myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source, LocationCategory, MainCode, Area) Select 'Central' as LocalCode, 'Central' as LocalName, 'WPAS' as Source, LocationCategory = 'Area', Maincode = 'Central', Area = 'Central' where not exists (select * from foundation.dbo.Common_Ref_Location_KR where localcode = 'Central'  and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, LocationCategory, MainCode, Area) Select 'West' as LocalCode, 'West' as LocalName, 'Pims' as Source, LocationCategory = 'Area', Maincode = 'West', Area = 'West' where not exists (select * from foundation.dbo.Common_Ref_Location_KR where localcode = 'West'  and source = 'Pims')


SELECT
	CM.MainCode,
	CM.Name,
	CM.LocationDescription,
	CM.SiteCode,
	CM.SiteName,
	CM.NationalGrouping,
	CM.HighLevelHealthGeography,
	CM.LocationCategory,
	CM.LocationType,
	CM.SortOrder,
	R.LocalCode,
	R.LocalName,
	R.LocalSiteCode,
	R.LocalLocationType,
	R.LocalCategory,
	R.LocalParentCode,
	R.Area,
	R.Source,
	CM.GeographicalArea
FROM
	@Results R
	LEFT JOIN Mapping.dbo.Common_Location_Map_kr CLM ON 
		ltrim(rtrim(R.LocalCode))=ltrim(rtrim(CLM.LocalCode)) AND 
		ltrim(rtrim(R.Source))=ltrim(rtrim(CLM.Source)) AND 
		LTRIM(RTRIM(R.Area))=CLM.Area
	LEFT JOIN Mapping.dbo.Common_Location_kr CM ON ltrim(rtrim(CLM.MainCode))=ltrim(rtrim(CM.MainCode))

	where r.LocalCode is not null	
	--where r.localcode in ('7A1A4', '7A1AU', '7A1A1')
		--where 
		--cm.maincode is null
		--r.source = 'pims' and
		--r.localCODE like '%buf%'


		--where cm.maincode is null
		--where r.localsitecode = '7A1A4'
		order by MainCode
		--order by sitecode, localname
END
GO
