SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Rule_PAS_Ref_Diagnosis]
	
	
AS
BEGIN
	SET NOCOUNT ON;



    SELECT * 
	
	from Landing.dbo.PAS_Ref_Diagnosis


	WHERE MainCode is null

END


GO