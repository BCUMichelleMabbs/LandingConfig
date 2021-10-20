SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Update_Common_Ref_Date]
@LoadGUID varchar(38)
AS  
BEGIN

Update [bcuinfo\bcudatawarehouse].[Dimension].[dbo].[Common_Date]
Set [DaysFromCurrentWeekStart] = '-1'

Update  [bcuinfo\bcudatawarehouse].[Dimension].[dbo].[Common_Date]
Set [DaysFromCurrentWeekStart] = CASE WHEN DATEDIFF(day,DATEADD(ww, DATEDIFF(ww,0,GETDATE()), 0),FullDate) BETWEEN 0 AND 31 THEN DATEDIFF(day,DATEADD(ww, DATEDIFF(ww,0,GETDATE()), 0),FullDate) ELSE '-1' END

END
GO
