SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_OutcomeReason]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(8),
	Name			VARCHAR(300),
	LocalCode		VARCHAR(8),
	LocalName		VARCHAR(100),
	Source			VARCHAR(8),
	Area			varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Reason_Code AS LocalCode,
		Descript AS LocalName,
		''WPAS'' AS Source,
		''Central'' as Area
	 FROM 
		LOCALOFF
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		Reason_Code AS LocalCode,
		Descript AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		LOCALOFF
	')

-- temporary took out description as a couple of the codes are duplicated - KR emailed JH 18/12
INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT Distinct
	MAIN_CODE AS LocalCode,
	DESCRIPTION AS LocalName,
	--null as LocalName,
	'Pims' AS Source,
	'West' as Area
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
WHERE
	RFVDM_CODE='CANCR'
	and main_code not in ('CX', 'CA', 'CB', 'CC', 'CD', 'CF', 'CM', 'CN', 'CO', 'CP', 'CT', 'CU', 'CW')
	and description not in ('other', 'Offer Rejected')






	INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
	select MAIN_CODe as LocalCode
	,DESCRIPTION  as LocalName
,'Pims' as Source,
'West' as Area
from [7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES 
where RFVDM_CODE = 'OFOCM'
and main_code not in('DNA','NSP','P','C', 'A', '1')  -- needs investigating, causes duplicates


--INSERT INTO @Results(LocalCode,LocalName,Source) Select '5' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = '5' and source = 'pims')
--INSERT INTO @Results(LocalCode,LocalName,Source) Select '8' as LocalCode, null as LocalName, 'Pims' as Source where not exists (select * from @Results where localcode = '8' and source = 'pims')

UPDATE @Results SET
	R.MainCode = O.MainCode,
	R.Name = O.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_OutcomeReason_Map ORM ON R.LocalCode=ORM.LocalCode AND R.Source=ORM.Source and r.area = orm.Area
	INNER JOIN Mapping.dbo.PAS_OutcomeReason O ON ORM.MainCode=O.MainCode
	
SELECT * FROM @Results

order by maincode
END
GO
