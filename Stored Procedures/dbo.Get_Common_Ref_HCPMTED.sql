SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPMTED]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) as CodeName, (p.Name  +' - '+ p.MainCode) as NameCode, r.Active, p.CHKS , P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded FROM (
SELECT DISTINCT 
	upper(HCP1.ConsultantCode) AS LocalCode,
	(
		SELECT TOP 1 
			HCP1.ConsultantSurname AS LocalName
		FROM
			[SSIS_Loading].[MTED].[dbo].[DAL] HCP2
		WHERE
			HCP2.ConsultantCode=HCP1.ConsultantCode
	) AS LocalName,			
	'MTED' AS Source,
	'BCU' as Area,
	'Y' as Active,
	null as LocalNationalCode,
	null as DateHCPEnded
FROM 
	[SSIS_Loading].[MTED].[dbo].[DAL] HCP1

WHERE 
	HCP1.ConsultantCode IS NOT NULL and HCP1.ConsultantCode <> ''
	and not (HCP1.ConsultantCode ='AB' and HCP1.ConsultantSurname = 'Baker')
	and not (HCP1.ConsultantCode ='AOK' and HCP1.ConsultantSurname = 'Kelly')
	and not (HCP1.ConsultantCode ='ARA' and HCP1.ConsultantSurname = 'Azzu')
	--NULLIF(RTRIM(HCP1.ConsultantCode),'') IS NOT NULL

) R


	LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON rtrim(r.LocalCode)=rtrim(PM.LocalCode) AND R.Source=PM.Source
	LEFT JOIN Mapping.dbo.Common_HCP P ON rtrim(PM.MainCode)=rtrim(P.MainCode)




order by MainCode, LocalCode
END
GO
