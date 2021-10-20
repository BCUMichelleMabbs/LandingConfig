SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_Security_Ref_SourceUser]

 @Nadex varchar(20)
as
begin

select 
s.Name 

from Foundation.dbo.Common_Ref_Source  s
join Foundation.dbo.Security_Ref_SourceBridge  sb
on sb.SourceSKey = s.SourceSKey 
join Foundation.dbo.Security_Ref_Users  u
on u.UserSKey = sb.UserSKey 

where u.Nadex = @Nadex
end
GO
