SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_PAS_Ref_Comments]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(20),
	Name			VARCHAR(200),
	NewCode			VARCHAR(20),
	LocalCode		VARCHAR(500),
	Source			VARCHAR(8),
	Area				varchar(10)
)

INSERT INTO @Results(NewCode,LocalCode,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		'''' AS NewCode,
		FTEXT AS LocalCode,
		''WPAS'' AS Source,
		''Central'' as area
	 FROM 
		REFER
	')

/*
INSERT INTO @Results(NewCode,LocalCode,Source, area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		'''' AS NewCode,
		FTEXT AS LocalCode,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		REFER
	')
*/
/*
INSERT INTO @Results(LocalCode,LocalName,Source, area)	
SELECT 
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source,
	'West' as area
FROM 
	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='ADMET'
*/


UPDATE @Results SET NewCode =
Case	
	
	--Type Of Appointment

	--System Generated
	when LocalCode like '%This referral was created %' then 'SYS'
	when LocalCode like '%DNA / Deferral%' then 'SYS'
	when LocalCode like '% DNA%' then 'SYS'
	when LocalCode like '%DNA %' then 'SYS'
	when LocalCode like '% CNA%' then 'SYS'
	when LocalCode like '%CNA %' then 'SYS'

	--System Generated
	when LocalCode like '% MOP%' then 'MOP'
	when LocalCode like '%MOP %' then 'MOP'
	when LocalCode like 'MOP%' then 'MOP'
	when LocalCode like '%Minor O%' then 'MOP'

	--Repeats and Checks
	when LocalCode like '%RPT%' then 'RPT'
	when LocalCode like '%REPEAT%' then 'RPT'
	when LocalCode like '%CHECK CY%' then 'CHK'
	when LocalCode like '%CHECK CO%' then 'CHK'
	when LocalCode like '%CHECK FL%' then 'CHK'
	when LocalCode like 'CHECK [0-9]%' then 'CHK'

	--Seen on symptoms
	when LocalCode like '% SOS %' then 'SOS'

	--Orthopaedics
	
	when LocalCode like '%TKR%' then 'TKR'
	when LocalCode like '%THR %' then 'THR'
	when LocalCode like '%Knee replacement%' then 'TKR'
	when LocalCode like '%hip replacement%' then 'THR'
	when LocalCode like '%Inj%' then 'INJ'
	when LocalCode like '%CTD%' then 'CTD'
	when LocalCode like '%Carpel%' then 'CTD'
	when LocalCode like '%Carpal%' then 'CTD'

	--ENT
	when LocalCode like '%ADENOI%' then 'TONS'
	when LocalCode like '%TONSIL%' then 'TONS'
	when LocalCode like '%GROMM%' then 'TONS'

	--Oscopies
	when LocalCode like '%Arthroscop%' then 'ARTH'
	when LocalCode like '%Arthoscop%' then 'ARTH'
	when LocalCode like '%BRONC%' then 'BRONC'
	when LocalCode like '%COLO %' then 'COLO'
	when LocalCode like '%COLON %' then 'COLO'
	when LocalCode like '% COLON%' then 'COLO'
	when LocalCode like '%COLONOSCOPY%' then 'COLO'
	when LocalCode like '% COLP%' and (LocalCode not like '%APHY%') then 'COLP'
	when LocalCode like '%COLPOS%' then 'COLP'
	when LocalCode like '%CYSTOS%' then 'CYST'
	when LocalCode like '% CYSTO %' then 'CYST'
	when LocalCode like '%FCC%' then 'CYST'
	when LocalCode like '%Esophago%' then 'ESO'
	when LocalCode like '%Gastros%' then 'GAST'
	when LocalCode like '%OGD%' then 'GAST'
	when LocalCode like '%Hysteros%' then 'HYSOSC'
	when LocalCode like 'LAP%' then 'LAP'
	when LocalCode like '% LAP%' then 'LAP'
	when LocalCode like '%(LAP%' then 'LAP'
	when LocalCode like '%LAPAROS%' then 'LAP'
	when LocalCode like '%LARYNG%' then 'LAR'
	when LocalCode like '%NEUROENDO%' then 'NEUR'
	when LocalCode like '%PROCTOS%' then 'PROC'
	when LocalCode like '% SIG %' then 'SIGM'
	when LocalCode like '%SIGMOID%' then 'SIGM'
	when LocalCode like '%THORACO%' then 'THOR'
	when LocalCode like '%URETERO%' then 'URET'
	when LocalCode like '%URETHRO%' then 'URET'
	when LocalCode like '% URS %' then 'URET'
	when LocalCode like '%ENDOSC%' then 'ENDO'
	when LocalCode like '%ENDO%' and (LocalCode not like '%Ref%' AND LocalCode not like '%endom%'AND LocalCode not like '%endoV%'AND LocalCode not like '%endon%'AND LocalCode not like '%endoc%' AND LocalCode not like '%endol%') then 'ENDO'
	when LocalCode like '%Scopy%' then 'SCOP'

	--tomys
	when LocalCode like '%tomy%' then 'TOMY'
	
	
	--Omas
	when LocalCode like '%oma %' then 'OMA'
	when LocalCode like '%oma,%' then 'OMA'
	when LocalCode like '%oma.%' then 'OMA'
	when LocalCode like '%oma/%' then 'OMA'

	--Plastys
	when LocalCode like '%plasty%' then 'PLASTY'

	--Eyes
	when LocalCode like '%CATARACT%' then 'CAT'
	when LocalCode like '% CAT %' and (LocalCode not like '%HV%' and LocalCode not like '%H.V%' and LocalCode not like '%H/V%' and LocalCode not like '%Flying Start%') then 'CAT'
	when LocalCode like '%PHACO%' then 'PHACO'
	when LocalCode like '%Field%' then 'FIELD'

	--Biopsies
	when LocalCode like '%BIOPS%' then 'BIOP'
	when LocalCode like '%BIOSP%' then 'BIOP'
	when LocalCode like '%BX%' then 'BIOP' 
	
	
	--Removals	
	when LocalCode like 'rem metal %' then 'REM'
	when LocalCode like 'rem of m %' then 'REM'
	when LocalCode like '%metalwork%' then 'REM'
	when LocalCode like '%metal work%' then 'REM'
	

	--Other
	when LocalCode like '%TURP%' then 'TURP'
	when LocalCode like '%TURBT%' then 'TURBT'
	when LocalCode like '%HERN%' then 'HERN'
	when LocalCode like '%CHEMO%' then 'CHEMO'
	when LocalCode like '%CHALLENGE%' then 'CHAL'
	when LocalCode like '%ESWL%' then 'ESWL'
	when LocalCode like '%CIRCUM%' then 'CIRC'
	when LocalCode like '%COPD%' then 'COPD'
	when LocalCode like '%STRIP%' then 'VEIN'
	when LocalCode like '%VEIN%' then 'VEIN'
	when LocalCode like '%VV%' then 'VEIN'
	when LocalCode like '%Excision%' then 'EXCI'
	
	

	
	--Admin Notes
	when LocalCode like '%InvWizard%' then 'PART'
	when LocalCode like 'PB%' then 'PART'
	when LocalCode like '% PB%' then 'PART'
	when LocalCode like '%PB %' then 'PART'
	when LocalCode like '%VALI%' then 'VAL'

	
	
	
	--Blank
	when LocalCode is null then ''
	when LocalCode = '' then ''
	
	else 'OTH'
end




UPDATE @Results SET
	R.MainCode = c.MainCode,
	R.Name = c.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_Comments_Map CM ON rtrim(R.NewCode)=ltrim(rtrim(CM.LocalCode)) AND rtrim(R.Source)=rtriM(CM.Source) and r.Area = cm.Area
	INNER JOIN Mapping.dbo.PAS_Comments C ON ltrim(rtrim(CM.MainCode))=ltrim(rtrim(C.MainCode))
	
SELECT * FROM @Results
--where MainCode is not null
order by newcode, localcode
END


GO
