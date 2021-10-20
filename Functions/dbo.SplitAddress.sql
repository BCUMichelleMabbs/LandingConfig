SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[SplitAddress] ( @stringToSplit VARCHAR(MAX) )
RETURNS
 @returnList TABLE 
 (
	PatAddress1 [varchar] (100) default NULL,
	PatAddress2 [varchar] (100) default NULL,
	PatAddress3 [varchar] (100) default NULL,
	PatAddress4 [varchar] (100) default NULL,
	PatAddress5 [varchar] (100) default NULL
)
AS
BEGIN

DECLARE @fieldCount int
DECLARE @name NVARCHAR(MAX)
DECLARE @pos INT
SET @fieldCount = 1

WHILE @fieldCount <= 5
	BEGIN

	SELECT @pos  = CHARINDEX(CHAR(10), @stringToSplit)

	if @pos = 0
		begin
			select @name = @stringToSplit
			set @stringToSplit = ''
		end
	else
		begin
			select @name = SUBSTRING(@stringToSplit, 1, @pos-1)
		end

	--Wouldn't work with 'case' or dynamic sql so using this instead
	if @fieldCount = 1
		begin
			Insert into @returnList (PatAddress1) values (Left(@name,100))
		end
	if @fieldCount = 2
		begin
			update @returnList set PatAddress2  = Left(@name,100)
		end
	if @fieldCount = 3
		begin
			update @returnList set PatAddress3  = Left(@name,100)
		end
	if @fieldCount = 4
		begin
			update @returnList set PatAddress4  = Left(@name,100)
		end
	if @fieldCount = 5
		begin
			update @returnList set PatAddress5  = Left(@name,100)
		end

	select @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
	 
	set @fieldCount = @fieldCount + 1
	 
	END
 RETURN
END





GO
