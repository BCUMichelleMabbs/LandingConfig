SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPTherapyManager]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) as CodeName, (p.Name  +' - '+ p.MainCode) as NameCode, r.Active, P.CHKS, P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded FROM (

SELECT DISTINCT 

'HR'+ cast(ID as varchar) as LocalCode,
NAME as LocalName,
'TherapyManager' as Source,
'Central' as Area,
case when discontinued = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
from [SQL4\SQL4].[physio].[dbo].[RESOURCES]
where Type ='Human Resource'

union

SELECT DISTINCT 

'RI' + cast(ID as varchar) as LocalCode,
NAME as LocalName,
'TherapyManager' as Source,
'Central' as Area,
case when discontinued = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
Null as DateHCPEnded
FROM [SQL4\SQL4].[physio].[dbo].[refferinginstance]


union

SELECT DISTINCT 

'UI' + cast(ID as varchar) as LocalCode,
Name as LocalName,
'TherapyManager' as Source,
'Central' as Area,
case when revoked = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
from [SQL4\SQL4].[physio].[dbo].[User_Information]

union

SELECT DISTINCT 

'HR'+ cast(ID as varchar) as LocalCode,
NAME as LocalName,
'TherapyManager' as Source,
'East' as Area,
case when discontinued = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
from [SQL4\SQL4].[physio].[dbo].[RESOURCES]
where Type ='Human Resource'

union

SELECT DISTINCT 

'RI' + cast(ID as varchar) as LocalCode,
NAME as LocalName,
'TherapyManager' as Source,
'East' as Area,
case when discontinued = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateHCPEnded
FROM [SQL4\SQL4].[physio].[dbo].[refferinginstance]


union

SELECT DISTINCT 

'UI' + cast(ID as varchar) as LocalCode,
Name as LocalName,
'TherapyManager' as Source,
'East' as Area,
case when revoked = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateEpisodeEnded
from [SQL4\SQL4].[physio].[dbo].[User_Information]

union


SELECT DISTINCT 

'HR'+ cast(ID as varchar) as LocalCode,
NAME as LocalName,
'TherapyManager' as Source,
'West' as Area,
case when discontinued = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateEpisodeEnded
from [SQL4\SQL4].[physio].[dbo].[RESOURCES]
where Type ='Human Resource'

union

SELECT DISTINCT 

'RI' + cast(ID as varchar) as LocalCode,
NAME as LocalName,
'TherapyManager' as Source,
'West' as Area,
case when discontinued = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateEpisodeEnded
FROM [SQL4\SQL4].[physio].[dbo].[refferinginstance]


union

SELECT DISTINCT 

'UI' + cast(ID as varchar) as LocalCode,
Name as LocalName,
'TherapyManager' as Source,
'West' as Area,
case when revoked = '0' then 'Y'
else 'N' 
end as Active,
null as LocalNationalCode,
null as DateEpisodeEnded
from [SQL4\SQL4].[physio].[dbo].[User_Information]


) R
LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON R.LocalCode=PM.LocalCode AND R.Source=PM.Source
LEFT JOIN Mapping.dbo.Common_HCP P ON PM.MainCode=P.MainCode

order by MainCode
END
GO
