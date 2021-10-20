SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[Get_Datix_Ref_CommunicationType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(6),
	Name				VARCHAR(50),
	Source				VARCHAR(8)
)

INSERT INTO @Results(MainCode,Name,Source)
	(
	SELECT 
		code AS MainCode,
		description AS Name,
		'Datix' AS Source
	FROM 
		[7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_com_type]

	)

SELECT * FROM @Results order by Source,Name

End
GO
