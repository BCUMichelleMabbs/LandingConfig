SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_OtherInformation]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(50),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(max),
	LocalName		VARCHAR(100),
	Source			VARCHAR(10),
	Area			varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		trim(CAST(SUBSTRING(OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000))) AS LocalCode,
		null AS LocalName,
		''WPAS'' AS Source,
		''Central''  as Area
	 FROM 
		treatmnt
		where trt_date >= ''01 April 2019''
		and other_Info is not null
		and other_Info <> ''''
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		trim(CAST(SUBSTRING(OTHER_INFO FROM 1 FOR 8000) AS VARCHAR(8000))) AS LocalCode,
		null AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		treatmnt
		where trt_date >= ''01 April 2019''
		and other_Info is not null
		and other_Info <> ''''
	')

--;with cte as (
--	select distinct 
--		sps.code as LocalCode
--		,CASE WHEN sps.code like 'C-%' then sps.code else sps.DESCRIPTION END as LocalName
--		,'PiMS' as Source
--		,'West' as Area
--		,Row_Number() over(Partition by sps.code order by sps.create_dttm desc) RN
--	from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].SERVICE_POINT_SESSIONS sps
--		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].SERVICE_POINTs sp
--		on sp.SPONT_REFNO = sps.SPONT_REFNO 
--		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].Specialties spec
--		on spec.SPECT_REFNO = sps.SPECT_REFNO 
--		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].prof_Carers pro
--		on pro.PROCA_REFNO = sp.PROCA_REFNO 
--	where ISNULL(sps.archv_flag,'N') = 'N'
--		and sps.template_flag = 'Y'
--) 
--INSERT INTO @Results (LocalCode,LocalName,Source, Area)	
--select LocalCode,LocalName,Source , Area
--from cte where RN = 1


UPDATE @Results SET LocalCode = ltrim(rtrim(REPLACE(REPLACE(REPLACE(LocalCode, CHAR(9), ''), CHAR(10), ''), CHAR(13), '')))



	UPDATE @Results SET MainCode =
	case 

	when LocalCode like '%This referral was created %' then 'SYS'
	when LocalCode like '%DNA / Deferral%' then 'SYS'
	when LocalCode like '% DNA%' then 'SYS'
	when LocalCode like '%DNA %' then 'SYS'
	when LocalCode like '%DNA-%' then 'SYS'
	when LocalCode like '% CNA%' then 'SYS'
	when LocalCode like '%CNA %' then 'SYS'
	when LocalCode like '%Dummy%' then 'SYS'

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
	when LocalCode like 'SOS %' then 'SOS'

	--Discharged
	when LocalCode like '%Disch%' then 'DISCH'
	when LocalCode like '%No Longer req%' then 'DISCH'
	when LocalCode like '%Moved Area%' then 'DISCH'
	when LocalCode like '%Back to%' then 'DISCH'
	when LocalCode like '%Declined Treatment%' then 'DISCH'
	when LocalCode like '%No Further%' then 'DISCH'

	--MDT
	when LocalCode like '%MDT%' then 'MDT'

	
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

	--Omas
	
	when LocalCode like '%ECG%' then 'CARD'
	when LocalCode like '%Echo%' then 'CARD'
	when LocalCode like '%Holter%' then 'CARD'
	when LocalCode like '%Pacing%' then 'CARD'
	when LocalCode like '%PulseOx%' then 'CARD'
	when LocalCode like '%Pulse Ox%' then 'CARD'

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
	when LocalCode like '%Glauc%' then 'Glauc'

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
	when LocalCode like '%VALIDA%' then 'VAL'

	
	
	
	--Blank
	--when LocalCode is null then null
	--when rtrim(LocalCode) = '' then null
	
			
			

	else null
	end 

	UPDATE @Results SET
	--R.MainCode = S.MainCode,
	R.Name = S.Name
FROM
	@Results R
	--INNER JOIN Mapping.dbo.PAS_Session_Map SM ON R.LocalCode=SM.LocalCode AND R.Source=SM.Source
	INNER JOIN Mapping.dbo.PAS_OtherInformation S ON RTRIM(r.MainCode)=rtrim(S.MainCode)


SELECT distinct * FROM @Results
--where MainCode is null
where maincode is not null -- don't need to store data that isn't used in a mapping

order by LocalCode
END
GO
