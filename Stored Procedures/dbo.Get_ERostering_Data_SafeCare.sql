SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- JOB MUST BE RUN AFTER 6:30 AM 


CREATE Procedure

[dbo].[Get_ERostering_Data_SafeCare]
as
begin
--declare @Date as Date = '01 June 2019'

-- Added Distinct to remove duplicates from initial data input

SELECT DISTINCT
      [DefaultCensusPeriodID] as CensusPeriodCode,
      [PatientTypeID],
	  [HPPDMultiplier],
      [PatientTypeType] as PatientTask,
	  CONVERT(date, [PatientCensusPeriodValidDate]) as CensusPeriodValidDate,
	  [EnteredBy] as EnteredByUser,
	  [PatientTypeStatus],
	  CONVERT(time(0), [CensusPeriodStartTime]) as CensusPeriodStartTime,
	  [OwningUnitLongName] as OwningUnit,
	  CASE WHEN [PatientCount] = '-1' THEN NULL ELSE [PatientCount] END As PatientCount,
	  [HPPDValue],
	  [HPPDPercentage],
	  [SpecificHoursPerUnit] as HoursPerUnit,
	  [Source] = 'E-Rostering',
	  [Area] = 'BCU'

	    

  FROM [SSIS_Loading].[SafeCare].[dbo].[Landing]

 where PatientCensusPeriodValidDate > DATEADD(DAY,-30, GETDATE())



  end
GO
