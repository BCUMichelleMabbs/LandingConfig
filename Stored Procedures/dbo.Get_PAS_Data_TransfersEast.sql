SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- ================================================================
-- Author:		Champika Balasuriya
-- Create date: July 2021
-- Description:	Extract of all episode and ward transfers WPAS East
-- ================================================================
CREATE PROCEDURE [dbo].[Get_PAS_Data_TransfersEast]
	
AS
--BEGIN TRY
	BEGIN
	SET NOCOUNT ON;


--use this for manual loads but remember there is a replacement plan set on the warehouse.
--declare @DateOfTransfer as Date = '01 January 2021'

DECLARE @DateOfTransfer AS DATE = (SELECT ISNULL(MAX(EventEndDate),'1 January 2017') FROM [Foundation].[dbo].[PAS_Data_Transfers] where Area = 'East')
DECLARE @DateOfTransferString AS VARCHAR(30) = DATENAME(DAY,@DateOfTransfer) + ' ' + DATENAME(MONTH,@DateOfTransfer) + ' ' + DATENAME(YEAR,@DateOfTransfer)




EXEC('select
       *
	   
	   
	   
	   FROM(
              SELECT 
                     ''East'' AS Area,
                     ''Myrddin'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TREAT.ACTNOTEKEY AS SpellNumber,
                     TRANS.EPISODENO AS EpisodeNo,  
                     --'''' AS PatientLinkIdEpisode,
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
                         --WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.CLOC
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
                     CAST(TRANS.TRANSFER_DATE AS DATE) >'''+@DateOfTransferString+''' 
                     --AND CAST(TRANS.TRANSFER_DATE AS DATE) <= '''+@DateOfTransferString+''' 
                     AND TREAT.TRT_TYPE IN (''AD'',''AC'',''AL'') 
                     AND TRANS.TRANSFER_WARD is  not null
              
UNION
              SELECT 
                     ''East'' AS Area,
                     ''Myrddin'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TREAT.ACTNOTEKEY AS SpellNumber,
                     1 as EpisodeNo,             -- Was TRANS.EPISODENO AS EpisodeNo, but that could have been 2 when 1st XFer due to Spec/Cons change  
                     --'''' AS PatientLinkIdEpisode,
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
                           --WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.CLOC
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
                     CAST(TREAT.TRT_DATE AS DATE) > '''+@DateOfTransferString+''' 
                    -- AND CAST(TREAT.TRT_DATE AS DATE) <= '''+@DateOfTransferString+''' 
                     AND TREAT.TRT_TYPE IN (''AD'',''AC'',''AL'') 
                     AND TRANS.TRANSFER_WARD is  not null
       ) 
              ORDER BY 
                     EventStartDate, SpellNumber'
) AT WPAS_East


END

--END TRY

--BEGIN CATCH

--SELECT ERROR_MESSAGE() ERROR ,ERROR_NUMBER() eNUMBER
--END CATCH




GO
