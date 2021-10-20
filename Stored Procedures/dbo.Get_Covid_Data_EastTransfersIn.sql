SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_Covid_Data_EastTransfersIn]
as
begin
EXEC('
       SELECT * FROM(
              SELECT 
                     ''East'' AS Area,
                     ''Myrddin'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TRANS.LINKID AS SpellNumber,
                     PAT.FORENAME ||'' ''|| PAT.SURNAME AS Name,
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
                     TRANS.TRANSFER_CONS AS Consultant,
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
					 ''In'' As TransferType,
					  '' '' as TestEntryDate,
					 '' '' as TestAuthorisedDate,
					 '' '' as TestCollectedDate,
					 '' '' as TestRequestedLocation,
					 '' '' as Result,
					 '' '' as UniqueIdentifier,
					 '' '' as VisitNumber,
					 CURRENT_TIMESTAMP  as LastUpdated,
					 NULLIF(RTRIM(TREAT.DESTINATION),'''') AS DischargeDestination,
					 TRANS.TRANSFER_NO AS TransferNumber,
					 CAST(PAT.BIRTHDATE AS DATE) as DateOfBirth,
					 PAT.NHS as NHSNumber,
					 CAST(TREAT.TRT_DATE AS DATE) AS DateAdmitted,
					 CAST(TREAT.DISDATE AS DATE) AS DateDischarged
              FROM
                     TRANSFER TRANS
                     INNER JOIN TREATMNT TREAT ON TRANS.LINKID=TREAT.LINKID
                     LEFT JOIN PATIENT PAT ON TREAT.CASENO= PAT.CASENO

		      WHERE  
					 (CAST(TRANS.TRANSFER_DATE AS DATE) >= ''01 November 2019'' or TREAT.DISDATE IS NULL)  --DATEADD(DAY, -8, CURRENT_TIMESTAMP)
					 AND
					 CAST(TRANS.TRANSFER_DATE AS DATE) <= ''YESTERDAY''
					 AND
					TREAT.TRT_TYPE IN (''AD'',''AC'',''AL'',''AE'') 
              
UNION ALL
              SELECT 
                     ''East'' AS Area,
                     ''Myrddin'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TREAT.LINKID AS SpellNumber,
                     PAT.FORENAME ||'' ''|| PAT.SURNAME AS Name,      
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
                     TREAT.ACONS AS Consultant,
					 ''ADMISSION'' AS PreviousWard,
                     TREAT.ALOC AS Ward,
					 
					 CASE
                           WHEN TRANS.EPISODENO IS NULL AND TREAT.DISDATE IS NOT NULL THEN ''DISCHARGE''
                           --WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.CLOC
						   ELSE (SELECT FIRST 1 innerT.TRANSFER_WARD FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO)
                     END AS NextWard,
                     TREAT.ASPEC AS Specialty,
					 ''In'' as TransferType,
					  '' '' as TestEntryDate,
					 '' '' as TestAuthorisedDate,
					 '' '' as TestCollectedDate,
					 '' '' as TestRequestedLocation,
					 '' '' as Result,
					 '' '' as UniqueIdentifier,
					 '' '' as VisitNumber,
					 CURRENT_TIMESTAMP  as LastUpdated,
					 NULLIF(RTRIM(TREAT.DESTINATION),'''') AS DischargeDestination,
					 0 AS TransferNumber,
					 CAST(PAT.BIRTHDATE AS DATE) as DateOfBirth,
					 PAT.NHS as NHSNumber,
					 CAST(TREAT.TRT_DATE AS DATE) AS DateAdmitted,
					 CAST(TREAT.DISDATE AS DATE) AS DateDischarged
				     
              FROM
                     TREATMNT TREAT
                     LEFT JOIN TRANSFER TRANS ON TRANS.LINKID=TREAT.LINKID AND TRANS.TRANSFER_NO=1
                     LEFT JOIN PATIENT PAT ON TREAT.CASENO= PAT.CASENO
			 WHERE  
					(CAST(TREAT.TRT_DATE AS DATE) >= ''01 November 2019'' or TREAT.DISDATE IS NULL)--DATEADD(DAY, -8, CURRENT_TIMESTAMP)
					AND
					CAST(TREAT.TRT_DATE AS DATE) <= ''YESTERDAY''
			 		 AND
					TREAT.TRT_TYPE IN (''AD'',''AC'',''AL'',''AE'') 


       ) 
              ORDER BY 
                     EventStartDate, SpellNumber'
) AT [WPAS_East];

END
GO
