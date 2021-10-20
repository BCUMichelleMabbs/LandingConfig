SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_Immunisation]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(80),
	Source			VARCHAR(8)
)

INSERT INTO @Results(MainCode,Name,Source)
SELECT
	Lkp_ID AS MainCode,
	Lkp_Name AS Name,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5653

INSERT INTO @Results(MainCode,Name,Source)
SELECT
	Lkp_ID AS MainCode,
	Lkp_Name AS Name,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5653

INSERT INTO @Results(MainCode,Name,Source)
	SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
		SELECT DISTINCT
			CODE AS MainCode,
			DESCRIPTION AS Name,
			''WPAS'' AS Source
		 FROM 
			AANDE_IMMUNISATION
		')
	

SELECT * FROM @Results
END
GO
