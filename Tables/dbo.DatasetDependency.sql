CREATE TABLE [dbo].[DatasetDependency]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[DatasetId] [int] NOT NULL,
[DependencyDatasetId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetDependency] ADD CONSTRAINT [PK_DatasetDependency] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatasetDependency] ON [dbo].[DatasetDependency] ([DatasetId], [DependencyDatasetId]) ON [PRIMARY]
GO
