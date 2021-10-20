SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROCEDURE [Reporting].[UnscheduledCare_EDAttendanceLive]

AS

BEGIN

;With Table_CTE as

(
SELECT  ROW_NUMBER() OVER(ORDER BY Logged DESC) AS [RN], Logged as Max_Date FROM [Landing_Config].[dbo].[AuditItem] WHERE Action = 'Create table' AND Stage = '_Init_Landing_Tables' AND Dataset = 'UnscheduledCare_Data_EDAttendanceLive' 
)



SELECT 
	*,
	CASE WHEN Action = 'ERROR' THEN 0 ELSE 1 END as [Flag]

FROM 
	[Landing_Config].[dbo].[AuditItem] a1

WHERE 
	a1.Dataset = 'UnscheduledCare_Data_EDAttendanceLive'
	AND
	a1.Logged >=  (SELECT Max_Date FROM Table_CTE WHERE RN = 1) 
--	AND
	--a1.Logged < (SELECT Max_Date FROM Table_CTE WHERE RN = 1)
	AND
	Value <> 'Dropped'

END
GO
