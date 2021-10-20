SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_StaffContributer]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode			VARCHAR(8),
	Name				VARCHAR(100),
	Email				VARCHAR(100),
	JobTitle			VARCHAR(100)

)

INSERT INTO @Results(MainCode,Name,Email,JobTitle)
	(
SELECT DISTINCT 
initials AS [MainCode],
fullname AS [Name],
NULLIF(con_email,'') as [Email],
NULLIF(con_jobtitle,'') as [JobTitle]

FROM [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[contacts_main]

WHERE initials IS NOT NULL
	)

SELECT * FROM @Results order by MainCode,Name

End
GO
