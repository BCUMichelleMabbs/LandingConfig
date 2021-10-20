SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_AlcoholRelated]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(5),
	Name			VARCHAR(50),
	LocalCode		VARCHAR(5),
	LocalName		VARCHAR(50),
	Source			VARCHAR(8)
	
)

INSERT INTO @Results(LocalCode,LocalName,Source)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		CODE AS LocalCode,
		DESCRIPTION AS LocalName,
		''WPAS'' AS Source
	FROM 
		AANDE_ALCOHOL
	')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
(1,'Yes','Symphony'),
(2,'No','Symphony'),
(3,'Don''t know','Symphony'),
(4,'Not applicable (follow up patient)','Symphony')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
(1,'Yes','WEDS'),
(2,'No','WEDS'),
(3,'Don''t know','WEDS'),
(4,'Not applicable (follow up patient)','WEDS')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('01','Yes','Pims'),
('02','No','Pims'),
('03','Don''t know','Pims'),
('04','Not applicable (follow up patient)','Pims')


UPDATE @Results SET
	R.MainCode = AR.MainCode,
	R.Name = AR.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_AlcoholRelated_Map ARM ON R.LocalCode=ARM.LocalCode AND R.Source=ARM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_AlcoholRelated AR ON ARM.MainCode=AR.MainCode
	

SELECT * FROM @Results

END
GO
