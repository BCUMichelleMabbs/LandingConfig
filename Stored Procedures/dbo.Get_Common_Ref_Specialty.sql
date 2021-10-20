SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_Specialty]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(300),
	MainCode				VARCHAR(6),
	Name					VARCHAR(300),
	SpecialtyCode		varchar(3),
	SpecialtyName		varchar(200),
	SubSpecialty		varchar(3),
	SubSpecialtyName	varchar(200),
	Division				varchar(50),
	Source				VARCHAR(10),
	Area					VARCHAR(10),
	Pathway				varchar(1),
	CapacityPlanning	varchar(1)
)

INSERT INTO @Results(LocalCode,LocalName,Source,Area, Pathway)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		SPECIALTY_REFERENCE_CODE AS LocalCode,
		SPECIALTY_NAME AS LocalName,
		''WPAS'' AS Source,
		''Central'' AS Area,
		case when Exclude_Pathway is not null then ''N''
		else ''Y'' end as Pathway
	 FROM 
		SPECS
	')


INSERT INTO @Results(LocalCode,LocalName,Source,Area,Pathway)
SELECT * FROM OPENQUERY(WPAS_EAST,'
		SELECT DISTINCT
			SPECIALTY_REFERENCE_CODE AS LocalCode,
		SPECIALTY_NAME AS LocalName,
		''Myrddin'' AS Source,
		''East'' AS Area,
		case when Exclude_Pathway is not null then ''N''
		else ''Y'' end as Pathway
		 FROM 
			SPECS
	')


INSERT INTO @Results(LocalCode,LocalName,Source,Area, Pathway)
	SELECT
		CASE ISNUMERIC(S.MAIN_IDENT)
			WHEN 1 THEN LEFT(S.MAIN_IDENT+'000000',6)
			ELSE S.MAIN_IDENT
		END AS LocalCode,
		S.DESCRIPTION AS LocalName,
		'Pims' AS Source,
		'West' AS Area,
		null as Pathway
		
	FROM 
		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].[SPECIALTIES] S
	WHERE 
		S.MAIN_IDENT IS NOT NULL 
		--AND
		--(S.END_DTTM IS NULL OR S.END_DTTM>GETDATE())
		and not (s.main_Ident = '1800' and s.description = 'Minor Casualty Units')


INSERT INTO @Results(LocalCode,LocalName,Source,Area, Pathway)
	SELECT
		CAST(Lkp_ID AS VARCHAR(10)) AS LocalCode,
		Lkp_Name AS LocalName,
		'Symphony' AS Source,
		'East' AS Areaa,
		null as Pathway
	FROM
		[RYPA4SRVSQL0014.CYMRU.NHS.UK].[Wrexham_Reports].dbo.Lookups
	WHERE
		Lkp_ParentID=675

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
RADIS
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
--DECLARE @SQL AS VARCHAR(MAX)

--SET @SQL='SELECT * FROM OPENQUERY(RADIS_CENTRAL,''
--Select Distinct
--	Code AS LocalCode,
--	Description AS LocalName,
--	''''Radis'''' AS Source,
--	''''Central'''' AS Areaa,
--null as Pathway
--From
--	Radis.dbo.Specialty
--WHERE
--	Active=''''1''''
--'')'
--INSERT INTO @Results(LocalCode,LocalName,Source,Area, Pathway)
--EXEC(@SQL)


--SET @SQL='SELECT * FROM OPENQUERY(RADIS_EAST,''
--Select Distinct
--	Code AS LocalCode,
--	Description AS LocalName,
--	''''Radis'''' AS Source,
--	''''East'''' AS Area
--From
--	Radis.dbo.Specialty
--WHERE
--	Active=''''1''''
--'')'
--INSERT INTO @Results(LocalCode,LocalName,Source,Area)
--EXEC(@SQL)


--SET @SQL='SELECT * FROM OPENQUERY(RADIS_WEST,''
--Select Distinct
--	Code AS LocalCode,
--	Description AS LocalName,
--	''''Radis'''' AS Source,
--	''''West'''' AS Area
--From
--	Radis.dbo.Specialty
--WHERE
--	Active=''''1''''
--'')'
--INSERT INTO @Results(LocalCode,LocalName,Source,Area)
--EXEC(@SQL)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */







UPDATE @Results SET
	R.MainCode = MI.MainCode,
	R.Name = MI.Name,
	r.SpecialtyCode = mi.SpecialtyCode,
	r.SpecialtyName = mi.SpecialtyName,
	r.SubSpecialty = mi.SubSpecialty,
	r.SubSpecialtyName = mi.SubSpecialtyName,
	r.Division = mi.division,
	r.CapacityPlanning = mi.CapacityPlanning
FROM
	@Results R
	INNER JOIN Mapping.dbo.Common_Specialty_Map MIM ON R.LocalCode=MIM.LocalCode AND R.Source=MIM.Source
	INNER JOIN Mapping.dbo.Common_Specialty MI ON MIM.MainCode=MI.MainCode




	UPDATE r SET r.Pathway =
	case when r.source in ('pims', 'Symphony') and r.pathway is null then r2.pathway
	else r.Pathway
	end 
	FROM
	@Results r left join @Results r2 on left(r.MainCode, 6) = left(r2.MainCode, 6) and r2.Source = 'WPAS' and r2.area = 'Central'
	


	



SELECT *

FROM @Results

order by MainCode

END

/*
NOTES
Mapping.dbo.Common_Specialty_Map - this table is used to map local codes to nationalcodes and is manually updated
Mapping.dbo.Common_Specialty - this table is fed from national look ups found on NRDS and ODS
Capacity Planning Flag is manually entered, Karyn Donnally provided the initial list - May 2020
Pathway Flag is being fed by the detail held on the source systems





*/
GO
