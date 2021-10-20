SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_BedApp_Data_BedNumbersHistoric]
*/
CREATE PROCEDURE [dbo].[Get_BedApp_Data_BedNumbersHistoric]
	
AS
BEGIN
	
SET NOCOUNT ON;

	SELECT
		[Id]
		,[Hospital]
		,[Clinical Programme Group] AS [ClinicalProgrammeGroup]
		,[Ward]
		,[Specialty]
		,LTRIM(RTRIM([Area])) AS [Area]
		,[Specialty Code] AS [SpecialtyCode]
		,[Current Bed Status] AS [CurrentBedStatus]
		,[EscalationBeds] AS [EscalationBedCount]
		,[ClosedBeds] AS [ClosedBedCount]
		,[FundedBeds] AS [FundedBedCount]
		,[Male_Beds] AS [MaleBedCount]
		,[Female_Beds] AS [FemaleBedCount]
		,[Trolleys] AS [TrolleyCount]
		,CAST([Date Changed] AS DATE) AS [DateChanged]
		,[LastChangedBy] AS [LastChangedByName]
		,[LastChangedByNadex]
		,NULLIF([Change_Reason], '') AS [ChangeReason]
		,CAST([SnapshotDate] AS DATE) AS [SnapshotDate]
		,CAST(RIGHT([Date Changed], 16) AS TIME) AS [TimeChanged]
		,CAST(RIGHT([SnapshotDate], 16) AS TIME) AS [SnapshotTime]
		,Ward_Covid_Status

	FROM [SSIS_LOADING].[Bed_Management_App].[Inpatients].[Historical_BedNumbers]

END
GO
