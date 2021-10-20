SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_RTAPatientType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode	VARCHAR(2),
	Name		VARCHAR(100),
	LocalCode	VARCHAR(10),
	LocalName	VARCHAR(80),
	Source		VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'Symphony' AS Source
FROM 
	[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Reports].dbo.Lookups
WHERE
	Lkp_ParentID=5656


INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT
	Lkp_ID AS LocalCode,
	Lkp_Name AS LocalName,
	'WEDS' AS Source
FROM 
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups
WHERE
	Lkp_ParentID=5656


INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('98','Not applicable','WPAS'),
('99','Not known','WPAS')


UPDATE @Results SET
	R.MainCode = RPT.MainCode,
	R.Name = RPT.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_RTAPatientType_Map RPTM ON R.LocalCode=RPTM.LocalCode AND R.Source=RPTM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_RTAPatientType RPT ON RPTM.MainCode=RPT.MainCode

SELECT * FROM @Results

END
GO
