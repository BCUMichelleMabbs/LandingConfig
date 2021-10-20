SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_Organisation]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(20),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(300),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		DHA AS LocalCode,
		DHA_NAME AS LocalName,
		''WPAS'' AS Source
	 FROM 
		DHACODES
')


INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		DHA AS LocalCode,
		DHA_NAME AS LocalName,
		''Myrddin'' AS Source
	 FROM 
		DHACODES
')


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Commissioner_Code AS LocalCode,
		Commissioner_Description AS LocalName,
		''WPAS'' AS Source
	 FROM 
		Commissioner
		where Commissioner_code is not null
')


INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		Commissioner_Code AS LocalCode,
		Commissioner_Description AS LocalName,
		''Myrddin'' AS Source
	 FROM 
		Commissioner
		where Commissioner_code is not null
		and Commissioner_Code not in (''OSV'')
')



--INSERT INTO @Results(LocalCode,LocalName,Source)	
--SELECT 
--		MAIN_IDENT AS LocalCode,
--		DESCRIPTION AS LocalName,
--		'Pims' AS Source
--	FROM 
--		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS
--	WHERE
--		HOTYP_REFNO in (213983,214076)

		-- 214077 kr removed these as they are 5 digits and not 3

--INSERT INTO @Results(LocalCode,LocalName,Source)	
--select distinct
--STATE_CODE as LocalCode
--,null as LocalName
--,'Pims' as Source 
--from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].POSTCODES
--where state_code <> ''

--INSERT INTO @Results(LocalCode,LocalName,Source)	
--select distinct 
--pcg_code as LocalCode
--,null as LocalName
--,'Pims' as Source
--from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].POSTCODES 
--where pcg_code <> ''
--kerry removed this as it created duplicates



INSERT INTO @Results(LocalCode,LocalName,Source)	
	SELECT DISTINCT
		ha_ha AS LocalCode,
		null AS LocalName,
		'Symphony' AS Source
	 FROM 
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].[HA_PCG]
		where ha_ha <> ''

		INSERT INTO @Results(LocalCode,LocalName,Source)	
	SELECT DISTINCT
		ha_pcg AS LocalCode,
		null AS LocalName,
		'Symphony' AS Source
	 FROM 
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].[HA_PCG]
		where ha_pcg <> ''





INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT DISTINCT 
	LocalCode AS LocalCode,
	(
		SELECT TOP 1 
			HO.DESCRIPTION 
		FROM 
			[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS HO 
			
		WHERE 
			HO.MAIN_IDENT=X.LocalCode AND 
			ISNULL(HO.ARCHV_FLAG,'N')='N' 
		ORDER BY 
			START_DTTM DESC
	) AS LocalName,
	'Pims' AS Source
FROM
	(
		SELECT 
			MAIN_IDENT AS LocalCode
		FROM 
			[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS
		WHERE
			HOTYP_REFNO in (213983,214076)
		UNION
		SELECT
			STATE_CODE as LocalCode
		FROM
			[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].POSTCODES
		WHERE 
			state_code <> ''
)X


INSERT INTO @Results(LocalCode,LocalName,Source) Select '14Y' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = '14Y'  and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q46' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q46' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q57' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q57' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q58' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q58' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'YK1' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'YK1' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q47' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q47' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q48' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q48' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15A' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = '15A' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'ZB1' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'ZB1' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q88' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q88' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15E' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = '15E' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '13T' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = '13T' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q73' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q73' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15F' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = '15F' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '14L' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = '14L' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q81' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q81' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q74' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q74' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q79' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q79' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q78' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q78' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q84' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q84' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q77' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q77' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q71' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q71' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q72' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q72' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q44' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q44' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q83' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q83' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q75' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q75' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q76' as LocalCode, null as LocalName, 'Myrddin' as Source where not exists (select * from @Results where localcode = 'Q76' and source = 'myrddin')

INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q44' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q44' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'SK9' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'SK9' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q88' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q88' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q60' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q60' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '13T' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '13T' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '005' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '005' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15F' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '15F' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'SJ9' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'SJ9' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'TAP' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'TAP' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'ZB1' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'ZB1' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q79' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q79' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q81' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q81' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q74' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q74' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q78' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q78' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q71' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q71' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q84' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q84' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '14L' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '14L' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q77' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q77' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q72' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q72' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q76' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q76' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q83' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q83' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'Q75' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'Q75' and source = 'WPAS')

INSERT INTO @Results(LocalCode,LocalName,Source) Select '14Y' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '14Y' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15A' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '15A' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15C' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '15C' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15D' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '15D' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select '15E' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = '15E' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'TAN' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'TAN' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'YK1' as LocalCode, null as LocalName, 'WPAS' as Source where not exists (select * from @Results where localcode = 'YK1' and source = 'WPAS')


INSERT INTO @Results(LocalCode,LocalName,Source) Select 'NT2' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'NT2' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'RBN' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'RBN' and source = 'pims')







UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.Common_Organisation_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source
	INNER JOIN Mapping.dbo.Common_Organisation AM ON AMM.MainCode=AM.MainCode
	
SELECT * FROM @Results
order by MainCode
END
GO
