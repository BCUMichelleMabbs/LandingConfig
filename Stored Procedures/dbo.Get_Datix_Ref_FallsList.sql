SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_FallsList]
@Ward varchar(20)

AS

BEGIN

DECLARE @Reduction float

SET @Reduction = (SELECT [RedTar] FROM [Foundation].[dbo].[Datix_Ref_WardFallReductionTargets] WHERE WardCode = @Ward)

INSERT INTO [Foundation].[dbo].[Datix_Ref_WardIndicatorList] ([Date],[Ward],[FallsRag])
	

SELECT 
	GETDATE() as [Date],
	@Ward as [Ward],
	CASE
		WHEN COUNT(*) > (SELECT Count(*)/12 FROM [Foundation].[dbo].[Datix_Data_Incident] WHERE inc_clin_detail = 'FALLS' AND inc_type = 'PAT' AND inc_locactual = @Ward AND rep_approved <> 'REJECT' AND inc_dincident >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-13, 0) AND inc_dincident <= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1)) OR COUNT(CASE WHEN inc_severity in ('CATA','HIGH','MEDIUM') THEN 1 ELSE NULL END) >0 THEN 3
		WHEN COUNT(*) > (SELECT (SELECT CAST(COUNT(*)/12 AS DECIMAL) *1.0 FROM [Foundation].[dbo].[Datix_Data_Incident] WHERE inc_clin_detail = 'FALLS' AND inc_type = 'PAT' AND inc_locactual = @Ward AND rep_approved <> 'REJECT' AND inc_dincident >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-13, 0) AND inc_dincident <= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))  *@Reduction )  THEN 2
		WHEN COUNT(*) <= (SELECT (SELECT CAST(COUNT(*)/12 AS DECIMAL) *1.0 FROM [Foundation].[dbo].[Datix_Data_Incident] WHERE inc_clin_detail = 'FALLS' AND inc_type = 'PAT' AND inc_locactual = @Ward AND rep_approved <> 'REJECT' AND inc_dincident >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-13, 0) AND inc_dincident <= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))  *@Reduction )  THEN 1
		ELSE 4
	END as [FallsRag]

FROM [Foundation].[dbo].[Datix_Data_Incident]
	

WHERE 
	inc_clin_detail = 'FALLS'
	AND
	inc_type = 'PAT'
    AND 
    inc_locactual = @Ward
    AND
    inc_dincident >= DATEADD(dd, -31, GETDATE())
	AND
    inc_dincident < DATEADD(dd,-1,GETDATE())
	AND
	rep_approved <> 'REJECT'

END
GO
