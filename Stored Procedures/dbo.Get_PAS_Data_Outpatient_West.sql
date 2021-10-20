SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_Outpatient_West]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	

	EXEC('
	use [iPMProduction]
	exec dbo.NWW_Get_PAS_Data_OutpatientWest
	'
	) AT [7A1AUSRVIPMSQL];


END
GO
