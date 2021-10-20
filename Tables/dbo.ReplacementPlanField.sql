CREATE TABLE [dbo].[ReplacementPlanField]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[DatasetId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReplacementPlanField] ADD CONSTRAINT [PK_ReplacementPlanField] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReplacementPlanField] ADD CONSTRAINT [FK_ReplacementPlanField_Dataset] FOREIGN KEY ([DatasetId]) REFERENCES [dbo].[Dataset] ([Id])
GO
