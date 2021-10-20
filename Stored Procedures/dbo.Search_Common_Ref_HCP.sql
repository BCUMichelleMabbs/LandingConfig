SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Search_Common_Ref_HCP] @localcode varchar (20), @localname varchar (200)
	
	
AS
BEGIN
	SET NOCOUNT ON;



    SELECT Source, Area, LocalCode, LocalName, MainCode as NationalCode
	
	from Foundation.dbo.Common_Ref_HCP
	where localcode like '%' + @localcode + '%'
	and localname like '%' + @localname + '%'

	order by localcode

end


GO
