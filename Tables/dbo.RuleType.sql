CREATE TABLE [dbo].[RuleType]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RuleType] ADD CONSTRAINT [PK_RuleType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
