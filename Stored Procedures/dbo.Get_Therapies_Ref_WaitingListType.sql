SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_WaitingListType]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(

	LocalCode		VARCHAR(20),
	LocalName		VARCHAR(128),
	MainCode        VARCHAR(20),
	Name            VARCHAR(128),
	LocationCode	VARCHAR(10),
	Source			VARCHAR(20),
	Area            VARCHAR(20)
	

)

INSERT INTO @Results(LocalCode,LocalName,MainCode,Name,LocationCode,Source, Area)
	(
	Select 	ID, Text, ID, Text, Site_Id, 'TherapyManager' AS Source, 'Central' as Area
from [SQL4\SQL4].[physio].[dbo].Lists  where type = '3'
	)


INSERT INTO @Results(LocalCode,LocalName,MainCode,Name,LocationCode,Source, Area)
	(
	Select 	ID, Text, ID, Text, Site_Id, 'TherapyManager' AS Source, 'East' as Area
from [SQL4\SQL4].[physio].[dbo].Lists  where type = '3'
	)

INSERT INTO @Results(LocalCode,LocalName,MainCode,Name,LocationCode,Source, Area)
	(
	Select 	ID, Text, ID, Text, Site_Id, 'TherapyManager' AS Source, 'West' as Area
from [SQL4\SQL4].[physio].[dbo].Lists  where type = '3'
	)





SELECT * FROM @Results order by Source,LocalCode



End

GO
