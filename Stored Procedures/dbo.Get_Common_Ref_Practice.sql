SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_Practice]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(20),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(300),
	Source			VARCHAR(8),
	Area				varchar(10),

	NationalGrouping varchar(3),
	HighLevelHealthGeography varchar(5),
	Address1 varchar(200),
	Commissioner varchar(3),
	ClusterCode varchar (5),
	ClusterName varchar (200),
	LHB varchar (3)

)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Practice AS LocalCode,
		null AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		GP2

		
')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		Practice AS LocalCode,
		null AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		GP2
')



INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
	SELECT DISTINCT
		pr_praccode AS LocalCode,
		null AS LocalName,
		'Symphony' AS Source,
		'West' as Area
	 FROM 
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].[dbo].[Gp_Practise]
		where pr_praccode <> ''



INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT 
	MAIN_IDENT,DESCRIPTION,'PIMS', 'West'
FROM 
	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].HEALTH_ORGANISATIONS 
WHERE 
	HOTYP_REFNO in (6012, 6003,201310) and 
	ISNULL(ARCHV_FLAG,'N')='N' AND
	Main_Ident is not null and 
	Main_Ident <> '' AND
	not (MAIN_IDENT = 'V81998' and DESCRIPTION = 'RAF Valley') AND
	not (MAIN_IDENT = 'V81999' and DESCRIPTION = 'Practice Code is unknown') and
	not (MAIN_IDENT = 'V81999' and DESCRIPTION = 'Unknown Dental Practice') and 
	not (MAIN_IDENT = 'V25525' and DESCRIPTION = 'Orchard House Health Cent, Union Street, Stirling, , FK8 1PH') and
	not (MAIN_IDENT = 'V25474' and DESCRIPTION = 'Slamannan Clinic, Bank Street, Slamannan, , FK1 3EZ') and
	not (MAIN_IDENT = 'V25436' and DESCRIPTION = 'Meadowbank Health Centre, 3 Salmon Inn Road, Polmont, Falkirk, FK2 0XF') and
	not (MAIN_IDENT = 'V25154' and DESCRIPTION = 'Bannockburn Health Centre, Firs Entry, Bannockburn, Stirling, FK7 0HW') and
	not (MAIN_IDENT = 'V25140' and DESCRIPTION = 'Bannockburn Health Centre, Firs Entry, Bannockburn, Stirling, FK7 0HW') 




INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'V8199' as LocalCode, null as LocalName, 'Myrddin' as Source, 'East' as Area where not exists (select * from @Results where localcode = 'V8199' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '1' as LocalCode, null as LocalName, 'Myrddin' as Source, 'East' as Area where not exists (select * from @Results where localcode = '1' and source = 'myrddin')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'AU' as LocalCode, null as LocalName, 'Myrddin' as Source, 'East' as Area where not exists (select * from @Results where localcode = 'AU' and source = 'myrddin')

INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '00' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = '00' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '1' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = '1' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '126' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = '126' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '1246' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = '1246' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '999999' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = '999999' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'V8199' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = 'V8199' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'W01016' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = 'W01016' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'W94634' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = 'W94634' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'Y05569' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = 'Y05569' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'BL' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = 'BL' and source = 'WPAS')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'S' as LocalCode, null as LocalName, 'WPAS' as Source, 'Central' as Area where not exists (select * from @Results where localcode = 'S' and source = 'WPAS')

INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select '7A1AU' as LocalCode, null as LocalName, 'Pims' as Source, 'West' as Area where not exists (select * from @Results where localcode = '7A1AU' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'RQBAU' as LocalCode, null as LocalName, 'Pims' as Source, 'West' as Area  where not exists (select * from @Results where localcode = 'RQBAU' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'RT7AU' as LocalCode, null as LocalName, 'Pims' as Source, 'West' as Area  where not exists (select * from @Results where localcode = 'RT7AU' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source, Area) Select 'RT7AV' as LocalCode, null as LocalName, 'Pims' as Source, 'West' as Area where not exists (select * from @Results where localcode = 'RT7AV' and source = 'pims')



--UPDATE @Results SET
--	R.MainCode = AM.MainCode,
--	R.Name = AM.Name
--FROM
--	@Results R
--	left JOIN Mapping.dbo.Common_Practice_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source
--	left JOIN Mapping.dbo.Common_Practice AM ON AMM.MainCode=AM.MainCode
	
SELECT
	AM.Maincode,
	AM.Name,
	R.LocalCode,
	R.LocalName,
	R.Source,
	R.Area,
	AM.NationalGrouping,
	AM.HighLevelHealthGeography,
	AM.Address1,
	AM.Commissioner,
	pc.ClusterCode,
	pc.ClusterName,
	pc.LHBOfPractice



 FROM @Results  R
	left JOIN Mapping.dbo.Common_Practice_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source
	left JOIN Mapping.dbo.Common_Practice AM ON AMM.MainCode=AM.MainCode
	left Join Mapping.dbo.Common_PracticeCluster PC on pc.maincode = am.maincode 

	--where r.LocalCode in ('W93046', 'W93061', 'W95044')


order by maincode
END
GO
