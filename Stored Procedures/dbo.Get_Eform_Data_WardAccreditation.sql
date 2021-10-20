SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Eform_Data_WardAccreditation]

AS

BEGIN 

SELECT 
	CAST(YearSel as varchar) + '-' + CAST(CASE WHEN LEN(MonthSel) = 1 THEN '0' + CAST(MonthSel as varchar) ELSE CAST(MonthSel as varchar) END as varchar) as [Date],
	w.Area,
	w.Hospital,
	w.Ward_Name,
	w.ReviewType,
	[Q_Set_Id],
	[Q_Set_Question_Number],
	[Q_Set_Audit_Type],
	CASE WHEN CAST(CAST(w.YearSel as varchar) + '-' + CASE WHEN LEN(CAST(w.MonthSel as varchar)) = 1 THEN '0' + CAST(w.MonthSel as varchar) ELSE CAST(w.MonthSel as varchar) END + '-' + '01' as date) = (SELECT MAX(CAST(CAST(w2.YearSel as varchar) + '-' + CASE WHEN LEN(CAST(w2.MonthSel as varchar)) = 1 THEN '0' + CAST(w2.MonthSel as varchar) ELSE CAST(w2.MonthSel as varchar) END + '-' + '01' as date)) FROM [SSIS_Loading].[EFORMS].[dbo].[X_WA_QuestionReturns] w2 WHERE w2.Ward_Name = w.Ward_Name) THEN 1 ELSE 0 END as [MaxMonth],
	CASE 
	WHEN   
		SUM(CASE WHEN [Q_Sample_1] IS NULL THEN 0 ELSE sc1.Value END) IS NULL AND
		SUM(CASE WHEN [Q_Sample_2] IS NULL THEN 0 ELSE sc2.Value END) IS NULL AND
		SUM(CASE WHEN [Q_Sample_3] IS NULL THEN 0 ELSE sc3.Value END) IS NULL
	THEN 
		NULL
		
	ELSE [Q_Samples_Req] END as [OutOf],
CASE 
	WHEN   
		SUM(CASE WHEN [Q_Sample_1] IS NULL THEN 0 ELSE sc1.Value END) IS NULL AND
		SUM(CASE WHEN [Q_Sample_2] IS NULL THEN 0 ELSE sc2.Value END) IS NULL AND
		SUM(CASE WHEN [Q_Sample_3] IS NULL THEN 0 ELSE sc3.Value END) IS NULL
	THEN 
		NULL
	ELSE
		SUM(CASE WHEN [Q_Sample_1] IS NULL THEN 0 ELSE ISNULL(sc1.Value, 0) END) +
		SUM(CASE WHEN [Q_Sample_2] IS NULL THEN 0 ELSE ISNULL(sc2.Value, 0) END) +
		SUM(CASE WHEN [Q_Sample_3] IS NULL THEN 0 ELSE ISNULL(sc3.Value, 0) END)           
     END AS [Score]


FROM 
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_QuestionReturns_Q_Set] q
	LEFT JOIN
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_Scoring] sc1 ON q.Q_Sample_1 = sc1.[Return] 
	LEFT JOIN
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_Scoring] sc2 ON q.Q_Sample_2 = sc2.[Return]  
	LEFT JOIN
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_Scoring] sc3 ON q.Q_Sample_3 = sc3.[Return]  
	JOIN
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_QuestionReturns] w
	on
	q.Set_Ref=w.Set_Ref



GROUP BY
	w.YearSel,
	w.MonthSel,
	w.Area,
	w.Hospital,
	w.Ward_Name,
	w.ReviewType,
	[Q_Set_Id],
	[Q_Set_Question_Number],
	[Q_Set_Audit_Type],
	[Q_Sample_1],
	[Q_Sample_2],
	[Q_Sample_3],
	[Q_Total_Score],
	[Q_Sample_Size],
	[Q_Samples_Req],
	sc1.Value,
	sc2.Value,
	sc3.Value
	

END
GO
