SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_LightFoot_Data_CentralTransfers]
as
begin

EXEC('
       SELECT *  FROM(
              SELECT 
                     ''Central'' AS Area,
                     ''WPAS'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TRANS.LINKID AS SpellNumber,
                     TRANS.TRANSFER_DATE,
					 TRANS.TRANSFER_TIME,
			         TRANS.TRANSFER_NO,
			         TRANS.LINKID,
                     TRANS.TRANSFER_CONS AS Consultant,				
                     TRANS.TRANSFER_WARD AS Ward,
					 TREAT.ASPEC AS Specialty
              FROM
                     TRANSFER TRANS
                     INNER JOIN TREATMNT TREAT ON TRANS.LINKID=TREAT.LINKID
					 LEFT JOIN PATIENT PAT ON TREAT.CASENO= PAT.CASENO

		      WHERE 
					CAST(CASE
                         WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.DISDATE
                         ELSE (SELECT FIRST 1 innerT.TRANSFER_DATE FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO+1)
                     END ) >= ''01 june 2021'' -- DATEADD(DAY, -8, CURRENT_TIMESTAMP)
					 AND
					CAST(CASE
                         WHEN TRANS.TRANSFER_NO = (SELECT MAX(TRANSFER_NO) FROM TRANSFER innerT WHERE innerT.LINKID=TREAT.LINKID) AND TREAT.DISDATE IS NOT NULL THEN TREAT.DISDATE
                         ELSE (SELECT FIRST 1 innerT.TRANSFER_DATE FROM TRANSFER innerT WHERE innerT.LINKID=TRANS.LINKID AND innerT.TRANSFER_NO=TRANS.TRANSFER_NO+1)
                     END ) <= ''YESTERDAY''
					
              
UNION ALL
                       ''Central'' AS Area,
                     ''WPAS'' AS Source,
                     TREAT.CASENO AS LocalPatientIdentifier,
                     TRANS.LINKID AS SpellNumber,
                     TRANS.TRANSFER_DATE,
					 TRANS.TRANSFER_TIME,
			         TRANS.TRANSFER_NO,
			         TRANS.LINKID,
                     TRANS.TRANSFER_CONS AS Consultant,				
                     TRANS.TRANSFER_WARD AS Ward,
					 TREAT.ASPEC AS Specialty
              FROM
                     TREATMNT TREAT
                     LEFT JOIN TRANSFER TRANS ON TRANS.LINKID=TREAT.LINKID AND TRANS.TRANSFER_NO=1
					 LEFT JOIN PATIENT PAT ON TREAT.CASENO= PAT.CASENO
            
			 WHERE  
			        CAST(COALESCE(TRANS.TRANSFER_DATE,TREAT.DISDATE) AS DATE) >= ''01 june 2021'' --DATEADD(DAY, -8, CURRENT_TIMESTAMP)
					AND
					CAST(COALESCE(TRANS.TRANSFER_DATE,TREAT.DISDATE) AS DATE) <= ''YESTERDAY''
					
			 		 


       ) 
              ORDER BY 
                     SpellNumber'
) AT [WPAS_Central];
END
GO
