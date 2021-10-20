SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_MTED_Data_DAL]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT RowID,
		NHSNumber,
		HospitalNumber,
		GPPracticeName,
		GPPracticeCode,
		CAST(MedsLocked AS DATETIME) AS MedsLocked,
		CAST(DALSigned AS DATETIME) AS DALSigned,
		CAST(AdmissionDate AS DATE) AS AdmissionDate,
		CAST(LEFT(AdmissionTime, 7) AS TIME) AS AdmissionTime,
		AdmissionHospital,
		LTRIM(RTRIM(am.MainCode)) AS AdmissionMethod,
		REPLACE(DischargeWard, 'Department', 'Dept') AS DischargeWard,
		CAST(DischargeDate AS DATE) AS DischargeDate,
		CAST(LEFT(DischargeTime, 7) AS TIME) AS DischargeTime,
		ConsultantSurname,
		chm.[MainCode] AS ConsultantCode,
		ClinicalFinding,
		PrimaryDischargeDiagnosis,
		SecondaryDischargeDiagnosis,
		CAST(DiagnosisRecordedDate AS DATE) AS DiagnosisRecordedDate,
		DischargeDiagnosisStatus,
		PresentingComplaint,
		AllergyStatus,
		Allergy,
		TreatmentNarrative,
		CAST(DocumentCreatedDate AS DATE) AS DocumentCreatedDate,
		CAST(LEFT(DocumentCreatedTime, 7) AS TIME) AS DocumentCreatedTime,
		CASE DocumentStatus
		WHEN 'Ready for send' THEN 'Yes'
		WHEN 'Ready for resend' THEN 'Yes'
		ELSE 'No' END AS DocumentStatus,
		InvestigationsAndResults,
		NULL AS Area,
		TimeBand,
		[Status],
		CAST(DALSigned AS DATE) AS DALSignedDate,
		CAST(DALSigned AS TIME) AS DALSignedTime,
		CAST(MedsLocked AS DATE) AS MedsLockedDate,
		CAST(MedsLocked AS TIME) AS MedsLockedTime
	FROM [SSIS_Loading].[MTED].[dbo].[DAL] dal
		LEFT JOIN [Foundation].dbo.PAS_Ref_AdmissionMethod am ON dal.AdmissionMethod = am.LocalName AND [Source] = 'MTED'
		LEFT JOIN [Mapping].[dbo].[Common_HCP_Map] chm ON dal.[ConsultantCode] = chm.[LocalCode] AND chm.[Source] = 'MTED'
END
GO
