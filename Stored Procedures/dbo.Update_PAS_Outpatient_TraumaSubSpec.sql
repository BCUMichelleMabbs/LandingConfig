SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Update_PAS_Outpatient_TraumaSubSpec]
@Load_GUID AS VARCHAR(38)
as
begin

Update [Foundation].[dbo].[PAS_Data_Outpatient]
Set TraumaSubSpec = CASE WHEN RIGHT(AdmittingSpecialty,3) = '444' THEN 1 ELSE 0 END
WHERE Load_GUID = @Load_GUID

END
GO
