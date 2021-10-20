SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_HealthMeasure]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode VARCHAR(50),
	LocalName VARCHAR(64),
	ScaleMin  DECIMAL(10,3),
	ScaleMax  DECIMAL(10,3),
	NormalMin DECIMAL(10,3),
	NormalMax DECIMAL(10,3),
	Source    VARCHAR(50),
	Area      VARCHAR(50),
	MainCode  VARCHAR(50)
	)
	


INSERT INTO @Results(LocalCode, LocalName, ScaleMin, ScaleMax, NormalMin, NormalMax, Source,Area,MainCode)
	(
	Select distinct ID, Name, Scale_Min, Scale_Max, Normal_Min, Normal_Max,
	'TherapyManager' AS Source,
	'Central' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].OUTCOME_DEFINITION
	)

INSERT INTO @Results(LocalCode, LocalName, ScaleMin, ScaleMax, NormalMin, NormalMax, Source,Area,MainCode)
	(
	Select distinct ID, Name, Scale_Min, Scale_Max, Normal_Min, Normal_Max,
	'TherapyManager' AS Source,
	'East' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].OUTCOME_DEFINITION
	)

INSERT INTO @Results(LocalCode, LocalName, ScaleMin, ScaleMax, NormalMin, NormalMax, Source,Area, MainCode)
	(
	Select distinct ID, Name, Scale_Min, Scale_Max, Normal_Min, Normal_Max,
	'TherapyManager' AS Source,
	'West' as Area,
	ID
from [SQL4\SQL4].[physio].[dbo].OUTCOME_DEFINITION
	)


SELECT * FROM @Results ORDER BY Area,LocalCode


End
GO
