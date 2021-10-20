CREATE TABLE [dbo].[DatasetLoadProc]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (max) COLLATE Latin1_General_CI_AS NOT NULL,
[DatasetId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetLoadProc] ADD CONSTRAINT [PK_DatasetLoadProc] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetLoadProc] ADD CONSTRAINT [FK_DatasetLoadProc_Dataset] FOREIGN KEY ([DatasetId]) REFERENCES [dbo].[Dataset] ([Id])
GO
