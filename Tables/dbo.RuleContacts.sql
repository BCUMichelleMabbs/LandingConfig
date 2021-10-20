CREATE TABLE [dbo].[RuleContacts]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[DatasetId] [int] NULL,
[RuleId] [int] NOT NULL,
[ContactId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RuleContacts] ADD CONSTRAINT [PK_RuleContacts] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
