SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPMyrddin]
AS
BEGIN	
SET NOCOUNT ON;
 
SELECT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) as CodeName, (p.Name  +' - '+ p.MainCode) as NameCode, r.Active, p.CHKS, P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded FROM (

	SELECT * FROM OPENQUERY(WPAS_EAST_SECONDARY,'
		SELECT DISTINCT
			ltrim(rtrim(HCP1.Practice)) AS LocalCode,
			(
				SELECT FIRST 1 
					GP_NAME AS LocalName 
				FROM 
					GP2 HCP2 
				WHERE 
					HCP2.GP_CODE=HCP1.GP_CODE
				ORDER BY
					CASE 
						WHEN HCP2.E_DATE>HCP2.SYNC_DATE THEN E_DATE
						WHEN HCP2.E_DATE<=HCP2.SYNC_DATE THEN SYNC_DATE
					END DESC
			) AS LocalName,
			''Myrddin'' AS Source,
			''East'' as Area,


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
				case when E_Date = ''2999-12-31'' then null
				else cast(E_Date as date)
				end as DateHCPEnded
				 


		FROM
			GP2 HCP1
		WHERE
			HCP1.GP_CODE IS NOT NULL
			and HCP1.Practice IS NOT NULL
			and Record_Type = ''C''
			and not (HCP1.GP_Code = ''X95'' and GP_Name = ''Ms J Carter'')
			and not (HCP1.GP_Code = ''xx'' and GP_Name = ''Use Jb Instead'')
			--and HCP1.Practice  = ''LJ1''

	')


	) R
LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON ltrim(rtrim(upper(R.LocalCode)))=ltrim(rtrim(upper(PM.LocalCode))) AND rtrim(upper(R.Source))=rtrim(upper(PM.Source))
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
