SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_cb_test] 
@table varchar(100)
as
begin
EXEC('
       SELECT * FROM(
            select a.rdb$field_name, b.rdb$field_type  from rdb$relation_fields a
			join rdb$fields b on b.rdb$field_name = a.rdb$field_source
where rdb$relation_name= ''' + @table + '''

	   )'
) AT [WPAS_Central];
END
GO
