SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_ClinicalDetail]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(6),
	Name				VARCHAR(100),
	Source				VARCHAR(8),
		StartDate		   DATE,
	EndDate			DATE
)

INSERT INTO @Results(MainCode,Name,Source,StartDate,EndDate)
	(
	SELECT 
		code AS MainCode,
		description AS Name,
		'Datix' AS Source,
		NULL AS StartDate,
		NULL AS EndDate
	FROM 
		[7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_sub_subject]

	)

SELECT * FROM @Results order by Source,Name

End
GO
