CREATE TABLE [dbo].[Field]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Definition] [varchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Description] [varchar] (300) COLLATE Latin1_General_CI_AS NULL,
[Link] [varchar] (255) COLLATE Latin1_General_CI_AS NULL,
[ApplicationName] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[DatatypeId] [int] NOT NULL,
[Length] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[IncomingFormat] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[InMainQuery] [char] (1) COLLATE Latin1_General_CI_AS NULL CONSTRAINT [DF_Field_InMainQuery] DEFAULT ('Y'),
[DatasetId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Field] ADD CONSTRAINT [PK_Field] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Field] ADD CONSTRAINT [FK_Field_Datatype] FOREIGN KEY ([DatatypeId]) REFERENCES [dbo].[Datatype] ([Id])
GO
ALTER TABLE [dbo].[Field] ADD CONSTRAINT [FK_Field_Table] FOREIGN KEY ([DatasetId]) REFERENCES [dbo].[Dataset] ([Id])
GO
