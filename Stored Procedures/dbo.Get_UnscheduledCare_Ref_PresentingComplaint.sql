SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_PresentingComplaint]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(5),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(5),
	LocalName		VARCHAR(100),
	Source			VARCHAR(8),
	Area			VARCHAR(7)
	
)

INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source,Area)
SELECT
	Lkp_ID,Lkp_Name,Lkp_ID,Lkp_Name,'WEDS','West' 
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE 
	Lkp_ParentID=8772

INSERT INTO @Results(MainCode,Name,LocalCode,LocalName,Source,Area)
SELECT
	Lkp_ID,Lkp_Name,Lkp_ID,Lkp_Name,'WEDS','East' 
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE 
	Lkp_ParentID=8772

		

SELECT * FROM @Results

END
GO
