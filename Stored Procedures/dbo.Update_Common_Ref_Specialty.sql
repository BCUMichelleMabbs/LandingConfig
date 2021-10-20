SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Update_Common_Ref_Specialty]
@LoadGUID varchar(38)
as
begin


Update [Foundation].[dbo].[Common_Ref_Specialty]
set 

Category  = d.Category
,ClinicalProgramGroup  = d.ClinicalProgramGroup 
,ClinicalProgramGroupCode  = d.ClinicalProgramGroupcode
,ClinicalProgramSubGroup  = d.ClinicalProgramSubGroup
,MainSpecialtyDescription  = d.MainSpecialtyDescription

from [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Specialty_NA d
inner join [Foundation].[dbo].[Common_Ref_Specialty] f
on f.MainCode = d.linkcode

end
GO
