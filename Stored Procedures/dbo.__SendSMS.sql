SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[__SendSMS] (@message [nvarchar] (max), @number [nvarchar] (max), @result [nvarchar] (max) OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [SendSMS].[Notification.SMS].[SendMessage]
GO
