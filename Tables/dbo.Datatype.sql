CREATE TABLE [dbo].[Datatype]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[SQLName] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Datatype] ADD CONSTRAINT [PK_Datatype] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
