SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_GPRefNo]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(15),
	Name			VARCHAR(300),
	NewCode			VARCHAR(15),
	LocalCode		VARCHAR(300),
	Source			VARCHAR(8),
	Area				varchar(10)
)

INSERT INTO @Results(NewCode,LocalCode,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		'''' AS NewCode,
		upper(GPREFNO) AS LocalCode,
		''WPAS'' AS Source,
		''Central'' as area
	 FROM 
		REFER
		where GPREFNo is not Null and GPREFNo <> ''''
	')


INSERT INTO @Results(NewCode,LocalCode,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		'''' AS NewCode,
		upper(GPREFNO) AS LocalCode,
		''Myrddin'' AS Source,
		''East'' as area
	 FROM 
		REFER
		where GPREFNo is not Null and GPREFNo <> ''''
	')

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
	
	--bowel screening wales
	when LocalCode like '%BSW%' then 'BSW'
	
	--Partial Booking Letters
	when LocalCode like '%PT B%' then 'PARTB'
	when LocalCode like 'B %' then 'PARTB'
	when LocalCode like 'B-%' then 'PARTB'
	when LocalCode like ' B %' then 'PARTB'
	when LocalCode like '% B' then 'PARTB'
	when LocalCode like '%PB%' then 'PARTB'
	when LocalCode like 'PT%' then 'PARTB'
	when LocalCode like '%PTB%' then 'PARTB'
	when LocalCode like 'PTR B%' then 'PARTB'
	when LocalCode like 'PTRB%' then 'PARTB'
	when LocalCode like 'PT BG%' then 'PARTB'
	when isdate (LocalCode) = 1 then 'PARTB'
	when LocalCode like '%/%' and LocalCode like '%[0-9]%'  then 'PARTB'
	when LocalCode like '%.%' and LocalCode like '%[0-9]%'  then 'PARTB'
	when LocalCode like 'B[0-9]%' then 'PARTB'
	when LocalCode like 'g[0-9]%' then 'PARTB'

	when LocalCode like '%PT C%' then 'PARTC'
	when LocalCode like 'C %' then 'PARTC'
	when LocalCode like 'PY C%' then 'PARTC'
	when LocalCode like 'PTC%' then 'PARTC'
	when LocalCode like 'PTY C%' then 'PARTC'

	when LocalCode like '%PT D%' then 'PARTD'
	when LocalCode like 'PTD%' then 'PARTD'
	when LocalCode like 'PD%' then 'PARTD'
	when LocalCode like 'D %' then 'PARTD'

	when LocalCode like 'ACK%' then 'ACK'

	

	--Cardiology Tests
	when LocalCode like '%BOTOX%' then 'BOTO'

	when LocalCode like '%PULMO%' then 'PULM'
	when LocalCode like '%PULSE%' then 'PULS'
	when LocalCode like '%PU;SE%' then 'PULS'
	when LocalCode like '%PULES%' then 'PULS'
	when LocalCode like '%ULSE%' then 'PULS'
	when LocalCode like '%POX%' then 'PULS'

	when LocalCode like '%MAKER%' then 'PACM'

	when LocalCode like '%PAC%' then 'PACE'
			
	when LocalCode like '%ECG%' then 'ECG'
	when LocalCode like '%EGC%' then 'ECG'
	when LocalCode like '%ECT%' then 'ECG'
	when LocalCode like '%ECC%' then 'ECG'
	when LocalCode like '%ECHO%' then 'ECG'
	when LocalCode like '%ECO%' then 'ECG'
	when LocalCode like '%EHC%' then 'ECG'
	when LocalCode like '%ECH%' then 'ECG'
	when LocalCode like '%EC HO%' then 'ECG'
	when LocalCode like '%CARDIOG%' then 'ECG'
	when LocalCode like '%STRES%' then 'ECG'
	
	when LocalCode like '%SIRO%' then 'SPIR'
	when LocalCode like '%SPOR%' then 'SPIR'
	when LocalCode like 'METRY%' then 'SPIR'
	when LocalCode like 'SPRI%' then 'SPIR'
	when LocalCode like '%SPRO%' then 'SPIR'
	when LocalCode like '%SPIRO%' then 'SPIR'
	
	when LocalCode like '%HOLT%' then 'HOLT'
	when LocalCode like 'HOT%' then 'HOLT'
	when LocalCode like 'HOLE%' then 'HOLT'
		
	when LocalCode like '%OMOR%' then 'OMRO'
	when LocalCode like '%OMR%' then 'OMRO'

	when LocalCode like '%NOVA%' then 'NOVA'

	when LocalCode like '%Monitor%' then 'BP'
	when LocalCode like '%Pressure%' then 'BP'
	when LocalCode like 'BP%' then 'BP'
	when LocalCode like '%BP' then 'BP'

	when LocalCode like '%WALK%' then 'WALK'
	when LocalCode like '%MWT%' then 'WALK'

	when LocalCode like 'ARRH%' then 'ARRH'
	when LocalCode like 'ARH%' then 'ARRH'
	when LocalCode like 'ARR%' then 'ARRH'

	when LocalCode like '%TILT%' then 'TILT'
	when LocalCode like '%TILE%' then 'TILT'
	when LocalCode like '%TLT%' then 'TILT'

	when LocalCode like '%PAIN%' then 'PAIN'
	when LocalCode like '%CHEST%' then 'PAIN'

	when LocalCode like '%HEART%' then 'HEAR'

	when LocalCode like '%LUN%' then 'LUNG'

	when LocalCode like '%VALV%' then 'VALV'

	when LocalCode like '%EXER%' then 'EXER'
	when LocalCode like '%ECER%' then 'EXER'
	when LocalCode like '%EXCE%' then 'EXER'

	when LocalCode like '%CARDI%' then 'CARD'

	--Other
	when LocalCode like 'ADJ%' then 'ADJ'
	when LocalCode like '%ADUST%' then 'ADJ'
	when LocalCode like '%AJU%' then 'ADJ'
	when LocalCode like '%DJU%' then 'ADJ'
	when LocalCode like '%WLI%' then 'WLI'
	when LocalCode like '%TRANS%' then 'TRAN'
	

	
	--CMAT
	when LocalCode like '%CMAT%' then 'CMAT'

	--CAMHS
	when LocalCode like '%DYSPR%' then 'DYSP'


	-- Minor Ops
	when LocalCode like '%MOP%' then 'MOP'
	when LocalCode like '%MINOR%' then 'MOP'


	-- Clinics
	when LocalCode like '%ASA%' then 'CLIN'
	when LocalCode like '%ASSESS%' then 'CLIN'

	when LocalCode like '%COLP%' then 'CLIN'
	when LocalCode like '%CAMH%' then 'CLIN'
	when LocalCode like '%CHC%' then 'CLIN'
	when LocalCode like '%CS%' then 'CLIN'
	
	when LocalCode like '%DCH%' then 'CLIN'
	when LocalCode like '%DERM%' then 'CLIN'
	when LocalCode like '%DMG%' then 'CLIN'
	when LocalCode like '%DER%' then 'CLIN'
	when LocalCode like '%DIA%' then 'CLIN'
	when LocalCode like '%DIE%' then 'CLIN'
	when LocalCode like '%DM%' then 'CLIN'
	
	when LocalCode like '%ENT%' then 'CLIN'
	when LocalCode like '%ETT%' then 'CLIN'
	when LocalCode like '%ENDO%' then 'CLIN'
	when LocalCode like '%EYE%' then 'CLIN'
	when LocalCode like '%EYN%' then 'CLIN'

	when LocalCode like '%F/C%' then 'CLIN'
	when LocalCode like '%FLIN%' then 'CLIN'

	when LocalCode like '%GAST%' then 'CLIN'	
	when LocalCode like '%GYN%' then 'CLIN'	
	when LocalCode like '%GLAU%' then 'CLIN'
	when LocalCode like '%GER%' then 'CLIN'
	when LocalCode like '%GM%' then 'CLIN'
	when LocalCode like '%GS%' then 'CLIN'
		
	when LocalCode like '%HN%' then 'CLIN'
	when LocalCode like '%HAEM%' then 'CLIN'
	when LocalCode like '%HYG%' then 'CLIN'
	when LocalCode like '%HIST%' then 'CLIN'
	
	when LocalCode like '%ICS%' then 'CLIN'
	when LocalCode like '%ICD%' then 'CLIN'
	when LocalCode like '%IMP%' then 'CLIN'
	
	when LocalCode like '%LAS%' then 'CLIN'
	when LocalCode like '%LOOP%' then 'CLIN'
	
	when LocalCode like '%MF%' then 'CLIN'
	when LocalCode like '%MH%' then 'CLIN'
	when LocalCode like '%MAT%' then 'CLIN'
	when LocalCode like '%MAN%' then 'CLIN'
	when LocalCode like '%MED%' then 'CLIN'
	when LocalCode like '%MOL%' then 'CLIN'

	when LocalCode like '%NUR%' then 'CLIN'

	when LocalCode like '%ORT%' then 'CLIN'
	when LocalCode like '%ONC%' then 'CLIN'
	when LocalCode like '%OPH%' then 'CLIN'
	when LocalCode like '%OB%' then 'CLIN'
	when LocalCode like '%OPEN%' then 'CLIN'

	when LocalCode like '%PAE%' then 'CLIN'
	when LocalCode like '%PHY%' then 'CLIN'

	when LocalCode like '%REN%' then 'CLIN'
	when LocalCode like '%RHE%' then 'CLIN'
	
	when LocalCode like '%SURG%' then 'CLIN'
	when LocalCode like '%STOP%' then 'CLIN'
	
	when LocalCode like '%TRAUM%' then 'CLIN'
	when LocalCode like '%TP%' then 'CLIN'
	
	when LocalCode like '%URO%' then 'CLIN'
	when LocalCode like '%URD%' then 'CLIN'

	when LocalCode like '%MON%' then 'CLIN'
	when LocalCode like '%TUE%' then 'CLIN'
	when LocalCode like '%WED%' then 'CLIN'
	when LocalCode like '%THU%' then 'CLIN'
	when LocalCode like '%FRI%' then 'CLIN'
	
	



	--Blank
	when LocalCode is null then null
	when LocalCode = '' then null
	
	else 'OTH'
end




UPDATE @Results SET
	R.MainCode = g.MainCode,
	R.Name = g.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_GPRefNo_Map GM ON R.NewCode=GM.LocalCode AND R.Source=GM.Source
	INNER JOIN Mapping.dbo.PAS_GPRefNo G ON GM.MainCode=G.MainCode



SELECT * FROM @Results
--where MainCode is not null
order by MainCode
END

GO
