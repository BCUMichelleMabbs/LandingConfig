SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_ImagingSite]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(10),
	Name		VARCHAR(132),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(132),	
	Source		VARCHAR(8)
)

INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS MainCode,
	Lkp_Name AS Name,
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source 
FROM
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_TableID = 5710 


INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS MainCode,
	Lkp_Name AS Name,
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source 
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_TableID = 5710 


INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source)
	SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
		SELECT DISTINCT
			CODEDESC AS MainCode,
			DESCRIPT AS Name,
			CODEDESC AS LocalCode,
			DESCRIPT AS LocalName,
			''WPAS'' AS Source
		FROM 
			AANDE_CODEDESC
		WHERE
			CODETYPE = ''RL''
		')

SELECT * FROM @Results
END
GO
