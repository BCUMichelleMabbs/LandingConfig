SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Covid_Data_LateralFlowTesting] AS BEGIN

SELECT 
		AppointmentDate,
		CovidSymptomatic,
		DateOfBirth,
		EmailAddress,
		FirstName,
		Gender,
		GPCode,
		KeyWorkerId,
		LastName,
		MobileNumber,
		NHSNumber,
		TestEndDate,
		TestStartDate,
		TestResult,
		TestReason,
		TestLocation,
		TestType,
		VaccinationDate,
		VaccinationStatus,
		'NDR' as Source,
		'BCU' as Area

  FROM [7A1A1SRVINFONDR].[CovidTesting].[dbo].[LateralFlowTests]

  WHERE AppointmentDate >= DATEADD(MM,-2, GETDATE())
  and TestKit = 'lft'


END
GO
