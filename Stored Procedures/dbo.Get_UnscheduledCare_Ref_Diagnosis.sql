SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_Diagnosis]
	
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

INSERT INTO @Results(MainCode,LocalCode,LocalName,Source)
SELECT
	(
		select top 1 LEFT(not_text,3) from [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.notes where not_noteid in 
		(
			select top 1 flm_value from [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.lookupmappings 
			where flm_lkpid = L.lkp_Id and flm_mtid = (select top 1 mt_id from [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.mappingtypes where mt_name = 'CDS')
		)
	) AS MainCode,
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups L
WHERE
	lkp_TableID=5673
	--Lkp_ParentID=5673

INSERT INTO @Results(MainCode,LocalCode,LocalName,Source)
SELECT
	case when
	len(
	(
		select top 1 not_text from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.notes where not_noteid in 
		(
			select top 1 flm_value from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookupmappings 
			where flm_lkpid = L.lkp_Id and flm_mtid = (select top 1 mt_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.mappingtypes where mt_name = 'CDS')
		)
	)) = 3 then
		(
		select top 1 not_text from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.notes where not_noteid in 
		(
			select top 1 flm_value from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookupmappings 
			where flm_lkpid = L.lkp_Id and flm_mtid = (select top 1 mt_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.mappingtypes where mt_name = 'CDS')
		)
	)

	else null end AS MainCode,
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups L
WHERE
	lkp_TableID IN(5673,7662)


--INSERT INTO @Results(LocalCode,LocalName,Source)
--SELECT
--	Lkp_ID AS LocalCode,
--	Lkp_Name AS LocalName,
--	'Symphony' AS Source
--FROM 
--	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
--WHERE
--	Lkp_ParentID IN (SELECT Lkp_ID FROM [RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups WHERE Lkp_ParentID =5673)


INSERT INTO @Results(MainCode,LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		NULLIF(NAT_CODE,'''') AS MainCode,
		CODEDESC AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_CODEDESC
	WHERE
		CODETYPE = ''ED''
')

INSERT INTO @Results(MainCode,LocalCode,LocalName,Source)	
SELECT 
	LEFT(CODE,3) AS MainCode,
	ODPCD_REFNO AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[ODPCD_CODES]
WHERE
	CCSXT_CODE='AEDIG'

UPDATE @Results SET
	R.MainCode = D.MainCode,
	R.Name = D.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_Diagnosis_Map DM ON R.LocalCode=DM.LocalCode AND R.Source=DM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_Diagnosis D ON DM.MainCode=D.MainCode
WHERE
	R.MainCode IS NULL

UPDATE @Results SET 
	Name = D.Name
FROM
	@Results r
	INNER JOIN Mapping.dbo.UnscheduledCare_Diagnosis D ON r.MainCode=D.MainCode

SELECT * FROM @Results
order by MainCode
END
GO
