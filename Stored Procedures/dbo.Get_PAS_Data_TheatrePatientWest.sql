SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_PAS_Data_TheatrePatientWest]
*/
CREATE PROCEDURE [dbo].[Get_PAS_Data_TheatrePatientWest]
AS
BEGIN
	SET NOCOUNT ON;
	EXEC ('
		DECLARE @start_date DATETIME = CAST(DATEADD(dd, -89, GETDATE()) AS DATE)
		DECLARE @end_date DATETIME = CONVERT(VARCHAR(8), GETDATE() - 1, 112)

		--SET @Start_date = ''2018-01-01''

		-- Create a temp table to hold most of the extract data in separate columns

		CREATE TABLE #x_theatreextract (
			SenderOrganisation VARCHAR(10),
			Theatrecaseno VARCHAR(20),
			Sessiondate DATE,
			ScheduleNumber VARCHAR(10),
			TheatreCode VARCHAR(10),
			[Session] VARCHAR(10),
			WardCode VARCHAR(10),
			OperatingOrder VARCHAR(10),
			SpellConsultantSpecialty VARCHAR(10),
			SpellConsultant VARCHAR(10),
			SpellStartDate DATE,
			SpellStartTime DATETIME,
			SpellDischargeDate DATE,
			SpellDischargeTime DATETIME,
			TimePatientSentFor DATETIME,
			ArrivalTimeinTheatreSuite DATETIME,
			TimeintoAnaestheticRoom DATETIME,
			StartTimeAnaesthesia DATETIME,
			FinishTimeAnaesthesia DATETIME,
			StartTimeSurgery DATETIME,
			KnifetoSkinStartTime DATETIME,
			FinishTimeSurgery DATETIME,
			StartTimeRecovery DATETIME,
			PatientReadyEndRecovery DATETIME,
			PatientLeaveRecovery DATETIME,
			PatientIdentifier VARCHAR(10),
			DateofBirth DATE,
			TreatmentFunctionCode VARCHAR(10),
			PatientCancelledFlag VARCHAR(10),
			CancellationDate DATE,
			ASAGrade VARCHAR(10),
			PatCancellationReason VARCHAR(10),
			Urgency VARCHAR(10),
			IntendedManagement VARCHAR(10),
			AdmissionMethod VARCHAR(10),
			PatientClassification VARCHAR(10),
			AdministrativeCategory VARCHAR(10),
			ActualAnaestheticType VARCHAR(100),
			PatientArrivingDelayReason VARCHAR(10),
			AnaesthetistCode VARCHAR(100),
			ProcedureCode VARCHAR(10),
			StockCode VARCHAR(10),
			StockType VARCHAR(10), 
			UnitofMeasure VARCHAR(10),
			Quantity VARCHAR(10),
			SurgeonCode VARCHAR(100),
			Surname VARCHAR(50),
			Forename VARCHAR(50),
			Sex VARCHAR(10),
			HospitalSiteCode VARCHAR(10),
			Outcome VARCHAR(50),
			OperationType VARCHAR(10),
			NHSNo VARCHAR(10),
			LocalSubSpec VARCHAR(20),
			PlannedMin VARCHAR(5)
		)

		-- Declare required variables
		DECLARE
			@sptyp_clinic NUMERIC(10, 0),
			@sptyp_theatre NUMERIC(10, 0),
			@prtyp_gmprc NUMERIC(10, 0),
			@cityp_natgp NUMERIC(10, 0),
			@cityp_gmc NUMERIC(10, 0),
			@cityp_dent NUMERIC(10, 0),
			@hotyp_trust NUMERIC(10, 0),
			@hityp_natnl NUMERIC(10, 0),
			@attnd_dna NUMERIC(10, 0),
			@attnd_2 NUMERIC(10, 0),
			@prtyp_conlt NUMERIC(10, 0),
			@prtyp_admgp NUMERIC(10, 0),
			@sctyp_theat NUMERIC(10, 0),
			@prtyp_surg NUMERIC(10, 0),
			@prtyp_anaes NUMERIC(10, 0)

		-- ****************************************************************************************************
		-- Pre-process parameters
		-- ****************************************************************************************************

		-- Set end date to 23:59:59.997 to get whole day (note SQL rounds to .003 of a second)
		SET @end_date = DATEADD(ms, -3, @end_date) + 1


		-- ****************************************************************************************************
		-- Set initial values for variables
		-- ****************************************************************************************************
		SET @sptyp_theatre = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''SPTYP''
				AND main_code = ''THEAT''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)


		SET @prtyp_gmprc = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''PRTYP''
				AND main_code = ''GMPRC''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @cityp_natgp = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''CITYP''
				AND main_code = ''NATGP''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @cityp_gmc = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''CITYP''
				AND main_code = ''GMC''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @cityp_dent = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''CITYP''
				AND main_code = ''NATDP''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @hotyp_trust = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''HOTYP''
				AND main_code = ''TRUST''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @hityp_natnl = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''HITYP''
				AND main_code = ''NATNL''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @attnd_dna = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''ATTND''
				AND main_code = ''DNA''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @attnd_2 = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''ATTND''
				AND main_code = ''2''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @prtyp_anaes = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''PRTYP''
				AND main_code = ''ANAES''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @prtyp_surg = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''PRTYP''
				AND main_code = ''SURG''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)


		SET @prtyp_conlt = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''PRTYP''
				AND main_code = ''CONLT''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @prtyp_admgp = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''PRTYP''
				AND main_code = ''ADMGP''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		SET @sctyp_theat = (
			SELECT rfval_refno
			FROM [ipmproduction].[dbo].[reference_values]
			WHERE rfvdm_code = ''SCTYP''
				AND main_code = ''THEAT''
				AND ISNULL(archv_flag, ''N'') = ''N''
		)

		-- ****************************************************************************************************
		-- Main processing
		-- ****************************************************************************************************

		-- First insert into the temp table the main schedule, patient AND referral info
		INSERT INTO #x_theatreextract
		SELECT DISTINCT
			''West'', --SenderOrg
			patnt.PASID, --Theatrecaseno NUMERIC(10, 0)
			CAST(sps.start_dttm AS DATE), --Sessiondate DATETIME
			schdl.schdl_Refno, --ScheduleNumber NUMERIC(10, 0)
			sp.code, --TheatreCode VARCHAR(20)
			sps.spssn_Refno, --[Session] NUMERIC(10, 0)
			sp.CODE, --WardCode VARCHAR(20)
			NULL, --OperatingOrder VARCHAR(10)
			spec.main_ident, --SpellConsultantSpecialty VARCHAR(20)
			proca.main_ident, --SpellConsultant VARCHAR(30)
			NULL, --SpellStartDate DATE
			NULL, --SpellStartTime DATETIME
			NULL, --SpellDischargeDate DATE
			NULL, --SpellDischargeTime DATETIME
			CAST(schdl.CALLED_DTTM AS DATETIME), --TimePatientSentFor DATETIME
			CAST(schdl.arrived_Dttm AS DATETIME), --ArrivalTimeinTheatreSuite DATETIME
			NULL, --TimeintoAnaestheticRoom DATETIME
			CAST(th.anaes_start_Dttm AS DATETIME), --StartTimeAnaesthesia DATETIME
			NULL, --FinishTimeAnaesthesia DATETIME
			CAST(th.surgy_Start_dttm AS DATETIME), --StartTimeSurgery DATETIME
			NULL, --KnifetoSkinStartTime DATETIME
			CAST(th.surgy_cmplt_dttm AS DATETIME), --FinishTimeSurgery DATETIME
			CAST(schdl.into_postop_dttm AS DATETIME), --StartTimeRecovery DATETIME
			NULL, --PatientReadyEndRecovery DATETIME
			CAST(schdl.departed_Dttm AS DATETIME), --PatientLeaveRecovery DATETIME
			patnt.pasid, --PatientIdentifier VARCHAR(20)
			patnt.dttm_of_birth, --DateofBirth DATE
			NULL, --TreatmentFunctionCode VARCHAR(20)
			CASE WHEN schdl.cancr_Dttm is not NULL AND cancb_refno = 206843 THEN ''1'' ELSE ''2'' END, --PatientCancelledFlag VARCHAR(1)
			CAST(DATEADD(d, DATEDIFF(d, 0, schdl.cancr_Dttm), 0) AS DATE), --CancellationDate DATE
			NULL, --ASAGrade VARCHAR(8)
			NULL, --PatCancellationReason VARCHAR(50)
			NULL, --Urgency VARCHAR(50)
			NULL, --IntendedManagement VARCHAR(20) 
			NULL, --AdmissionMethod VARCHAR(15)
			NULL, --PatientClassification VARCHAR(20)
			NULL, --AdministrativeCategory VARCHAR(50)
			NULL, --ActualAnaestheticType VARCHAR(10)
			NULL, --PatientArrivingDelayReason VARCHAR(8)
			NULL, --AnaesthetistCode VARCHAR(20)
			NULL, --ProcedureCode VARCHAR(20)
			NULL, --StockCode VARCHAR(20)
			NULL, --StockType VARCHAR(8)
			NULL, --UnitofMeasure VARCHAR(20)
			NULL, --Quantity VARCHAR(20)
			NULL, --SurgeonCode VARCHAR(20)
			patnt.surname, --PatientSurname
			patnt.forename, --PatientForename
			CASE WHEN patnt.sexxx_Refno = 3814 THEN ''F'' ELSE ''M'' END, --PatientSex
			CASE WHEN sp.code like ''%YG%'' THEN ''7A1AU'' when 
			sp.code like ''%LL%'' THEN ''7A1AV'' ELSE NULL end, --HospitalSiteCode
			r1.DESCRIPTION, --Outcome
			NULL, --OperationType
			patnt.NHS_IDENTIFIER, --NHSIdentifier
			NULL, --LocalSubSpec
			CONVERT(VARCHAR(5),schdl.oper_duration) --PlannedMinutes
		FROM [IPMproduction].[dbo].[schedules] schdl
			INNER JOIN [ipmproduction].[dbo].[patients] patnt ON schdl.patnt_refno = patnt.patnt_refno
			INNER JOIN [ipmproduction].[dbo].[prof_carers] proca ON schdl.proca_refno = proca.proca_refno
			INNER JOIN [ipmproduction].[dbo].[service_point_Sessions] sps on sps.spssn_Refno = schdl.spssn_Refno
			INNER JOIN [ipmproduction].[dbo].[service_points] sp on sp.spont_Refno = sps.spont_Refno
			INNER JOIN [ipmproduction].[dbo].[specialties] spec on spec.spect_refno = schdl.SPECT_REFNO
			LEFT OUTER JOIN [ipmproduction].[dbo].[theatre_events] th on th.schdl_Refno = schdl.schdl_Refno
			LEFT OUTER JOIN [ipmproduction].[dbo].[referrals] refrl ON schdl.refrl_refno = refrl.refrl_refno
			LEFT JOIN [ipmproduction].[dbo].[reference_Values] r1 on r1.RFVAL_REFNO = th.THOCM_REFNO 
		WHERE schdl.sctyp_refno = @sctyp_theat -- OTPAT schedules only (** Hardcoded in original Extract_OP_ATTENDANCE sp **)
				AND schdl.start_dttm BETWEEN @start_date AND @end_date -- Schedules starting BETWEEN given dates
				AND ISNULL(schdl.archv_flag, ''N'') = ''N'' -- Only unarchived schedules
				AND ISNULL(th.archv_flag, ''N'') = ''N''

		-- ****************************************************************************************************
		-- Update the temp table with additional info not done in initial select
		-- ****************************************************************************************************

		--SpellStartDate
		UPDATE #x_theatreextract
		SET SpellStartDate = CAST(DATEADD(d, DATEDIFF(d, 0, sps.start_dttm), 0) AS DATE)
		FROM [ipmproduction].[dbo].[service_point_Stays] sps
			JOIN [ipmproduction].[dbo].[provider_spells] pv ON pv.prvsp_Refno = sps.prvsp_Refno AND sps.end_dttm = pv.disch_Dttm
			JOIN [ipmproduction].[dbo].[patients] p ON p.patnt_Refno = pv.patnt_Refno
		WHERE p.pasid = #x_theatreextract.PatientIdentifier
			AND #x_theatreextract.TimePatientSentFor BETWEEN CONVERT(VARCHAR, pv.admit_Dttm, 113) AND CONVERT(VARCHAR, pv.disch_Dttm, 113)

		---SpellStartTime
		UPDATE #x_theatreextract
		SET SpellStartTime = CAST(sps.start_dttm AS DATETIME)
		FROM [ipmproduction].[dbo].[service_point_Stays] sps
			JOIN [ipmproduction].[dbo].[provider_spells] pv ON pv.prvsp_Refno = sps.prvsp_Refno AND sps.end_dttm = pv.disch_Dttm
			JOIN [ipmproduction].[dbo].[patients] p ON p.patnt_Refno = pv.patnt_Refno
		WHERE p.pasid = #x_theatreextract.PatientIdentifier
			AND #x_theatreextract.TimePatientSentFor BETWEEN CONVERT(VARCHAR, pv.admit_Dttm, 113) AND CONVERT(VARCHAR, pv.disch_Dttm, 113)


		---SpellEndDate
		UPDATE #x_theatreextract
		SET SpellDischargeDate = CAST(DATEADD(d, DATEDIFF(d, 0, sps.end_dttm), 0) AS DATE)
		FROM [ipmproduction].[dbo].[service_point_Stays] sps
			JOIN [ipmproduction].[dbo].[provider_spells] pv ON pv.prvsp_Refno = sps.prvsp_Refno AND sps.end_dttm = pv.disch_Dttm
			JOIN [ipmproduction].[dbo].[patients] p ON p.patnt_Refno = pv.patnt_Refno
		WHERE p.pasid = #x_theatreextract.PatientIdentifier
			AND #x_theatreextract.TimePatientSentFor BETWEEN CONVERT(VARCHAR, pv.admit_Dttm, 113) AND CONVERT(VARCHAR, pv.disch_Dttm, 113)


		--SpellEndTime
		UPDATE #x_theatreextract
		SET SpellDischargeTime = CAST(sps.end_dttm AS DATETIME)
		FROM [ipmproduction].[dbo].[service_point_Stays] sps
			JOIN [ipmproduction].[dbo].[provider_spells] pv ON pv.prvsp_Refno = sps.prvsp_Refno AND sps.end_dttm = pv.disch_Dttm
			JOIN [ipmproduction].[dbo].[patients] p ON p.patnt_Refno = pv.patnt_Refno
		WHERE p.pasid = #x_theatreextract.PatientIdentifier
			AND #x_theatreextract.TimePatientSentFor BETWEEN CONVERT(VARCHAR, pv.admit_Dttm, 113) AND CONVERT(VARCHAR, pv.disch_Dttm, 113)


		--PatCancellationReason VARCHAR(50)
		UPDATE #x_theatreextract
		SET PatCancellationReason = ri.identifier
		FROM [ipmproduction].[dbo].[reference_Value_ids] ri
			JOIN [ipmproduction].[dbo].[reference_Values] r ON r.rfval_Refno = ri.rfval_Refno AND ri.rityp_code=''NHS''
			JOIN [ipmproduction].[dbo].[schedules] s ON s.cancr_Refno = r.rfval_Refno
		WHERE s.schdl_Refno = #x_theatreextract.ScheduleNumber


		--Urgency VARCHAR(50)
		UPDATE #x_theatreextract
		SET Urgency = ''1''
		FROM [ipmproduction].[dbo].[reference_values] r
			JOIN [ipmproduction].[dbo].[schedules] s ON s.urgnc_Refno = r.rfval_Refno
		WHERE s.schdl_Refno = #x_theatreextract.ScheduleNumber


		--AdmissionMethod VARCHAR(15)
		UPDATE #x_theatreextract 
		SET admissionmethod = ri.identifier
		FROM [ipmproduction].[dbo].[reference_values] r
			JOIN [ipmproduction].[dbo].[reference_value_ids] ri ON ri.rfval_refno = r.rfval_refno AND ri.rityp_code = ''NHS''
			JOIN [ipmproduction].[dbo].[provider_spells] pv ON pv.admet_Refno = r.rfval_Refno
			JOIN [ipmproduction].[dbo].[patients] p ON p.patnt_Refno = pv.patnt_Refno
		WHERE p.pasid = #x_theatreextract.PatientIdentifier
			AND CONVERT(DATE, #x_theatreextract.Sessiondate) BETWEEN CONVERT(DATE, pv.admit_Dttm) AND CONVERT(DATE, pv.disch_Dttm)

		UPDATE #x_theatreextract 
		SET admissionmethod = ''99'' 
		WHERE admissionmethod IS NULL


		--AdministrativeCategory VARCHAR(50)
		UPDATE #x_theatreextract 
		SET AdministrativeCategory = NULL
		FROM [ipmproduction].[dbo].[reference_values] r
			JOIN [ipmproduction].[dbo].[schedules] s ON s.adcat_Refno = r.rfval_Refno
		WHERE s.schdl_Refno = #x_theatreextract.ScheduleNumber


		--ActualAnaestheticType VARCHAR(10)
		UPDATE #x_theatreextract 
		SET ActualAnaestheticType = r.description
		FROM [ipmproduction].[dbo].[reference_values] r
			JOIN [ipmproduction].[dbo].[schedules] s ON s.antyp_Refno = r.rfval_Refno
		WHERE s.schdl_Refno = #x_theatreextract.ScheduleNumber


		--AnaesthetistCode
		UPDATE #x_theatreextract 
		SET AnaesthetistCode = pro.main_ident
		FROM [ipmproduction].[dbo].[prof_Carers] pro
			JOIN [ipmproduction].[dbo].[prof_Carer_map] pcm ON pcm.proca_Refno = pro.proca_Refno
			JOIN [ipmproduction].[dbo].[schedules] s ON s.schdl_Refno = pcm.schdl_Refno
		WHERE s.schdl_Refno = #x_theatreextract.ScheduleNumber
			AND pcm.prrol_Refno = 100170


		--SurgeonCode VARCHAR(20)
		UPDATE #x_theatreextract 
		SET SurgeonCode = pro.main_ident
		FROM [ipmproduction].[dbo].[prof_Carers] pro
			JOIN [ipmproduction].[dbo].[prof_Carer_map] pcm ON pcm.proca_Refno = pro.proca_Refno
			JOIN [ipmproduction].[dbo].[schedules] s ON s.schdl_Refno = pcm.schdl_Refno
		WHERE s.schdl_Refno = #x_theatreextract.ScheduleNumber
			AND pcm.prrol_Refno = 100176


		SELECT
			TheatreCaseNo,
			SessionDate,
			ScheduleNumber,
			TheatreCode,
			[Session],
			WardCode,
			LEFT(SpellConsultantSpecialty, 3) AS SpellConsultantSpecialty,
			SpellConsultant,
			SpellStartDate,
			CAST(SpellStartTime AS TIME) AS SpellStartTime,
			SpellDischargeDate,
			CAST(SpellDischargeTime AS TIME) AS SpellDischargeTime,
			CAST(TimePatientSentFor AS DATE) AS PatientSentForDate,
			CAST(TimePatientSentFor AS TIME) AS PatientSentForTime,
			CAST(ArrivalTimeInTheatreSuite AS DATE) AS ArrivalInTheatreSuiteDate,
			CAST(ArrivalTimeInTheatreSuite AS TIME) AS ArrivalInTheatreSuiteTime,
			CAST(TimeIntoAnaestheticRoom AS DATE) AS IntoAnaestheticRoomDate,
			CAST(TimeIntoAnaestheticRoom AS TIME) AS IntoAnaestheticRoomTime,
			CAST(StartTimeAnaesthesia AS DATE) AS StartAnaesthesiaDate,
			CAST(StartTimeAnaesthesia AS TIME) AS StartAnaesthesiaTime,
			CAST(FinishTimeAnaesthesia AS DATE) AS FinishAnaesthesiaDate,
			CAST(FinishTimeAnaesthesia AS TIME) AS FinishAnaesthesiaTime,
			CAST(StartTimeSurgery AS DATE) AS StartSurgeryDate,
			CAST(StartTimeSurgery AS TIME) AS StartSurgeryTime,
			CAST(KnifeToSkinStartTime AS DATE) AS KnifeToSkinStartDate,
			CAST(KnifeToSkinStartTime AS TIME) AS KnifeToSkinStartTime,
			CAST(FinishTimeSurgery AS DATE) AS FinishSurgeryDate,
			CAST(FinishTimeSurgery AS TIME) AS FinishSurgeryTime,
			CAST(StartTimeRecovery AS DATE) AS StartRecoveryDate,
			CAST(StartTimeRecovery AS TIME) AS StartRecoveryTime,
			CAST(PatientReadyEndRecovery AS DATE) AS PatientReadyEndRecoveryDate,
			CAST(PatientReadyEndRecovery AS TIME) AS PatientReadyEndRecoveryTime,
			CAST(PatientLeaveRecovery AS DATE) AS PatientLeaveRecoveryDate,
			CAST(PatientLeaveRecovery AS TIME) AS PatientLeaveRecoveryTime,
			PatientIdentifier,
			DateOfBirth,
			TreatmentFunctionCode,
			PatientCancelledFlag,
			CancellationDate,
			ASAGrade,
			PatCancellationReason,
			Urgency,
			IntendedManagement,
			AdmissionMethod,
			PatientClassification,
			AdministrativeCategory,
			ActualAnaestheticType,
			PatientArrivingDelayReason,
			Surname,
			Forename,
			Sex,
			HospitalSiteCode,
			Outcome,
			OperationType,
			NHSNo,
			CAST(NULL AS TIME) AS SessionStartTime,
			CAST(NULL AS TIME) AS SessionEndTime,
			CAST(NULL AS VARCHAR(10)) AS OPCSPlanned1,
			CAST(NULL AS VARCHAR(10)) AS OPCSPlanned2,
			CAST(NULL AS VARCHAR(10)) AS OPCSPlanned3,
			CAST(NULL AS VARCHAR(10)) AS OPCSPlanned4,
			CAST(NULL AS VARCHAR(10)) AS OPCSPlanned5,
			CAST(NULL AS VARCHAR(10)) AS OPCSActual1,
			CAST(NULL AS VARCHAR(10)) AS OPCSActual2,
			CAST(NULL AS VARCHAR(10)) AS OPCSActual3,
			CAST(NULL AS VARCHAR(10)) AS OPCSActual4,
			CAST(NULL AS VARCHAR(10)) AS OPCSActual5,
			CAST(NULL AS VARCHAR(10)) AS Site1,
			CAST(NULL AS VARCHAR(10)) AS Site2,
			CAST(NULL AS VARCHAR(10)) AS Site3,
			CAST(NULL AS VARCHAR(10)) AS Site4,
			CAST(NULL AS VARCHAR(10)) AS Site5,
			CAST(NULL AS VARCHAR(10)) AS SharpCount1,
			CAST(NULL AS VARCHAR(10)) AS SharpCount2,
			CAST(NULL AS VARCHAR(10)) AS SwabCount1,
			CAST(NULL AS VARCHAR(10)) AS SwabCount2,
			CAST(NULL AS VARCHAR(10)) AS InstrumentCount1,
			CAST(NULL AS VARCHAR(10)) AS InstrumentCount2,
			AnaesthetistCode AS LeadAnaesth,
			SurgeonCode AS LeadCons,
			SenderOrganisation,
			CAST(NULL AS VARCHAR(MAX)) AS TheatreNotes,
			CAST(NULL AS VARCHAR(1)) AS ByPassRecovery
		FROM #x_theatreextract
	') AT [7A1AUSRVIPMSQL]
END
GO
