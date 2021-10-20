SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Eform_Ref_Questions]
	
AS
BEGIN
	
SELECT DISTINCT 
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([Q_Set_Id], CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) as [Q_Set_Id],
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([Q_Set_Topic], CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) as [Q_Set_Topic],
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([Q_Set_Question_Number], CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) as [Q_Set_Question_Number],
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([Q_Set_Question_Text], CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) as [Q_Set_Question_Text],
	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([Q_Set_Audit_Type], CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' '))) as [Q_Set_Audit_Type]

FROM 
	[SSIS_Loading].[EFORMS].[dbo].[X_WA_QuestionSetBuilder]

End
GO
