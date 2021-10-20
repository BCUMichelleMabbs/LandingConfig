SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Jacob Hammer (JH)
-- Create date: August 2017
-- Description:	Extract of all Referral Data
--
-- Author: Heather v2/v3
-- version 2 - OUTPUT for Referrals
-- Version 3 - Referrals Dataset to now include Waiting List Additions Data
-- Step1 Extract Waiting List Entries data (Exclude Outpatient Check/Repeat)
-- Step2 Extract Data from Schedules where no WLE exists But New Appointment Exists (ie Waiting List bypassed)
-- Step3 Extract Data from Referrals where Referral has not been actioned yet (ie no Waiting List or Appointment exists)
--
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Referral_West]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	

	EXEC('
	use iPMProduction

	-- exec dbo.Get_PAS_Data_ReferralWest
	   exec dbo.Get_PAS_Data_ReferralWest_v2
	'
	) AT [7A1AUSRVIPMSQL];


END


GO
