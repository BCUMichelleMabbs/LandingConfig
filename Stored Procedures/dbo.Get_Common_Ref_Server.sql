SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure  [dbo].[Get_Common_Ref_Server] 

as begin 

Declare @execution_id bigint

EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Server.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'DTOC', @project_name=N'ServerCheck', @use32bitruntime=False, @reference_id=Null

DECLARE @var0 smallint = 1

EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var0

EXEC [SSISDB].[catalog].[start_execution] @execution_id


END
GO
