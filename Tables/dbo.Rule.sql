CREATE TABLE [dbo].[Rule]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Text] [varchar] (max) COLLATE Latin1_General_CI_AS NOT NULL,
[TypeId] [int] NOT NULL,
[SeverityId] [int] NOT NULL,
[Active] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_Rule_Active] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Rule] ADD CONSTRAINT [PK_Rule] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Rule] ADD CONSTRAINT [FK_Rule_RuleType] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[RuleType] ([Id])
GO
ALTER TABLE [dbo].[Rule] ADD CONSTRAINT [FK_Rule_Severity] FOREIGN KEY ([SeverityId]) REFERENCES [dbo].[Severity] ([Id])
GO
