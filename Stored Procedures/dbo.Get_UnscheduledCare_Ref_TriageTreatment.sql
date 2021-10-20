SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_TriageTreatment]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
		Lkp_ID AS MainCode,
		Lkp_Name AS Name,
		Lkp_ID AS LocalCode,
		Lkp_Name AS LocalName,
		'Symphony' AS Source
	FROM 
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Live].dbo.Lookups
	WHERE
		Lkp_ParentID=5667
UNION ALL
	SELECT
		Lkp_ID AS MainCode,
		Lkp_Name AS Name,
		Lkp_ID AS LocalCode,
		Lkp_Name AS LocalName,
		'WEDS' AS Source
	FROM 
		[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
	WHERE
		Lkp_ParentID=5667

END
GO
