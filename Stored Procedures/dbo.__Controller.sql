SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[__Controller]
	@Schedule VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @Load_GUIDs AS TABLE(
	Load_GUID VARCHAR(38)
)
DECLARE @Load_GUID varchar(38)
DECLARE @Username VARCHAR(50)
DECLARE @RunStart SMALLDATETIME
DECLARE @RunEnd SMALLDATETIME
DECLARE @ThisStageFeedback VARCHAR(100)
DECLARE @ScheduleId INT
DECLARE @DimensionServer AS NVARCHAR(200)='[BCUINFO\BCUDATAWAREHOUSE]'

--AUDIT
/* * * * * * * * * * * * * * * * * * * * * * * */
SET @Username = ORIGINAL_LOGIN()
SET @RunStart = GETDATE()

SET @ScheduleId = (SELECT Id FROM Landing_Config.dbo.Schedule S WHERE S.Name = @Schedule)

IF @ScheduleId IS NOT NULL
	BEGIN
		INSERT INTO Landing_Config.dbo.LoadAudit(ProcessStart, RunBy,ScheduleId) 
		OUTPUT inserted.Load_Guid INTO @Load_GUIDs
		VALUES (@RunStart, @Username,@ScheduleId)
		SET @Load_GUID = (SELECT TOP 1 Load_GUID FROM @Load_GUIDs)
		/* * * * * * * * * * * * * * * * * * * * * * * */

		
		/* * * * * * * * * * * * * * * * * * * * * * * */
		EXEC Landing_Config.dbo._Init_Landing_Tables @Load_Guid, @ScheduleId

		EXEC Landing_Config.dbo._Init_Exception_Tables @Load_Guid, @ScheduleId

		EXEC Landing_Config.dbo._Init_Foundation_Tables @Load_Guid, @ScheduleId

		EXEC Landing_Config.dbo._Prep_Foundation_Tables @Load_Guid, @RunStart, @ScheduleId  --Swapped all these around as we may want to check a max date in the foundation tables to load in the landing tables

		EXEC Landing_Config.dbo._Load_Landing_Tables @Load_GUID, @RunStart, @ScheduleId

		EXEC Landing_Config.dbo._Apply_Standard_Rules @Load_GUID, @ScheduleId

		EXEC Landing_Config.dbo._Apply_Custom_Rules @Load_GUID, @ScheduleId

		EXEC Landing_Config.dbo._Load_Foundation_Tables @Load_Guid, @RunStart, @ScheduleId

		EXEC Landing_Config.dbo._Update_Foundation_Tables @Load_Guid, @ScheduleId

		EXEC Landing_Config.dbo._Send_Notifications @Load_Guid, @ScheduleId
		/* * * * * * * * * * * * * * * * * * * * * * * */


		--AUDIT
		/* * * * * * * * * * * * * * * * * * * * * * * */
		UPDATE Landing_Config.dbo.LoadAudit SET ProcessEnd = GETDATE() WHERE Load_Guid = @Load_GUID
		/* * * * * * * * * * * * * * * * * * * * * * * */

	END

END
GO
