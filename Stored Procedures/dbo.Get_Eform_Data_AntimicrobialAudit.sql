SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Eform_Data_AntimicrobialAudit]

AS

BEGIN

SELECT [AuditNumber]
      ,[PatientNumber]
      ,[DateOfSubmission]
      ,[Area]
      ,[Site]
      ,[Ward]
      ,[Auditor]
      ,[AuditorProfession]
      ,[AuditorBleep]
      ,[ConsultantTeamInitials]
      ,[CircumstancesPrescription]
      ,[InputNadex]
      ,[InputName]
      ,[DateSaved]
      ,[Score]
      ,[Measures] as [Measure]
  FROM [SSIS_LOADING].[EFORMS].[dbo].[Antimicrobial_Audit]

END
GO
