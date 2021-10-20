SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE  FUNCTION [dbo].[GPOH_BSTOffset]
(
       @ReceivedDateTime datetime
)
RETURNS datetime
AS
BEGIN
DECLARE @dateout datetime
select @dateout = UTCOffset from Foundation.dbo.GPOH_Ref_BSTAdjustment
  where @ReceivedDateTime >= UTCStart and @ReceivedDateTime < UTCEnd
Return @dateout
 
END


GO
