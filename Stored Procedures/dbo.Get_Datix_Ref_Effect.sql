SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[Get_Datix_Ref_Effect]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(6),
	Name				VARCHAR(61),
	Source				VARCHAR(6)
)

INSERT INTO @Results(MainCode,Name,Source)
	(
	SELECT distinct 
		cod_code AS MainCode,
		cod_descr AS Name,
		'Datix' AS Source
FROM 
		[7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_types]

		 where cod_type = 'EFFECT'

	)

SELECT * FROM @Results order by Source,Name


End
GO
