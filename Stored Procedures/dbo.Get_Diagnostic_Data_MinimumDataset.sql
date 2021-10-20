SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Diagnostic_Data_MinimumDataset]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	/*
	exec [dbo].[Get_Lims_Data_LimsMinimumDataset]
	*/


-- REMOVE AND REPLACE/RE-INSERT LAST 7 DAYS (HISTORIC) EVERY DAY APART FORM SUNDAY (30 DAYS REPLACED) TO MATCH NDR FEED REFRESH --
-- DW2 TABLE DOES NOT CURRENTLY INCLUDE TODAY'S DATA (YESTERDAY'S DATA ONWARDS HISTORICALLY) --


DELETE FROM [Foundation].[dbo].[Diagnostic_Data_MinimumDataset] WHERE CAST([DateOfEntry] AS DATE) BETWEEN (CASE WHEN DATEPART(WEEKDAY, GETDATE()) = 1 THEN CAST(GETDATE() -30 AS DATE) ELSE CAST(GETDATE() -7 AS DATE) END) AND CAST(GETDATE() -1 AS DATE)

SELECT

	[LimsMdsId] AS [MdsId],
	[VisitNumber],
	'XXXX' AS [Surname],
	'XXXX' AS [Forename],
	'XXXX' AS [NHSNumber],
	[EPVIS_HospitalUR] AS [LocalPatientIdentifier],
	--[HospitalNumber], -- COMMENTED OUT AS DUPLICATING COMPARED TO [EPVIS_HospitalUR] --
	[Sex],
	--[DOB] AS [DateOfBirth] -- COMMENTED OUT (SECURITY REASONS) FOR TESTING --,
	'XXXX' AS [Postcode],
	[DateOfEntry],
	[TimeOfEntry],
	[DateOfCollection],
	[TimeOfCollection],
	[DateOfRequest],
	[TimeOfRequest],
	[TestSetName],
	[TestSetSynonym],
	[TestComponent],
	[TestResult],
	[DateOfReceiving],
	[TimeofReceiving],
	[HospitalName] AS [LocationName],
	[HospitalCode] AS [LocationCode],
	[DateOfAuthorisation],
	[TimeOfAuthorisation],
	[DoD] AS [DateOfDeath],
	[Notes],
	[RequestingClinician],
	--[EPVIS_HospitalUR] AS [LocalPatientIdentifier],
	[EPVIS_UserSite_DR] AS [Site],

	[VISTS_UserSite_DR],
	[RequestingSite] AS [RequestingLocation],
	[EPVIS_PatientType] AS [PatientType],
	'XXXX' AS [RequestingClinicianSurname], --[CTDR_Surname] AS [RequestingClinicianSurname],
	'XXXX' AS [RequestingClinicianForename], -- [CTDR_GivenName] AS [RequestingClinicianForename],
	[VISTS_SpecimenType_DR],
	[CTTS_Department_DR],
	[EPVIS_TestSets],
	[CTSPL_Desc],
	[EPVIS_StatusPatient],
	LEFT([RequestingSite],5) AS [RequestingSite],
	'LIMS' AS [Source],
	CASE	WHEN LEFT([RequestingSite],5) = '7A1A4' THEN 'East'
			WHEN LEFT([RequestingSite],5) = '7A1A1' THEN 'Central'
			WHEN LEFT([RequestingSite],5) = 'CA1AA' THEN 'Central'
			WHEN LEFT([RequestingSite],5) = '7a1au' THEN 'West'

			WHEN [HospitalCode] LIKE '%WMH%' THEN 'East'
			WHEN [HospitalCode] LIKE '%YGC%' THEN 'Central'
			WHEN [HospitalCode] LIKE '%YGH%' THEN 'West'

			WHEN [HospitalName] LIKE '%East%' THEN 'East'
			WHEN [HospitalName] LIKE '%Central%' THEN 'Central'
			WHEN [HospitalName] LIKE '%West%' THEN 'West'

			WHEN [HospitalName] LIKE '%Shotton%' THEN 'East'
			WHEN [HospitalName] LIKE '%Caia Park%' THEN 'East'
			WHEN [HospitalName] LIKE '%Connahs Quay%' THEN 'East'
			WHEN [HospitalName] LIKE '%Wrexham%' THEN 'East'
			WHEN [HospitalName] LIKE '%Flint%' THEN 'East'
			WHEN [HospitalName] LIKE '%Mold%' THEN 'East'
			WHEN [HospitalName] LIKE '%Chirk%' THEN 'East'
			WHEN [HospitalName] LIKE '%Berwyn%' THEN 'East'
			WHEN [HospitalName] LIKE '%Rhyl%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Prestatyn%' THEN 'Central'
			WHEN [HospitalName] LIKE '%St Asaph%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Rhuddlan%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Denbigh%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Ruthin%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Llandudno%' THEN 'Central'
			WHEN [HospitalName] LIKE '%YGC%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Colwyn Bay%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Abergele%' THEN 'Central'
			WHEN [HospitalName] LIKE '%Anglesey%' THEN 'West'
			WHEN [HospitalName] LIKE '%Bron Castell%' THEN 'West'
			WHEN [HospitalName] LIKE '%Gwynedd%' THEN 'West'
			WHEN [HospitalName] LIKE '%Aberconwy/Colwyn%' THEN 'West'
			WHEN [HospitalName] LIKE '%Menai%' THEN 'West'

			WHEN [HospitalCode] IN ('7A100EPMH','7A100SHSSAL','7A100V06859','7A100WHITB') THEN 'East'
			WHEN [HospitalCode] IN ('7A100COMDIC','7A100HPTNW','7A100LGHSHS','7A1A21A2ORP','7A1AVLGHROP') THEN 'Central'
			WHEN [HospitalCode] IN ('7A100ISGSMS','7A100NSDW','7A100V06700') THEN 'West'

			WHEN [HospitalCode] IN ('7A100IL1','7A100NOS1','7A100MIDCER','7A100NS1','7A100NSFLWX','7A100PRIVEN','7A100RUABC','7A100SARC','7A100TEST1','7A100UCRR') AND [EPVIS_UserSite_DR] = '7a1a4' THEN 'East'
			WHEN [HospitalCode] IN ('7A100IL1','7A100NOS1','7A100MIDCER','7A100NS1','7A100NSFLWX','7A100PRIVEN','7A100RUABC','7A100SARC','7A100TEST1','7A100UCRR') AND [EPVIS_UserSite_DR] = '7a1a1' THEN 'Central'
			WHEN [HospitalCode] IN ('7A100IL1','7A100NOS1','7A100MIDCER','7A100NS1','7A100NSFLWX','7A100PRIVEN','7A100RUABC','7A100SARC','7A100TEST1','7A100UCRR') AND [EPVIS_UserSite_DR] = '7a1au' THEN 'West'

			ELSE 'Unknown'
	END AS [Area],
	ISNULL([EPVIS_HospitalUR],'') + '|' + CAST([LimsMdsId] AS VARCHAR) + '|' + [HospitalCode] + '|LIMS|Diagnostic' AS [PatientLinkID]

FROM [7a1a1srvinfondr].[LIMS].[dbo].[LIMS_MDS]

WHERE 1 = 1
-- (SUNDAY = 1) THIS IS TO DELETE & RE-INSERT LAST 30 DAYS EVERY SUNDAY --
-- OTHER DAYS TO DELETE & RE-INSERT LAST 7 DAYS --
AND CAST([DateOfEntry] AS DATE) BETWEEN (CASE WHEN DATEPART(WEEKDAY, GETDATE()) = 1 THEN CAST(GETDATE() -30 AS DATE) ELSE CAST(GETDATE() -7 AS DATE) END) AND CAST(GETDATE() -1 AS DATE)



END
GO
