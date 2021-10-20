SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_ESR_Data_AssignmentCosting]
AS BEGIN

SELECT 
RecordType,
PersonID,
AssignmentID,
CostingAllocationID,
CONVERT(Date,EffectiveStartDate) as EffectiveStartDate,
CONVERT(Date,EffectiveEndDate) as EffectiveEndDate,
EntityCode,
CharitableIndicator,
CostCentre,
Subjective,
Analysis1,
Analysis2,
ElementNumber,
SpareSegment,
PercentageSplit,
CONVERT(Date,LEFT([LastUpdateDate],8)) as LastUpdateDate,
DeletionFlag
	  ,LoadDate as RetrivalDate

FROM [SSIS_Loading].[ESR].[dbo].[AssignmentCosting]
  
END
GO
