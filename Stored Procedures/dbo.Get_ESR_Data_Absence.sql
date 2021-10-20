SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure

[dbo].[Get_ESR_Data_Absence]
as
begin
SELECT a.[RecordType]
      ,a.[PersonID]
      ,RTRIM(LTRIM([AbsenceAttendanceID])) as AbsenceAttendanceID
      ,[AbsenceType]
      ,[AbsenceReason]
      ,[Status]
      ,CONVERT(date,[NotificationDate]) as [NotificationDate]
      ,CONVERT(date,[ProjectedStartDate]) as [ProjectedStartDate]
      ,CONVERT(Time,[ProjectedStartTime]) as [ProjectedStartTime]
      ,CONVERT(date,[ProjectedEndDate]) as [ProjectedEndDate]
      ,CONVERT(Time,[ProjectedEndTime]) as [ProjectedEndTime]
      ,CONVERT(date,[ActualStartDate]) as [ActualStartDate]
      ,CONVERT(Time,[ActualStartTime]) as [ActualStartTime]
      ,CONVERT(date,[ActualEndDate]) as [ActualEndDate]
      ,CONVERT(Time,[ActualEndTime]) as [ActualEndTime]
      ,CONVERT(date,[SicknessStartDate]) as [SicknessStartDate]
      ,CONVERT(date,[SicknessEndDate]) as [SicknessEndDate]
      ,[AbsenceDurationDays]
      ,[AbsenceDurationHours]
      ,[AbsenceUnits]
      ,[HoursLost]
      ,[SessionsLost]
      ,[WorkRelated]
      ,[ThirdParty]
      ,[DisabilityRelated]
      ,[ViolenceandAggressionRelated]
      ,[Column27]
      ,[Column28]
      ,[Column29]
      ,CONVERT(Date,LEFT(a.[LastUpdateDate],8)) as LastUpdateDate
      ,[SurgeryRelated]
      ,[DHMonitoring]
      ,[Column33]
      ,[ThirdPartySystemReference]
      ,[Column35]
      ,[Column36]
      ,[Column37]
      ,[Column38]
      ,[Column39]
      ,[Column40]
      ,[Column41]
      ,[Column42]
      ,[Column43]
      ,[HRManager]
      ,[Column45]
      ,[Column46]
      ,[Column47]
      ,[WorkingDaysLost]
      ,a.[DeletionFlag]
	  ,assi.Fte
      ,assi.NormalHoursSessions
      ,O.OrgName
	  ,a.LoadDate as RetrievalDate
  FROM [SSIS_Loading].[ESR].[dbo].[Absence] a
  left join Foundation.dbo.ESR_Data_Assignment  assi  on assi.personid = A.personid  and assi.PrimaryAssignment = 'Yes'
  left join Foundation.dbo.ESR_Data_Organisation  o  on O.organisationid = assi.organisationid 

  --WHERE absenceAttendanceID is not null 
  --bring all records in so we have those which need to be purgred from the system post foundation

  end
GO
