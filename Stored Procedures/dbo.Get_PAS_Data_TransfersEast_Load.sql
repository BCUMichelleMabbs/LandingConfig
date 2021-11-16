SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_TransfersEast_Load]

AS

BEGIN

IF OBJECT_ID(N'tempdb..#Trial') IS NOT NULL
BEGIN
DROP TABLE #Trial
END 

--use this for manual loads but remember there is a replacement plan set on the warehouse.
--declare @DateOfTransfer as Date = '01 January 2021'

DECLARE @DateOfTransfer AS DATE = (SELECT ISNULL(MAX(EventEndDate),'1 January 2017') FROM [Foundation].[dbo].[PAS_Data_Transfers] where Area = 'East')
DECLARE @DateOfTransferString AS VARCHAR(30) = DATENAME(DAY,@DateOfTransfer) + ' ' + DATENAME(MONTH,@DateOfTransfer) + ' ' + DATENAME(YEAR,@DateOfTransfer)
DECLARE @Load_Guid VARCHAR(38)

SET @Load_Guid = newid();



CREATE TABLE #Trial(

    [Area] [varchar](255) NULL,
    [Source] [varchar](255) NULL,
	[LocalPatientIdentifier] [varchar](255) NULL,
	[SpellNumber] [varchar](20) NULL,
	[EpisodeNo] [int] NULL,
	[PatientLinkIdEpisode] [varchar](220) NULL,
	[AdmissionMethod] [varchar](220) NULL,
	[DischargeMethod] [varchar](20) NULL,
	[EVENTSTARTDATE] [datetime2](7) NULL,
	[EVENTSTARTTIME] [time](7) NULL,
	[EVENTENDDATE] [datetime2](7) NULL,
	[EVENTENDTIME] [time](7) NULL,
	[Consultant] [varchar](20) null,
	[PREVIOUSWARD] [varchar](20) NULL,
	[Ward] [varchar](20) NULL,
	[NEXTWARD] [varchar](20) NULL,
	[Specialty] [varchar](20) NULL,
	[LastUpdate] [datetime2](7) NULL,
	[DischargeDestination] [varchar](20) NULL,
	[TransferNumber] [int] NULL

	)

INSERT INTO #Trial 

EXEC('select
       *
	   
	   
	   
	   FROM(
              SELECT 
                     ''East'' AS Area,
                     ''Myrddin'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TREAT.ACTNOTEKEY AS SpellNumber,
                     TRANS.EPISODENO AS EpisodeNo,  
                     '''' AS PatientLinkIdEpisode,
                     TREAT.ADMIT_METHOD As AdmissionMethod,
                     NULLIF(RTRIM(TREAT.DISMETHOD),'''') AS DischargeMethod,
                     CAST(TRANS.TRANSFER_DATE AS DATE) AS EventStartDate,
                     CASE
                           WHEN TRANS.TRANSFER_DATE IS NULL THEN NULL
                           WHEN TRIM(TRANS.TRANSFER_TIME)='':'' THEN ''00:00''
                           WHEN TRANS.TRANSFER_TIME IS NULL THEN ''00:00''
                           WHEN TRIM(TRANS.TRANSFER_TIME)='''' THEN ''00:00''
                           ELSE SUBSTRING(TRANS.TRANSFER_TIME FROM 1 FOR 2)||'':''||SUBSTRING(TRANS.TRANSFER_TIME FROM 3 FOR 2) 
                     END AS EventStartTime,
                     CAST(CASE
                           WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.DISDATE
                           ELSE (SELECT FIRST 1 innerT.TRANSFER_DATE FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO+1)
                     END AS DATE) AS EventEndDate,
                     CASE
                           WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID) THEN 
                                  CASE
                                         WHEN TREAT.DISDATE IS NULL THEN NULL
                                         WHEN TRIM(TREAT.LEAVING_TIME)='':'' THEN ''00:00''
                                         WHEN TREAT.LEAVING_TIME IS NULL THEN ''00:00''
                                         WHEN TRIM(TREAT.LEAVING_TIME)='''' THEN ''00:00''
                                         ELSE SUBSTRING(TREAT.LEAVING_TIME FROM 1 FOR 2)||'':''||SUBSTRING(TREAT.LEAVING_TIME FROM 3 FOR 2) 
                                  END
                           ELSE (
                                         SELECT FIRST 1
                                                CASE
                                                       WHEN innerT.TRANSFER_DATE IS NULL THEN NULL
                                                       WHEN TRIM(innerT.TRANSFER_TIME)='':'' THEN ''00:00''
                                                       WHEN innerT.TRANSFER_TIME IS NULL THEN ''00:00''
                                                       WHEN TRIM(innerT.TRANSFER_TIME)='''' THEN ''00:00''
                                                       ELSE SUBSTRING(innerT.TRANSFER_TIME FROM 1 FOR 2)||'':''||SUBSTRING(innerT.TRANSFER_TIME FROM 3 FOR 2) 
                                                END
                                         FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO+1
                           ) 
                     END AS EventEndTime,  
                     TRANS.TRANSFER_CONS AS HCP,
                     CASE
                           WHEN TRANS.TRANSFER_NO = 1 THEN TREAT.ALOC
                         WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.CLOC
                           ELSE (SELECT FIRST 1 innerT.TRANSFER_WARD FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO-1)
                     END AS PreviousWard,
                     TRANS.TRANSFER_WARD AS Ward,
                     CASE
                           WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN ''DISCHARGE''
                           ELSE (SELECT FIRST 1 innerT.TRANSFER_WARD FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO+1)
                     END AS NextWard,
                     TRANS.TRANSFER_SPEC AS Specialty,
                     CURRENT_TIMESTAMP  as LastUpdated,
                     NULLIF(RTRIM(TREAT.DESTINATION),'''') AS DischargeDestination,
                     TRANS.TRANSFER_NO AS TransferNumber
              FROM
                     TRANSFER TRANS
                     INNER JOIN TREATMNT TREAT ON TRANS.LINKID=TREAT.LINKID
                     LEFT JOIN PATIENT PAT ON TREAT.CASENO= PAT.CASENO
              WHERE  
                     --CAST(TRANS.TRANSFER_DATE AS DATE) >'''+@DateOfTransferString+''' 
                     --AND CAST(TRANS.TRANSFER_DATE AS DATE) <= '''+@DateOfTransferString+''' 
                      TREAT.TRT_TYPE IN (''AD'',''AC'',''AL'') 
                     AND TRANS.TRANSFER_WARD is  not null
              
UNION
              SELECT 
                     ''East'' AS Area,
                     ''Myrddin'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TREAT.ACTNOTEKEY AS SpellNumber,
                     1 as EpisodeNo,             -- Was TRANS.EPISODENO AS EpisodeNo, but that could have been 2 when 1st XFer due to Spec/Cons change  
                     '''' AS PatientLinkIdEpisode,
                     TREAT.ADMIT_METHOD As AdmissionMethod,
                     NULLIF(RTRIM(TREAT.DISMETHOD),'''') AS DischargeMethod,
                     CAST(TREAT.TRT_DATE AS DATE) AS EventStartDate,
                     CASE
                           WHEN TREAT.TRT_DATE IS NULL THEN NULL
                           WHEN TRIM(TREAT.APPOINTMENT_TIME)='':'' THEN ''00:00''
                           WHEN TREAT.APPOINTMENT_TIME IS NULL THEN ''00:00''
                           WHEN TRIM(TREAT.APPOINTMENT_TIME)='''' THEN ''00:00''
                           ELSE SUBSTRING(TREAT.APPOINTMENT_TIME FROM 1 FOR 2)||'':''||SUBSTRING(TREAT.APPOINTMENT_TIME FROM 3 FOR 2) 
                     END AS EventStartTime,
                     CAST(COALESCE(TRANS.TRANSFER_DATE,TREAT.DISDATE) AS DATE) AS EventEndDate,
                     COALESCE(
                           CASE
                                  WHEN TRANS.TRANSFER_DATE IS NULL THEN NULL
                                  WHEN TRIM(TRANS.TRANSFER_TIME)='':'' THEN ''00:00''
                                  WHEN TRANS.TRANSFER_TIME IS NULL THEN ''00:00''
                                  WHEN TRIM(TRANS.TRANSFER_TIME)='''' THEN ''00:00''
                                  ELSE SUBSTRING(TRANS.TRANSFER_TIME FROM 1 FOR 2)||'':''||SUBSTRING(TRANS.TRANSFER_TIME FROM 3 FOR 2) 
                           END,
                           CASE
                                  WHEN TREAT.DISDATE IS NULL THEN NULL
                                  WHEN TRIM(TREAT.LEAVING_TIME)='':'' THEN ''00:00''
                                  WHEN TREAT.LEAVING_TIME IS NULL THEN ''00:00''
                                  WHEN TRIM(TREAT.LEAVING_TIME)='''' THEN ''00:00''
                                  ELSE SUBSTRING(TREAT.LEAVING_TIME FROM 1 FOR 2)||'':''||SUBSTRING(TREAT.LEAVING_TIME FROM 3 FOR 2) 
                           END
                     ) AS EventEndTime,
                     TREAT.ACONS AS HCP,
                     ''ADMISSION'' AS PreviousWard,
                     TREAT.ALOC AS Ward,
                     CASE
                           WHEN TRANS.EPISODENO IS NULL AND TREAT.DISDATE IS NOT NULL THEN ''DISCHARGE''
                           WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.CLOC
                           ELSE (SELECT FIRST 1 innerT.TRANSFER_WARD FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO)
                     END AS NextWard,
                     TREAT.ASPEC AS Specialty,
                     CURRENT_TIMESTAMP  as LastUpdated,
                     NULLIF(RTRIM(TREAT.DESTINATION),'''') AS DischargeDestination,
                     0 AS TransferNumber
				     
              FROM
                     TREATMNT TREAT
                     LEFT JOIN TRANSFER TRANS ON TRANS.LINKID=TREAT.LINKID AND TRANS.TRANSFER_NO=1
                     LEFT JOIN PATIENT PAT ON TREAT.CASENO= PAT.CASENO
			 WHERE 
                     --CAST(TREAT.TRT_DATE AS DATE) > '''+@DateOfTransferString+''' 
                     ---AND CAST(TREAT.TRT_DATE AS DATE) <= '''+@DateOfTransferString+''' 
                      TREAT.TRT_TYPE IN (''AD'',''AC'',''AL'') 
                     AND TRANS.TRANSFER_WARD is  not null
       ) 
              ORDER BY 
                     EventStartDate, SpellNumber'
) AT WPAS_East

--SELECT * FROM #Trial ;

;WITH final_transfer

AS
(
SELECT
    [Area],
	[Source],
	[LocalPatientIdentifier],
	[SpellNumber],
	[EpisodeNo],
	[PatientLinkIdEpisode],
	[AdmissionMethod],
	[DischargeMethod],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[Consultant],
	[PREVIOUSWARD],
	[Ward] ,
	[NEXTWARD],
	[Specialty],
	[LastUpdate],
	[DischargeDestination],
	[TransferNumber],
    ROW_NUMBER() OVER(PARTITION BY [SpellNumber],[WARD] ORDER BY [EVENTENDTIME]) AS rowid  FROM  #Trial
),

--SELECT * FROM final_transfer ;

final_transfer1

AS(

SELECT 
    [Area],
    [Source],
	[LocalPatientIdentifier],
	[SpellNumber],
	[EpisodeNo],
	[PatientLinkIdEpisode],
	[AdmissionMethod],
	[DischargeMethod],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[Consultant],
	[PREVIOUSWARD],
	[Ward] ,
	[NEXTWARD],
	[Specialty],
	[LastUpdate],
	[DischargeDestination],
	[TransferNumber] AS TransferNumber_bckup

FROM

final_transfer
WHERE rowid =  1

) 

--SELECT * FROM final_transfer1 ;
INSERT INTO Foundation.dbo.PAS_Data_TransfersII
(
    Load_Guid,
	[LoadDate],
	[Area],
    [Source],
	[LocalPatientIdentifier],
	[ProviderSpellNumber],
	[EpisodeNumber],
	--[PatientLinkIdEpisode],
	[AdmissionMethod],
	[DischargeMethod],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[HCP],
	[PREVIOUSWARD],
	[Ward] ,
	[NEXTWARD],
	[Specialty],
	[LastUpdate],
	[DischargeDestination],
	TransferNumber
	)
SELECT 
    @Load_GUID,
	GETDATE(),
	[Area],
    [Source],
	[LocalPatientIdentifier],
	[SpellNumber],
	[EpisodeNo],
	--[PatientLinkIdEpisode],
	[AdmissionMethod],
	[DischargeMethod],
	[EVENTSTARTDATE],
	[EVENTSTARTTIME],
	[EVENTENDDATE],
	[EVENTENDTIME],
	[Consultant],
	[PREVIOUSWARD],
	[Ward] ,
	[NEXTWARD],
	[Specialty],
	[LastUpdate],
	[DischargeDestination],
	--TransferNumber_bckup,
    ROW_NUMBER() OVER(PARTITION BY [SpellNumber] ORDER BY [TransferNumber_bckup]) -1 AS TransferNumber  
   
     FROM  final_transfer1

	 ORDER BY  [SpellNumber] 
     
	 ;



END 
GO
