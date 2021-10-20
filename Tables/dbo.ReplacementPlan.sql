CREATE TABLE [dbo].[ReplacementPlan]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Value] [int] NULL,
[UnitId] [int] NULL,
[TypeId] [varchar] (2) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReplacementPlan] ADD CONSTRAINT [PK_ReplacementPlan] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReplacementPlan] ADD CONSTRAINT [FK_ReplacementPlan_ReplacementPlanType] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[ReplacementPlanType] ([Id])
GO
