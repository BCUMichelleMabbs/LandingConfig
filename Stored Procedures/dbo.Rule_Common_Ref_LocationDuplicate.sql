SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rule_Common_Ref_LocationDuplicate]
	
	
AS
BEGIN
	SET NOCOUNT ON;



    SELECT LocalCode, source, area, count(*)
	from Landing.dbo.Common_Ref_Location_KR
	group by LocalCode, source, area
	having count(*) >1


END


GO
