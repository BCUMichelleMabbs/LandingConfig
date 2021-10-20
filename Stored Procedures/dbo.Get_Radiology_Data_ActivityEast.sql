SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Radiology_Data_ActivityEast]
	
AS
BEGIN
	
	SET NOCOUNT ON;


	/*
	exec [dbo].[Get_Radiology_Data_ActivityEast]
	*/
DECLARE @FromDate AS DATETIME
--DECLARE @ToDate AS DATETIME

SET @FromDate = CAST(DATEADD(DAY,-1,GETDATE()) AS DATE)


;


SELECT


	P.hospitalnumber AS LocalPatientIdentifier,
	P.RadisNumber AS RadisNumber,
	R.RequestID AS RequestId,
	R.RequestStatus AS RequestStatus,
	s.Code AS ProviderCode,

	s1.Code AS ReferringSpecialtyCode,
	CONVERT(INT, cp.IsGP ) AS ReferralTypeCode,
	cp.Code AS HCPCode,
	l.Code AS LocationCode,
	r.Priority AS PriorityCode,
	ct.Code AS CategoryCode,

	RDR.Code AS RoomCode,
	CONVERT(INT, p.DeceasedPatientFlag) AS PatientDeceased,
	CONVERT(INT, l.InPatient) AS InPatient,
	abn.code AS AbandonedReasonCode,
	can.Code AS CancellationReasonCode,

	CASE WHEN CAST(R.ReferralDate AS DATE) = '18790101' THEN NULL ELSE CAST(R.ReferralDate AS DATE) END AS ReferralDate,
	CASE WHEN CAST(R.RequestReceivedDate AS DATE) = '18790101' THEN NULL ELSE CAST(R.RequestReceivedDate AS DATE) END AS RequestReceivedDate,
	LEFT(CAST(r.RequestReceivedTime AS TIME),8) AS RequestReceivedTime,
	CAST(StartDate AS DATE) AS AppointmentDate,
	LEFT(CAST(a.StartTime AS TIME),8) AS AppointmentTime,
	CAST(a.AttendanceDate AS DATE) AS AttendanceDate,
	LEFT(CAST(a.AttendanceTime AS TIME),8) AS AttendanceTime,

	CASE WHEN CAST(r.CancellationDate AS DATE) = '18790101' THEN NULL ELSE CAST(r.CancellationDate AS DATE) END AS CancellationDate,
	LEFT(CAST(r.CancellationTime AS TIME),8) AS CancellationTime,
	CAST(r.DNADate AS DATE) AS DNADate,
	LEFT(CAST(r.DNATime AS TIME),8) AS DNATime,
	LEFT(CAST(p1.StartTime AS TIME),8) AS ProcedureStartTime,
	LEFT(CAST(p1.EndTime AS TIME),8) AS ProcedureEndTime,
	p1.Duration AS ProcedureDuration,
	r.OrderSource AS OrderSource,
	--FLOOR(DATEDIFF(DAY, p.DateOfBirth, a.AttendanceDate) / 365.25) AS AgeAtAttendance, -- FLOOR(DATEDIFF(DAY, p.DateOfBirth, a.AttendanceDate) / 365.25)

	'RADIS' AS Source,
	'East' AS Area,

	p1.AccessionNumber AS AccessionNumber,
	p.HospitalNumber AS HospitalNumber,
	-- BELOW IN PATIENT REF --
	--null AS NHSNumber,		-- p.NHSNumber AS NHSNumber,
	--null AS PatientName,	-- P.Title + ' ' + P.Forename + ' ' + P.Surname AS PatientName ,
	--null AS DateOfBirth,	-- p.DateOfBirth AS DateOfBirth,

	CP.Code AS ReferrerCode,	-- MM : link to the HCP dim
	pr.Code AS PracticeCode,	-- link to the hcp table
	RTRIM(pc.Code) AS ExamCode,	-- MM : links to the ProcedureCode Tbl
	CAST(rc.DateCreated AS DATETIME) + CAST(rc.TimeCreated AS DATETIME) AS DateReportCreated,
	CAST(rc.DateValidated AS DATETIME) + CAST(rc.TimeValidated AS DATETIME) AS DateReportValidated,

	-- REF? as report text seems to be comments  --
	--NULL AS ReportText,		-- rc.ReportText AS ReportText,  

	---- patient ref details --
	--null AS Title,	-- p.Title
	--null AS Address1,	-- p.Address1
	--null AS Address2,	-- p.Address2 
	--null AS Address3,	-- p.Address3
	--null AS Address4,	-- p.Address4
	--null AS Address5,	-- p.Address5
	--null AS Postcode,	-- p.Postcode
	--null AS TelephoneNumber,	-- p.TelephoneNumber

	p.LibraryFilingReference AS LibraryFilingReference,
	--null AS DeathDate,	-- p.DeathDate
	--null AS AlternatePhone,	-- p.AlternatePhone
	CONVERT(INT, p.FilmsCulledFlag) AS FilmsCulledFlag,
	CASE WHEN CAST(p.DateFilmsCulled AS DATE) = '18790101' THEN NULL ELSE CAST(p.DateFilmsCulled AS DATE) END AS DateFilmsCulled,
	--null AS EmailAddress,	-- p.EmailAddress
	CAST(p.DateCreated AS DATE) AS DateCreated,

	p.PASCheckDigit AS PASCheckDigit, -- null
--	null AS MaritalStatus, -- p.MaritalStatus
	CASE	WHEN p.TranslatorRequired = 0 THEN 'NO'
			ELSE 'YES'
	END AS TranslatorRequired,
	convert(int,p.IncompleteDetailsFlag) AS IncompleteDetailsFlag,
	convert(int,p.DataProtectionFlag) AS DataProtectionFlag,
	convert(int,p.DataSharingFlag) AS DataSharingFlag,
--	p.NHSNumberStatus AS NHSNumberStatus,
	--convert(int, p.SameNameFlag) AS SameNameFlag,

	--p.SameNameType AS SameNameType,
--	p.MergedPatientStatus AS MergedPatientStatus,
	Pat2.RadisNumber AS RadisNoMergedFrom,
	-- special requirements is free text like Comments --
	--null AS SpecialRequirements, -- p.SpecialRequirements
	--null AS DateMerged,
	--null AS MobilePhoneNumber, -- p.MobilePhoneNumber
	--p.SurnameSoundex AS SurnameSoundex,

	--p.LastUpdated AS PatientLastUpdate,
	convert(int,p.ElectronicallyValidated) AS ElectronicallyValidated,	
	--null AS Notes, -- a.Notes 
	--CP2.Code AS PatientsRegisteredGPCode,
	d.Code AS UnitCode,
	e.RadiationDose AS RadiationDose,
	f.Code AS FilmCode,
	f.FilmSize AS FilmSize,
	lan.Code AS LangCode,
	lan.Description AS LangDesc,
	isnull(rpcd.HealthBoardCode,'00000') AS LHBCode,
	pathc.Code AS PathologyCode,
	convert(int, pathc.Active) AS PathologyCodeActive,

--	preg.PregnancyNumber AS PregnancyNumber, -- null
--	preg.DateRecorded AS PregnancyDateRecorded,
	--preg.fk_PregnancyStatus_ID AS PregnancyCode,
	pc.KornerCategory AS KornerCategory,
	p1.ExamSide AS ExamSide,
	--NULL AS RadiographerComment, -- p1.RadiographerComment
	p1.NumberOfNurses AS NumberOfNurses,
	cast(p1.ScreeningTime AS VARCHAR) AS ScreeningTime,

	p1.AngioNumber AS AngioNumber, -- REF?
	p1.StorageMedia AS StorageMedia,
	p1.FilmCopyStatus AS FilmCopyStatus,
	p1.ScanType AS ScanType,
	p1.USStatus AS USStatus,
	p1.Amnionicity AS Amnionicity,
	p1.Chorionicity AS Chorionicity,
	p1.MappingCode AS AllWalesMappingCode,
	p1.LastUpdated AS ProcedureLastUpdated,
	pc.ProcedureCount AS ProcedureCount,
	convert(int, pc.Interventional) AS Interventional,

	rc.ChapterType AS ChapterType,

	CAST(rc.DateCreated AS DATE) AS ReportChapterDateCreated,
	rc.TimeCreated AS ReportChapterTimeCreated,
	CAST(rc.DateValidated AS DATE) AS ReportChapterDateValidated,
	rc.TimeValidated AS ReportChapterTimeValidated,
	CAST(rc.DateLastPrinted AS DATE) AS ReportChapterDateLastPrinted,
	rc.TimeLastPrinted AS ReportChapterTimeLastPrinted,

	CONVERT(int, rc.Publish) AS Publish,
	CAST(rc.DateDictated AS DATE) AS DateDictated,
	rc.TimeDictated AS TimeDictated,
	CAST(rc.DateDictationTranscribed AS DATE) AS DateDictationTranscribed,
	rc.TimeDictationTranscribed AS TimeDictationTranscribed,
	rc.fk_UserDetail_Author_ID AS AuthorID,
	CAST(r.RequestCreatedDate AS DATE) AS RequestCreatedDate,
	r.RequestCreatedTime AS RequestCreatedTime,
	CASE WHEN CAST(r.ResultsRequiredByDate AS DATE) = '18790101' THEN NULL ELSE CAST(r.ResultsRequiredByDate AS DATE) END AS ResultsRequiredByDate,

	convert(int,r.IsCooperative) AS IsCooperative,
	r.FilmDestination AS FilmDestination,
	convert(int, r.OncallIndicator) AS OncallIndicator,
	CASE WHEN CAST(r.LMPDate AS DATE) = '18790101' THEN NULL ELSE CAST(r.LMPDate AS DATE) END AS LMPDate,
	r.UserOrderReference AS UserOrderReference,
	convert(int,r.ReportResultIndicator) AS ReportResultIndicator,
	--NULL AS ClinicalComments, --r.ClinicalComments -- REF?
	-- r.Alerts AS Alerts, -- r.Alerts -- REF? perhaps
	convert(int,r.ReminderFlag) AS ReminderFlag,
	CASE WHEN CAST(r.ReminderDate AS DATE) = '18790101' THEN NULL ELSE CAST(r.ReminderDate AS DATE) END AS ReminderDate,

	--null AS VettingComments, 
	r.VettingAssignedDate AS VettingAssignedDate, -- null
	r.VettingByPassedDate AS VettingByPassedDate, -- null
	r.VettingRemovedDate AS VettingRemovedDate, -- null
	r.VettedDate AS VettedDate, -- null
	r.LastUpdated AS RequestLastUpdated,

	r.FileReference AS FileReference,
	convert(int,r.DufusConsent) AS DufusConsent,
	DATEDIFF(week, r.RequestReceivedDate, a.StartDate) AS AppointmentWeeksWaitRequestReceived,
	DATEDIFF(week, r.RequestCreatedDate, a.StartDate) AS AppointmentWeeksWaitPutOnHold,

	convert(int, s.Active) AS SiteActive,
	s.Mnemonic AS SiteMnemonic,
	UD3.UserID AS ReceptionedByCode,
	UD4.UserID AS AppointmentBookedByCode,
	UD5.UserID AS RadiographerCode,
	CASE	WHEN RequestStatus IN ( 1, 2, 4 ) AND r.Priority <> 4 THEN 1
			ELSE 0
	END AS IsOnWaitingList,
	pd.Code AS PriorityDetailCode,
	pur.Code AS PurchaserCode,
	convert(int, pur.Active) AS PurchaserActive,
	--port.PorteringMessage AS PorteringMessage, -- ref

	CASE WHEN CAST(port.PorteringCollectorAssignedDate AS DATE) = '18790101' THEN NULL ELSE CAST(port.PorteringCollectorAssignedDate AS DATE) END AS PorteringCollectorAssignedDate,
	CASE WHEN CAST(port.PorteringCollectorFinishedDate AS DATE) = '18790101' THEN NULL ELSE CAST(port.PorteringCollectorFinishedDate AS DATE) END AS PorteringCollectorFinishedDate,
	CASE WHEN CAST(port.PorteringReturnorAssignedDate AS DATE) = '18790101' THEN NULL ELSE CAST(port.PorteringReturnorAssignedDate AS DATE) END AS PorteringReturnorAssignedDate,
	CASE WHEN CAST(port.PorteringReturnorFinishedDate AS DATE) = '18790101' THEN NULL ELSE CAST(port.PorteringReturnorFinishedDate AS DATE) END AS PorteringReturnorFinishedDate,

	convert(int,port.PorteringLocationConfirmed) AS PorteringLocationConfirmed,
	convert(int,port.PorteringUrgent) AS PorteringUrgent,
	convert(int,port.PorteringDelayed) AS PorteringDelayed,			
	CAST(port.PorteringCollectionFlaggedDate AS DATE) AS PorteringCollectionFlaggedDate,
	CAST(port.PorteringReturnFlaggedDate AS DATE) AS PorteringReturnFlaggedDate,
	pors.pk_PorteringStatus_id AS PorteringStatus, -- NULL
	convert(int,pors.Active) AS PorteringStatusActive,
	portcol1.Code AS PorterCol1Code,
	portcol2.Code AS PorterCol2Code,
	portcol3.Code AS PorterCol3Code,
	portcol4.Code AS PorterCol4Code,
	portret1.Code AS PorterRet1Code,
	portret2.Code AS PorterRet2Code,
	portret3.Code AS PorterRet3Code,
	portret4.Code AS PorterRet4Code,
	
	CASE WHEN CAST(r.AbandonedDate AS DATE) = '18970101' THEN NULL ELSE CAST(r.AbandonedDate AS DATE) END AS AbandonedDate,
	--NULL AS AbandonedText, -- r.AbandonedText --ref?
	--NULL AS AbandonedReportText, -- abn.ReportText --ref?
	ug.Code AS UserGroupCode, -- null
	CASE	WHEN PC.Code  = 'CAPUG' THEN 1 
			WHEN PC.Code  = 'NCHEQ' THEN 1 
			WHEN PC.Code  = 'NCHEV' THEN 1 
			WHEN PC.Code  = 'ULLVB' THEN 1 
			WHEN PC.Code  = 'ULLVL' THEN 1 
			WHEN PC.Code  = 'ULLVR' THEN 1 
			WHEN PC.Code  = 'ULLCL' THEN 1 
			WHEN PC.Code  = 'ULLCR' THEN 1 
			WHEN PC.Code  = 'ULLCB' THEN 1 
			ELSE 0
	END AS HATProcedure,
	bs.code AS BatchsourceID,
	CAST(a.BookedDate AS DATE) AS AppointmentBookedDate,
	a.BookedTime AS AppointmentBookedTime,
	CAST(a.EndDate AS DATE) AS AppointmentEndDate,
	LEFT(CAST(a.EndTime AS TIME),8) AS AppointmentEndTime,

	p1.fk_UserDetail_PerformingOperator1_ID AS PerformingOperator1ID,
	p1.fk_UserDetail_PerformingOperator2_ID AS PerformingOperator2ID,
	p1.fk_UserDetail_PerformingOperator3_ID AS PerformingOperator3ID,
	p1.fk_UserDetail_Radiologist_ID AS DirectingRadiologistID,
	p1.fk_UserDetail_Radiographer_ID AS PerformingRadiographerID,
	p1.fk_UserDetail_PatientIDChecker_ID AS PatientIDCheckerID,
	r.fk_UserDetail_ReportingRadiologist_ID  AS AssignedReporterID,

	-- 19/08/2021 (EJ) - ABANDONED TIME KEPT AT BOTTOM AS ORDER OF COLUMNS IS IMPORTANT WHEN LOADING INTO FOUNDATION TABLE --
	-- (IF MOVED THEN ABANDONED TIME COLUMN IN FOUNDATION TABLE WILL APPEAR AS A STING OF NUMBERS AND NOT LOOK LIKE TIME COLUMN) --
	LEFT(CAST(r.AbandonedTime AS TIME),8) AS AbandonedTime
	,P.RadisNumber+'|'+P.pk_Patient_ID +'|'+'East'+'|'+'Radis' as PatientLinkID
			,pg.Code AS ExamGroupCode                          
                           

FROM
	[RADIS_EAST].RadisReporting.dbo.Patient P		
	      inner join [RADIS_EAST].RadisReporting.dbo.Request AS r WITH ( nolock ) ON p.pk_Patient_ID = r.fk_Patient_ID
            inner join  [RADIS_EAST].RadisReporting.dbo.[Procedure] AS p1 WITH ( nolock ) ON r.pk_Request_ID = p1.fk_Request_ID
            left outer join [RADIS_EAST].RadisReporting.dbo.Appointment AS a WITH ( nolock ) ON a.fk_Procedure_ID = p1.pk_Procedure_ID
            left outer join [RADIS_EAST].RadisReporting.dbo.ReportChapter AS rc WITH ( nolock ) ON r.pk_Request_ID = rc.fk_Request_ID 
            left outer join [RADIS_EAST].RadisReporting.dbo.ReportBatch AS rb WITH ( nolock ) ON rb.pk_ReportBatch_ID = rc.fk_ReportBatch_ID
            left outer join [RADIS_EAST].RadisReporting.dbo.BatchSource AS bs WITH ( nolock ) ON bs.pk_BatchSource_ID = rb.BatchSource 
            left outer join [RADIS_EAST].RadisReporting.dbo.ReportChapterStatus AS rcs WITH ( nolock ) ON rcs.pk_ReportChapterStatus_ID  = rc.fk_ReportChapterStatus_ID
            inner join  [RADIS_EAST].RadisReporting.dbo.ProcedureCode AS pc WITH ( nolock ) ON pc.pk_ProcedureCode_ID = p1.fk_ProcedureCode_ID
            inner join  [RADIS_EAST].RadisReporting.dbo.ProcedureGroup AS pg WITH ( nolock ) ON pg.pk_ProcedureGroup_ID = pc.fk_ProcedureGroup_ID
            inner join  [RADIS_EAST].RadisReporting.dbo.ClinicianPractice AS cp WITH ( nolock ) ON cp.pk_ClinicianPractice_ID = r.fk_ClinicianPractice_Referring_ID
            left outer join [RADIS_EAST].RadisReporting.dbo.Clinician AS c WITH ( nolock ) ON c.pk_Clinician_ID = cp.fk_Clinician_ID
            inner join  [RADIS_EAST].RadisReporting.dbo.Practice AS pr WITH ( nolock ) ON pr.pk_Practice_ID = cp.fk_Practice_ID
            --INNER JOIN  [RADIS_EAST].dbo.SystemSetting WITH ( NOLOCK ) ON [RADIS_EAST].dbo.SystemSetting.SettingName = 'sitename'
            INNER JOIN  [RADIS_EAST].RadisReporting.dbo.RequestStatus AS rs WITH ( NOLOCK ) ON rs.pk_RequestStatus_ID = r.RequestStatus
            INNER JOIN  [RADIS_EAST].RadisReporting.dbo.Site AS s WITH ( NOLOCK ) ON s.pk_Site_ID = r.fk_Site_ID
            INNER JOIN  [RADIS_EAST].RadisReporting.dbo.Specialty AS s1 WITH ( NOLOCK ) ON s1.pk_Specialty_ID = r.fk_Specialty_ID
            INNER JOIN  [RADIS_EAST].RadisReporting.dbo.Location AS l WITH ( NOLOCK ) ON l.pk_Location_ID = r.fk_Location_ID
            INNER JOIN  [RADIS_EAST].RadisReporting.dbo.Priority AS pt WITH ( NOLOCK ) ON pt.pk_Priority_ID = r.Priority
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Language AS lan WITH ( NOLOCK ) ON p.fk_Language_ID = lan.pk_Language_ID
            --left outer join dbo.LocalHealthBoardMasterIndex AS lhb WITH ( nolock ) ON p.Postcode = lhb.PostCode
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Pregnancy AS preg WITH ( NOLOCK ) ON p.fk_Pregnancy_ID = preg.pk_Pregnancy_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.PregnancyStatus AS prst WITH ( NOLOCK ) ON preg.fk_PregnancyStatus_ID = prst.pk_PregnancyStatus_ID
          --inner join  [RADIS_EAST].RadisReporting.dbo.Category AS ct WITH ( nolock ) ON ct.pk_Category_ID = r.fk_Category_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Category AS ct WITH ( NOLOCK ) ON ct.pk_Category_ID = r.fk_Category_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.RDRoom AS RDR WITH ( NOLOCK ) ON RDR.pk_RDRoom_ID = a.fk_RDRoom_ID
            --LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Session AS S3 WITH ( NOLOCK ) ON S3.pk_Session_ID = a.fk_Session_ID
            --LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.SessionCode AS SC WITH ( NOLOCK ) ON SC.pk_SessionCode_ID = S3.fk_SessionCode_ID
            ----LEFT OUTER JOIN [RADIS_EAST].dbo.UserDetail AS UD1 WITH ( NOLOCK ) ON UD1.pk_UserDetail_ID = rc.fk_UserDetail_DictationTranscribedBy_ID
            --LEFT OUTER JOIN [RADIS_EAST].dbo.UserDetail AS UD2 WITH ( NOLOCK ) ON UD2.pk_UserDetail_ID = rc.fk_UserDetail_PublishedBy_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.ClinicianPractice AS CP2 WITH ( NOLOCK ) ON CP2.pk_ClinicianPractice_ID = p.fk_ClinicianPractice_Registered_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Clinician AS C2 WITH ( NOLOCK ) ON C2.pk_Clinician_ID = CP2.fk_Clinician_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Patient AS Pat2 WITH ( NOLOCK ) ON Pat2.pk_Patient_ID = p.fk_Patient_Primary_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.RequestPathologyCode AS RPC WITH ( NOLOCK ) ON RPC.fk_Request_ID = r.pk_Request_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.PathologyCode AS pathc WITH ( NOLOCK ) ON pathc.pk_PathologyCode_ID = RPC.fk_PathologyCode_ID
            --INNER JOIN  [RADIS_EAST].dbo.MergedPatientStatus AS MPS WITH ( NOLOCK ) ON MPS.pk_MergedPatientStatus_ID = p.MergedPatientStatus
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.PriorityDetail AS pd WITH ( NOLOCK ) ON r.fk_PriorityDetail_ID = pd.pk_PriorityDetail_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Exposure AS e WITH ( NOLOCK ) ON p1.pk_Procedure_ID = e.fk_Procedure_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.DoseUnit AS d WITH ( NOLOCK ) ON d.pk_DoseUnit_ID = e.fk_DoseUnit_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Film AS f WITH ( NOLOCK ) ON e.fk_Film_ID = f.pk_Film_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Cancellation AS can WITH ( NOLOCK ) ON r.fk_Cancellation_ID = can.pk_Cancellation_ID
            LEFT OUTER JOIN  [RADIS_EAST].RadisReporting.[dbo].[RadisPostcodeData] rpcd WITH (NOLOCK) ON p.PostCode = rpcd.PostCode
        --  left outer join NHSWalesPostCodeToLHB nhs with (nolock) on p.Postcode = nhs.Postcode
        --  left outer join NewLHBName nlhb with (nolock) on nhs.fk_NewLHBName_ID = nlhb.pk_NewLHBName_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.[Purchaser] AS pur WITH (NOLOCK ) ON pur.pk_Purchaser_ID = r.fk_Purchaser_ID
			LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Portering AS port WITH (NOLOCK ) ON r.pk_Request_ID = port.fk_Request_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.PorteringStatus AS pors WITH (NOLOCK ) ON pors.pk_Porteringstatus_ID = port.fk_Porteringstatus_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portcol1 WITH (NOLOCK ) ON portcol1.pk_Porter_ID = port.fk_Porter_Collector1_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portcol2 WITH (NOLOCK ) ON portcol2.pk_Porter_ID = port.fk_Porter_Collector2_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portcol3 WITH (NOLOCK ) ON portcol3.pk_Porter_ID = port.fk_Porter_Collector3_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portcol4 WITH (NOLOCK ) ON portcol4.pk_Porter_ID = port.fk_Porter_Collector4_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portret1 WITH (NOLOCK ) ON portret1.pk_Porter_ID = port.fk_Porter_Returnor1_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portret2 WITH (NOLOCK ) ON portret2.pk_Porter_ID = port.fk_Porter_Returnor2_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portret3 WITH (NOLOCK ) ON portret3.pk_Porter_ID = port.fk_Porter_Returnor3_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Porter AS portret4 WITH (NOLOCK ) ON portret4.pk_Porter_ID = port.fk_Porter_Returnor4_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.Abandoned AS abn WITH (NOLOCK) ON abn.pk_Abandoned_ID = r.fk_Abandoned_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.UserGroup AS ug WITH (NOLOCK) ON ug.pk_UserGroup_ID = r.fk_UserGroup_Vetting_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.UserDetail AS UD3 WITH ( NOLOCK ) ON UD3.pk_UserDetail_ID = r.fk_UserDetail_ReceptionedBy_ID
            LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.UserDetail AS UD4 WITH ( NOLOCK ) ON UD4.pk_UserDetail_ID = a.fk_UserDetail_BookedBy_ID 
			LEFT OUTER JOIN [RADIS_EAST].RadisReporting.dbo.UserDetail AS UD5 WITH ( NOLOCK ) ON UD5.pk_UserDetail_ID = p1.fk_UserDetail_Radiographer_ID
					--LEFT OUTER JOIN [RADIS_EAST].Radis.dbo.UserDetail AS UD6 WITH ( NOLOCK ) ON UD5.pk_UserDetail_ID = rc.fk_UserDetail_Author_ID
WHERE


	a.AttendanceDate >='01 July 2021'
	---= @FromDate
	
	






END
GO
GRANT ALTER ON  [dbo].[Get_Radiology_Data_ActivityEast] TO [CYMRU\He105872]
GO
GRANT EXECUTE ON  [dbo].[Get_Radiology_Data_ActivityEast] TO [CYMRU\He105872]
GO
GRANT VIEW DEFINITION ON  [dbo].[Get_Radiology_Data_ActivityEast] TO [CYMRU\He105872]
GO
