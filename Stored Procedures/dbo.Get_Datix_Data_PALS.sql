SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[Get_Datix_Data_PALS] AS BEGIN 

SELECT DISTINCT [recordid]
      ,[updateid]
      ,[updateddate]
      ,NULLIF([updatedby],'') AS [updatedby]
      ,NULLIF([pal_name],'') AS [pal_name]
      ,NULLIF([pal_handler],'') AS [pal_handler]
      ,NULLIF([pal_method],'') AS [pal_method]
      ,NULLIF(CONVERT(date,[pal_dreceived]) ,'') AS [pal_dreceived]
      ,NULLIF(CONVERT(date,[pal_dclosed]),'') AS [pal_dclosed]
      ,NULLIF([pal_unit],'') AS [pal_unit]
      ,NULLIF([pal_type],'') AS [pal_type]
      ,NULLIF([pal_outcomecode],'') AS [pal_outcomecode]
      ,NULLIF([pal_organisation],'') AS [pal_organisation]
      ,NULLIF([pal_timecode],'') AS [pal_timecode]
      ,NULLIF([pal_ourref],'') AS [pal_ourref]
      ,NULLIF([pal_whereheard],'') AS [pal_whereheard]
      ,NULLIF([pal_investigator],'') AS [pal_investigator]
      ,NULLIF([pal_inv_dstart],'') AS [pal_inv_dstart]
      ,NULLIF([pal_inv_dcomp],'') AS [pal_inv_dcomp]
      ,NULLIF([pal_inv_outcome],'') AS [pal_inv_outcome]
      ,NULLIF([pal_action_code],'') AS [pal_action_code]
      ,NULLIF([pal_lessons_code],'') AS [pal_lessons_code]
      ,NULLIF([pal_locactual],'') AS [pal_locactual]
      ,NULLIF([pal_directorate],'') AS [pal_directorate]
      ,NULLIF([pal_specialty],'') AS [pal_specialty]
      ,NULLIF([rep_approved],'') AS [rep_approved]
      ,NULLIF([createdby],'') AS [createdby]
      ,NULLIF([PAL_SYNOPSIS],'') AS [PAL_SYNOPSIS]
      ,NULLIF([PAL_OUTCOME],'') AS [PAL_OUTCOME]
      ,NULLIF([pal_inv_action],'') AS [pal_inv_action]
      ,NULLIF([pal_inv_lessons],'') AS [pal_inv_lessons]
      ,NULLIF([pal_last_updated],'') AS [pal_last_updated]
  FROM [7a1ausrvdtxsql2].[datixcrm].[dbo].[pals_main]

  END
GO
