SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Ref_AppointmentDirective]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @Results AS TABLE(
	MainCode			VARCHAR(2),
	Name				VARCHAR(50),
	LocalCode		VARCHAR(3),
	LocalName		VARCHAR(100),
	Source			VARCHAR(7),
	Area				varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		APPT_DIRECTIVE AS LocalCode,
		DESCRIPTION AS Name,
		''WPAS'' as Source,
		''Central'' as Area
	 FROM 
		APPT_DIRECTIVE
	')


	INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_East,'
	SELECT DISTINCT
		APPT_DIRECTIVE AS LocalCode,
		DESCRIPTION AS Name,
		''Myrddin'' as Source,
		''East'' as Area
	 FROM 
		APPT_DIRECTIVE
	')


UPDATE @Results SET
	R.MainCode = ADS.MainCode,
	R.Name = ADS.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_AppointmentDirective_Map ASM ON R.LocalCode=ASM.LocalCode AND R.Source=ASM.Source and R.Area = ASM.Area
	INNER JOIN Mapping.dbo.PAS_AppointmentDirective ADS ON ASM.MainCode=ADS.MainCode


SELECT * FROM @Results
--where MainCode is not null
END


GO
