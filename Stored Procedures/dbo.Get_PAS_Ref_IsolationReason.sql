SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: October 2021
-- Description:	
-- =============================================


CREATE PROCEDURE [dbo].[Get_PAS_Ref_IsolationReason]
	
AS
BEGIN

SET NOCOUNT ON;


--NOTES
--Stream Data is in addition to inpatient data

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(2),
	LocalName			VARCHAR(100),
	Source				VARCHAR(10),
	area				VARCHAR(10)
)






INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT 
		id AS LocalCode,
		Description AS LocalName,
		'WPAS' AS Source, --this is actually from the stream database but to match to inpatient hourly this uas to be pas
		'Central' AS Area

FROM [7A1AUSRVSQL0003].[WardBoards].[dbo].[IsolationReasons]

INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT 
		id AS LocalCode,
		Description AS LocalName,
		'Myrddin' AS Source, --this is actually from the stream database but to match to inpatient hourly this uas to be pas
		'East' AS Area

FROM [7A1AUSRVSQL0003].[WardBoards].[dbo].[IsolationReasons]


INSERT INTO @Results(LocalCode,LocalName,Source, area)
SELECT 
		id AS LocalCode,
		Description AS LocalName,
		'Pims' AS Source, --this is actually from the stream database but to match to inpatient hourly this uas to be pas
		'West' AS Area

FROM [7A1AUSRVSQL0003].[WardBoards].[dbo].[IsolationReasons]


UPDATE @Results SET
	R.MainCode = PC.MainCode,
	R.Name = PC.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_IsolationReason_Map PCM ON R.LocalCode=PCM.LocalCode AND R.Source=PCM.Source AND r.area = pcm.area
	INNER JOIN Mapping.dbo.PAS_IsolationReason PC ON PCM.MainCode=PC.MainCode


SELECT * FROM @Results 
--where MainCode is not null
ORDER BY Source,Name
END
GO
