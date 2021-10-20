SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_DTOC_Ref_DischargeReason]
AS
BEGIN
SET NOCOUNT ON;

DECLARE 
 @Server varchar(100) = (Select Top 1 '['+[Server]+']' FROM [Foundation].[dbo].[Common_Ref_Server] WHERE Dataset = 'DTOC' ORDER BY Date desc, Time Desc) --Select the working server for that day (job runs to check each morning)
,@SQL2 varchar(200)

Set @Server += '.[DTOCS].[dbo].[VW_HealthBoard_DischargeReason] )'   -- Concatinate server name with table into one parameter
Set @SQL2 = ' SELECT * FROM @Results order by Source,Name'

Declare @SQL as Varchar(max) =
'DECLARE @Results AS TABLE (MainCode VARCHAR(6),Name VARCHAR(200), Source VARCHAR(8) )
INSERT INTO @Results(MainCode,Name,Source)
	(
	SELECT 
		DRID AS MainCode,
	REASON AS Name,
		''DTOC'' AS Source
	FROM '
	+ @Server
	+ @SQL2
	
exec (@SQL)
	
End
GO
