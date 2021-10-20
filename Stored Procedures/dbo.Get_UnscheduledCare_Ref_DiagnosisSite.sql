SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_DiagnosisSite]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(3),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(255),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source 
FROM
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	lkp_TableID=5670  --Leave it for now, if we find we're getting missing dimension values then look at putting this back in
	--Lkp_ParentID IN (SELECT Lkp_ID from [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups WHERE Lkp_ParentID =5670) 

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source 
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	lkp_TableID=5670 

INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
		SELECT DISTINCT
			CODEDESC AS LocalCode,
			DESCRIPT AS LocalName,
			''WPAS'' AS Source
		FROM 
			AANDE_CODEDESC
		WHERE
			CODETYPE = ''ST''
		')
	) 
	
INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT 
		ODPCD_REFNO AS LocalCode,
		DESCRIPTION AS LocalName,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[ODPCD_CODES]
	WHERE
		CCSXT_CODE='AESIT'
	) 


UPDATE @Results SET
	R.MainCode = DS.MainCode,
	R.Name = DS.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_DiagnosisSite_Map DSM ON R.LocalCode=DSM.LocalCode AND R.Source=DSM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_DiagnosisSite DS ON DSM.MainCode=DS.MainCode

SELECT * FROM @Results
order by MainCode
END
GO
