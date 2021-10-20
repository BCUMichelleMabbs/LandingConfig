SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_ESR_Data_TrainingAbsence]
AS BEGIN

SELECT 
RecordType,
PersonID,
AbsenceAttendanceID,
AbsenceType,
AbsenceReason,
Status,
CONVERT(Date,NotificationDate) as NotificationDate,
CONVERT(Date,ProjectedStartDate) as ProjectedStartDate,
CONVERT(Time,ProjectedStartTime) as ProjectedStartTime,
CONVERT(Date,ProjectedEndDate) as ProjectedEndDate,
CONVERT(Time,ProjectedEndTime) as ProjectedEndTime,
CONVERT(Date,ActualStartDate) as ActualStartDate,
CONVERT(Time,ActualStartTime) as ActualStartTime,
CONVERT(Date,ActualEndDate) as ActualEndDate,
CONVERT(Time,ActualEndTime) as ActualEndTime,
CONVERT(Date,SicknessStartDate) as SicknessStartDate,
CONVERT(Date,SicknessEndDate) as SicknessEndDate,
AbsenceDurationDays,
AbsenceDurationHours,
AbsenceUnits,
HoursLost,
SessionsLost,
WorkRelated,
ThirdParty,
DisabilityRelated,
ViolenceandAggressionRelated,
NotifyableDisease,
CONVERT(Date,ReturntoworkDiscussionDate) as ReturntoworkDiscussionDate,
CONVERT(Date,OccupationalHealthReferralDate) as OccupationalHealthReferralDate,
CONVERT(Date,LEFT([LastUpdateDate],8)) as LastUpdateDate,
DeletionFlag
	  ,LoadDate as RetrivalDate

FROM [SSIS_Loading]. ESR.dbo.TrainingAbsence
  where RecordType <>'TRL'
END
GO
