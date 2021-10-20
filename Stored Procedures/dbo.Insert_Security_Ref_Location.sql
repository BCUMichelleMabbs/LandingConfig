SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Insert_Security_Ref_Location]


@Nadex varchar(20)
,@Area varchar(20)

as
begin


insert into 

Foundation.dbo.Security_Ref_LocationBridge (LocationSKey,UserSKey)

select 
locationskey,(select userskey from Foundation.dbo.Security_Ref_Users  where Nadex = @Nadex ) from Foundation.dbo.Common_Ref_Location 
where Area = @Area
END
GO
