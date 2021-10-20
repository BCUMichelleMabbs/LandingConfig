CREATE TABLE [dbo].[LoadAudit]
(
[Load_Guid] [uniqueidentifier] NOT NULL CONSTRAINT [DF__LoadAudit__Load___43D61337] DEFAULT (newid()),
[ProcessStart] [smalldatetime] NOT NULL,
[ProcessEnd] [smalldatetime] NULL,
[RunBy] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[ScheduleId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoadAudit] ADD CONSTRAINT [PK__LoadAudi__F0787AD77AEAB5CD] PRIMARY KEY CLUSTERED ([Load_Guid]) ON [PRIMARY]
GO
