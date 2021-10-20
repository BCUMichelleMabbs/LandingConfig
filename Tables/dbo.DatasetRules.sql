CREATE TABLE [dbo].[DatasetRules]
(
[DatasetId] [int] NOT NULL,
[RuleId] [int] NOT NULL,
[FieldId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetRules] ADD CONSTRAINT [PK_FieldRules] PRIMARY KEY CLUSTERED ([DatasetId], [RuleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatasetRules] ADD CONSTRAINT [FK_DatasetRules_Dataset] FOREIGN KEY ([DatasetId]) REFERENCES [dbo].[Dataset] ([Id])
GO
ALTER TABLE [dbo].[DatasetRules] ADD CONSTRAINT [FK_FieldRules_Rule] FOREIGN KEY ([RuleId]) REFERENCES [dbo].[Rule] ([Id])
GO
