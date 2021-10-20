SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_ESR_Data_ElementEntry]
AS BEGIN

SELECT 
RecordType,
PersonID,
ElementEntryID,
CONVERT(Date,EffectiveStartDate) as EffectiveStartDate,
CONVERT(Date,EffectiveEndDate) as EffectiveEndDate,
ElementEntryType,
AssignmentID,
ElementTypeID,
ElementTypeName,
CONVERT(Date,EarnedDate) as EarnedDate,
EntryValue1,
EntryValue2,
EntryValue3,
EntryValue4,
EntryValue5,
EntryValue6,
EntryValue7,
EntryValue8,
EntryValue9,
EntryValue10,
EntryValue11,
EntryValue12,
EntryValue13,
EntryValue14,
EntryValue15,
CONVERT(Date,LEFT([LastUpdateDate],8)) as LastUpdateDate,
DeletionFlag
	  ,LoadDate as RetrivalDate

FROM [SSIS_Loading].[ESR].[dbo].[ElementEntry]

END
GO
