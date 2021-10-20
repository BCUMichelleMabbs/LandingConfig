SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Reporting].[UnscheduledCare_EDAttendanceLiveDTSX]

AS

BEGIN


DECLARE @Max datetime
SET @Max =  (SELECT MIN(Logged) as [Max] FROM OPENQUERY ([7A1A1SRVINFODW2], 'EXEC Landing_Config.Reporting.UnscheduledCare_EDAttendanceLive'))


SELECT
	  n.project_name
	, package_name
	, [status]
	,n.start_time
	,n.end_time
	, CASE [status] 
		WHEN 1 THEN 'Created' 
		WHEN 2 THEN 'Running' 
		WHEN 3 THEN 'Canceled' 
		WHEN 4 THEN 'Failed' 
		WHEN 5 THEN 'Pending' 
		WHEN 6 THEN 'Ended Unexpectedly' 
		WHEN 7 THEN 'Succeeded' 
		WHEN 8 THEN 'Stopping' 
		WHEN 9 THEN 'Completed' END AS [Value]

FROM [SSISDB].[catalog].[executions] n 
INNER JOIN (
  SELECT project_name, MAX(start_time) as [st]
  FROM [SSISDB].[catalog].[executions] GROUP BY project_name
) as max on n.project_name = max.project_name and n.start_time = max.st

WHERE n.package_name = 'EDAttendanceLive.dtsx' and CAST(n.start_time AS DATETIME) > @Max

END
GO
