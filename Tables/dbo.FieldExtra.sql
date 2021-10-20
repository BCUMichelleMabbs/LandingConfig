CREATE TABLE [dbo].[FieldExtra]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FieldId] [int] NULL,
[Name] [varchar] (200) COLLATE Latin1_General_CI_AS NOT NULL,
[TypeId] [int] NOT NULL,
[Source] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FieldExtra] ADD CONSTRAINT [PK_FieldExtra] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FieldExtra] WITH NOCHECK ADD CONSTRAINT [FK_FieldExtra_Field] FOREIGN KEY ([FieldId]) REFERENCES [dbo].[Field] ([Id])
GO
ALTER TABLE [dbo].[FieldExtra] WITH NOCHECK ADD CONSTRAINT [FK_FieldExtra_FieldExtraType] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[FieldExtraType] ([Id])
GO
