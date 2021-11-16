SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Update_PAS_Outpatients_ProcedureGroup]


@LoadGUID varchar(38)

AS
BEGIN
SET NOCOUNT ON;



UPDATE [Foundation].[dbo].[PAS_Data_Outpatients]
Set ProcedureGroup = 
CONCAT(coalesce(procedure1+', ', ''),  coalesce(procedure2 +', ', ''), coalesce(Procedure3 +', ', ''), coalesce(Procedure4 +', ', '') , coalesce(Procedure5 +', ', ''), coalesce(Procedure6 +', ', ''), coalesce(Procedure7 +', ', '') , coalesce(Procedure8 +', ', '') , coalesce(Procedure9 +', ', ''), coalesce(Procedure10 +', ', ''), coalesce(Procedure11 +', ', ''), coalesce(Procedure12, ''))
FROM [Foundation].[dbo].[PAS_Data_Outpatients]



END
GO
