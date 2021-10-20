SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create Procedure [dbo].[Update_PAS_NonContact_Exclusions]

@LoadGUID varchar(38)
as
begin

delete from foundation.dbo.PAS_Data_NonContact  
where exists
		(
		Select e.Value
		from foundation.dbo.Common_Ref_Exclusion e
		where foundation.dbo.PAS_Data_NonContact.localpatientidentifier = e.Value
		and foundation.dbo.PAS_Data_NonContact.source = e.Source
		)


end
GO
