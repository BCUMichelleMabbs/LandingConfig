SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_CumulativeMinute]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @MaxCumulativeMinute AS INT=1576800 --Increase this if we need more minutes adding to the table
DECLARE @ThisCumulativeMinute AS INT=0

;WITH CM AS (
	SELECT
		@ThisCumulativeMinute AS CumulativeMinute
		UNION ALL
		SELECT CumulativeMinute+1 FROM CM WHERE CumulativeMinute+1<=@MaxCumulativeMinute
)
SELECT 
	CumulativeMinute,
	(CumulativeMinute/60) AS [Hour], 
	CumulativeMinute-((CumulativeMinute/60)*60) AS [Minute],
	CASE
		WHEN CumulativeMinute BETWEEN 0 AND 239 THEN '1. Up to 4Hrs'
		WHEN CumulativeMinute BETWEEN 240 AND 479 THEN '2. 4Hrs and up to 8Hrs'
		WHEN CumulativeMinute BETWEEN 480 AND 719 THEN '3. 8Hrs and up to 12Hrs'
		WHEN CumulativeMinute BETWEEN 720 AND 1439 THEN '4. 12Hrs and up to 24Hrs'
		WHEN CumulativeMinute >1439 THEN '5. Over 24Hrs'
		WHEN CumulativeMinute<0 THEN '6. Negative'
	END AS EDWaitingBand,
	CASE
		WHEN CumulativeMinute BETWEEN 0 AND 239 THEN 1
		WHEN CumulativeMinute BETWEEN 240 AND 479 THEN 2
		WHEN CumulativeMinute BETWEEN 480 AND 719 THEN 3
		WHEN CumulativeMinute BETWEEN 720 AND 1439 THEN 4
		WHEN CumulativeMinute >1439 THEN 5
		WHEN CumulativeMinute<0 THEN 6
	END AS EDWaitingBandOrder


FROM 
	CM OPTION(MAXRECURSION 0)




END
GO
