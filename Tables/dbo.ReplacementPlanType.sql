CREATE TABLE [dbo].[ReplacementPlanType]
(
[Id] [varchar] (2) COLLATE Latin1_General_CI_AS NOT NULL,
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReplacementPlanType] ADD CONSTRAINT [PK_ReplacementPlanType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
