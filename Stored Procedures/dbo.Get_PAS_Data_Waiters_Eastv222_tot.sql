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


CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_Eastv222_tot]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)



EXEC('

Select "OP",  count(*) AS Total
from REF_WAIT_LEN_VIEW_ENH (''21'',''' + @TodayDateText + ''','''','''','''','''') as wl
	
UNION
Select "DC" ,  count(*) AS Total
from REF_WAIT_LEN_VIEW_ENH (''31'',''' + @TodayDateText + ''','''','''','''','''') as wl
	
UNION
Select "IP" , count(*) AS Total
from REF_WAIT_LEN_VIEW_ENH (''41'',''' + @TodayDateText + ''','''','''','''','''') as wl
	
UNION
Select "PP", count(*) AS Total
from REF_WAIT_LEN_VIEW_ENH (''PP'',''' + @TodayDateText + ''','''','''','''','''') as wl
	
UNION
Select "FU", count(*) AS Total
from 	
REF_WAIT_LEN_VIEW_ENH (''FU'',''01/01/2999'','''','''','''','''') as wl

UNION 

Select "TF", count(*) AS Total
from 	
REF_WAIT_LEN_VIEW_ENH (''TF'',''01/01/2999'','''','''','''','''') as wl

UNION 
Select ''TO'' , count(*) AS TFCount
from 	
REF_WAIT_LEN_VIEW_ENH (''TO'',''' + @TodayDateText + ''','''','''','''','''') as wl

'

) at [WPAS_East];
END

---EXEC(' Select * from REF_WAIT_LEN_VIEW_ENH (''21'', ''06 OCT 2020'' ,'''','''','''','''') ') AT [WPAS_Central] 
-- REF_WAIT_LEN_VIEW_ENH (''''21'''',''''' + @TodayDateText + ''''','''''''','''''''','''''''','''''''') as wl


GO
