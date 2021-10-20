SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Update_Datix_Ref_LocationType]

@LoadGUID varchar(38)
	
AS
BEGIN
	
SET NOCOUNT ON;

with cte  
       as (
       SELECT MainCode
       ,name
       ,Case when ROW_NUMBER() over(Partition by Maincode order by MainCode asc,LoadDate asc) = 1 then '1900-01-01' ELSE LoadDate END as [StartDate]
       ,Case when ROW_NUMBER() over(Partition by Maincode order by MainCode asc,LoadDate asc) = 1 then LoadDate
			else  ISNULL(CONVERT(Date,Dateadd(dd,0,LEAD(LoadDate) over (order by MainCode asc,LoadDate asc))),LoadDate) END as EndDate
       ,ROW_NUMBER() over(Partition by Maincode order by LoadDate asc) as [RN]
       FROM [Foundation].[dbo].[Datix_Ref_LocationType]
       WHERE MainCode IS NOT NULL
         )
		 , CTE2 AS 
		 ( SELECT DISTINCT
			   c1.MainCode,
			   c1.Name,
			   CASE WHEN c1.RN <> '1' THEN DATEADD(DD, 1, c2.EndDate) ELSE '1900-01-01'  END as [StartDate],
			   c1.EndDate,
			   c1.RN
		FROM cte c1 LEFT JOIN cte c2 ON c1.MainCode=c2.MainCode and c1.RN = c2.RN + 1 
)

update s
set s.StartDate = cte2.StartDate, 
EndDate = case when cte2.RN = (select max(cte2a.RN) from cte2 cte2a where cte2a.MainCode = s.MainCode) then cast(getdate() as date) else cte2.EndDate end 

From [Foundation].[dbo].[Datix_Ref_LocationType] s
 join CTE2 cte2 on s.MainCode = cte2.MainCode and s.Name = cte2.Name


END
GO
