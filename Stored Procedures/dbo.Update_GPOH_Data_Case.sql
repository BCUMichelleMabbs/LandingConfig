SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Update_GPOH_Data_Case]
@Load_GUID AS VARCHAR(38)

AS	
BEGIN
	
	SET NOCOUNT ON;
UPDATE Foundation.dbo.GPOH_Data_Case SET 
ActivePerformanceManagementRef='TEST' WHERE
Load_GUID=@Load_GUID
--ActiveDate = '11 DECEMBER 2018'


END
GO
