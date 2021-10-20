SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_Clock]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode VARCHAR(10),
	LocalName VARCHAR(128),
	MainCode  VARCHAR(10),
	Name      VARCHAR(128),
	Source    VARCHAR(20),
	Area      VARCHAR(20)
	)

INSERT INTO @Results(LocalCode, LocalName, MainCode, Name, Source, Area)
	(
	Select ID, Text, ID, Text, 'TherapyManager' AS Source, 'Central' as Area
    from [SQL4\SQL4].[physio].[dbo].Lists  where type = '17'
	)

INSERT INTO @Results(LocalCode, LocalName, MainCode, Name, Source, Area)
	(
	Select ID, Text, ID, Text, 'TherapyManager' AS Source, 'East' as Area
    from [SQL4\SQL4].[physio].[dbo].Lists  where type = '17'
	)

INSERT INTO @Results(LocalCode, LocalName, MainCode, Name, Source, Area)
	(
	Select ID, Text, ID, Text, 'TherapyManager' AS Source, 'West' as Area
	from [SQL4\SQL4].[physio].[dbo].Lists  where type = '17'
	)


SELECT * FROM @Results order by Source,LocalCode


End

GO
