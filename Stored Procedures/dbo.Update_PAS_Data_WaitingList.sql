SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-------------------------------------------------------
-- Author :  Heather W Lewis
-- Date   :  11/05/2021
--
-- Post Foundation Procedure for the Waiting List Dataset
-- Based on Ardentia Derive Rule : XWL_FUREPFLAG
--          Ardentia View        : XWL_ALL_FUWL
--
--------------------------------------------------------
CREATE Procedure [dbo].[Update_PAS_Data_WaitingList]
@Load_GUID AS VARCHAR(38)
as
begin

Update [Foundation].[dbo].[PAS_Data_WaitingList]
Set

DaysToTarget  = DATEDIFF(d, W.DateOnWaitingList, w.DateBooked),
DaysToCurrent = DATEDIFF(d, W.DateOnWaitingList, w.DateWaitingListCensus),
DaysFromBookedToCurrent = DATEDIFF(d, w.DateBooked,w.DateWaitingListCensus),

pc25_flag=CASE WHEN (CASE WHEN datediff(d, W.DateOnWaitingList, w.DateBooked) = 0 THEN 0 
	            ELSE datediff(d, W.DateOnWaitingList, w.DateWaitingListCensus) * 1.0 / datediff(d, W.DateOnWaitingList, w.DateBooked) 
		        END) > 1.25 THEN 'Y' 
		        ELSE 'N' END,

pc50_flag=CASE WHEN (CASE WHEN datediff(d, W.DateOnWaitingList, w.DateBooked) = 0 THEN 0 
		        ELSE datediff(d, W.DateOnWaitingList, w.DateWaitingListCensus) * 1.0 / datediff(d, W.DateOnWaitingList, w.DateBooked) 
		        END) > 1.5 THEN 'Y' 
		        ELSE 'N' END,

PCDelay = (CASE WHEN datediff(d , w.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
		        ELSE datediff(d , w.DateOnWaitingList , w.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList , w.DateBooked) 
				END) * 100 - 100,

PC0_25Flag = CASE WHEN (CASE WHEN datediff(d ,W.DateOnWaitingList,w.DateBooked) = 0 THEN 0 
                  ELSE datediff(d , W.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , W.DateOnWaitingList , w.DateBooked) 
				  END) BETWEEN 1.000000001 AND 1.2499999 THEN 'Y' 
				  ELSE 'N' 
				  END,

PC25_50Flag = CASE WHEN (CASE WHEN datediff(d , W.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
                         ELSE datediff(d , w.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList ,w.DateBooked) 
						 END) BETWEEN 1.2500000 AND 1.4999999 THEN 'Y' 
						 ELSE 'N' 
						 END,

PC50_100FLag = CASE WHEN (CASE WHEN datediff(d , w.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
                          ELSE datediff(d , w.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList ,w.DateBooked ) 
						  END) BETWEEN 1.5000000000 AND 1.9999999 THEN 'Y' 
						  ELSE 'N' 
						  END,

PCOver100Flag = CASE WHEN (CASE WHEN datediff(d , w.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
                          ELSE datediff(d , w.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList , w.DateBooked) 
						  END) >= 2.0 THEN 'Y' 
						  ELSE 'N' 
						  END,   

 ReportableFlag = CASE WHEN w.Area in ('East','Central') and w.CommentsOfReferral ='Awaiting Diagnostics' then 'N'
	                   WHEN w.Specialty in ('320100','320200') THEN 'N' 
	                   WHEN w.Specialty like '160%' then 'N'
                       WHEN w.Specialty like '171%' then 'N'
	                   WHEN w.Specialty LIKE '211%' then 'N'
	                   WHEN w.Specialty LIKE '304%' then 'N'
	                   WHEN w.Specialty like '321%' then 'N'
	                   WHEN w.Specialty like '400%' then 'N'
	                   WHEN w.Specialty LIKE '421%' then 'N'
	                   WHEN w.Specialty LIKE '501%' then 'N'
	                   WHEN w.Specialty LIKE '510%' then 'N'
	                   WHEN w.Specialty like 'CMA%' then 'N'
	                   WHEN w.Specialty like 'DIA%' then 'N'
	                   WHEN w.Specialty LIKE 'DIE%' then 'N'
	                   WHEN w.Specialty LIKE 'EYE%' then 'N'
	                   WHEN w.Specialty like 'HYG%' then 'N'
	                   WHEN w.Specialty like 'NUR%' then 'N'
	                   WHEN w.Specialty LIKE 'PHY%' then 'N'
	                   WHEN w.Specialty LIKE 'PSY%' then 'N'
	                   WHEN w.Specialty LIKE 'WRD%' then 'N'
	 WHEN w.WaitinglistType ='FU' and w.DateBooked is null and w.Area ='East' and w.specialty like '501%' or w.specialty like '510%' or w.specialty like '650%' or w.specialty like '651%' or w.specialty like '652%' or w.specialty like '654%' or w.specialty like '700%' or w.specialty like '710%' or w.specialty like '711%' or w.specialty like '713%' or w.specialty like '715%' or w.specialty like '800%' or w.specialty like '822%' or w.specialty like '831%' or w.specialty like '950%' THEN 'N' 
	 WHEN w.Area ='Central' and w.Specialty in ('110111','110112','110113','110552') THEN 'N' 
	 WHEN w.Area ='East' and w.Specialty like '650%' or w.Specialty like '651%' or w.Specialty like '652%' or  w.Specialty like '654%' THEN 'N' 
	 WHEN w.WaitinglistType ='FB' and w.Area ='East' and Specialty like '%555' or Specialty like '%559' THEN 'N'
	 WHEN w.WaitinglistType ='FB' and w.Area ='East' AND W.Specialty IN ('302550' , '303550' , '303552' , '320200') THEN 'N' 
	 WHEN (ISNULL(YEAR(w.DateBooked) , 1) = 2079) THEN 'N' 
     WHEN w.Area = 'West' AND w.Specialty like '304%' or  w.Specialty like '501%' THEN 'N'
		ELSE 'Y' 
		END,

ValidFlag = 'Y'

from [Foundation].[dbo].[PAS_Data_WaitingList] w
WHERE Load_GUID = @Load_GUID
and WaitingListType in ('IP','DC','OP','FU','FB','EF','EN')

END



/*
select 
Area, 
HCP,
specialty, 
WaitinglistType,
CASE WHEN w.Area in ('East','Central') and w.CommentsOfReferral ='Awaiting Diagnostics' then 'N'
	 WHEN w.Specialty in ('320100','320200') THEN 'N' 
	 WHEN w.Specialty like '160%' then 'N'
     WHEN w.Specialty like '171%' then 'N'
	 WHEN w.Specialty LIKE '211%' then 'N'
	 WHEN w.Specialty LIKE '304%' then 'N'
	 WHEN w.Specialty like '321%' then 'N'
	 WHEN w.Specialty like '400%' then 'N'
	 WHEN w.Specialty LIKE '421%' then 'N'
	 WHEN w.Specialty LIKE '501%' then 'N'
	 WHEN w.Specialty LIKE '510%' then 'N'
	 WHEN w.Specialty like 'CMA%' then 'N'
	 WHEN w.Specialty like 'DIA%' then 'N'
	 WHEN w.Specialty LIKE 'DIE%' then 'N'
	 WHEN w.Specialty LIKE 'EYE%' then 'N'
	 WHEN w.Specialty like 'HYG%' then 'N'
	 WHEN w.Specialty like 'NUR%' then 'N'
	 WHEN w.Specialty LIKE 'PHY%' then 'N'
	 WHEN w.Specialty LIKE 'PSY%' then 'N'
	 WHEN w.Specialty LIKE 'WRD%' then 'N'
	 WHEN w.WaitinglistType ='FU' and w.DateBooked is null and w.Area ='East' and w.specialty like '501%' or w.specialty like '510%' or w.specialty like '650%' or w.specialty like '651%' or w.specialty like '652%' or w.specialty like '654%' or w.specialty like '700%' or w.specialty like '710%' or w.specialty like '711%' or w.specialty like '713%' or w.specialty like '715%' or w.specialty like '800%' or w.specialty like '822%' or w.specialty like '831%' or w.specialty like '950%' THEN 'N' 
	 WHEN w.Area ='Central' and w.Specialty in ('110111','110112','110113','110552') THEN 'N' 
	 WHEN w.Area ='East' and w.Specialty like '650%' or w.Specialty like '651%' or w.Specialty like '652%' or  w.Specialty like '654%' THEN 'N' 
	 WHEN w.WaitinglistType ='FB' and w.Area ='East' and Specialty like '%555' or Specialty like '%559' THEN 'N'
	 WHEN w.WaitinglistType ='FB' and w.Area ='East' AND W.Specialty IN ('302550' , '303550' , '303552' , '320200') THEN 'N' 
	 WHEN (ISNULL(YEAR(w.DateBooked) , 1) = 2079) THEN 'N' 
     WHEN w.Area = 'West' AND w.Specialty like '304%' or  w.Specialty like '501%' THEN 'N'
		ELSE 'Y' 
		END as ReportableFlag,
ValidFlag = 'Y',
W.LocalPatientIdentifier,
w.WaitingListRefNo,
w.ActNoteKey,
w.DateOnSystem,
w.DateBooked,
w.DateOnWaitingList,
w.DateWaitingListCensus,

CASE WHEN (CASE WHEN datediff(d, W.DateOnWaitingList, w.DateBooked) = 0 THEN 0 
	            ELSE datediff(d, W.DateOnWaitingList, w.DateWaitingListCensus) * 1.0 / datediff(d, W.DateOnWaitingList, w.DateBooked) 
		        END) > 1.25 THEN 'Y' 
		        ELSE 'N' END AS pc25_flag,
CASE WHEN (CASE WHEN datediff(d, W.DateOnWaitingList, w.DateBooked) = 0 THEN 0 
		        ELSE datediff(d, W.DateOnWaitingList, w.DateWaitingListCensus) * 1.0 / datediff(d, W.DateOnWaitingList, w.DateBooked) 
		        END) > 1.5 THEN 'Y' 
		        ELSE 'N' END AS pc50_flag,

DATEDIFF(d, W.DateOnWaitingList, w.DateBooked) AS days_to_target, 
DATEDIFF(d, W.DateOnWaitingList, w.DateWaitingListCensus) AS days_to_current, 
DATEDIFF(ww, W.DateOnWaitingList,  w.DateBooked) AS weeks_to_target, 
(DATEDIFF(d,  w.DateBooked, w.DateWaitingListCensus) + CASE WHEN datediff(d,  w.DateBooked, w.DateWaitingListCensus) > 0 THEN - 1 
                                                            ELSE 1 
															END) / 7 AS Weeks_OU,
 DATEDIFF(d,  w.DateBooked,w.DateWaitingListCensus) AS Days_OU, 

datediff(d , w.DateOnSystem , w.DateBooked) as DateOnSystemDateBooked ,
datediff(d , w.DateOnWaitingList , w.DateWaitingListCensus) as DateOnWaitingListDateWaitingListCensus,
datediff(d , w.DateOnWaitingList , w.DateBooked) as DateOnWaitingListDateBooked,

PCDelay = (CASE WHEN datediff(d , w.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
		        ELSE datediff(d , w.DateOnWaitingList , w.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList , w.DateBooked) 
				END) * 100 - 100,

PC0_25Flag = CASE WHEN (CASE WHEN datediff(d ,W.DateOnWaitingList,w.DateBooked) = 0 THEN 0 
                  ELSE datediff(d , W.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , W.DateOnWaitingList , w.DateBooked) 
				  END) BETWEEN 1.000000001 AND 1.2499999 THEN 'Y' 
				  ELSE 'N' 
				  END,
PC25_50Flag = CASE WHEN (CASE WHEN datediff(d , W.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
                         ELSE datediff(d , w.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList ,w.DateBooked) 
						 END) BETWEEN 1.2500000 AND 1.4999999 THEN 'Y' 
						 ELSE 'N' 
						 END,

PC50_100FLag = CASE WHEN (CASE WHEN datediff(d , w.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
                          ELSE datediff(d , w.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList ,w.DateBooked ) 
						  END) BETWEEN 1.5000000000 AND 1.9999999 THEN 'Y' 
						  ELSE 'N' 
						  END,
PCOver100Flag = CASE WHEN (CASE WHEN datediff(d , w.DateOnWaitingList , w.DateBooked) = 0 THEN 0 
                          ELSE datediff(d , w.DateOnWaitingList , W.DateWaitingListCensus) * 1.0 / datediff(d , w.DateOnWaitingList , w.DateBooked) 
						  END) >= 2.0 THEN 'Y' 
						  ELSE 'N' 
						  END    

from PAS_Data_WaitingList w
where DateWaitingListCensus='2021-05-10'
and WaitingListType in ('IP','DC','OP','FU','FB','EF','EN')
--AND W.LocalPatientIdentifier = 'G430539'
order by Area, ActNoteKey
*/

GO
