SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Update_WPAS_Data_OPA_CPT_Flag]
AS	
BEGIN
	
	SET NOCOUNT ON;

DECLARE @ThisFilterRowId AS INT
DECLARE @MaxFilterRowId AS INT
DECLARE @ThisCriteriaRowId AS INT
DECLARE @MaxCriteriaRowId AS INT
DECLARE @Load_GUID AS VARCHAR(38)=(SELECT TOP 1 [Load_Guid] FROM [Landing_Config].[dbo].[LoadAudit] ORDER BY ProcessStart DESC)
DECLARE @FilterId					INT
DECLARE @FilterCriteriaCount		INT
DECLARE @FilterCriteriaCurrentRow	INT
DECLARE @Area						VARCHAR(10)
DECLARE @Fieldname					VARCHAR(50)
DECLARE @FunctionKey				VARCHAR(50)
DECLARE @FunctionValue				VARCHAR(50)
DECLARE @Operator					VARCHAR(50)
DECLARE @Value						VARCHAR(MAX)
DECLARE @ValueType					VARCHAR(50)
DECLARE @ValueArray					VARCHAR(1)
DECLARE @Result						VARCHAR(50)

DECLARE @Filter TABLE
(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	DataSetId			INT,
	FilterId			INT,
	Name				VARCHAR(50),
	Area				VARCHAR(10),
	Result				VARCHAR(50)
)
DECLARE @FilterCriteria TABLE 
(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1), 
	FieldName			VARCHAR(50),
	FunctionKey			VARCHAR(50),
	FunctionValue		VARCHAR(50),
	Operator			VARCHAR(50),
	Value				VARCHAR(MAX),
	ValueType			VARCHAR(50),
	ValueArray			VARCHAR(1),
	FilterId			INT
)


INSERT INTO @Filter (DataSetId, FilterId, Name, Area, Result)
SELECT 
	F.DatasetId, F.Id, F.Name, F.Area, F.Result 
FROM 
	[7A1A1SRVINFODW1].CPT.dbo.Filter F 
	INNER JOIN [7A1A1SRVINFODW1].CPT.dbo.Dataset D ON D.Id = F.DatasetId 
WHERE 
	D.Name = 'MP - new warehouse OPA test' AND 
	F.Active = 'Y' 
ORDER BY 
	RuleOrder ASC
SELECT @ThisFilterRowId = MIN(RowId), @MaxFilterRowId = MAX(RowId) FROM @Filter

WHILE @ThisFilterRowId <= @MaxFilterRowId
	BEGIN

		SELECT @FilterId=FilterId,@Area=Area,@Result=Result FROM @Filter WHERE RowId=@ThisFilterRowId
		
		INSERT INTO @FilterCriteria (Fieldname, FunctionKey, FunctionValue, Operator, Value, ValueType, ValueArray, FilterId)
		SELECT 
			Fieldname, FunctionKey, FunctionValue, Operator, Value, ValueType, ValueArray, FilterId
		FROM 
			[7A1A1SRVINFODW1].CPT.dbo.FilterCriteria FC
		WHERE 
			FC.FilterId = @FilterId
		SELECT @ThisCriteriaRowId = MIN(RowId), @MaxCriteriaRowId = MAX(RowId) FROM @FilterCriteria

		DECLARE @SQL AS VARCHAR(MAX)
		DECLARE @SQL_AuditDetail AS VARCHAR(MAX)

		SET @SQL = 
			CASE @Result
				WHEN 'Exclude' THEN 'UPDATE Foundation.dbo.WPAS_Data_OPA SET CPTFlag=''N'' WHERE Load_GUID='''+@Load_GUID+''' AND '
				WHEN 'Include' THEN 'UPDATE Foundation.dbo.WPAS_Data_OPA SET CPTFlag=''Y'' WHERE Load_GUID='''+@Load_GUID+''' AND '
			END
		
		WHILE @ThisCriteriaRowId <= @MaxCriteriaRowId
			BEGIN  --3
				SELECT 
					@Fieldname=Fieldname,
					@FunctionKey=FunctionKey, 
					@FunctionValue=FunctionValue, 
					@Operator=Operator, 
					@Value=Value, 
					@ValueType=ValueType, 
					@ValueArray=ValueArray 
				FROM 
					@FilterCriteria 
				WHERE 
					RowId = @ThisCriteriaRowId

				--The lines below allow for functions like rtrim (without a second argument) as well as functions like left(fieldname, 2)
				SET @SQL += CASE 
								WHEN @FunctionKey IS NOT NULL THEN 
									CASE
										WHEN @FunctionValue IS NOT NULL THEN
											@FunctionKey + '(' + @Fieldname + ',' + @FunctionValue + ') '
										WHEN @FunctionValue IS NULL	THEN
											@FunctionKey + '(' + @Fieldname + ') '
									END
								WHEN @FunctionKey IS NULL THEN @Fieldname + ' '
							END
	
				SET @SQL += @Operator + ' '
	
				SET  @Value = CASE @Operator WHEN 'Like' THEN '%' + @Value + '%' ELSE @Value END
	
				SET @SQL +=
				CASE
					WHEN @ValueType = 'string' THEN
						CASE @ValueArray 
							WHEN 'Y' THEN '(''' + REPLACE(@Value,'|',''',''') + ''')'
							WHEN 'N' THEN '''' + @Value + ''''
						END
					WHEN @ValueType = 'int' THEN
						CASE	@ValueArray
							WHEN 'Y' THEN '(' + REPLACE(@Value,'|',',') + ')'
							WHEN 'N' THEN @Value
						END
					WHEN @ValueType = 'sql' THEN  --Don't allow arrays of sql statements
						'(' + @Value + ')'
				END

		

		IF @ThisCriteriaRowId < @MaxCriteriaRowId
			BEGIN
				SET @SQL += ' AND '
			END
		SET @ThisCriteriaRowId+=1;
		END --3  End the filtercriteria bit
		
	SET @SQL +=
		CASE @Area
			WHEN 'Central' THEN ' AND Area = ''Central'''
			WHEN 'East' THEN ' AND Area = ''East'''
			WHEN 'West' THEN ' AND Area = ''West'''
			WHEN 'OBCU' THEN ' AND Area = ''OBCU'''
			ELSE ''
		END

	EXEC(@SQL)
		
	--PRINT @SQL
		
	DELETE @FilterCriteria
	SET @ThisFilterRowId+=1	
	
	END  --2
END
GO
