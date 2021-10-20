SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_MTED_Ref_Status]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @Results AS TABLE
	(
		[MainCode] VARCHAR(20),
		[Source] VARCHAR(4)
	)

	INSERT INTO @Results([MainCode], [Source])
	(
		SELECT 'Med Lock 1st' AS [MainCode], 'MTED' AS [Source]
		UNION
		SELECT 'DAL Signed 1st', 'MTED'
		UNION
		SELECT'No Sign/Lock', 'MTED'
	)


	SELECT *
	FROM @Results

	ORDER BY [Source]
END
GO
