SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[Get_Covid_Data_WestTransfersIn]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	

	EXEC('
	use ipmreports
	exec [dbo].[Get_Covid_Data_WestTransfersIn]
	'
	) AT [7A1AUSRVIPMSQLR\REPORTS];


END
GO
