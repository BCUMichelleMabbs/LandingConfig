SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SORT THE GP AND REGISTERED GP HISTORY
--ADD THE CONTACT ADDRESS AS THE THIRD OPTION
--REFERENCE TABLES FOR NHS NUMBER LOOKUP, ETHNICITY, ETC ETC

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_PatientWestSymphonyORIG-MP]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @LastAttendanceDate AS DATE = (SELECT ISNULL(MAX(ArrivalDate),'31 December 2019') FROM [Foundation].[dbo].[UnscheduledCare_Data_EDAttendance] WHERE Source='WEDS' AND Area='West')-- AND SiteCodeOfTreatment='7A1AU')
DECLARE @LastAttendanceDateString AS VARCHAR(30) = DATENAME(DAY,@LastAttendanceDate) + ' ' + DATENAME(MONTH,@LastAttendanceDate) + ' ' + DATENAME(YEAR,@LastAttendanceDate)
DECLARE @DateToString AS VARCHAR(30) = DATENAME(DAY,GETDATE()) + ' ' + DATENAME(MONTH,GETDATE()) + ' ' + DATENAME(YEAR,GETDATE())
--DECLARE @DateToString AS VARCHAR(30) = '28 february 2021'
  
DECLARE @Result AS TABLE(
	RowId					INT NOT NULL IDENTITY(1,1),
	AttendanceIdentifier	INT,
	EpisodeIdentifier		INT,
	LocalPatientIdentifier	VARCHAR(30),
	NHSNumber				VARCHAR(30),
	Surname					VARCHAR(50),
	Forename				VARCHAR(50),
	DateOfBirth				DATE,
	Gender					VARCHAR(10),
	Title					VARCHAR(20),
	Address1				VARCHAR(100),
	Address2				VARCHAR(100),
	Address3				VARCHAR(100),
	Address4				VARCHAR(100),
	Address5				VARCHAR(100),
	Postcode				VARCHAR(10),
	RegisteredGP			VARCHAR(20),
	RegisteredPractice		VARCHAR(20),
	NHSNumberStatus			VARCHAR(5),
	DHA						VARCHAR(5),
	Ethnicity				VARCHAR(5),
	AttendanceDate			DATETIME
)
DECLARE @NHSNumber AS TABLE(
	RowId					INT NOT NULL IDENTITY(1,1),
	LocalPatientIdentifier	VARCHAR(30),
	NHSNumber				VARCHAR(30),
	NHSNumberStatus			VARCHAR(5),
	UpdateDate				DATETIME
)
DECLARE @Patient AS TABLE(
	RowId					INT NOT NULL IDENTITY(1,1),
	LocalPatientIdentifier	VARCHAR(30),
	Surname					VARCHAR(50),
	Forename				VARCHAR(50),
	DateOfBirth				DATE,
	Gender					VARCHAR(10),
	Title					VARCHAR(20),
	UpdateDate				DATETIME
)
DECLARE @PatientDetail AS TABLE(
	RowId					INT NOT NULL IDENTITY(1,1),
	LocalPatientIdentifier	VARCHAR(30),
	Ethnicity				VARCHAR(5),
	RegisteredGP			VARCHAR(20),
	RegisteredPractice		VARCHAR(20),
	UpdateDate				DATETIME
)

DECLARE @Address AS TABLE(
	RowId					INT NOT NULL IDENTITY(1,1),
	LocalPatientIdentifier	VARCHAR(30),
	Address1				VARCHAR(100),
	Address2				VARCHAR(100),
	Address3				VARCHAR(100),
	Address4				VARCHAR(100),
	Address5				VARCHAR(100),
	Postcode				VARCHAR(10),
	DHA						VARCHAR(5),
	Type					VARCHAR(5),
	UpdateDate				DATETIME
)

INSERT INTO @Result(AttendanceIdentifier,EpisodeIdentifier,LocalPatientIdentifier,AttendanceDate)
SELECT DISTINCT
	A.atd_id AS AttendanceIdentifier,
	E.epd_id AS EpisodeIdentifier,
	E.epd_pid AS LocalPatientIdentifier,
	A.atd_arrivaldate AS ArrivalDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Attendance_Details A
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Episodes E ON A.atd_epdid=E.epd_id
WHERE
	CAST(A.atd_arrivaldate AS DATE)>@LastAttendanceDateString AND CAST(A.atd_arrivaldate AS DATE)<@DateToString AND
	--CAST(A.atd_arrivaldate AS DATE)>'01 november 2019' AND CAST(A.atd_arrivaldate AS DATE)<'31 december 2019' AND
	atd_deleted=0 AND 
	--epd_deptid = 1
	LEFT(A.ATD_NUM,2) IN ('LL','TM','ED','YA','YP','YB','YG')

	--and E.epd_pid = '859581'


/* UPDATE NHS NUMBER AND STATUS */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
--;WITH N(psi_pid,psi_system_id,psi_status,psi_update)AS(
--	SELECT DISTINCT 
--		psi_pid,psi_system_id,psi_status,CAST(psi_update AS DATE)
--	FROM 
--		[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient_system_ids PSI 
--		INNER JOIN @Result R ON R.LocalPatientIdentifier=PSI.psi_pid AND PSI.psi_system_name=1583
--)
--UPDATE 
--	@Result
--SET 
--	NHSNumber=(SELECT TOP 1 N.psi_system_id FROM N WHERE R.LocalPatientIdentifier=N.psi_pid AND CAST(R.AttendanceDate AS DATE)>=CAST(N.psi_update AS DATE)),
--	NHSNumberStatus=(SELECT TOP 1 N.psi_status FROM N WHERE R.LocalPatientIdentifier=N.psi_pid AND CAST(R.AttendanceDate AS DATE)>=CAST(N.psi_update AS DATE))
--FROM
--	@Result R

INSERT INTO @NHSNumber(LocalPatientIdentifier,NHSNumber,NHSNumberStatus,UpdateDate)
SELECT DISTINCT psi_pid,psi_system_id,psi_status,CAST(psi_update AS DATE) FROM Patient_system_ids PSI INNER JOIN @Result R ON R.LocalPatientIdentifier=PSI.psi_pid AND PSI.psi_system_name=1583
UNION
SELECT DISTINCT psi_pid,psi_system_id,psi_status,CAST(psi_update AS DATE) FROM Aud_Patient_System_ids APSI INNER JOIN @Result R ON R.LocalPatientIdentifier=APSI.psi_pid AND APSI.psi_system_name=1583

UPDATE 
	@Result
SET 
	NHSNumber=ISNULL(
	(SELECT TOP 1 NHSNumber FROM @NHSNumber NHS WHERE R.LocalPatientIdentifier=NHS.LocalPatientIdentifier AND CAST(R.AttendanceDate AS DATE)>=CAST(NHS.UpdateDate AS DATE) ORDER BY CAST(NHS.UpdateDate AS DATE) DESC),
	(SELECT TOP 1 NHSNumber FROM @NHSNumber NHS WHERE R.LocalPatientIdentifier=NHS.LocalPatientIdentifier AND CAST(R.AttendanceDate AS DATE)<CAST(NHS.UpdateDate AS DATE) ORDER BY CAST(NHS.UpdateDate AS DATE))
	),
	NHSNumberStatus=ISNULL(
	(SELECT TOP 1 NHSNumberStatus FROM @NHSNumber NHS WHERE R.LocalPatientIdentifier=NHS.LocalPatientIdentifier AND CAST(R.AttendanceDate AS DATE)>=CAST(NHS.UpdateDate AS DATE) ORDER BY CAST(NHS.UpdateDate AS DATE) DESC),
	(SELECT TOP 1 NHSNumberStatus FROM @NHSNumber NHS WHERE R.LocalPatientIdentifier=NHS.LocalPatientIdentifier AND CAST(R.AttendanceDate AS DATE)<CAST(NHS.UpdateDate AS DATE) ORDER BY CAST(NHS.UpdateDate AS DATE))
	)
FROM
	@Result R

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* UPDATE PATIENT AND PATIENT AUDIT */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
INSERT INTO @Patient(LocalPatientIdentifier,Surname,Forename,DateOfBirth,Gender,Title,UpdateDate)
SELECT 
	P.pat_pid AS LocalPatientIdentifier,
	P.pat_surname AS Surname,
	P.pat_forename AS Forename,
	P.pat_dob AS DateOfBirth,
	P.pat_sex AS Gender,
	P.pat_title AS Title,
	P.pat_update AS UpdateDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient P
	INNER JOIN @Result R ON LocalPatientIdentifier=P.pat_pid
	
MERGE @Patient AS Target
USING (
SELECT DISTINCT
		AP.pat_pid AS LocalPatientIdentifier,
		AP.pat_surname AS Surname,
		AP.pat_forename AS Forename,
		AP.pat_dob AS DateOfBirth,
		AP.pat_sex AS Gender,
		AP.pat_title AS Title,
		AP.pat_update AS UpdateDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Aud_Patient AP
	INNER JOIN @Result R ON LocalPatientIdentifier=AP.pat_pid
) AS Source (LocalPatientIdentifier,Surname,Forename,DateOfBirth,Gender,Title,UpdateDate)
ON (
	Target.LocalPatientIdentifier=Source.LocalPatientIdentifier AND 
	Target.Surname=Source.Surname AND 
	Target.Forename=Source.Forename AND 
	Target.DateOfBirth=Source.DateOfBirth AND 
	Target.Gender=Source.Gender AND 
	Target.Title=Source.Title AND 
	Target.UpdateDate=Source.UpdateDate 
)
WHEN NOT MATCHED THEN INSERT(LocalPatientIdentifier,Surname,Forename,DateOfBirth,Gender,Title,UpdateDate)
VALUES(LocalPatientIdentifier,Surname,Forename,DateOfBirth,Gender,Title,UpdateDate);

--UPDATE
--	@Result
--SET
--	Surname=P.Surname,
--	Forename=P.Forename,
--	DateOfBirth=P.DateOfBirth,
--	Gender=P.Gender,
--	Title=P.Title
--FROM
--	@Result R
--	INNER JOIN @Patient P ON 
--		R.LocalPatientIdentifier=P.LocalPatientIdentifier AND 
--		P.UpdateDate=(
--			SELECT TOP 1 UpdateDate 
--			FROM @Patient innerP 
--			WHERE innerP.LocalPatientIdentifier=R.LocalPatientIdentifier AND
--			CAST(R.AttendanceDate AS DATE)>=CAST(innerP.UpdateDate AS DATE)
--			ORDER BY innerP.UpdateDate DESC)

UPDATE
	@Result
SET
	Surname=ISNULL(P.Surname,P1.Surname),
	Forename=ISNULL(P.Forename,P1.Forename),
	DateOfBirth=ISNULL(P.DateOfBirth,P1.DateOfBirth),
	Gender=ISNULL(P.Gender,P1.Gender),
	Title=ISNULL(P.Title,P1.Title)
FROM
	@Result R
	LEFT JOIN @Patient P ON 
		R.LocalPatientIdentifier=P.LocalPatientIdentifier AND 
		P.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Patient innerP 
			WHERE innerP.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			CAST(R.AttendanceDate AS DATE)>=CAST(innerP.UpdateDate AS DATE)
			ORDER BY innerP.UpdateDate DESC)
	LEFT JOIN @Patient P1 ON
		R.LocalPatientIdentifier=P1.LocalPatientIdentifier AND 
		P1.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Patient innerP 
			WHERE innerP.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			CAST(R.AttendanceDate AS DATE)<=CAST(innerP.UpdateDate AS DATE)
			ORDER BY innerP.UpdateDate)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* UPDATE PATIENT DETAIL AND PATIENT DETAIL AUDIT */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
INSERT INTO @PatientDetail(LocalPatientIdentifier,Ethnicity,RegisteredGP,RegisteredPractice,UpdateDate)
SELECT 
	PD.pdt_pid AS LocalPatientIdentifier,
	PD.pdt_ethnic AS Ethnicity,
	GP.gp_code AS RegisteredGP,
	GPPractice.pr_praccode AS RegisteredPractice,
	PD.pdt_update AS UpdateDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient_details PD
	INNER JOIN @Result R ON LocalPatientIdentifier=PD.pdt_pid
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Gp GP ON PD.pdt_gpid=GP.gp_id
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Gp_Practise GPPractice ON PD.pdt_practise=GPPractice.Pr_id
	
MERGE @PatientDetail AS Target
USING (
SELECT DISTINCT
	APD.pdt_pid AS LocalPatientIdentifier,
	APD.pdt_ethnic AS Ethnicity,
	GP.gp_code AS RegisteredGP,
	GPPractice.pr_praccode AS RegisteredPractice,
	APD.pdt_update AS UpdateDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Aud_Patient_Details APD
	INNER JOIN @Result R ON LocalPatientIdentifier=APD.pdt_pid
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Gp GP ON APD.pdt_gpid=GP.gp_id
	LEFT JOIN [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Gp_Practise GPPractice ON APD.pdt_practise=GPPractice.Pr_id
) AS Source (LocalPatientIdentifier,Ethnicity,RegisteredGP,RegisteredPractice,UpdateDate)
ON (
	Target.LocalPatientIdentifier=Source.LocalPatientIdentifier AND 
	Target.Ethnicity=Source.Ethnicity AND 
	Target.RegisteredGP=Source.RegisteredGP AND 
	Target.RegisteredPractice=Source.RegisteredPractice AND 
	Target.UpdateDate=Source.UpdateDate 
)
WHEN NOT MATCHED THEN INSERT(LocalPatientIdentifier,Ethnicity,RegisteredGP,RegisteredPractice,UpdateDate)
VALUES(LocalPatientIdentifier,Ethnicity,RegisteredGP,RegisteredPractice,UpdateDate);

--UPDATE
--	@Result
--SET
--	Ethnicity=PD.Ethnicity,
--	RegisteredGP=PD.RegisteredGP,
--	RegisteredPractice=PD.RegisteredPractice
--FROM
--	@Result R
--	INNER JOIN @PatientDetail PD ON 
--		R.LocalPatientIdentifier=PD.LocalPatientIdentifier AND 
--		PD.UpdateDate=(
--			SELECT TOP 1 UpdateDate 
--			FROM @PatientDetail innerPD 
--			WHERE innerPD.LocalPatientIdentifier=R.LocalPatientIdentifier AND
--			CAST(R.AttendanceDate AS DATE)>=CAST(innerPD.UpdateDate AS DATE)
--			ORDER BY innerPD.UpdateDate DESC)

UPDATE
	@Result
SET
	Ethnicity=ISNULL(PD.Ethnicity,PD1.Ethnicity),
	RegisteredGP=ISNULL(PD.RegisteredGP,PD1.RegisteredGP),
	RegisteredPractice=ISNULL(PD.RegisteredPractice,PD1.RegisteredPractice)
FROM
	@Result R
	LEFT JOIN @PatientDetail PD ON 
		R.LocalPatientIdentifier=PD.LocalPatientIdentifier AND 
		PD.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @PatientDetail innerPD 
			WHERE innerPD.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			CAST(R.AttendanceDate AS DATE)>=CAST(innerPD.UpdateDate AS DATE)
			ORDER BY innerPD.UpdateDate DESC)
	LEFT JOIN @PatientDetail PD1 ON 
		R.LocalPatientIdentifier=PD1.LocalPatientIdentifier AND 
		PD1.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @PatientDetail innerPD 
			WHERE innerPD.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			CAST(R.AttendanceDate AS DATE)<=CAST(innerPD.UpdateDate AS DATE)
			ORDER BY innerPD.UpdateDate)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* UPDATE ADDRESS AND ADDRESS AUDIT */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
INSERT INTO @Address(LocalPatientIdentifier,Address1,Address2,Address3,Address4,Address5,Postcode,DHA,Type,UpdateDate)
SELECT 
	A.add_linkid AS LocalPatientIdentifier,
	A.add_line1 AS Address1,
	A.add_line2 AS Address2,
	A.add_line3 AS Address3,
	A.add_line4 AS Address4,
	A.add_line5 AS Address5,
	A.add_postcode AS Postcode,
	A.add_pcg AS DHA,
	A.add_type AS Type,
	A.add_update AS UpdateDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Address A
	INNER JOIN @Result R ON LocalPatientIdentifier=A.add_linkid
WHERE
	add_linktype=1 AND
	add_type IN (2673,4993,2677)


MERGE @Address AS Target
USING (
SELECT DISTINCT
	AA.add_linkid AS LocalPatientIdentifier,
	AA.add_line1 AS Address1,
	AA.add_line2 AS Address2,
	AA.add_line3 AS Address3,
	AA.add_line4 AS Address4,
	AA.add_line5 AS Address5,
	AA.add_postcode AS Postcode,
	AA.add_pcg AS DHA,
	AA.add_type AS Type,
	AA.add_update AS UpdateDate
FROM
	[BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Aud_Address AA
	INNER JOIN @Result R ON LocalPatientIdentifier=AA.add_linkid
WHERE
	add_linktype=1 AND
	add_type IN (2673,4993,2677)
) AS Source (LocalPatientIdentifier,Address1,Address2,Address3,Address4,Address5,Postcode,DHA,Type,UpdateDate)
ON (
	Target.LocalPatientIdentifier=Source.LocalPatientIdentifier AND 
	Target.Address1=Source.Address1 AND 
	Target.Address2=Source.Address2 AND 
	Target.Address3=Source.Address3 AND 
	Target.Address4=Source.Address4 AND 
	Target.Address5=Source.Address5 AND 
	Target.Postcode=Source.Postcode AND
	Target.DHA=Source.DHA AND
	Target.Type=Source.Type AND
	Target.UpdateDate=Source.UpdateDate 
)
WHEN NOT MATCHED THEN INSERT(LocalPatientIdentifier,Address1,Address2,Address3,Address4,Address5,Postcode,DHA,Type,UpdateDate)
VALUES(LocalPatientIdentifier,Address1,Address2,Address3,Address4,Address5,Postcode,DHA,Type,UpdateDate);

--UPDATE
--	@Result
--SET
--	Address1=COALESCE(A1.Address1,A2.Address1,A3.Address1),
--	Address2=COALESCE(A1.Address2,A2.Address2,A3.Address2),
--	Address3=COALESCE(A1.Address3,A2.Address3,A3.Address3),
--	Address4=COALESCE(A1.Address4,A2.Address4,A3.Address4),
--	Address5=COALESCE(A1.Address5,A2.Address5,A3.Address5),
--	Postcode=COALESCE(A1.Postcode,A2.Postcode,A3.Postcode),
--	DHA=COALESCE(A1.DHA,A2.DHA,A3.DHA)
--FROM
--	@Result R
--	LEFT JOIN @Address A1 ON 
--		R.LocalPatientIdentifier=A1.LocalPatientIdentifier AND 
--		A1.UpdateDate=(
--			SELECT TOP 1 UpdateDate 
--			FROM @Address innerA 
--			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
--			innerA.Type=2673 AND
--			CAST(R.AttendanceDate AS DATE)>=CAST(innerA.UpdateDate AS DATE)
--			ORDER BY innerA.UpdateDate DESC)
--	LEFT JOIN @Address A2 ON 
--		R.LocalPatientIdentifier=A2.LocalPatientIdentifier AND 
--		A2.UpdateDate=(
--			SELECT TOP 1 UpdateDate 
--			FROM @Address innerA 
--			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
--			innerA.Type=4993 AND
--			CAST(R.AttendanceDate AS DATE)>=CAST(innerA.UpdateDate AS DATE)
--			ORDER BY innerA.UpdateDate DESC)
--	LEFT JOIN @Address A3 ON 
--		R.LocalPatientIdentifier=A3.LocalPatientIdentifier AND 
--		A3.UpdateDate=(
--			SELECT TOP 1 UpdateDate 
--			FROM @Address innerA 
--			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
--			innerA.Type=2677 AND
--			CAST(R.AttendanceDate AS DATE)>=CAST(innerA.UpdateDate AS DATE)
--			ORDER BY innerA.UpdateDate DESC)

UPDATE
	@Result
SET
	Address1=COALESCE(A1.Address1,A2.Address1,A3.Address1,A4.Address1,A5.Address1,A6.Address1),
	Address2=COALESCE(A1.Address2,A2.Address2,A3.Address2,A4.Address2,A5.Address2,A6.Address2),
	Address3=COALESCE(A1.Address3,A2.Address3,A3.Address3,A4.Address3,A5.Address3,A6.Address3),
	Address4=COALESCE(A1.Address4,A2.Address4,A3.Address4,A4.Address4,A5.Address4,A6.Address4),
	Address5=COALESCE(A1.Address5,A2.Address5,A3.Address5,A4.Address5,A5.Address5,A6.Address5),
	Postcode=COALESCE(A1.Postcode,A2.Postcode,A3.Postcode,A4.Postcode,A5.Postcode,A6.Postcode),
	DHA=COALESCE(A1.DHA,A2.DHA,A3.DHA,A4.DHA,A5.DHA,A6.DHA)
FROM
	@Result R
	LEFT JOIN @Address A1 ON 
		R.LocalPatientIdentifier=A1.LocalPatientIdentifier AND 
		A1.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Address innerA 
			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			innerA.Type=2673 AND
			CAST(R.AttendanceDate AS DATE)>=CAST(innerA.UpdateDate AS DATE)
			ORDER BY innerA.UpdateDate DESC)
	LEFT JOIN @Address A2 ON 
		R.LocalPatientIdentifier=A2.LocalPatientIdentifier AND 
		A2.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Address innerA 
			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			innerA.Type=4993 AND
			CAST(R.AttendanceDate AS DATE)>=CAST(innerA.UpdateDate AS DATE)
			ORDER BY innerA.UpdateDate DESC)
	LEFT JOIN @Address A3 ON 
		R.LocalPatientIdentifier=A3.LocalPatientIdentifier AND 
		A3.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Address innerA 
			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			innerA.Type=2677 AND
			CAST(R.AttendanceDate AS DATE)>=CAST(innerA.UpdateDate AS DATE)
			ORDER BY innerA.UpdateDate DESC)
	LEFT JOIN @Address A4 ON 
		R.LocalPatientIdentifier=A4.LocalPatientIdentifier AND 
		A4.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Address innerA 
			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			innerA.Type=2673 AND
			CAST(R.AttendanceDate AS DATE)<=CAST(innerA.UpdateDate AS DATE)
			ORDER BY innerA.UpdateDate)
	LEFT JOIN @Address A5 ON 
		R.LocalPatientIdentifier=A5.LocalPatientIdentifier AND 
		A5.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Address innerA 
			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			innerA.Type=4993 AND
			CAST(R.AttendanceDate AS DATE)<=CAST(innerA.UpdateDate AS DATE)
			ORDER BY innerA.UpdateDate)
	LEFT JOIN @Address A6 ON 
		R.LocalPatientIdentifier=A6.LocalPatientIdentifier AND 
		A6.UpdateDate=(
			SELECT TOP 1 UpdateDate 
			FROM @Address innerA 
			WHERE innerA.LocalPatientIdentifier=R.LocalPatientIdentifier AND
			innerA.Type=2677 AND
			CAST(R.AttendanceDate AS DATE)<=CAST(innerA.UpdateDate AS DATE)
			ORDER BY innerA.UpdateDate)

/* OUTPUT THE REQUIRED FIELDS */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


SELECT 
	R.AttendanceIdentifier,
	R.LocalPatientIdentifier,
	R.NHSNumber,
	R.Surname,
	R.Forename,
	R.DateOfBirth,
	R.Gender,
	R.Title,
	NULL AS Address,
	R.Address1,
	R.Address2,
	R.Address3,
	R.Address4,
	R.Address5,
	R.Postcode,
	R.RegisteredGP,
	R.RegisteredPractice,
	'West' AS Area,
	'WEDS' AS Source,
	'EDA' AS Dataset,
	CAST(R.Attendanceidentifier AS VARCHAR(20))+'|West|WEDS|EDA' AS PatientLinkId,
	R.NHSNumberStatus,
	R.DHA,
	R.Ethnicity
FROM 
	@Result R
	
END
GO
