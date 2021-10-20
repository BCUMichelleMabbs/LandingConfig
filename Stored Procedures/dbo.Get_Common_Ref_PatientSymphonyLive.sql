SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientSymphonyLive]
	as begin

	
EXEC('

USE [Wrexham_Live]

SELECT DISTINCT 
                         p.pat_pid AS LocalPatientIdentifier, p.pat_forename AS Forename, p.pat_surname AS Surname, CONVERT(Date, p.DOB) AS DateOfBirth, p.NHSNumber, p.pat_title AS Title, p.pat_sex AS Sex, 
                         CASE WHEN CDS_Ethnic = '' '' THEN NULL ELSE CDS_Ethnic END AS EthnicGroup, CASE WHEN add_line1 = '' '' THEN NULL ELSE add_line1 END AS Address1, CASE WHEN add_line2 = '' '' THEN NULL 
                         ELSE add_line2 END AS Address2, CASE WHEN add_line3 = '' '' THEN NULL ELSE add_line3 END AS Address3, CASE WHEN add_line4 = '' '' THEN NULL ELSE add_line4 END AS Address4, 
                         p.add_postcode AS Postcode, CONVERT(date, ca.cat_Arrivaldate) AS StartDate, NULL AS EndDate, ''Symphony'' AS Source, ''EDAttendance'' as Type
						 ,NULL as [NursingHomeFlag]
						 ,NULL as [NursingHomeType]
						 ,NULL as [EMIFlag]
						 ,NULL AS [NursingHomeName]

FROM            [Wrexham_Live].[dbo].PatAddressNumber_View AS p INNER JOIN
                        [Wrexham_Live].dbo.Current_Attendance AS ca ON p.pat_pid = ca.cat_patid
	'
	) AT [RYPA4SRVSQL0014.CYMRU.NHS.UK];




END
GO
