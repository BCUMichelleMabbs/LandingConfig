SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Now Create the object
CREATE FUNCTION [dbo].[PIMS_GetRefValID] (	@rityp_code	varchar(10),
					@rfval_refno	numeric(10,0) )

RETURNS varchar(50)
AS

/******************************************************************************************************
Function name: 		IS_GetRefValID
Author name:		CH
Creation Date:		26/06/2008
======================================================================================================
Description:
Returns the IDENTIFIER associated with the supplied rfval_refno and rityp_code.
======================================================================================================
Change History:
v1.00 	26/06/2008	- (CH) Created

******************************************************************************************************/

BEGIN
	-- Declare required variables
	DECLARE	@ReturnID	varchar(50)

	-- Populate the Return variable
	SET @ReturnID = (	select 	top 1 identifier
        			from 	[7A1AUSRVIPMSQLR\REPORTS].[iPMReports].dbo.reference_value_ids with (nolock)
        			where 	ISNULL(archv_flag,'N') = 'N'
        			  and 	rityp_code = @rityp_code
        			  and 	rfval_refno = @rfval_refno
			 )

	IF @ReturnID is null
	BEGIN
		SET @ReturnID = ''
	END

	RETURN @ReturnID
END


GO
