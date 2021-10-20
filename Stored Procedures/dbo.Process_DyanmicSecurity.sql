SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Process_DyanmicSecurity] 
as
begin


EXEC msdb.dbo.sp_start_job N'Dynamic Security'  
 
END
GO
