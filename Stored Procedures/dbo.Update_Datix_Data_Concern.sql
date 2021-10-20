SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Update_Datix_Data_Concern]

@LoadGUID varchar(38)
	
AS
BEGIN
	
SET NOCOUNT ON;

update Foundation.dbo.Datix_Data_Concern

Set 
		BCURefId = cast(c.BCURefId as varchar) + 'Temp' + cast(RN as varchar)
From
		Foundation.dbo.Datix_Data_Concern c
		JOIN 
(
		Select Row_GUID,BCURefId,ROW_NUMBER() OVER(partition by bcurefid order by bcurefid) as RN
		from Foundation.dbo.Datix_Data_Concern 
		where bcurefid in ('EA14/512','EA13/437','CA14/522','CA13/427','WU11/049','CA13/466','EA14/545','EA13/420','EA13/402','CA13/424','EA13/475','T11/089','WA14/534','CA13/387','CA13/426','EA13/417',
										'CA13/489','WA14/517','EA13/428','EA13/494','EA11/0174','WU11/213','CA13/439','NWA14/548','EA13/498','WA13/485','EPF11-E43','CA12/265','W7757','WA13/505','ea13/436','EA13/404',
										'WA13/470','CA13/497','CA13/405','NWA14/543','CA14/541','CA13/441')
) CTE
		ON c.BCURefId = cte.BCURefId and c.Row_GUID = cte.Row_GUID

END
GO
