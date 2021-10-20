SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Covid_Data_LateralFlowRegister] AS BEGIN


SELECT  Forename + ' ' + Surname AS Name,
        Email,
		convert(VARCHAR, DOB,103),
		VaccineReceived,
		WorkLocation,
		AppointmentDate,
		CovidSymptomatic,
		Gender,
		GPCode,
		KeyWorkerId,
	    MobileNumber,
		NHSNumber,
		TestEndDate,
		TestStartDate,
		TestResult,
		TestReason,
		TestLocation,
		TestType,
		CASE WHEN AppointmentDate is null then 0
		ELSE 1 END as Result



 FROM [7A1A1SRVINFONDR].[Booking].[dbo].[LFTESR] e
 LEFT JOIN [7A1A1SRVINFONDR].CovidTesting.dbo.LateralFlowTests l on 
 (l.EmailAddress = e.Email)-- or (FirstName = Forename and LastName = Surname and CONVERT(varchar, DOB, 113) = CONVERT(varchar, DateOfBirth,113)))
 

 where 1=1 
 and MultipleEntries is null
 and (TestKit = 'lft' OR TestKit is null)


END
GO
