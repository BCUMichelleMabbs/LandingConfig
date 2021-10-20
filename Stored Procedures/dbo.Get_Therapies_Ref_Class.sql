SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_Class]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(128),
	MainCode		VARCHAR(10),
	Name			VARCHAR(128),
	ResourceCode	VARCHAR(10), 
	SiteCode		VARCHAR(10),
	SymbolCode		VARCHAR(10),
	Source			VARCHAR(20),
	Area			VARCHAR(20)
	)

INSERT INTO @Results(LocalCode, LocalName, MainCode, Name, ResourceCode, SiteCode, SymbolCode, Source, Area)
	(
	Select ID, Name, ID, Name, Resource_id, Site_id, symbol_id, 'TherapyManager' AS Source, 'Central' as Area
    from [SQL4\SQL4].[physio].[dbo].CLASS  
	)

INSERT INTO @Results(LocalCode, LocalName, MainCode, Name, ResourceCode, SiteCode, SymbolCode, Source, Area)
	(
	Select ID, Name, ID, Name, Resource_id, Site_id, symbol_id, 'TherapyManager' AS Source, 'East' as Area
    from [SQL4\SQL4].[physio].[dbo].CLASS  
	)

INSERT INTO @Results(LocalCode, LocalName, MainCode, Name, ResourceCode, SiteCode, SymbolCode, Source, Area)
	(
	Select ID, Name, ID, Name, Resource_id, Site_id, symbol_id, 'TherapyManager' AS Source, 'West' as Area
    from [SQL4\SQL4].[physio].[dbo].CLASS  
	)


SELECT * FROM @Results order by MainCode


End

GO
