SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Get_Security_Ref_LocationArea]


 @Area varchar(20)
 as
 begin




select distinct u.Nadex 
from Foundation.dbo.Security_Ref_LocationBridge  b
join Foundation.dbo.Common_Ref_Location  l
on l.LocationSKey = b.LocationSKey 
join Foundation.dbo.Security_Ref_Users  u
on u.UserSKey = b.UserSKey 
where l.Area = @Area
and 
(select count(*) from Foundation.dbo.Security_Ref_LocationBridge) = (select count(*) from Foundation.dbo.Security_Ref_LocationBridge where l.Area = @Area)
end
GO
