SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_MTED_Ref_TimeBand]
	
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
		SELECT '    Over 7 days' AS [MainCode], 'MTED' AS [Source]
		UNION
		SELECT '   Within 7 days', 'MTED'
		UNION
		SELECT '  Within 48h', 'MTED'
		UNION
		SELECT ' Pre Discharge', 'MTED'
	)


	SELECT *
	FROM @Results

	ORDER BY [MainCode] DESC
END
GO
