SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Rule_PAS_Ref_AdministrativeCategory]
	
	
AS
BEGIN
	SET NOCOUNT ON;



    SELECT * 
	
	from Landing.dbo.pas_ref_AdministrativeCategory


	WHERE MainCode is null

END
GO
