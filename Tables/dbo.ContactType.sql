CREATE TABLE [dbo].[ContactType]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ContactType] ADD CONSTRAINT [PK_ContactType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
