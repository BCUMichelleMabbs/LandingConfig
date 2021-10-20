CREATE TABLE [dbo].[AuditItem]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Load_Guid] [varchar] (38) COLLATE Latin1_General_CI_AS NOT NULL,
[Stage] [varchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[Action] [varchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[Object] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Value] [varchar] (max) COLLATE Latin1_General_CI_AS NOT NULL,
[Dataset] [varchar] (200) COLLATE Latin1_General_CI_AS NULL,
[Logged] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditItem] ADD CONSTRAINT [PK_AuditItem] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
