SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Data_TasAssessment]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @FromDate AS DATETIME

SET @FromDate = '1 January 2018 08:00:00'
--SET @FromDate = CONVERT(VARCHAR(10),GETDATE() -1 ,120) + ' ' + '08:00:00'

SELECT
	TA.TasAssessmentRef,
	TA.CaseRef,
	CAST(TA.StartDate AS DATE) AS StartDate,
	CAST(TA.StartDate AS TIME(0)) AS StartTime,
	CAST(TA.FinishDate AS DATE) AS FinishDate,
	CAST(TA.FinishDate AS TIME(0)) AS FinishTime,
	TA.AssessmentScoreLevel,
	TA.TriageFinalUrgency,
	TA.TriageChangeReason,
	TA.ProblemNo,
	TA.EncounterNo,
	TA.ProviderRef,
	TA.AssessmentScoreDescription
FROM
	[SQL4\SQL4].Adastra3.dbo.[Case] C
	INNER JOIN [SQL4\SQL4].Adastra3.dbo.TasAssessment TA ON C.CaseRef=TA.CaseRef AND TA.Obsolete=0
WHERE
	C.ActiveDate+Landing_Config.dbo.GPOH_BSTOffset(C.ActiveDate) >= @FromDate
END
GO
