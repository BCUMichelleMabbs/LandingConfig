SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Common_Ref_Postcode]
	
AS
BEGIN
	
	SET NOCOUNT ON;


	-- this removed any duplicates from the table BUT will leave the most up to date record

Delete  aliasName from (
Select  *,
        ROW_NUMBER() over (Partition by postcode order by lastupdated desc) as rowNumber
From    mapping.[dbo].[Common_postcode]) aliasName 
Where   rowNumber > 1



SELECT *
FROM mapping.dbo.Common_Postcode p
left join mapping.dbo.Common_PostcodeLSOAWelsh W on p.PostcodeNoSpace = w.WelshPostcodeNoSpaces
order by postcode 
END

/*
WelshLSOA data is downloaded from 
https://statswales.gov.wales/Catalogue/Community-Safety-and-Social-Inclusion/Welsh-Index-of-Multiple-Deprivation
Download the file Postcode to WIMD rank lookup and select the WElsh_Postcodes tab in excel
check the columns match, add a colum to the end and add the year, clear out currnt table and paste in data

Main Postcode table is extracted from https://www.doogal.co.uk/PostcodeDownloads.php
*/
GO
