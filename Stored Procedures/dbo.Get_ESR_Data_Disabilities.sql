SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_ESR_Data_Disabilities]
AS BEGIN

SELECT 
RecordType,
PersonID,
DisabilityID,
Column4,
Column5,
Column6,
Category,
Status,
DeletionFlag
	  ,LoadDate as RetrivalDate

FROM [SSIS_Loading]. [ESR].[dbo].[Disabilities]
  
END
GO
