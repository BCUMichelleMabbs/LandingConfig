SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Get_Security_Ref_LocationUser]


 @Nadex varchar(20)
 as begin



select distinct l.area 

from Foundation.dbo.Common_Ref_Location  l
join Foundation.dbo.Security_Ref_LocationBridge  lb
on lb.LocationSKey = l.LocationSKey 
join Foundation.dbo.Security_Ref_Users  u
on u.UserSKey = lb.UserSKey 
where u.Nadex = @Nadex
end
GO
