SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_Priority]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(100),
	LocalCode			VARCHAR(10),
	LocalName			VARCHAR(80),
	Source				VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source)
(
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT Distinct
		Priority_Code AS LocalCode,
		Descript AS LocalName,
		''Myrddin'' AS Source
	FROM 
		PRIORITY
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source)
(
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		Priority_CODE AS LocalCode,
		DESCRIPT AS LocalName,
		''WPAS'' AS Source
	FROM 
		PRIORITY
	')
)

INSERT INTO @Results(LocalCode,LocalName,Source)
	(
	SELECT 
		Main_Code AS LocalCode,
		DESCRIPTION AS LocalName,
		'Pims' AS Source
	FROM 
		[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].[dbo].REFERENCE_VALUES
	WHERE
		RFVDM_CODE='PRITY' 
		AND ISNULL(ARCHV_FLAG,'N')='N'
	) 

/*

-- THERAPY MANAGER - No Referral Priority Reference data exists on TM 
-- received via Daniel front end 
INSERT INTO @Results(LocalCode,LocalName,Source)
VALUES ('-1','Null Field not completed')
VALUES ('0','unspecified')
VALUES ('1','Urgent')
VALUES ('2','Non urgent')
VALUES ('3','Routine')
VALUES ('4','1')
VALUES ('5','2')
VALUES ('6','3')

*/



UPDATE @Results SET
	R.MainCode = P.MainCode,
	R.Name = P.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.Common_Priority_Map PM ON R.LocalCode=pm.LocalCode AND R.Source=PM.Source
	INNER JOIN Mapping.dbo.Common_Priority P ON PM.MainCode=P.MainCode

	

SELECT * FROM @Results order by Source,Name
END
GO
