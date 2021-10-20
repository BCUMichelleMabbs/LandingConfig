SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Data_EscalationStatus]

AS
BEGIN
	SET NOCOUNT ON;

SELECT

	[ID],
	[Status],
	[Site],
	CONVERT(VARCHAR, [Date]) as [Date],
	CONVERT(VARCHAR, [Time]) as [Time]

INTO #TEMP1

FROM	[SSIS_Loading].[WAST].[dbo].[SITREP_Status]

;With CTE AS	(

				SELECT

					[ID],
					[Status],
					[Site],
					CONVERT(datetime,[Date]) + CONVERT(datetime, [Time]) as [DateTime],
					[Date],
					[Time]

				FROM	#TEMP1

			)

SELECT

	[Site],
	[Status],
	CAST([Date] AS DATETIME),
	CAST([Time] AS TIME),
	CASE	WHEN [DateTime] = ( SELECT MAX([DateTime]) FROM CTE c2 WHERE c2.[Site] = c.[Site] ) THEN 'Y'
			ELSE 'N'
	END AS [Active]

FROM CTE c

End
GO
