SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: October 2021
-- Description:	
-- =============================================




--NOTES
--Stream Data is in addition to inpatient data






CREATE PROCEDURE [dbo].[Get_PAS_Ref_DischargeDetailSub]
	
AS
BEGIN

SET NOCOUNT ON;

--NOTES
--Stream Data is in addition to inpatient data

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(5),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(5),
	LocalName			VARCHAR(100),
	Source				VARCHAR(10),
	area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, area)
Select 
		id AS LocalCode,
		Description AS LocalName,
		'Stream' AS Source,
		'BCU' AS Area

from [7A1AUSRVSQL0003].[WardBoards].[dbo].[ActivitySubCategories]




UPDATE @Results SET
	R.MainCode = PC.MainCode,
	R.Name = PC.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_DischargeDetailSub_Map PCM ON R.LocalCode=PCM.LocalCode AND R.Source=PCM.Source and r.area = pcm.area
	INNER JOIN Mapping.dbo.PAS_DischargeDetailSub PC ON PCM.MainCode=PC.MainCode


SELECT * FROM @Results 
--where MainCode is not null
order by Source,Name
END
GO
