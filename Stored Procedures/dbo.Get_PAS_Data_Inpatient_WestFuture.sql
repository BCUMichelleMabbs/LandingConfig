SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[Get_PAS_Data_Inpatient_WestFuture]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	

	EXEC('
	USE [iPMProduction]
	exec dbo.NWW_Get_PAS_Data_InpatientWestFuture
	'
	) AT [7A1AUSRVIPMSQL];


END


GO
