SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_AccompaniedBy]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(80),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(80),
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
	Lkp_ParentID=5647


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].[EMIS_SYM_BCU_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5647



INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
		FROM 
		AANDE_ACCOMPANIEDBY
')


UPDATE @Results SET 
	MainCode=
		CASE 
			WHEN LocalName = 'Brother' THEN '6590'
			WHEN LocalName = 'Daughter' THEN '6591'
			WHEN LocalName = 'Father' THEN '6592'
			WHEN LocalName = 'Friend' THEN '6593'
			WHEN LocalName = 'Husband' THEN '6594'
			WHEN LocalName = 'Mother' THEN '6595'
			WHEN LocalName IN ('None','Unaccompanied') THEN '6596'
			WHEN LocalName IN ('Partner','Boyfriend','Fiance','Fiancee','Girlfriend') THEN '6597'
			WHEN LocalName = 'Sister' THEN '6598'
			WHEN LocalName = 'Son' THEN '6599'
			WHEN LocalName = 'Neighbour' THEN '6961'
			WHEN LocalName = 'Wife' THEN '6600'
			WHEN LocalName = 'Carer' THEN '6601'
			WHEN LocalName = 'Other' THEN '6602'
			WHEN LocalName IN ('Grandparent','Grand Mother','Grand Father') THEN '6960'
			WHEN LocalName = 'Teacher' THEN '6962'
			WHEN NULLIF(RTRIM(LocalName),'') IS NOT NULL THEN '6602'
		END,
	Name = 
		CASE 
			WHEN LocalName = 'Brother' THEN 'Brother'
			WHEN LocalName = 'Daughter' THEN 'Daughter'
			WHEN LocalName = 'Father' THEN 'Father'
			WHEN LocalName = 'Friend' THEN 'Friend'
			WHEN LocalName = 'Husband' THEN 'Husband'
			WHEN LocalName = 'Mother' THEN 'Mother'
			WHEN LocalName IN ('None','Unaccompanied') THEN 'None'
			WHEN LocalName IN ('Partner','Boyfriend','Fiance','Fiancee','Girlfriend') THEN 'Partner'
			WHEN LocalName = 'Sister' THEN 'Sister'
			WHEN LocalName = 'Son' THEN 'Son'
			WHEN LocalName = 'Neighbour' THEN 'Neighbour'
			WHEN LocalName = 'Wife' THEN 'Wife'
			WHEN LocalName = 'Carer' THEN 'Carer'
			WHEN LocalName = 'Other' THEN 'Other'
			WHEN LocalName IN ('Grandparent','Grand Mother','Grand Father') THEN 'Grandparent'
			WHEN LocalName = 'Teacher' THEN 'Teacher'
			WHEN NULLIF(RTRIM(LocalName),'') IS NOT NULL THEN 'Other'
		END


SELECT * FROM @Results ORDER BY Source, Name
END
GO
