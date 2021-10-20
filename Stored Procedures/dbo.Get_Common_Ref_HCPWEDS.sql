SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPWEDS]
	
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT DISTINCT
	HCP.MainCode,
	HCP.Name,
	R.LocalCode,
	R.LocalName,
	'WEDS',
	'West',
	HCP.Email, 
	HCP.Nadex, 
	HCP.PractitionerType, 
	(HCP.MainCode +' - '+ HCP.Name) as CodeName, 
	(HCP.Name  +' - '+ HCP.MainCode) as NameCode,
	R.Active,
	HCP.CHKS, 
	HCP.CapacityPlanning, 
	R.LocalNationalCode,
	HCP.specialtycode,
	null as DateHCPEnded
FROM
	(
		SELECT DISTINCT
			CAST(stf_staffid AS VARCHAR(12)) AS LocalCode,
			RTRIM(stf_forename)+' '+RTRIM(stf_surname) AS LocalName,
			'Y' as Active,
			ROW_NUMBER() OVER (Partition By CAST(stf_staffid AS VARCHAR(12)) Order By stf_startdate desc) as [RN],
			null as LocalNationalCode

		FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Staff S

	UNION

		SELECT DISTINCT
			CASE gp_code WHEN 'G9999998' THEN CAST(gp_id AS VARCHAR(10)) 	ELSE gp_code END AS LocalCode,
			RTRIM(gp_surname)+' '+RTRIM(gp_initials) AS LocalName,
			'Y' as Active,
			ROW_NUMBER() OVER (Partition By CASE gp_code WHEN 'G9999998' THEN CAST(gp_id AS VARCHAR(10)) 	ELSE gp_code END Order By gp_startdate desc) as [RN],
			CASE gp_code WHEN 'G9999998' THEN CAST(gp_id AS VARCHAR(10)) 	ELSE gp_code END as LocalNationalCode

		FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Gp

		WHERE NULLIF(RTRIM(gp_code),'') IS NOT NULL

)R 
	LEFT JOIN Mapping.dbo.Common_HCP_Map HCPM ON R.LocalCode=HCPM.LocalCode AND HCPM.Source='WEDS' AND HCPM.Area='West'
	LEFT JOIN Mapping.dbo.Common_HCP HCP ON HCPM.MainCode=HCP.MainCode

WHERE RN = 1
--and hcp.MainCode is null
ORDER BY MainCode

END
GO
