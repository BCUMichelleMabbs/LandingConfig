SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPWPAS]
AS
BEGIN
SET NOCOUNT ON;

SELECT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) as CodeName, (p.Name  +' - '+ p.MainCode) as NameCode, r.Active, p.CHKS, P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded FROM (

	SELECT * FROM OPENQUERY(WPAS_Central,'
		SELECT DISTINCT
			ltrim(rtrim(HCP1.Practice)) AS LocalCode,
			GP_NAME AS LocalName ,
			--(
			--	SELECT FIRST 1 
			--		GP_NAME AS LocalName 
			--	FROM 
			--		GP2 HCP2 
			--	WHERE 
			--		HCP2.GP_CODE=HCP1.GP_CODE
			--	ORDER BY
			--		CASE 
			--			WHEN HCP2.E_DATE>HCP2.SYNC_DATE THEN E_DATE
			--			WHEN HCP2.E_DATE<=HCP2.SYNC_DATE THEN SYNC_DATE
			--		END DESC
			--) AS LocalName,
			''WPAS'' AS Source,
			''Central'' as Area,


			Case When 
					(
				SELECT FIRST 1 
					E_Date AS EndDate 
				FROM 
					GP2 HCP2 
				WHERE 
					HCP2.GP_CODE=HCP1.GP_CODE
				ORDER BY
					CASE 
						WHEN HCP2.E_DATE>HCP2.SYNC_DATE THEN E_DATE
						WHEN HCP2.E_DATE<=HCP2.SYNC_DATE THEN SYNC_DATE
					END DESC
					) = ''2999-12-31'' then ''Y''

			when 	(
				SELECT FIRST 1 
					E_Date AS EndDate 
				FROM 
					GP2 HCP2 
				WHERE 
					HCP2.GP_CODE=HCP1.GP_CODE
				ORDER BY
					CASE 
						WHEN HCP2.E_DATE>HCP2.SYNC_DATE THEN E_DATE
						WHEN HCP2.E_DATE<=HCP2.SYNC_DATE THEN SYNC_DATE
					END DESC
					) > dateadd(YEAR, -1, current_timestamp) then ''Y''

					else ''N'' end 
			 AS Active,
				 ltrim(rtrim(HCP1.GP_Code)) as LocalNationalCode,
				 

				 case when HCP1.E_Date = ''2999-12-31'' then null
				else cast(HCP1.E_Date as date)
				end as DateHCPEnded
		FROM
			GP2 HCP1
		WHERE

			HCP1.GP_CODE IS NOT NULL
			and HCP1.Practice IS NOT NULL
			and Record_Type = ''C''

	')

	Union Select  'C00I7141' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C02C0217' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C08B0105' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C13F1544' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C6160004' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C771581' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C83L0366' as localcode, null as localname,  'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C8410046' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'C94C008E' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CN900004' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'COT50727' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'COT59313' as localcode, null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'COT68114' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'COT73756' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPH31503' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPH32999' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPH44945' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPYL0299' as localcode, null as localname, 'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPYL2162' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPYL3486' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CSW04989' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CSW10716' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CW/11070' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CW/50041' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CPH34142' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CSW73295' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'CSW81370' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	
	union	Select  'C9999981' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G1111111' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G6043130' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G6061428' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G6996301' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G9307384' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G6996631' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G6996741' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G7777777' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G8834820' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G9546424' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G999990' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded
	union	Select  'G9999997' as localcode,  null as localname,'WPAS' as Source, 'Central' as Area, 'N' as Active, null as LocalNationalCode, null as DateEpisodeEnded


)R 


LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON ltrim(rtrim(upper(R.LocalCode)))=ltrim(rtrim(upper(PM.LocalCode))) AND ltrim(rtrim(upper(R.Source)))=ltrim(rtrim(upper(PM.Source)))
LEFT JOIN Mapping.dbo.Common_HCP P ON ltrim(rtrim(upper(PM.MainCode)))=ltrim(rtrim(upper(P.MainCode)))

order by MainCode

END



/*
NOTES
Mapping.dbo.Common_HCP_Map - this table is used to map local codes to nationalcodes and is manually updated
Mapping.dbo.Common_HCP - this table is fed from national look ups found on NRDS and ODS
Capacity Planning Flag is manually entered, Karyn Donnally provided the initial list - May 2020





*/
GO
