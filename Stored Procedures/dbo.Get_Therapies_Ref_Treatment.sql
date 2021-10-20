SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_Treatment]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode VARCHAR(50),
	LocalName VARCHAR(128),
	SiteCode  VARCHAR(50),
	Source    VARCHAR(50),
	Area      VARCHAR(50),
	MainCode  VARCHAR(50)
	)

INSERT INTO @Results(LocalCode, LocalName, SiteCode, Source,Area, MainCode)
	(
	Select distinct ID, Text, Site_id, 
	'TherapyManager' AS Source,
	'Central' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].LISTS where Type in (1)
	)

INSERT INTO @Results(LocalCode, LocalName, SiteCode, Source,Area, MainCode)
	(
	Select distinct ID, Text, Site_id, 
	'TherapyManager' AS Source,
	'East' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].LISTS where Type in (1)
	)

INSERT INTO @Results(LocalCode, LocalName, SiteCode, Source,Area, MainCode)
	(
	Select distinct ID, Text, Site_id, 
	'TherapyManager' AS Source,
	'West' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].LISTS where Type in (1)
	)

SELECT * FROM @Results ORDER BY Area,LocalCode


End
GO
