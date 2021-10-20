SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_HarmType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(20),
	Name				VARCHAR(20),
	Source				VARCHAR(8)
)

INSERT INTO @Results(MainCode,Name,Source)
	(
SELECT
	'Medication Errors' as [Code],
	'Medication Error' as [Name],
	'Datix' as [Source]

UNION

SELECT
	'HAPU' as [Code],
	'HAPU' as [Name],
	'Datix' as [Source]

UNION

SELECT
	'Falls' as [Code],
	'Fall' as [Name],
	'Datix' as [Source]

UNION

SELECT
	'Other' as [Code],
	'Other' as [Name],
	'Datix' as [Source]

	)

SELECT * FROM @Results order by Source,Name


End
GO
