SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_ProcedureDELETE]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(4),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(300), 
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		cast(CODEDESC as varchar(10) character set WIN1251) AS LocalCode,
		cast(SHORTDESC as varchar(300) character set WIN1251) AS LocalName,
		''WPAS'' AS Source
	 FROM 
		CODEDESC
	WHERE CODETYPE = ''OP''
	and CODEDESC is not null 
	and CODEDESC <>''''
	and SHORTDESC <> ''INTRAVENOUS TRANSFUSION OF OTHER SPECIFIED''
	')


INSERT INTO @Results(LocalCode,LocalName,Source)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		ltrim(rtrim(CODEDESC)) AS LocalCode,
		cast(SHORTDESC as varchar(300) character set WIN1251) AS LocalName,
		''Myrddin'' AS Source
	 FROM 
		CODEDESC
	WHERE CODETYPE = ''OP''
	and CODEDESC is not null 
	and CODEDESC <>''''
	and SHORTDESC <> ''INTRAVENOUS TRANSFUSION OF OTHER SPECIFIED''
	')


INSERT INTO @Results(LocalCode,LocalName,Source)	
select distinct

code as [LOCALCODE]
,DESCRIPTION as [LOCALNAME]
,'PIMS' as Source

from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].ODPCD_CODES 
where CCSXT_CODE = 'OPCS4'


UPDATE @Results SET
	R.MainCode = P.MainCode,
	R.Name = P.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_Procedure_Map PM ON R.LocalCode=PM.LocalCode AND R.Source=PM.Source
	INNER JOIN Mapping.dbo.PAS_Procedure P ON PM.MainCode=P.MainCode
	
SELECT * FROM @Results
--where MainCode is not null
order by LocalCode
END
GO
