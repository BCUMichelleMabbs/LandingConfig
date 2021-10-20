SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Dylan Jones (DJ)
-- Create date: May 2020
-- Description:	Extract of all Outpatient Non-Contact Data
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_NonContact_West]
	
AS
BEGIN

SET NOCOUNT ON;

	EXEC('
	USE [iPMProduction]
	exec [dbo].[NWW_Get_PAS_Data_NonContact_West]
	'
	) AT [7A1AUSRVIPMSQL];


END
GO
