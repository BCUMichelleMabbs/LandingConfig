SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_AttendanceCategory]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(50),
	LocalCode		VARCHAR(10),
	LocalName		VARCHAR(80),
	Source			VARCHAR(8)
)

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('01','New','WPAS'),
('02','Planned follow up','WPAS'),
('03','Unplanned follow up','WPAS')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('01','New','Symphony'),
('02','Planned follow up','Symphony'),
('03','Unplanned follow up','Symphony')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('01','New','WEDS'),
('02','Planned follow up','WEDS'),
('03','Unplanned follow up','WEDS')

INSERT INTO @Results(LocalCode,LocalName,Source) 
SELECT 
	RFVAL_REFNO AS LocalCode,
	DESCRIPTION AS LocalName,
	'Pims' AS Source
FROM 
	[7A1AUSRVIPMSQL].[iPMProduction].[dbo].REFERENCE_VALUES
WHERE
	RFVDM_CODE='ATCAT'
 

 	INSERT INTO @Results(LocalCode,LocalName,Source)
(
Select Distinct
		a.AttendanceCategory as LocalCode,
		NULL as LocalName,
		a.Source as Source
From Foundation.dbo.UnscheduledCare_Data_EDAttendance a
left join mapping.dbo.UnscheduledCare_AttendanceCategory_Map as tc on rtrim(ltrim(upper(tc.LocalCode))) = ltrim(rtrim(upper(a.AttendanceCategory))) and a.source = 'OldWH' 
where a.AttendanceCategory is not null
)


UPDATE @Results SET
	R.MainCode = AC.MainCode,
	R.Name = AC.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_AttendanceCategory_Map ACM ON R.LocalCode=ACM.LocalCode AND R.Source=ACM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_AttendanceCategory AC ON ACM.MainCode=AC.MainCode

SELECT * FROM @Results
order by maincode
END
GO
