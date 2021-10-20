SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create Procedure [dbo].[Update_PAS_Patient_Exclusions]

@LoadGUID varchar(38)
as
begin

delete from foundation.dbo.PAS_Ref_Patient
where exists
		(
		Select e.Value
		from foundation.dbo.Common_Ref_Exclusion e
		where foundation.dbo.PAS_Ref_Patient.localpatientidentifier = e.Value
		and foundation.dbo.PAS_Ref_Patient.source = e.Source
		)


end
GO
