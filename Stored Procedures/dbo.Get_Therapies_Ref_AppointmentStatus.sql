SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_AppointmentStatus]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	LocalCode         VARCHAR(10),
	LocalName         VARCHAR(20),
	MainCode          VARCHAR(10),
	Name              VARCHAR(20),
	IsDefault         VARCHAR(2),
	PatientAttending  VARCHAR(2),
	EndStatus         VARCHAR(2),
	Active            VARCHAR(10),
	Message           VARCHAR(600),
	Source            VARCHAR(20),
	Area              VARCHAR(20)
	)

INSERT INTO @Results(LocalCode, LocalName , MainCode, Name, IsDefault, PatientAttending, EndStatus, Active, Message, Source, Area)
	(
	Select 
	ID as LocalCode, 
	Name as LocalName, 
	ID as MainCode, 
	Name as Name,
	Is_Default as IsDefault,    
	Patient_Attending  as PatientAttending, 
	EndStatus as EndStatus,
	case when discontinued = '0' then 'Y' else 'N' 
    end as Active,
	Message as Message,
	'TherapyManager' AS Source,
	'Central' as Area
from [SQL4\SQL4].[physio].[dbo].Appointment_Status
)

INSERT INTO @Results(LocalCode, LocalName , MainCode, Name, IsDefault, PatientAttending, EndStatus, Active, Message, Source, Area)
	(
	Select 
	ID as LocalCode, 
	Name as LocalName, 
	ID as MainCode, 
	Name as Name,
	Is_Default as IsDefault,    
	Patient_Attending  as PatientAttending, 
	EndStatus as EndStatus,
	case when discontinued = '0' then 'Y' else 'N' 
    end as Active,
	Message as Message,
	'TherapyManager' AS Source,
	'East' as Area
from [SQL4\SQL4].[physio].[dbo].Appointment_Status
)

INSERT INTO @Results(LocalCode, LocalName , MainCode, Name, IsDefault, PatientAttending, EndStatus, Active, Message, Source, Area)
	(
	Select 
	ID as LocalCode, 
	Name as LocalName, 
	ID as MainCode, 
	Name as Name,
	Is_Default as IsDefault,    
	Patient_Attending  as PatientAttending, 
	EndStatus as EndStatus,
	case when discontinued = '0' then 'Y' else 'N' 
    end as Active,
	Message as Message,
	'TherapyManager' AS Source,
	'West' as Area
from [SQL4\SQL4].[physio].[dbo].Appointment_Status
)



SELECT * FROM @Results order by Source,LocalCode



End

GO
