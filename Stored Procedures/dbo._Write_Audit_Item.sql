SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[_Write_Audit_Item]

	@Load_Guid AS VARCHAR(38),
	@Stage AS VARCHAR(100),
	@Action AS VARCHAR(100),
	@Object AS VARCHAR(100),
	@Value AS VARCHAR(MAX),
	@Dataset AS VARCHAR(200)

AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO Landing_Config.dbo.AuditItem (Load_Guid, Stage, Action, Object, Value, Dataset, Logged)
	VALUES (@Load_Guid, @Stage, @Action, @Object, @Value, @Dataset, GetDate())

END
GO
