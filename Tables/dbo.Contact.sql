CREATE TABLE [dbo].[Contact]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Value] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[TypeId] [int] NOT NULL,
[Active] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_Contact_Active] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contact] ADD CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contact] ADD CONSTRAINT [FK_Contact_ContactType] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[ContactType] ([Id])
GO
