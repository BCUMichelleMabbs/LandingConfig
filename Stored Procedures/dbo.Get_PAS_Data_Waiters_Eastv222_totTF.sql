SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Heather Lewis 
-- Create date: 6/10/2020
-- Description:	East - Extract of all Waiters (OP/DC/IP/FU/PP)
--              This version created to fix error "Unable to Execute an Execute"
--              Data succesfully loads into foundation   
--  Amend Date: 
--              
-- =============================================


CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Eastv222_totTF]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)


EXEC('

Select ''TO'' , count(*) AS TFCount
from 	
REF_WAIT_LEN_VIEW_ENH (''TO'',''' + @TodayDateText + ''','''','''','''','''') as wl

'

) at [WPAS_East];
END


GO
