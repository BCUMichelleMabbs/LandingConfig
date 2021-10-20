SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPPims]
AS
BEGIN
SET NOCOUNT ON;

SELECT DISTINCT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) as CodeName, (p.Name  +' - '+ p.MainCode) as NameCode, r.Active, p.CHKS, P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded 

FROM (

	SELECT DISTINCT
		CASE WHEN hcp1.prtyp_Refno = 4054 then ISNULL(pci.identifier,HCP1.Main_ident) else identifier END AS LocalCode,
		(
			SELECT TOP 1 
				LTRIM(ISNULL(LTRIM(RTRIM(FORENAME)),'')+' '+ISNULL(LTRIM(RTRIM(SURNAME)),''))
			FROM 
				[7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].PROF_CARERS HCP2
			WHERE 
				HCP2.MAIN_IDENT=HCP1.MAIN_IDENT
			ORDER BY
				ISNULL(HCP2.END_DTTM,GETDATE()) DESC
		) AS LocalName,
		'Pims' AS Source,
		'West' as Area,
		CASE 
		WHEN hcp1.end_dttm is null then 'Y'
		WHEN (hcp1.end_Dttm is not null and DATENAME(year,getdate()) = DATENAME(year,hcp1.end_Dttm)) then 'Y'
		ELSE 'N'
		END 
		as Active,
HCP1.Main_ident as LocalNationalCode,
cast(hcp1.end_Dttm  as date) as DateHCPEnded
	FROM 
		[7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].PROF_CARERS HCP1
		left join [7A1AUSRVIPMSQLR\REPORTS].[iPMREPORTS].[dbo].prof_Carer_ids pci on pci.proca_Refno = hcp1.proca_Refno and pci.cityp_Refno = 200921 and ISNULL(pci.Archv_Flag,'N') = 'N'

		WHERE
		HCP1.MAIN_IDENT IS NOT NULL
		and not LTRIM(ISNULL(LTRIM(RTRIM(FORENAME)),'')+' '+ISNULL(LTRIM(RTRIM(SURNAME)),'')) in ('Gerald Vincent Murphy','Thomas Windsor-Lewis', 'A Ross')
		and pci.identifier is not null
		and CASE WHEN main_ident like 'C%' and IDENTIFIER is null THEN main_ident ELSE IDENTIFIER END is not null
		and not (case when main_ident like 'C%' and IDENTIFIER is null then main_ident else IDENTIFIER end  in ('G8345127', '    -    -') )
		and pci.identifier <> '    -    -'

		) R
LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON ltrim(rtrim(upper(R.LocalCode)))=ltrim(rtrim(upper(PM.LocalCode))) AND upper(R.Source)=upper(PM.Source)
LEFT JOIN Mapping.dbo.Common_HCP P ON PM.MainCode=P.MainCode

--where r.LocalCode = 'AR8'

order by MainCode

end

/*
NOTES
Mapping.dbo.Common_HCP_Map - this table is used to map local codes to nationalcodes and is manually updated
Mapping.dbo.Common_HCP - this table is fed from national look ups found on NRDS and ODS
Capacity Planning Flag is manually entered, Karyn Donnally provided the initial list - May 2020





*/
GO
