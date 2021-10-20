SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_ResourceGroup]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode    VARCHAR(20),
	LocalName    VARCHAR(20),
	MainCode     VARCHAR(20),
	Name         VARCHAR(20),
	SiteCode     VARCHAR(20),
	Source       VARCHAR(20),
	Area         VARCHAR(20)

)

INSERT INTO @Results(LocalCode,LocalName,MainCode, Name, SiteCode,Source, Area)
	(
	Select ID,  
	Name,  
    ID,
	Name,
	Site_Id, 
	'TherapyManager' AS Source, 
	'Central' as Area

from [SQL4\SQL4].[physio].[dbo].Resource_Group
	)


	INSERT INTO @Results(LocalCode,LocalName,MainCode, Name, SiteCode,Source, Area)
	(
	Select ID,  
	Name,  
    ID,
	Name,
	Site_Id, 
	'TherapyManager' AS Source, 
	'East' as Area

from [SQL4\SQL4].[physio].[dbo].Resource_Group
	)


	INSERT INTO @Results(LocalCode,LocalName,MainCode, Name, SiteCode,Source, Area)
	(
	Select ID,  
	Name,  
    ID,
	Name,
	Site_Id, 
	'TherapyManager' AS Source, 
	'West' as Area

from [SQL4\SQL4].[physio].[dbo].Resource_Group
	)

	

SELECT * FROM @Results order by Source,LocalCode

End

GO
