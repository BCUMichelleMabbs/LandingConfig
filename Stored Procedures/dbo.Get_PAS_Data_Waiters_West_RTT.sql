SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:	Heather	
-- 
-- =============================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_Waiters_West_RTT]
	
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

	
	use [RTTdata]

	
	exec Get_West_RTT_Foundation
	
	'
--	) AT [NWWINTEGRATION];

  ) AT [NWWINTEGRATION.CYMRU.NHS.UK];

END



/* 

-- NWWINTEGRATION.CYMRU.NHS.UK - this connection works  and I can run all these below - but can't run the above due to permissions required to drop/recreate table

SELECT *
FROM [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].[dbo].[rtt_refs]

SELECT *
FROM [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].[dbo].[RTTWest_NewWH]




-- NWWINTEGRATION link - does NOT work!

SELECT *
FROM [NWWINTEGRATION].[RTTdata].[dbo].[RTTWest_NewWH]

SELECT *
FROM [NWWINTEGRATION].[RTTdata].[dbo].[rtt_refs]


SELECT *
FROM [nwwintegration].[RTTdata].[dbo].[rtt_refs]


*/

GO
