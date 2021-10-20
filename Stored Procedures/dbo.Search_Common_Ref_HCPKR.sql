SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Search_Common_Ref_HCPKR] 
(
		@column varchar (100) , 
		@value varchar (100)
		
)
	
	AS
BEGIN
	SET NOCOUNT ON;


declare @sql varchar(max)
Set @sql =
   (' SELECT	LocalCode, 
				LocalName, 
				MainCode as NationalCode, 
				Source, 
				Area 

	
	from Foundation.dbo.Common_Ref_HCP 
	 where '+ @Column +' like  ''%' +@value+ '%'''


	)

	

--print @sql
	
exec (@sql)


end

--Exec [dbo].[Search_Common_Ref_HCPkr] @column = 'localcode', @value = 'liv'


GO
