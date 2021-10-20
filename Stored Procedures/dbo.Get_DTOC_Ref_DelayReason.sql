SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_DTOC_Ref_DelayReason]
AS
BEGIN
SET NOCOUNT ON;

DECLARE 
 @Server varchar(100) = (Select Top 1 '['+[Server]+']' FROM [Foundation].[dbo].[Common_Ref_Server] WHERE Dataset = 'DTOC' ORDER BY Date desc, Time Desc) --Select the working server for that day (job runs to check each morning)
,@SQL2 varchar(200)

Set @Server += '.[DTOCS].[dbo].[VW_HealthBoard_DelayReason] '   -- Concatinate server name with table into one parameter
Set @SQL2 = 'WHERE DCODE <> ''-1'') SELECT * FROM @Results order by Source,Name'

Declare @SQL as Varchar(max) =
'DECLARE @Results AS TABLE (MainCode VARCHAR(7),Point varchar(8) ,Name VARCHAR(200), Source VARCHAR(8),DelayCategory varchar(100),DelayArea varchar(100) )
INSERT INTO @Results(MainCode,Point,Name,Source,DelayCategory,DelayArea)
	(
	SELECT 
		DCODE AS MainCode,
		DPOINT as Point,
	   DREASON AS Name,
		''DTOC'' AS Source,
		DELAYCATEGORY as DelayCategory,
		DELAYAREA as DelayArea
	FROM '
	+ @Server
	+ @SQL2
	
exec (@SQL)
	
End
GO
