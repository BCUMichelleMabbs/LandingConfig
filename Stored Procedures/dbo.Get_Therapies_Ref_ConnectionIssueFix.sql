SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_ConnectionIssueFix]
AS
BEGIN
	
	SET NOCOUNT ON;

	
	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Appointments

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Appointment_Status

    select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Budget_Categories

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Diagnosis

	select TOP (1) [Referral_ID]
    FROM [SQL4\SQL4].[physio].[dbo].Diagnosis_Link

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Lists

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Outcome

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Outcome_Definition
	
	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Patient

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Referral
		
	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].RefferingInstance

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Resources
	
	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Resource_Group

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Site_Information

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].Symbols

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].User_Information

	select TOP (1) [ID]
    FROM [SQL4\SQL4].[physio].[dbo].WaitingList


	












End
GO
