SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_ERostering_Data_HoursAssignment]
as
begin
SELECT  
[HoursAssignmentID]
,CONVERT(date,ValidDate) as[ValidDate]
,CONVERT(date,ActualStart) as [ActualStartDate]
,CONVERT(time,ActualStart) as [ActualStartTime]
,CONVERT(date,ActualEnd) as [ActualEndDate]
,CONVERT(time,ActualEnd) as [ActualEndTime]
,[WorkTime]
,[ContractedTime]
,[PayState]
,[AssignmentNumber]
,[StaffNumber]
,[EmployeeTypeName]
 ,[PersonGradeShortName]
 ,[PersonWTE]
,[AssignmentMethod]
,[FromRequest]
,[PostTitle]
,[PostGradeShortName]
 ,[CancelFlag]
,[CancelReasonName]
 ,[InCharge]
,[ShiftType]
,[ShiftName]
 ,CONVERT(Time,LEFT(CONVERT(varchar,dutystart,103),5))  as DutyStartTime
 ,CONVERT(Time,LEFT(CONVERT(varchar,dutyend,103),5))  as DutyEndTime
,[FulfillmentType]
,[FulfillmentStatus]
,[FulfillmentCategory]
,[CostCentreCode]
,[OwningUnitShortName]
 ,[RequiredGradeTypeName]
,[LocationType]
,'E-Rostering' as Source
 

FROM [SSIS_LOADING].[ERostering].[dbo].[HoursAssignment]


END
GO
