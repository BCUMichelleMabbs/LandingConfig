CREATE TABLE [dbo].[Severity]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
[Remove] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_Severity_Remove] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Severity] ADD CONSTRAINT [PK_ExceptionSeverity] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
