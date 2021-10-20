SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_ApprovalStatus]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(6),
	Name				VARCHAR(100),
	Dataset			VARCHAR(10),
	Source				VARCHAR(8)
)

INSERT INTO @Results(MainCode,Name,Dataset,Source)
	(
	SELECT distinct
		code AS MainCode,
		description AS Name,
		module as Dataset,
		'Datix' AS Source
	FROM 
		[7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_approval_status]

  where module in ('INC','CON','CLA')
  and description not in ('Finally approved','In holding area, saved to complete later')

	)

SELECT * FROM @Results order by Source,Name

End
GO
