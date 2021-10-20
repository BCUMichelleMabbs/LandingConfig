SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_AppropriateAttendance]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(2),
	Name			VARCHAR(50),
	LocalCode		VARCHAR(2),
	LocalName		VARCHAR(50),
	Source			VARCHAR(8)
	
)

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
('01','Appropriate attendance','WPAS'),
('02','Inappropriate attendance','WPAS'),
('03','Not applicable (Planned follow up)','WPAS')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
(1,'Appropriate attendance','Symphony'),
(3,'Not applicable (Planned follow up)','Symphony')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
(1,'Appropriate attendance','WEDS'),
(3,'Not applicable (Planned follow up)','WEDS')

INSERT INTO @Results(LocalCode,LocalName,Source) VALUES
(1,'Appropriate attendance','Pims'),
(2,'Inappropriate attendance','Pims'),
(3,'Not applicable (Planned follow up)','Pims')


UPDATE @Results SET
	R.MainCode = AA.MainCode,
	R.Name = AA.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.UnscheduledCare_AppropriateAttendance_Map AAM ON R.LocalCode=AAM.LocalCode AND R.Source=AAM.Source
	INNER JOIN Mapping.dbo.UnscheduledCare_AppropriateAttendance AA ON AAM.MainCode=AA.MainCode
	

SELECT * FROM @Results

END
GO
