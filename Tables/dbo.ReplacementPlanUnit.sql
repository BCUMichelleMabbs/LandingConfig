CREATE TABLE [dbo].[ReplacementPlanUnit]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReplacementPlanUnit] ADD CONSTRAINT [PK_ReplacementPlanUnit] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
