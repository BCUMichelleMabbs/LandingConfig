CREATE TABLE [dbo].[FieldExtraType]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FieldExtraType] ADD CONSTRAINT [PK_FieldExtraType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
