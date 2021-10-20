SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Ref_Patient]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @FromDate AS DATETIME
SET @FromDate = CONVERT(VARCHAR(10),GETDATE() -1 ,120) + ' ' + '08:00:00'

SELECT 
	P.PatientRef AS LocalPatientIdentifier,
	P.Forename AS Forename,
	P.Surname AS Surname,
	CAST(P.DOB AS DATE) AS DateOfBirth,
	P.Sex AS Gender,
	P.NationalCode AS NHSNumber,
	DATEDIFF(YEAR, P.DOB,GETDATE()) - (
		CASE 
			WHEN DATEADD(YEAR,DATEDIFF(YEAR, P.DOB, GETDATE()), P.DOB) > GETDATE() THEN 1 
			ELSE 0 
		END
	) AS Age,
	RTRIM(A.Building)+' '+RTRIM(A.Street) AS Address1,
	A.Locality AS Address2,
	A.Town AS Address3,
	A.County AS Address4,
	A.Postcode AS Postcode
FROM 
	[SQL4\SQL4].[Adastra3].[dbo].Patient P
	INNER JOIN [SQL4\SQL4].[Adastra3].[dbo].Address A ON P.AddressRef=A.AddressRef
WHERE
	(
		P.EditDate >= @FromDate
		OR
		P.LastCaseDate >= @FromDate
	)

END
GO
