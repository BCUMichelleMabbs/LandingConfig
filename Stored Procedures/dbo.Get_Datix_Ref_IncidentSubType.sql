SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_IncidentSubType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(10),
	Name				VARCHAR(200),
	Source				VARCHAR(8),
		StartDate		   DATE,
	EndDate			DATE
)

INSERT INTO @Results(MainCode,Name,Source,StartDate,EndDate)
	(
	SELECT distinct 
		cod_code AS MainCode,
		cod_descr AS Name,
		'Datix' AS Source,
		NULL AS StartDate,
		NULL AS EndDate
FROM 
		[7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_types]

		where cod_type = 'CLINDT'

	)

SELECT * FROM @Results order by Source,Name


End
GO
