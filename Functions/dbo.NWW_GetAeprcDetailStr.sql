SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[NWW_GetAeprcDetailStr] (
                           @sorce_code   varchar(10),  -- e.g. 'SCHDL'
                           @sorce_refno  numeric(10,0),       -- e.g. schdl.schdl_refno
                           @dptyp_code   varchar(10),  -- e.g. 'PROCE'
                           @ccsxt_code   varchar(5),   -- e.g. 'I10' for ICD10
                           @mplev_code   varchar(10),  -- e.g. 'SECND'
                           @num          int,          -- e.g. 12 (the number of codes to return)
                           @len          int,          -- e.g. 4 (the length of each code)
                           @type         char(1)       = 'C'  -- (D)etails (code, dttm, status) or (C)ode only
                           )

RETURNS varchar(1000)
AS

/******************************************************************************************************
Function name:             NWW_GetAeprcDetailStr
Author name:         JP
Creation Date:             10/09/2009
======================================================================================================
Description:
Returns the diagnosis or procedure description matching the supplied context code and level for the activity
represented by the supplied sorce_code and refno.  The @num determines how many are returned.
======================================================================================================
Change History:
v1.00 10/09/2009    - (JP) Created
******************************************************************************************************/

BEGIN

       -- Declare required variables
       DECLARE       @ReturnVal    varchar(1000),
              @DiagProc     varchar(50),
              @dgpro_dttm   varchar(8),
              @dttm_status  char(1),
              @mplev_refno  numeric(10,0),
              @cnt          int

       -- Set @mplev_refno = to the refno relating to the supplied mplev code
       SET @mplev_refno = ( select        rfval_refno
                           from   [7A1AUSRVIPMSQL].iPMProduction.dbo.reference_values with (nolock)
                           where  rfvdm_code = 'MPLEV'
                             and  main_code = @mplev_code
                             and  ISNULL(archv_flag,'N') = 'N' )

       -- Set initial values for the return value and the loop control
       SET @ReturnVal = ''
       SET @cnt = 1

       -- Declare cursor to get the number of codes specified
       DECLARE cur_diag_proc CURSOR FOR 
       select  isnull(odpcd.description,''),
              isnull(convert(varchar(8),dgpro.dgpro_dttm,112),'        ')
       from   [7A1AUSRVIPMSQL].iPMProduction.dbo.diagnosis_procedures as dgpro with (nolock)
                     join [7A1AUSRVIPMSQL].iPMProduction.dbo.odpcd_codes as odpcd with (nolock)
                     on dgpro.odpcd_refno = odpcd.odpcd_refno
       where ISNULL(dgpro.archv_flag,'N') = 'N'
         and  dgpro.dptyp_code = @dptyp_code
         and  odpcd.ccsxt_code = @ccsxt_code
         and  dgpro.sorce_code = @sorce_code
         and  dgpro.sorce_refno = @sorce_refno
       order by convert(varchar,dgpro.dgpro_dttm,112)
--            sort_order

       -- Now open the cursor and start fetching values
       OPEN cur_diag_proc
       FETCH NEXT FROM cur_diag_proc INTO @DiagProc, @dgpro_dttm

       -- Set up loop to return the number of codes defined by @num
       WHILE @@fetch_status = 0 AND @cnt <= @num
              BEGIN
                     -- Populate the Return variable
                     IF @cnt < 2
                           SET @ReturnVal = @DiagProc
                     ELSE
                           SET @ReturnVal = @ReturnVal + ', ' + @DiagProc
                     
                     IF @type = 'D'       -- Need to add date and date status
                     BEGIN
                           SET @dttm_status = CASE @dgpro_dttm WHEN '        ' THEN '8' ELSE '1' END
                           SET @ReturnVal = @ReturnVal + @dgpro_dttm + @dttm_status
                     END
       
                     SET @cnt = @cnt + 1

                     FETCH NEXT FROM cur_diag_proc INTO @DiagProc, @dgpro_dttm
              END

       CLOSE         cur_diag_proc
       DEALLOCATE    cur_diag_proc

       RETURN @ReturnVal
END







GO
