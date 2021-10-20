CREATE TABLE [dbo].[RuleValue]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Value] [varchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RuleValue] ADD CONSTRAINT [PK_RuleValue] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
