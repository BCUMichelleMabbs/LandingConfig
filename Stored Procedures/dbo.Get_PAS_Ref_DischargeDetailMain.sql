SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: October 2021
-- Description:	
-- =============================================


CREATE PROCEDURE [dbo].[Get_PAS_Ref_DischargeDetailMain]
	
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
	area				varchar(10)
)






INSERT INTO @Results(LocalCode,LocalName,Source, area)
Select 
		id AS LocalCode,
		ActivityCategoryDescription AS LocalName,
		'Stream' AS Source,
		'BCU' AS Area

from [7A1AUSRVSQL0003].[WardBoards].[dbo].[ActivityCategories]




UPDATE @Results SET
	R.MainCode = PC.MainCode,
	R.Name = PC.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_DischargeDetailMain_Map PCM ON R.LocalCode=PCM.LocalCode AND R.Source=PCM.Source and r.area = pcm.area
	INNER JOIN Mapping.dbo.PAS_DischargeDetailMain PC ON PCM.MainCode=PC.MainCode


SELECT * FROM @Results 
--where MainCode is not null
order by Source,Name
END
GO
