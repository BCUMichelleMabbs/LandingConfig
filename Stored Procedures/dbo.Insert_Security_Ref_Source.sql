SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Insert_Security_Ref_Source]

@Nadex varchar(20)
,@Source varchar(20)



as
begin


insert into 

[Foundation].[dbo].[Security_Ref_SourceBridge] (SourceSKey,UserSKey)

select 
sourceskey,(select userskey from [Foundation].[dbo].[Security_Ref_Users] where Nadex = @Nadex ) from [Foundation].[dbo].[Common_Ref_Source]
where Name  = @Source

END
GO
