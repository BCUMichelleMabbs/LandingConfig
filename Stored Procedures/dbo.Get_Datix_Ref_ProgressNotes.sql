SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_ProgressNotes]
AS
BEGIN
SET NOCOUNT ON;

SELECT DISTINCT 
		NULLIF(n.recordid,'') AS [ProgressRecordID]
		,NULLIF(pno_link_id,'') AS [RecordID]
		,NULLIF(i.inc_ourref,'') AS [BCURefID]
		,CASE pno_link_module WHEN 'INC' THEN 'Incident' END AS [Dataset]
		,NULLIF(pno_createdby,'') AS [CreatedBy]
		,NULLIF(CAST(pno_createddate AS DATE ),'')AS [CreatedDate]
		,NULLIF(CAST(pno_createddate AS TIME ),'') AS [CreatedTime]
		,NULLIF(LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(pno_progress_notes))),CHAR(13),''), CHAR(10),''),CHAR(9),''),8000), '') AS [ProgressNotes]
		,NULLIF(LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(formatted_progress_notes))),CHAR(13),''), CHAR(10),''),CHAR(9),''),8000), '') AS [FormattedProgressNotes]
		,'Datix' as [Source]

FROM	[7a1ausrvdtxsql2].[datixcrm].[dbo].[progress_notes] n
		LEFT JOIN [7a1ausrvdtxsql2].[datixcrm].[dbo].incidents_main i ON n.pno_link_id = i.recordid

WHERE pno_link_module = 'INC'
		AND inc_ourref <> ''
		AND inc_ourref IS NOT NULL

UNION

SELECT DISTINCT 
		NULLIF(n.recordid,'') AS [ProgressRecordID]
		,NULLIF(pno_link_id,'') AS [RecordID]
		,NULLIF(c.com_ourref,'') AS [BCURefID]
		,CASE pno_link_module WHEN 'COM' THEN 'Concern' END AS [Dataset]
		,NULLIF(pno_createdby,'') AS [CreatedBy]
		,NULLIF(CAST(pno_createddate AS DATE ),'')AS [CreatedDate]
		,NULLIF(CAST(pno_createddate AS TIME ),'') AS [CreatedTime]
		,NULLIF(LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(pno_progress_notes))),CHAR(13),''), CHAR(10),''),CHAR(9),''),8000), '') AS [ProgressNotes]
		,NULLIF(LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(formatted_progress_notes))),CHAR(13),''), CHAR(10),''),CHAR(9),''),8000), '') AS [FormattedProgressNotes]
		,'Datix' as [Source]

FROM	[7a1ausrvdtxsql2].[datixcrm].[dbo].[progress_notes] n
		LEFT JOIN [7a1ausrvdtxsql2].[datixcrm].[dbo].compl_main c ON n.pno_link_id = c.recordid

WHERE pno_link_module = 'COM'
		AND com_ourref <> ''
		AND com_ourref IS NOT NULL

END
GO
