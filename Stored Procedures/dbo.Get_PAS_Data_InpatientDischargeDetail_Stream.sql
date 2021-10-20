SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: October 2021
-- Description:	
-- =============================================




--NOTES
--Stream Data is in addition to inpatient data






CREATE PROCEDURE [dbo].[Get_PAS_Data_InpatientDischargeDetail_Stream]
	
AS
BEGIN

SET NOCOUNT ON;

--declare @DateEpisodeEnded as Date = '01 November 2020'

DECLARE @DateRequested AS DATE = (SELECT ISNULL(MAX(DateRequestedActivity),'1 January 2010') FROM [Foundation].[dbo].[PAS_Data_InpatientDischargeDetail]) 
DECLARE @DateRequestedString AS VARCHAR(30) = DATENAME(DAY,@DateRequested) + ' ' + DATENAME(MONTH,@DateRequested) + ' ' + DATENAME(YEAR,@DateRequested)
--print @DateRequested
--print @DateRequestedString


Select 
		Area as Area,
		Patientid as LocalPatientIdentifier,
		AdmissionID as SystemLinkID,
		ActivityID AS ActivityMain,
		SubActivityID AS ActivitySub,
		CAST(DateTimePlaced AS date) AS DatePlacedOnSystem,
		CAST(DateTimePlaced AS TIME) AS TimePlacedOnSystem,
		CAST(DateTimeRequested AS DATE) AS DateRequestedActivity,
		CAST(DateTimeRequested AS TIME) AS TimeRequestedActivity,
		cast(DateTimeCompleted AS Date) AS DateCompletedActivity,
		CAST(DateTimeCompleted AS TIME) AS TimeCompletedActivity
		

from [7A1AUSRVSQL0003].[WardBoards].[dbo].[PatientActivity]
WHERE CAST(DateTimeRequested AS DATE) > ''+@DateRequestedString+''

--WHERE CONVERT(VARCHAR, DateTimeRequested, 106) > '@DateRequestedstring'
--WHERE CAST(DateTimeRequested AS DATE) > '12 october 2021'
--WHERE PatientId = 'B5135588'





end
GO
