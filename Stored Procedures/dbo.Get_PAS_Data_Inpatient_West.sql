SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--NOTES
--Should be placed on the 1 month or null replacement plan otherwise those with a null episiode end date won't be removed.


CREATE PROCEDURE [dbo].[Get_PAS_Data_Inpatient_West]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	

	EXEC('
	USE [iPMProduction]
	exec dbo.NWW_Get_PAS_Data_InpatientWest

	'
	) AT [7A1AUSRVIPMSQL];


END


--Removed from script as it appears to be unrelated. 

--DROP TABLE WestWaitingList_NewWH
--SELECT * INTO WestWaitingList_NewWH FROM eis_wlist_hwl
--ALTER TABLE WestWaitingList_NewWH ADD PriorityOnLetter [varchar] (30)
--ALTER TABLE WestWaitingList_NewWH ADD Outcome[varchar] (30)
--ALTER TABLE WestWaitingList_NewWH ADD ReferralIntent[varchar] (30)

--select * from WestWaitingList_NewWH
GO
