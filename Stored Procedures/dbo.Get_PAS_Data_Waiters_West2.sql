SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:	Heather	
-- 
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_West2]
	
AS
BEGIN
	
	SET NOCOUNT ON;

declare @sql as varchar(max)
declare @today as datetime
declare @TodayDateText as varchar(20)

set @today = getdate()
set @TodayDateText = datename(day, @today) + ' ' + datename(month, @today) + ' ' + datename(year, @today)

DECLARE @LastDateWaitingListCensus AS DATE = (SELECT ISNULL(MAX(DateWaitingListCensus),'01 January 2018') FROM [Foundation].[dbo].[PAS_Data_WaitingList] where Area='West')
DECLARE @LastDateWaitingListCensusString AS VARCHAR(30) = DATENAME(DAY,@LastDateWaitingListCensus) + ' ' + DATENAME(MONTH,@LastDateWaitingListCensus) + ' ' + DATENAME(YEAR,@LastDateWaitingListCensus)	
	






	EXEC('

	--use ipmreports                                   [7A1AUSRVIPMSQLR\REPORTS]     Heather using production until testing done 
	
	use iPMProduction  
	exec dbo.nww_sp_eis_wlist_hwl
	exec dbo.Get_PAS_Data_Waiters_West_Z1

	'
	) AT [7A1AUSRVIPMSQL];


END


GO
