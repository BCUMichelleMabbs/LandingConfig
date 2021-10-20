SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Eform_Data_MatronsWalkabout]

AS

BEGIN 

SELECT 
	sa.[reviewer_name] as [Reviewer],
	sa.area as [Area],
	sa.ward as [Ward],
	sa.hospital as [Hospital],
	CAST(sa.date_visited as date) as [VisitStartDate], 
	CAST(sa.date_visited as date) as [VisitEndDate],
    s.[PatientRef],
    s.[Section],
	 s.[Question],
    s.[Type],
    s.[Value],
    s.[Denominator],
    s.[Text],
	CASE WHEN s.Type = 3 AND S.vALUE IS NOT NULL THEN CONVERT(VARCHAR, CAST(ROUND(((s.Value*1.0/NULLIF(s.Denominator,0))*100), 2) AS decimal)) +'%'
		 WHEN s.Type = 3 AND S.vALUE IS NULL THEN NULL
		 WHEN s.Type = 2 THEN s.Text
		 WHEN s.Type = 9 THEN CONVERT(VARCHAR, s.Value)
	     ELSE V.Answer END as [Answer],
	CAST(time_visited as time) as [VisitStartTime],
	CAST(time_visit_ended as time) as [VisitEndTime],
	s.QNumber,
	CAST(
	CASE 
		WHEN s.Type = 3 THEN 
			CASE 
				WHEN s.Value*1.0/NULLIF(s.Denominator,0) < 0.5 THEN -2 * (0.5 - s.Value*1.0/NULLIF(s.Denominator,0)) 
				ELSE 2 * (s.Value*1.0/NULLIF(s.Denominator,0) - 0.5)
			END
		ELSE sc.Score
	END
	AS decimal(6,4)) as [Scoring],
	w.Weight as [QuestionWeighting]
	,sc.rag
	  

FROM 
	[7a1ausrvsql0003.cymru.nhs.uk].[Safe_Clean_Care_Dashboard].[dbo].[SafeCleanCare_Master_X] s
	LEFT JOIN
	[7a1ausrvsql0003.cymru.nhs.uk].[Safe_Clean_Care_Dashboard].[dbo].[Safe_Clean_Care_Dashboard_Values] v
	ON
	s.Type=V.Type and s.Value=v.Value
	JOIN
	[7a1ausrvsql0003.cymru.nhs.uk].[Safe_Clean_Care_Dashboard].[dbo].[Safe_Clean_Dashboard] sa
	ON
	sa.scdid=s.scdid
	LEFT JOIN
	[7a1ausrvsql0003.cymru.nhs.uk].[Safe_Clean_Care_Dashboard].[dbo].[Safe_Clean_Care_Scoring] sc
	ON
	s.QNumber=sc.Qnumber and 
	CASE WHEN s.Type = 3 THEN CONVERT(VARCHAR, s.Value*1.0/NULLIF(s.Denominator,0))
		 WHEN s.Type = 2 THEN s.Text
		 WHEN s.Type = 9 THEN CONVERT(VARCHAR, s.Value)
	     ELSE V.Answer END = sc.Answer
	LEFT JOIN
	[7a1ausrvsql0003.cymru.nhs.uk].[Safe_Clean_Care_Dashboard].[dbo].[MatronQuestionWeighting] w
	ON
	s.Qnumber=w.QuestionNumber





END
GO
