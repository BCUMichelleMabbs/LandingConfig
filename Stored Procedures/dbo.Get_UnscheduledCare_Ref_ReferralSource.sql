SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_ReferralSource]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(80),
	Source				VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
WHERE
	Lkp_TableId=5657
	--Lkp_ParentID=5657

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_TableId=5657


INSERT INTO @Results(LocalCode,LocalName,Source)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_SENTBY
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT 
		RFVAL_REFNO AS LocalCode,
		DESCRIPTION AS LocalName,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
	WHERE
		RFVDM_CODE='SORRF'
	) 



UPDATE @Results SET
	R.MainCode = RS.MainCode,
	R.Name = RS.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_ReferralSource_Map RSM ON R.LocalCode=RSM.LocalCode AND R.Source=RSM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_ReferralSource RS ON RSM.MainCode=RS.MainCode




SELECT * FROM @Results order by Source,Name
END
GO
