SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Update_PAS_Transfer]
@Load_GUID AS VARCHAR(38)

--declare @Load_GUID varchar(50)
--set @Load_GUID = 'DA2C2F8A-BA82-42B3-BC5F-5008E6060737'


AS	
BEGIN
	
	SET NOCOUNT ON;


IF OBJECT_ID(N'tempdb..#DataLoad') IS NOT NULL
BEGIN
DROP TABLE #DataLoad
END 


CREATE TABLE #DataLoad(

   	[Row_GUID] [varchar](50) NULL,
	[LocalPatientIdentifier] [varchar](255) NULL,
	[SpellNumber] [varchar](20) NULL,
	[EVENTSTARTDATE] [datetime2](7) NULL,
	[EVENTSTARTTIME] [time](7) NULL,
	[EVENTENDDATE] [datetime2](7) NULL,
	[EVENTENDTIME] [time](7) NULL,
	[Ward] [varchar](20) NULL,
	[TransferNumber] [int] NULL

	)

	INSERT INTO #DataLoad 

    SELECT 

	[Row_GUID],
	[LocalPatientIdentifier],
	[ProviderSpellNumber],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[Ward],
	[TransferNumber]
	
	FROM 
	
	Foundation.dbo.PAS_Data_Transfers T

	WHERE
	T.Load_GUID = @Load_GUID 
	--AND
	--Area IN ('Central','East') 


	---SELECT  * FROM #DataLoad where SpellNumber = 12199176 ORDER BY TransferNumber
	
;WITH 

final_transfer

AS
(
    
	SELECT
	[Row_GUID],
	[LocalPatientIdentifier],
	[SpellNumber],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[Ward] ,
	[TransferNumber],
    ROW_NUMBER() OVER(PARTITION BY [SpellNumber],TransferNumber ORDER BY [EVENTSTARTTIME],[EVENTENDTIME]) AS RowID 
	FROM  #DataLoad
)

, Dups

AS(

SELECT 
    [Row_GUID],
    [LocalPatientIdentifier],
	[SpellNumber],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[Ward] ,
	[TransferNumber],
    CASE WHEN RowID =  1 THEN 'N' ELSE 'Y' END AS DuplicateFlag,
	RowID
    
    FROM final_transfer 
	--WHERE SpellNumber = 12193534

)

--SELECT * FROM Dups ORDER BY TransferNumber,ROWID

,final_transfer1

AS(

SELECT 
   [Row_GUID],
	[SpellNumber],
	[TransferNumber] AS TransferNumber_bckup,
	(ROW_NUMBER() OVER(PARTITION BY [SpellNumber] ORDER BY [TransferNumber]) -1) AS TransferNumber_Revised

	FROM

	final_transfer
	WHERE rowid =  1 
	--AND SpellNumber = 12193534

) 

--SELECT * FROM final_transfer1 where SpellNumber = 12193534


,FinalDataLoad
AS
(

SELECT 
 
    D.[Row_GUID],
    D.[LocalPatientIdentifier],
	D.[SpellNumber],
	D.[EVENTSTARTDATE],
	D.[EVENTSTARTTIME],
	D.[EVENTENDDATE],
	D.[EVENTENDTIME],
	D.[Ward] ,
	D.[TransferNumber],
    D.DuplicateFlag,
	D.RowID,
	FT.TransferNumber_Revised

	FROM  Dups D
	LEFT JOIN  final_transfer1  FT ON D.Row_GUID = FT.Row_GUID AND D.SpellNumber = FT.SpellNumber

	)


	--SELECT * FROM FinalDataLoad  where spellnumber  = 11934514 order by TransferNumber_Revised


UPDATE
	Foundation.dbo.PAS_Data_Transfers 
SET
	TransferNumber_Revised = CASE WHEN PT.Area IN ('Central','East') THEN T.TransferNumber_Revised
	ELSE PT.TransferNumber END,
	DuplicateFlag =  CASE WHEN PT.Area IN ('Central','East') THEN T.DuplicateFlag
					ELSE PT.DuplicateFlag END

FROM
    Foundation.dbo.PAS_Data_Transfers  PT
	INNER JOIN  FinalDataLoad T ON T.Row_GUID = PT.Row_GUID 
	
	
WHERE
	PT.Load_GUID = @Load_GUID 






END
	
GO
