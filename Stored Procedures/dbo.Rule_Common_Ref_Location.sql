SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rule_Common_Ref_Location]
	
	
AS
BEGIN
	SET NOCOUNT ON;



    SELECT * 
	
	from Landing.dbo.Common_Ref_Location_KR


	WHERE MainCode is null
	order by source, area
END

GO
