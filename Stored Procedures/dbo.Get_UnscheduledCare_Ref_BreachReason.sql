SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_BreachReason]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(10),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(100),
	Source				VARCHAR(8)
)

--INSERT INTO @Results(LocalCode,LocalName,Source)
--SELECT
--	Lkp_ID AS LocalCode,
--	Lkp_Name AS LocalName,
--	'Symphony' AS Source
--FROM 
--	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
--WHERE
--	Lkp_ParentID=5650

INSERT INTO @Results(LocalCode,LocalName,Source)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_BREACH
	')
)

--INSERT INTO @Results(LocalCode,LocalName,Source)
--	(
--	SELECT 
--		RFVAL_REFNO AS LocalCode,
--		DESCRIPTION AS LocalName,
--		'Pims' AS Source
--	FROM 
--		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES
--	WHERE
--		RFVDM_CODE='ARMOD'
	--) 


UPDATE @Results SET
	R.MainCode = B.MainCode,
	R.Name = B.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_BreachReason_Map BM ON R.LocalCode=BM.LocalCode AND R.Source=BM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_BreachReason B ON BM.MainCode=B.MainCode





SELECT * FROM @Results order by Source,Name
END
GO
