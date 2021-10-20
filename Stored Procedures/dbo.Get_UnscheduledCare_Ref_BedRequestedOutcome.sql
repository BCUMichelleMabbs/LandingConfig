SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_BedRequestedOutcome]
	
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

INSERT INTO @Results
SELECT
	Lkp_ID AS MainCode,
	Lkp_Name AS Name,
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_ParentID=5701

INSERT INTO @Results
SELECT
	Lkp_ID AS MainCode,
	Lkp_Name AS Name,
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5701

SELECT * FROM @Results

END
GO
