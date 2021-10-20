CREATE TABLE [dbo].[DatasetGroup]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Active] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_System_Active] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetGroup] ADD CONSTRAINT [PK_System] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
