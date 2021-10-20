SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Common_Ref_Procedure]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(4),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(300), 
	Source			VARCHAR(10),
	Area			varchar(10),
	Chapter		varchar(300),
	SubChapter	varchar(300),
	versionIntroduced	varchar(5)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		cast(CODEDESC as varchar(10) character set WIN1251) AS LocalCode,
		cast(SHORTDESC as varchar(300) character set WIN1251) AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		CODEDESC
	WHERE CODETYPE = ''OP''
	--and CODEDESC is not null 
	and CODEDESC <>''''
	--and SHORTDESC <> ''INTRAVENOUS TRANSFUSION OF OTHER SPECIFIED''
	and CODEDESC <> ''X348''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		ltrim(rtrim(CODEDESC)) AS LocalCode,
		cast(SHORTDESC as varchar(300) character set WIN1251) AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		CODEDESC
	WHERE CODETYPE = ''OP''
	--and CODEDESC is not null 
	and CODEDESC <>''''
	--and SHORTDESC <> ''INTRAVENOUS TRANSFUSION OF OTHER SPECIFIED''
	and CODEDESC = ''X348''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
select distinct

code as [LOCALCODE]
,DESCRIPTION as [LOCALNAME]
,'PIMS' as Source,
 'West' as Area

from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].ODPCD_CODES 
where CCSXT_CODE = 'OPCS4'



INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Code AS LocalCode,
	Description AS LocalName,
	'Radis' AS Source,
	'Central' AS Area
FROM 
	[RADIS_CENTRAL].[Radis].dbo.ProcedureCode


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Code AS LocalCode,
	Description AS LocalName,
	'Radis' AS Source,
	'East' AS Area
FROM
	[RADIS_EAST].[Radis].dbo.ProcedureCode


INSERT INTO @Results(LocalCode,LocalName,Source,Area)
SELECT
	Code AS LocalCode,
	Description AS LocalName,
	'Radis' AS Source,
	'West' AS Area
FROM
	[RADIS_WEST].[Radis].dbo.ProcedureCode


UPDATE @Results SET
	R.MainCode = P.MainCode,
	R.Name = P.Name,
	R.Chapter = p.Chapter,
	R.SubChapter = p.SubChapter
FROM
	@Results R
	INNER JOIN Mapping.dbo.Common_Procedure_Map PM ON R.LocalCode=PM.LocalCode AND R.Source=PM.Source
	INNER JOIN Mapping.dbo.Common_Procedure P ON PM.MainCode=P.MainCode
	
SELECT * FROM @Results
--where MainCode is null

--where localcode = 'X348'
order by MainCode
END

GO
