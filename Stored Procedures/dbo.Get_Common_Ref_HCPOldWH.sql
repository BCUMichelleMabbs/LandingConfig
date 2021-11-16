SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Common_Ref_HCPOldWH]
AS
BEGIN
SET NOCOUNT ON;

SELECT P.MainCode,P.Name,R.LocalCode,R.LocalName,R.Source,r.Area,p.Email, p.nadex, p.PractitionerType, (p.MainCode +' - '+ p.Name) AS CodeName, (p.Name  +' - '+ p.MainCode) AS NameCode, r.Active, p.CHKS, P.CapacityPlanning, r.LocalNationalCode, p.SpecialtyCode, r.DateHCPEnded FROM (



	Select DISTINCT
		EDClinicianSeen AS LocalCode,
		NULL AS LocalName,
		'OldWH' AS Source,
		area AS area,
		'N' AS Active,
		NULL AS LocalNationalCode,
		'18 November 2016' as DateHCPEnded

	
	FROM [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] ed
	WHERE SOURCE = 'OldWH'
	--WHERE ed.source NOT IN ('Symphony', 'WPAS', 'PIMS', 'weds')
	AND ed.EDClinicianSeen IS NOT null




)R 


LEFT JOIN Mapping.dbo.Common_HCP_Map PM ON LTRIM(RTRIM(UPPER(R.LocalCode)))=LTRIM(RTRIM(UPPER(PM.LocalCode))) AND LTRIM(RTRIM(UPPER(R.Source)))=LTRIM(RTRIM(UPPER(PM.Source)))
LEFT JOIN Mapping.dbo.Common_HCP P ON LTRIM(RTRIM(UPPER(PM.MainCode)))=LTRIM(RTRIM(UPPER(P.MainCode)))

ORDER BY MainCode

END



/*
NOTES
Mapping.dbo.Common_HCP_Map - this table is used to map local codes to nationalcodes and is manually updated
Mapping.dbo.Common_HCP - this table is fed from national look ups found on NRDS and ODS
Capacity Planning Flag is manually entered, Karyn Donnally provided the initial list - May 2020





*/
GO
