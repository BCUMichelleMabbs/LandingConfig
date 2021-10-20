SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Data_Event]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @FromDate AS DATETIME

SET @FromDate = '1 January 2018 08:00:00'
--SET @FromDate = CONVERT(VARCHAR(10),GETDATE() -1 ,120) + ' ' + '08:00:00'

SELECT 
	CE.EventRef,
	CE.CaseRef,
	CE.EventType,
	CAST(CE.EntryDate AS DATE) AS EntryDate,
	CAST(CE.EntryDate AS TIME(0)) AS EntryTime,
	CAST(CE.StartDate AS DATE) AS StartDate,
	CAST(CE.StartDate AS TIME(0)) AS StartTime,
	CAST(CE.FinishDate AS DATE) AS FinishDate,
	CAST(CE.FinishDate AS TIME(0)) AS FinishTime,
	CE.UserRef,
	CE.EventDescription,
	CAST(CE.CreationDate AS DATE) AS CreationDate,
	CAST(CE.CreationDate AS TIME(0)) AS CreationTime,
	CE.LocationRef,
	CE.CaseAuditRef,
	CASE
		WHEN EC.EventCancelRef IS NOT NULL THEN 'Y'
		ELSE 'N'
	END AS EventCancelled
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].[Case] C
	INNER JOIN [SQL4\SQL4].[Adastra3].[dbo].CaseEvents CE ON C.CaseRef = CE.CaseRef
	LEFT JOIN [SQL4\SQL4].[Adastra3].[dbo].EventCancel EC ON CE.CaseRef = EC.CaseRef AND CE.Ref = EC.EventCancelRef
WHERE
	C.ActiveDate+Landing_Config.dbo.GPOH_BSTOffset(C.ActiveDate) >= @FromDate
	
END
GO
