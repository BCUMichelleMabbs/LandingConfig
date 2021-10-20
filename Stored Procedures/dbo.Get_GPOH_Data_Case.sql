SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Data_Case]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @FromDate AS DATETIME
--DECLARE @ToDate AS DATETIME

--SET @FromDate = '1 January 2018 08:00:00'
SET @FromDate = '10 December 2018 08:00:00'
--SET @FromDate = CONVERT(VARCHAR(10),GETDATE() -1 ,120) + ' ' + '08:00:00'
--SET @ToDate = CONVERT(Varchar(10),GETDATE() ,120) + ' ' + '07:59:59'

SELECT
	C.CaseRef,
	--C.ServiceRef,
	C.OrganisationGroupRef,
	--C.CurrentLocationRef,
	C.PatientRef,
	C.ProviderRef,
	C.CaseTypeRef AS FinalCaseTypeRef,
	CA.CaseTypeRef AS ReceivedCaseTypeRef,
	C.CallerRelationshipRef,
	C.ProviderGroupRef,
	C.LocationRef,
	--C.FinalOutcomeRef,
	--C.PatientAuditRef,
	--C.SpecialismRef,
	--C.DutyStationRef,
	C.RegistrationTypeRef,
	--C.MultipleCallMasterCaseRef,
	C.CoverRef,
	C.ActivePerformanceManagementRef,
	--C.SpecialismTypeRef,
	--C.PassProviderRef,
	--C.AcknowledgementMessageRef,
	--C.CaseTagRef,
	CAST(C.ActiveDate AS DATE) AS ActiveDate,
	CAST(C.ActiveDate AS TIME(0)) AS ActiveTime,
	CAST(C.EditDate AS DATE) AS EditDate,
	CAST(C.EditDate AS TIME(0)) AS EditTime,
	CAST(C.EntryDate AS DATE) AS EntryDate,
	CAST(C.EntryDate AS TIME(0)) AS EntryTime,
	C.CaseNo,
	CAST(C.BookedDate AS DATE) AS BookedDate,
	CAST(C.BookedDate AS TIME(0)) AS BookedTime,
	C.Cancelled,
	C.TestCall,
	C.ProviderGroupAdditionalText AS PatientPracticeText,
	--C.ProviderType,
	C.WalkIn,
	C.SequenceNumber,
	C.NationalProviderCode AS PatientGP,
	C.NationalProviderGroupCode AS PatientPractice,
	A.Postcode AS PatientPostcode
	--(SELECT MIN(StartDate) FROM [SQL4\SQL4].Adastra3.dbo.[Consultation] CON WHERE CON.CaseRef=C.CaseRef AND CON.Obsolete=0) AS CaseStartDate,
	--(SELECT MAX(EndDate) FROM [SQL4\SQL4].Adastra3.dbo.[Consultation] CON WHERE CON.CaseRef=C.CaseRef AND CON.Obsolete=0) AS CaseEndDate
	
FROM
	[SQL4\SQL4].Adastra3.dbo.[Case] C
	LEFT JOIN [SQL4\SQL4].Adastra3.dbo.[Patient] P ON P.PatientRef = C.PatientRef AND P.Obsolete=0
	LEFT JOIN [SQL4\SQL4].Adastra3.dbo.[Address] A ON A.AddressRef = P.AddressRef 
	LEFT JOIN [SQL4\SQL4].Adastra3.dbo.[CaseEvents] CE ON C.CaseRef = CE.CaseRef and CE.eventRef = (SELECT TOP 1 CE2.EventRef FROM [SQL4\SQL4].Adastra3.dbo.CaseEvents CE2 where CE2.CaseRef = C.CaseRef and CE2.EventType = 'RECEIVE' AND CE2.EntryDate > @FromDate ORDER BY CE2.EntryDate)
	LEFT JOIN [SQL4\SQL4].Adastra3.dbo.[CaseAudit] CA ON CE.CaseAuditRef = CA.CaseAuditRef and CA.CaseRef = C.CaseRef 
	--LEFT JOIN [SQL4\SQL4].Adastra3.dbo.[Consultation] CON ON C.CaseRef=CON.CaseRef AND CON.Obsolete=0
WHERE
	C.ActiveDate+Landing_Config.dbo.GPOH_BSTOffset(C.ActiveDate) >= @FromDate
END
GO
