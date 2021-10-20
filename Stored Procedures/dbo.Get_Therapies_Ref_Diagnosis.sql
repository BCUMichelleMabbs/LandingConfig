SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_Diagnosis]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode      VARCHAR(20),
	LocalName      VARCHAR(200),
	SiteCode       VARCHAR(20),
	DiagnosisCode  VARCHAR(10),
	DiagnosisGroup VARCHAR(10),
	Source         VARCHAR(20),
	Area           VARCHAR(20),
	MainCode       VARCHAR(20)
	)


INSERT INTO @Results(LocalCode, LocalName, SiteCode, DiagnosisCode, DiagnosisGroup, Source,Area, MainCode)
	(
	Select distinct ID, Text, Site_id,Code, Group_code,
	'TherapyManager' AS Source,
	'Central' as Area,
	ID 
from [SQL4\SQL4].[physio].[dbo].diagnosis
	)

INSERT INTO @Results(LocalCode, LocalName, SiteCode, DiagnosisCode, DiagnosisGroup, Source,Area, MainCode)
	(
	Select distinct ID, Text, Site_id,Code, Group_code,
	'TherapyManager' AS Source,
	'East' as Area,
	ID 
from [SQL4\SQL4].[physio].[dbo].diagnosis
	)

INSERT INTO @Results(LocalCode, LocalName, SiteCode, DiagnosisCode, DiagnosisGroup, Source,Area, MainCode)
	(
	Select distinct ID, Text, Site_id,Code, Group_code,
	'TherapyManager' AS Source,
	'West' as Area,
	ID 
from [SQL4\SQL4].[physio].[dbo].diagnosis
	)




SELECT * FROM @Results ORDER BY LocalCode, area


End
GO
