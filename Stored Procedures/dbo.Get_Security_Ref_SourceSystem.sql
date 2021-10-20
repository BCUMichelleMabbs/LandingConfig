SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Get_Security_Ref_SourceSystem]

 @Source varchar(20)

 as
 begin



select distinct u.Nadex 
from Foundation.dbo.Security_Ref_SourceBridge b
join Foundation.dbo.Common_Ref_Source  s
on s.SourceSKey = b.SourceSKey 
join Foundation.dbo.Security_Ref_Users  u
on u.UserSKey = b.UserSKey 
where s.Name = @Source
and 
(select count(*) from Foundation.dbo.Security_Ref_SourceBridge ) = (select count(*) from Foundation.dbo.Security_Ref_SourceBridge  where s.name = @Source)

END
GO
