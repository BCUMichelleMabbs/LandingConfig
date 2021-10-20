SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_BedApp_Data_BedNumbersChangeList]
*/
CREATE PROCEDURE [dbo].[Get_BedApp_Data_BedNumbersChangeList]
	
AS
BEGIN
	
SET NOCOUNT ON;

	SELECT
		[Id]
		,[Ward_Id]
		,[Hospital]
		,[Clinical Programme Group] AS [ClinicalProgrammeGroup]
		,[Ward]
		,[New Ward Name] AS [NewWardName]
		,[Specialty]
		,LTRIM(RTRIM([Area])) AS [Area]
		,[Specialty Code] AS [SpecialtyCode]
		,[Current Bed Status] AS [CurrentBedStatus]
		,[EscalationBeds] AS [EscalationBedCount]
		,[ClosedBeds] AS [ClosedBedCount]
		,[Trolleys] AS [TrolleyCount]
		,CAST([Date Changed] AS DATE) AS [DateChanged]
		,[LastChangedBy] AS [LastChangedByName]
		,[LastChangedByNadex]
		,NULLIF([Change_Reason], '') AS [ChangeReason]
		,[Funded Beds] AS [FundedBedCount]
		,[Male_Beds] AS [MaleBedCount]
		,[Female_Beds] AS [FemaleBedCount]
		,[ChangeEmailed]
		,CAST([ChangedOnSystemDate] AS DATE) AS [ChangedOnSystemDate]
		,CAST(RIGHT([Date Changed], 16) AS TIME) AS [TimeChanged]
		,CAST(RIGHT([ChangedOnSystemDate], 16) AS TIME) AS [ChangedOnSystemTime]
	FROM [SSIS_LOADING].[Bed_Management_App].[Inpatients].[ChangeList_BedNumbers]
END
GO
