SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_Symbol]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode			VARCHAR(20),
	LocalName			VARCHAR(64),
	MainCode            VARCHAR(20),
	Name                VARCHAR(64),
	TypeSymbol			VARCHAR(1),
	ResourceTypeSymbol	VARCHAR(20),
	DurationSymbol		VARCHAR(1),
	LocationCodeSymbol	VARCHAR(10),
	GroupSymbol         VARCHAR(1),
	Source				VARCHAR(20),
	Area                VARCHAR(20),
	ProcessInfo         VARCHAR(1)
	
)


INSERT INTO @Results(LocalCode,LocalName,MainCode, Name, TypeSymbol,ResourceTypeSymbol,DurationSymbol,
                     LocationCodeSymbol,GroupSymbol, Source , Area, ProcessInfo )
	(
	Select Id,label, Id, Label, type, res_TYPE, Duration,Site_Id, Symb_Group, 
	'TherapyManager' AS Source, 'Central' as Area, Process_Info
from [SQL4\SQL4].[physio].[dbo].Symbols 
	)


INSERT INTO @Results(LocalCode,LocalName,MainCode, Name, TypeSymbol,ResourceTypeSymbol,DurationSymbol,
                     LocationCodeSymbol,GroupSymbol, Source , Area, ProcessInfo )
	(
	Select Id,label, Id, Label, type, res_TYPE, Duration,Site_Id, Symb_Group, 
	'TherapyManager' AS Source, 'East' as Area, Process_Info
from [SQL4\SQL4].[physio].[dbo].Symbols 
	)


INSERT INTO @Results(LocalCode,LocalName,MainCode, Name, TypeSymbol,ResourceTypeSymbol,DurationSymbol,
                     LocationCodeSymbol,GroupSymbol, Source , Area, ProcessInfo )
	(
	Select Id,label, Id, Label, type, res_TYPE, Duration,Site_Id, Symb_Group, 
	'TherapyManager' AS Source, 'West' as Area, Process_Info
from [SQL4\SQL4].[physio].[dbo].Symbols 
	)







SELECT * FROM @Results order by Source, LocalCode



End

GO
