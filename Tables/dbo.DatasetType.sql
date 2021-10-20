CREATE TABLE [dbo].[DatasetType]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetType] ADD CONSTRAINT [PK_DatasetType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
