SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Outsourced_Data_PreReq]
	
AS
BEGIN
	
	SET NOCOUNT ON;

EXEC sp_configure 'xp_cmdshell',1;RECONFIGURE;


END

GO