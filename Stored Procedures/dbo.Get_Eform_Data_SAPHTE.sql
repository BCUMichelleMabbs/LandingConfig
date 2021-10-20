SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Eform_Data_SAPHTE]

AS

BEGIN

SELECT 

EntryDate,
CAST(DateTimeEntered as DATETIME) as CreatedDateTime ,
Hospital,
Score,
Nadex,
CAST(ModifiedDateTime as DATETIME) as ModifiedDateTime,
ModifiedBy,
SiteId as SiteCode ,
null as SiteName,
Risk



  FROM [SSIS_LOADING].[EFORMS].[dbo].[SAPhTE] a
  --left join [SSIS_LOADING].[EFORMS].[dbo].[SAPHTEReferenceData] b on a.SiteId=b.site_ID

END
GO
