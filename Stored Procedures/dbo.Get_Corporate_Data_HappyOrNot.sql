SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		EJ
-- Create date: 20/02/2020
-- Description:	Happy or Not Patient Experience
-- =============================================

CREATE PROCEDURE [dbo].[Get_Corporate_Data_HappyOrNot]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

SET NOCOUNT ON;

SELECT

	[ID],
	[Area],
	[Site],
	[Location],
	[Type],
	[SurveyID],
	[Question],
	[Button],
	CAST([Relevance] AS DECIMAL(20,10)) AS [Relevance],
	[Spam],
	[Text],
	[Subject],
	CAST([TimeStamp] AS DATETIME) AS [TimeStamp],
	CAST([InsertDateTime] AS DATETIME) AS [InsertDateTime]

FROM	[SSIS_LOADING].[PatientExperience].[dbo].[HON_Data]

END
GO
