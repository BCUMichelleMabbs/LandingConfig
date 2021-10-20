SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_BudgetCategory]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode         VARCHAR(10),
	LocalName         VARCHAR(64),
	BudgetCategory    VARCHAR(10),
	BudgetSubCategory VARCHAR(10),
	Source            VARCHAR(20),
	Area              VARCHAR(20),
	MainCode          VARCHAR(10)

	)

INSERT INTO @Results(LocalCode, LocalName , BudgetCategory, BudgetSubCategory, Source, Area, MainCode)
	(
	Select ID, Name, Code, Sub_Code,
	'TherapyManager' AS Source,
	'Central' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].BUDGET_CATEGORIES
	)

INSERT INTO @Results(LocalCode, LocalName , BudgetCategory, BudgetSubCategory, Source, Area, MainCode)
	(
	Select ID, Name, Code, Sub_Code,
	'TherapyManager' AS Source,
	'East' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].BUDGET_CATEGORIES
	)

INSERT INTO @Results(LocalCode, LocalName , BudgetCategory, BudgetSubCategory, Source, Area, MainCode)
	(
	Select ID, Name, Code, Sub_Code,
	'TherapyManager' AS Source,
	'West' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].BUDGET_CATEGORIES
	)



SELECT * FROM @Results order by Source,LocalCode



End

GO
