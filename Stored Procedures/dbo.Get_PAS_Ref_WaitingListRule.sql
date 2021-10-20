SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_WaitingListRule]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(10),
	Name			VARCHAR(70),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(70),
	Source			VARCHAR(8),
	Area			varchar(10)
)


/*
INSERT INTO @Results(LocalCode,MainCode, LocalName,Source, Area)	
SELECT 
	wlrul_refno AS LocalCode,
	Code as MainCode,
	Name as LocalName,
	'Pims' AS Source,
	'West' as Area
FROM 
	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].[Waiting_List_Rules]

	
-- to do Mappings 

UPDATE @Results SET
	R.MainCode = rtrim(C.MainCode),
	R.Name = rtrim(C.Name)
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_WaitingListRule_Map CCM ON R.LocalCode=CCM.LocalCode AND R.Source=CCM.Source and r.Area = ccm.Area
	INNER JOIN Mapping.dbo.PAS_WaitingListRule C ON CCM.MainCode=C.MainCode
	

*/


SELECT * FROM @Results
--where MainCode is not null

order by maincode
END

GO
