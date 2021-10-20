SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPRadis]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) as CodeName, (p.Name  +' - '+ p.MainCode) as NameCode, r.Active, P.CHKS, P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded FROM (

SELECT DISTINCT 

ltrim(rtrim(Code)) as LocalCode,
Title + ' ' + Initials + ' ' + Surname as LocalName,
--'' as localname,
'Radis' as Source,
'Central' as Area,
case when Active = '0' then 'N'
else 'Y' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
from [RADIS_CENTRAL].Radis.dbo.Clinician
where code is not null
and code <> ''

union

SELECT DISTINCT 

ltrim(rtrim(Code)) as LocalCode,
Title + ' ' + Initials + ' ' + Surname as LocalName,
--'' as LocalName,
'Radis' as Source,
'East' as Area,
case when Active = '0' then 'N'
else 'Y' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
from [RADIS_EAST].Radis.dbo.Clinician
where code is not null
and code <> ''


union

SELECT DISTINCT 

ltrim(rtrim(Code)) as LocalCode,
Title + ' ' + Initials + ' ' + Surname as LocalName,
--'' as LocalName,
'Radis' as Source,
'West' as Area,
case when Active = '0' then 'N'
else 'Y' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
from [RADIS_West].Radis.dbo.Clinician
where code is not null
and code <> ''


) R

LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON R.LocalCode=ltrim(rtrim(PM.LocalCode))  collate Latin1_General_CI_AS AND R.Source=PM.Source and r.area=pm.area collate Latin1_General_CI_AS
LEFT JOIN Mapping.dbo.Common_HCP P ON PM.MainCode=P.MainCode collate Latin1_General_CI_AS

--where r.LocalCode = 'FM1'

order by MainCode
END
GO
