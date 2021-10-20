SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_Contact]
	
AS
BEGIN

SET NOCOUNT ON;

SELECT DISTINCT
	NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER(LEFT([con_forenames],1))+LOWER(SUBSTRING([con_forenames],2,LEN([con_forenames]))), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [Forename]
	,NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER(LEFT([con_surname],1))+LOWER(SUBSTRING([con_surname],2,LEN([con_surname]))), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [Surname]
	,NULLIF([con_type],'') as [Type]
	,NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER([con_number]), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [CRN]
	,NULLIF([con_subtype],'') as [SubType]
	,NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER([con_nhsno]), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [NHSNo]
	,m.inc_ourref as [BCURefId]
	,'Datix' as [Source]
	,NULLIF(LEFT(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(m.inc_notes))),CHAR(13),''), CHAR(10),''),8000), '') as [Notes]
	,'Incident' as [SubSource]
	,NULLIF(LTRIM(RTRIM(inc_name)),'') as [ComplainantName]
	,NULLIF(inc_organisation,'') as [Area]

FROM [7a1ausrvdtxsql2].[datixcrm].[dbo].incidents_main m 
	LEFT JOIN [7a1ausrvdtxsql2].[datixcrm].[dbo].[link_contacts] lc on m.recordid = lc.inc_id
	LEFT JOIN [7a1ausrvdtxsql2].[datixcrm].[dbo].[contacts_main] cm on lc.con_id = cm.recordid

WHERE inc_ourref <> ''
	and inc_ourref is not null

UNION 

SELECT DISTINCT
	NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER(LEFT([con_forenames],1))+LOWER(SUBSTRING([con_forenames],2,LEN([con_forenames]))), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [Forename]
	,NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER(LEFT([con_surname],1))+LOWER(SUBSTRING([con_surname],2,LEN([con_surname]))), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [Surname]
	,NULLIF([con_type],'') as [Type]
	,NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER([con_number]), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [CRN]
	,NULLIF([con_subtype],'') as [SubType]
	,NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(UPPER([con_nhsno]), CHAR(9), ''), CHAR(13), ''), CHAR(10), ''))),'') as [NHSNo]
	,m.com_ourref as [BCURefId]
	,'Datix' as [Source]
	,NULLIF(LEFT(REPLACE(REPLACE(CONVERT(VARCHAR(8000),LTRIM(RTRIM(m.com_detail))),CHAR(13),''), CHAR(10),''),8000), '') as [Notes]
	,'Concern' as [SubSource]
	,NULLIF(LTRIM(RTRIM(com_name)),'') as [ComplainantName]
	,NULLIF(com_organisation,'') as [Area]

FROM [7a1ausrvdtxsql2].[datixcrm].[dbo].compl_main m 
	LEFT JOIN [7a1ausrvdtxsql2].[datixcrm].[dbo].[link_contacts] lc on m.recordid = lc.com_id
	LEFT JOIN [7a1ausrvdtxsql2].[datixcrm].[dbo].[contacts_main] cm on lc.con_id = cm.recordid

WHERE com_ourref <> ''
	and com_ourref is not null

END
GO
