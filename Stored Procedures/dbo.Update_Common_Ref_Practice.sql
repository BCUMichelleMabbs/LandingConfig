SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Update_Common_Ref_Practice]
@LoadGUID varchar(38)
as
begin


Update [Foundation].[dbo].[Common_Ref_Practice]
set 

ClusterCode = d.ClusterCode
,ClusterDescription = d.ClusterDescription
,LHBCode = d.LHBCode
,LHBDescription = d.LHBDescription
,PracticeArea = d.PracticeArea
,PracticeAddressLine1 = d.PracticeAddressLine1
,PracticeAddressLine2 = d.PracticeAddressLine2
,PracticeAddressLine3 = d.PracticeAddressLine3
,PracticeAddressLine4 = d.PracticeAddressLine4
,PracticeAddressLine5 = d.PracticeAddressLine5
,PracticePhoneNumber = d.PracticePhoneNumber
,PracticePostCode = d.PracticePostCode


from [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Practice_NA d
inner join [Foundation].[dbo].[Common_Ref_Practice] f
on f.MainCode = d.PracticeCode

end
GO
