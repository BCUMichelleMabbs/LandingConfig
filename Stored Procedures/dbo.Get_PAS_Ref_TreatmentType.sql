SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_TreatmentType]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(2),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				varchar(10)
	)


	INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
			TRT_TYPE AS LocalCode,
			TRT_DESCRIPTION AS LocalName,
			''WPAS'' as Source,
			''Central'' as Area
			
		 FROM 
			TRT_TYPE
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
				TRT_TYPE AS LocalCode,
				TRT_DESCRIPTION AS LocalName,
				''Myrddin'' as Source,
				''East'' as Area
			 FROM 
				TRT_TYPE
		')


	INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
			TRT_TYPE AS LocalCode,
			TRT_DESCRIPTION AS LocalName,
			''Pims'' as Source,
			''West'' as Area
			
		 FROM 
			TRT_TYPE
	')
		


/*
INSERT INTO  @Results(LocalCode,LocalName,Source)
VALUES 
('0','Not Specified','TherMan')
('1','OutPatient','TherMan')
('2','Inpatient','TherMan')
('3','Daycase','TherMan')
*/


UPDATE @Results SET
	R.MainCode = AM.MainCode,
	R.Name = AM.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_TreatmentType_Map AMM ON R.LocalCode=AMM.LocalCode AND R.Source=AMM.Source and r.source = amm.source
	INNER JOIN Mapping.dbo.PAS_TreatmentType AM ON AMM.MainCode=AM.MainCode
	
SELECT * FROM @Results
END
GO
