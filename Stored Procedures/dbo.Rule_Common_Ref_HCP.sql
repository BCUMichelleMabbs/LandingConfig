SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Rule_Common_Ref_HCP]
	
	
AS
BEGIN
	SET NOCOUNT ON;



    SELECT * 
	
	from Landing.dbo.Common_Ref_HCP


	WHERE MainCode is null

END
GO
