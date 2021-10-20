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


CREATE PROCEDURE [dbo].[Get_PAS_Ref_ClinicalReview_Central]
	
AS
BEGIN

SET NOCOUNT ON;

--DECLARE @LastReviewDate as date = '01 January 2010'

--DECLARE @LastReviewDate AS DATE = (SELECT ISNULL(MAX(DateOfReview),'01 January 2010') FROM [Foundation].[dbo].[PAS_Ref_ClinicalReview] where Area = 'Central')
--DECLARE @LastReviewDateString AS VARCHAR(30) = DATENAME(DAY,@LastReviewDate) + ' ' + DATENAME(MONTH,@LastReviewDate) + ' ' + DATENAME(YEAR,@LastReviewDate)



EXEC( 'SELECT DISTINCT 
		nullif(rtrim(cr.Caseno), '''') as LocalPatientIdentifier,
		nullif(rtrim(cr.linkid), '''') as SystemLinkID,
		
		extract(YEAR from cr.Review_Date)||''-''||extract(month from cr.Review_Date)||''-''||extract(DAY from cr.Review_Date) as DateOfReview,
		
			CASE
				WHEN cr.Review_Date IS NULL THEN NULL
				WHEN TRIM(cr.Review_Date) ='''' THEN null
				when SUBSTRING(cr.Review_Date FROM 12 FOR 5) = '''' then null
				ELSE RIGHT(''0''||CAST(extract(HOUR from cr.Review_Date) AS VARCHAR(2)),2) ||'':''|| RIGHT(''0''||CAST(extract(Minute from cr.Review_Date) AS VARCHAR(2)),2)
				--ELSE SUBSTRING(cr.Review_Date FROM 12 FOR 2)||'':''||SUBSTRING(cr.Review_Date FROM 15 FOR 2) 
			END AS TimeOfReview,

		nullif(rtrim(cr.Review_Spec), '''') as SpecialtyOfReview,
		nullif(rtrim(cast(cr.Completion_date as date)), '''') as DateReviewCompleted,

		CASE
				WHEN cr.Completion_date IS NULL THEN NULL
				WHEN TRIM(cr.Completion_date) ='''' THEN null
				when SUBSTRING(cr.Completion_date FROM 12 FOR 5) = '''' then null
				ELSE RIGHT(''0''||CAST(extract(HOUR from cr.Completion_date) AS VARCHAR(2)),2) ||'':''|| RIGHT(''0''||CAST(extract(Minute from cr.Completion_date) AS VARCHAR(2)),2)
				--ELSE SUBSTRING(cr.Completion_date FROM 12 FOR 2)||'':''||SUBSTRING(cr.Completion_date FROM 15 FOR 2) 
			END AS TimeOfReviewCompleted,


		nullif(rtrim(cr.Completion_cons), '''') as HCPCompletedReview,
		 nullif(rtrim(cr.Next_Review_Description), '''') as NextReviewDetail,
		nullif(rtrim(cr.Next_Review_Spec), '''') as SpecialtyOfNextReview,
		nullif(rtrim(cast(cr.Next_Review_Date as date)), '''') as DateOfNextReview,

		CASE
				WHEN cr.Next_Review_Date IS NULL THEN NULL
				WHEN TRIM(cr.Next_Review_Date) ='''' THEN null
				when SUBSTRING(cr.Next_Review_Date FROM 12 FOR 5) = '''' then null
				ELSE RIGHT(''0''||CAST(extract(HOUR from cr.Next_Review_Date) AS VARCHAR(2)),2) ||'':''|| RIGHT(''0''||CAST(extract(Minute from cr.Next_Review_Date) AS VARCHAR(2)),2)
				--ELSE SUBSTRING(cr.Next_Review_Date FROM 12 FOR 2)||'':''||SUBSTRING(cr.Next_Review_Date FROM 15 FOR 2) 
		END AS TimeOfNextReview,

		nullif(rtrim(cr.SeqNo), '''') as OrderOfReview,
		''Central'' as Area,
		''WPAS'' as Source

FROM
	ClinReview as cr

WHERE

		cr.Completion_date is null or cr.Completion_date = ''30 december 1899''
			
	


	

')AT [WPAS_Central];
END


--cr.review_date > '''+@LastReviewDateString+'''
GO
