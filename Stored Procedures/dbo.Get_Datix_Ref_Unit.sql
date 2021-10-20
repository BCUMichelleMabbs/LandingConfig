SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[Get_Datix_Ref_Unit]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(6),
	Name				VARCHAR(100),
	Source				VARCHAR(6)
)

INSERT INTO @Results(MainCode,Name,Source)
	(
	SELECT 
		code AS MainCode,
		description AS Name,
		'Datix' AS Source
	FROM 
		[7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_unit]


	)

SELECT * FROM @Results order by Source,Name

End
GO
