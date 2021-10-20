SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_Diagnosis]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(300),
	Source			VARCHAR(8),
	Area				varchar(10)
)


INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT distinct
		cast(CODEDESC as varchar(10) character set WIN1251) AS LocalCode,
		--cast(SHORTDESC as varchar(300) character set WIN1251) AS LocalName,
		null as LocalName,
		''WPAS'' AS Source,
		''Central'' as area
	FROM 
		CODEDESC
	WHERE
		CODETYPE = ''10''
	and CODEDESC is not null 
	and CODEDESC <>''''
')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT distinct
		cast(CODEDESC as varchar(10) character set WIN1251) AS LocalCode,
		--cast(SHORTDESC as varchar(300) character set WIN1251) AS LocalName,
		null as LocalName,
		''Myrddin'' AS Source,
		''East'' as area
	FROM 
		CODEDESC
	WHERE
		CODETYPE = ''10''
	and CODEDESC is not null 
	and CODEDESC <>''''
')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)
select distinct

code as LocalCode,
null as localname,
--DESCRIPTION as LocalName
'Pims' as Source,
'West' as area

from [7A1AUSRVIPMSQL].ipmproduction.dbo.ODPCD_CODES 
where CCSXT_CODE = 'I10'
--and DESCRIPTION is not null
--and DESCRIPTION <> ' '



INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M0700' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M0700' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M0707' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M0707' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M0759' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M0759' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M0837' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M0837' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M1301' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M1301' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M1304' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M1304' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M2426' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M2426' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X0' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X0' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X2' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X2' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X3' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X3' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X5' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X5' and source = 'pims')
--INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X5' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X6' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X8' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X8' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M45X9' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M45X9' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M4950' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M4950' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M4954' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M4954' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M5421' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M5421' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M5430' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M5430' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M5435' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M5435' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M5452' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M5452' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M5454' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M5454' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M5465' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M5465' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M6544' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M6544' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7265' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7265' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7268' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7268' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7615' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7615' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7635' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7635' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7667' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7667' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7677' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7677' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7970' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7970' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7971' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7971' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7975' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7975' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7977' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7977' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7978' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7978' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M7979' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M7979' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'M8280' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'M8280' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'T0210' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'T0210' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'T0230' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'T0230' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'T0240' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'T0240' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'T0250' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'T0250' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'T10X0' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'T10X0' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'T12X0' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'T12X0' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'W469' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'W469' and source = 'pims')
INSERT INTO @Results(LocalCode,LocalName,Source) Select 'W460' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = 'W460' and source = 'pims')


-- Therapy Manager

--INSERT INTO @Results(LocalCode,LocalName,Source)
--select distinct

--ID as LocalCode,
----null as LocalName,
--TEXT as LocalName,
--'TherMan' as Source
--from [SQL4\SQL4].[physio].[dbo].DIAGNOSIS







UPDATE @Results SET
	R.MainCode = RTRIM(D.AlternativeCode),
	R.Name = RTRIM(D.Name)
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_Diagnosis_Map DM ON RTRIM(R.LocalCode)=RTRIM(DM.LocalCode) AND R.Source=DM.Source
	INNER JOIN Mapping.dbo.PAS_Diagnosis D ON rtrim(dm.MainCode)=rtrim(D.AlternativeCode)


SELECT * FROM @Results
where MainCode is not null
--order by LocalCode
END
GO
