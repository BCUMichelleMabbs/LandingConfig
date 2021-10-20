SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Update_Common_Ref_Patient]
@LoadGUID varchar(38)
AS
BEGIN
SET NOCOUNT ON;

WITH CTE AS 
	(
	SELECT p.Row_GUID, 
	CASE WHEN [Type] IS NOT NULL THEN 'Y' ELSE 'N' END as [NursingHomeFlag],
	n.[Type] as [NursingHomeType],
	CASE n.[EMI Flag] WHEN 'EMI' THEN 'Y' ELSE 'N' END AS [EMIFlag]

	FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')
	)

--First pass to set initial flags for nursing homes based on the results from the lookup.
UPDATE p
SET p.[NursingHomeFlag] = c.[NursingHomeFlag],
p.[NursingHomeType] = c.[NursingHomeType],
p.[EMIFlag] = c.[EMIFlag]

FROM [Foundation].[dbo].[Common_Ref_Patient] p
JOIN CTE c on p.Row_GUID = c.Row_GUID

--Second pass to set the potential nursing homes not picked up in the first pass based on keywords in the address 1 field.
UPDATE p
SET p.[NursingHomeFlag] = 
	CASE WHEN NursingHomeFlag = 'N' AND 
		(	Address1 LIKE '% nurse %' OR
			Address1 LIKE '% care %' OR
			Address1 LIKE '% residential %' OR
			Address1 LIKE '% nursing %' OR
			Address1 LIKE '%Polish Housing Society%' AND
			Address1 NOT LIKE '%HMP%' AND
			Address1 NOT LIKE '%caravan%'
		)
		THEN 'Y' ELSE NursingHomeFlag END
FROM [Foundation].[dbo].[Common_Ref_Patient] p


--Update the missing nursing home types from the 2nd pass.
UPDATE p
SET p.[NursingHomeType] = 
	CASE 
		WHEN NursingHomeFlag = 'P' AND (Address1 LIKE '% nurse %' OR Address1 LIKE '% nursing %') THEN 'Nursing Home'
		WHEN NursingHomeFlag = 'P' AND Address1 LIKE '% residential %' THEN 'Residential Home'
		WHEN NursingHomeFlag = 'P' AND NursingHomeType IS NULL THEN 'Care Home'
		ELSE [NursingHomeType]
	END

FROM [Foundation].[dbo].[Common_Ref_Patient] p

--Update nursing home name field based on contents of lookup and address1 for the potential matches.
UPDATE p
SET [NursingHomeName] = 
	CASE 
		WHEN [Place Name] IS NULL AND NursingHomeFlag = 'P' THEN Address1 
		ELSE [Place Name] 
	END

FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')


--Update P to Y to cleanse final output
UPDATE p
SET NursingHomeFlag = CASE WHEN NursingHomeFlag = 'P' THEN 'Y' ELSE NursingHomeFlag END

FROM [Foundation].[dbo].[Common_Ref_Patient] p


--Update to cleanse neighbours from popular Residential Homes
UPDATE p
 SET NursingHomeFlag = 
 CASE WHEN p.Postcode = 'LL30 2EH' AND (
	  (Address1 LIKE '%nursing%') OR 
	  (Address2 LIKE '%81%' ) OR 
	  (address1 LIKE '%81%')
	  ) THEN 'Y' ELSE 'N' END

FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL30 2EH'

UPDATE p
 SET NursingHomeFlag = 
CASE WHEN p.Postcode = 'CH5 3EX' AND (
         (Address1 LIKE '%Aston Hall%')AND 
         (Address1 NOT LIKE '%[0-9]%' ) OR
         (Address1 LIKE '%Care%')
         )    THEN 'Y' ELSE 'N' END
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'CH5 3EX'

  UPDATE p
 SET NursingHomeFlag = 
CASE WHEN p.Postcode = 'LL65 1AA' AND (
         (Address1 LIKE '%Bryn Goleu%') AND 
         (Address1 NOT LIKE '%[0-9]%' ) AND
         (Address1 NOT LIKE '%Avenue%') OR
         (Address1 LIKE '%Home%') OR
         (Address1 LIKE '%Res%')
         )    THEN 'Y' ELSE 'N' END
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL65 1AA'

UPDATE p
 SET NursingHomeFlag = 
         CASE WHEN p.Postcode = 'LL55 3DB' AND (
         (Address1 LIKE '%Nursing%') AND
         (Address1 NOT LIKE '%[0-9]%' ) OR
         (Address1 LIKE '%Care%') OR
         (Address1 LIKE '%Nyrsio%') OR
         (Address1 LIKE '%Residential%') 
         )    THEN 'Y' ELSE 'N' END 
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL55 3DB'

UPDATE p
 SET NursingHomeFlag = 
         CASE WHEN p.Postcode = 'LL30 1UU' AND (
         (Address1 LIKE '%Nursing%') AND
         (Address1 NOT LIKE '%[0-9]%' ) OR
         (Address1 LIKE '%20%') OR
         (Address1 LIKE '% RH%') OR
         (Address2 LIKE '%20%') OR
         (Address1 LIKE '%Care%') OR
         (Address1 LIKE '%Res%')
         )    THEN 'Y' ELSE 'N' END 
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL30 1UU'

UPDATE p
 SET NursingHomeFlag = 
       CASE WHEN p.Postcode = 'LL65 2TY' AND (
         (Address1 NOT LIKE '%Lon%') AND
         (Address1 LIKE '% Re%') AND
         (Address1 NOT LIKE '%[0-9]%' ) OR
         (Address1 LIKE '%Home%')
         )    THEN 'Y' ELSE 'N' END 
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL65 2TY'

UPDATE p
 SET NursingHomeFlag = 
         CASE WHEN p.Postcode = 'LL12 7AD' AND (
         (Address1 LIKE '%4%' )
         )    THEN 'Y' ELSE 'N' END
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL12 7AD'

UPDATE p
 SET NursingHomeFlag = 
         CASE WHEN p.Postcode = 'LL65 1NS' AND (
         (Address1 LIKE '%Res%') OR
         (Address1 LIKE '%Nurse%') OR
         (Address1 LIKE '%Home%')
         )    THEN 'Y' ELSE 'N' END 
FROM [Foundation].[dbo].[Common_Ref_Patient] p
	LEFT JOIN [7a1a1srvinfodw1].[Ardentia_HealthWare_5_Release].[dbo].[X_NursingHomeLookup] n ON p.Postcode = n.Postcode and (Address1 like '%'+[Name Excluding Descriptor]+'%' or Address2 like '%'+[Name Excluding Descriptor]+'%')

WHERE p.Postcode = 'LL65 1NS'

END
GO
