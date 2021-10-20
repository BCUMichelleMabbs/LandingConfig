SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jacob Hammer (JH)
-- Create date: August 2017
-- Description:	Extract of all Inpatient Data
-- =============================================
Create PROCEDURE [dbo].[Get_PAS_Data_CovidWest]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	

	EXEC('
	use ipmreports
	exec dbo.NWW_Get_PAS_Data_CovidWest
	'
	) AT [7A1AUSRVIPMSQLR\REPORTS];


END

GO
