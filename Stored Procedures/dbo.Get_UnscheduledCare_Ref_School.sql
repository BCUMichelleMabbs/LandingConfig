SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_School]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(10),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(100),
	Source				VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
select LKP_ID,LKP_NAME,'WEDS' from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookups where lkp_TableID=11833 and Lkp_ParentID!=11833

INSERT INTO @Results(LocalCode,LocalName,Source)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_SCHOOL
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT 
		HEORG_REFNO AS LocalCode,
		DESCRIPTION AS LocalName,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[HEALTH_ORGANISATIONS]
	WHERE
		HOTYP_REFNO=202705 AND
		DESCRIPTION !='%%'
	) 




--Don't currently have a definitive list of schools to map to
--so just going to use the local stuff for the main code and name
--until we get a list

UPDATE @Results SET MainCode=LocalCode,Name=LocalName

SELECT * FROM @Results order by Source,Name
END
GO
