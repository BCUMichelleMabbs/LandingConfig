CREATE TABLE [dbo].[AuditItem_Archive]
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER 
	[DatasetErrors] ON 
	[Landing_Config].[dbo].[AuditItem]
	AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [7A1A1SRVINFODEV].[David].[dbo].[DatasetErrors]
	SELECT Dataset, Value, Logged   FROM inserted
END
GO
DISABLE TRIGGER [dbo].[DatasetErrors] ON [dbo].[AuditItem_Archive]
GO
DISABLE TRIGGER [dbo].[DatasetErrors] ON [dbo].[AuditItem_Archive]
GO
DISABLE TRIGGER [dbo].[DatasetErrors] ON [dbo].[AuditItem_Archive]
GO
