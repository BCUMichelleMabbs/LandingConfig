SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_ESR_Data_Qualifications]
AS BEGIN

SELECT 
RecordType,
PersonID,
QualificationID,
QualificationType,
Title,
Status,
Grade,
CONVERT(Date,AwardedDate) as AwardedDate,
CONVERT(Date,StartDate) as StartDate,
CONVERT(Date,EndDate) as EndDate,
Establishment,
Country,
CONVERT(Date,LEFT([LastUpdateDate],8)) as LastUpdateDate,
DeletionFlag
	  ,LoadDate as RetrivalDate

FROM [SSIS_Loading].[ESR].[dbo].[Qualifications]

END
GO
