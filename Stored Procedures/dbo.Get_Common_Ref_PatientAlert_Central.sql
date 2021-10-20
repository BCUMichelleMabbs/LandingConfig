SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Kerry Roberts (KR)
-- Create date: 12/11/2020
-- Description:	Extract of all Clinical Review Data from WPAS to be linked to IP Data
-- =============================================


--NOTES


CREATE PROCEDURE [dbo].[Get_Common_Ref_PatientAlert_Central]
	
AS
BEGIN

SET NOCOUNT ON;

--DECLARE @AlertStartDate as date = '01 January 2010'

DECLARE @AlertStartDate AS DATE = (SELECT ISNULL(MAX(DateStarted),'01 January 2010') FROM [Foundation].[dbo].[Common_Ref_PatientAlert] where Area = 'Central')
DECLARE @AlertStartDateString AS VARCHAR(30) = DATENAME(DAY,@AlertStartDate) + ' ' + DATENAME(MONTH,@AlertStartDate) + ' ' + DATENAME(YEAR,@AlertStartDate)





EXEC( '
		SELECT DISTINCT 
			nullif(rtrim(pk.Caseno), '''') as LocalPatientIdentifier,
		nullif(rtrim(pk.keynote_key), '''') as AlertKey,
		nullif(rtrim(pk.keynote_id), '''') as AlertIdentifier,
		nullif(rtrim(cast(pk.Start_date as timestamp)), '''') as DateStarted,

		Case
			when pk.end_date = ''31-DEC-2999'' then null
			else nullif(rtrim(cast(pk.end_date as timestamp)), '''') 
		end as DateEnded,

		nullif(rtrim(pk.KeyNote_Importance), '''') as Priority,
		--castst(pk.keynote_description as varchar(9500) character set win1252) as Note1,
		--CAST(SUBSTRING(pk.keynote_description FROM 1 FOR 32000) AS VARCHAR(32000)) as Note2,
		cast(trim(pk.keynote_description) as char(4000)) as Note,
		
		--char_length (pk.keynote_description),
		''Central'' as Area,
		''WPAS'' as Source,
		''PAS Key Note'' as AlertType,
		p.nhs as NHSNumber

FROM
	patkeynote pk
	left join patient p on pk.caseno = p.caseno

WHERE

pk.start_date > '''+@AlertStartDateString+'''
			
	

')AT [WPAS_Central];
END



--pk.start_date > '''+@AlertStartDateString+'''
--and pk.KeyNote_Importance <> ''3''
GO
