CREATE TABLE [dbo].[Dataset]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[FromDefinition] [varchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Alias] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[ProcTypeId] [int] NULL,
[GroupId] [int] NOT NULL,
[ReplacementPlanId] [int] NULL,
[DatasetTypeId] [int] NULL,
[ScheduleId] [int] NULL,
[PostFoundationProc] [varchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Active] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_Table_Active] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dataset] ADD CONSTRAINT [PK_Table] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dataset] ADD CONSTRAINT [FK_Dataset_DatasetType] FOREIGN KEY ([DatasetTypeId]) REFERENCES [dbo].[DatasetType] ([Id])
GO
ALTER TABLE [dbo].[Dataset] ADD CONSTRAINT [FK_Dataset_ProcType] FOREIGN KEY ([ProcTypeId]) REFERENCES [dbo].[ProcType] ([Id])
GO
ALTER TABLE [dbo].[Dataset] ADD CONSTRAINT [FK_Dataset_ReplacementPlan] FOREIGN KEY ([ReplacementPlanId]) REFERENCES [dbo].[ReplacementPlan] ([Id])
GO
ALTER TABLE [dbo].[Dataset] ADD CONSTRAINT [FK_Dataset_Schedule] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[Schedule] ([Id])
GO
ALTER TABLE [dbo].[Dataset] ADD CONSTRAINT [FK_Table_System] FOREIGN KEY ([GroupId]) REFERENCES [dbo].[DatasetGroup] ([Id])
GO
