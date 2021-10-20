SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PCNSX_MinorsRepeatEDAttendancesLL]
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ThisCurrentAttendance AS INT
DECLARE @MaxCurrentAttendance AS INT
DECLARE @ThisCurrentRecipient AS INT
DECLARE @ThisMaxRecipient AS INT
DECLARE @SQL AS VARCHAR(MAX)
DECLARE @RecipientList AS VARCHAR(MAX)=''
DECLARE @Recipient AS TABLE(
	RowId		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Id			INT NOT NULL,
	SMTP		VARCHAR(100) NOT NULL,
	TypeId		INT NOT NULL
)
INSERT INTO @Recipient (Id, SMTP, TypeId)
SELECT Id, Value, RecipientTypeId FROM [7A1A1SRVINFODW1].PCNS.dbo.Recipient R WHERE R.GroupId = 66 AND Active='Y' AND RecipientTypeId=1  --66 is the group id for the temporary ed group
SELECT @ThisCurrentRecipient=MIN(RowId), @ThisMaxRecipient=MAX(RowId) FROM @Recipient

WHILE @ThisCurrentRecipient <= @ThisMaxRecipient
	BEGIN
		DECLARE @ThisRecipient AS VARCHAR(100) = (SELECT SMTP FROM @Recipient WHERE RowId = @ThisCurrentRecipient)
		IF @ThisCurrentRecipient=1
			BEGIN
				SET @RecipientList=@ThisRecipient
			END
		ELSE
			BEGIN
				SET @RecipientList+=';'+@ThisRecipient
			END
		
		SET @ThisCurrentRecipient+=1
	END

--SELECT @RecipientList



DECLARE @CurrentAttendance AS TABLE(
	RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	LocalPatientIdentifier	VARCHAR(20) NOT NULL,
	NHSNumber				VARCHAR(10),
	PatientIdentifier		VARCHAR(20) NOT NULL,
	PatientName				VARCHAR(100),
	BirthDate				DATE,
	ArrivalDate				DATE,
	ArrivalDateTime			SMALLDATETIME,
	AttendanceCount			INT
)
DECLARE @PreviousAttendance AS TABLE(
	RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	CurrentAttendanceId		INT NOT NULL,
	Area					VARCHAR(50) NOT NULL,
	LocalPatientIdentifier	varchar(20) NOT NULL,
	NHSNumber				VARCHAR(10),
	PatientName				VARCHAR(100),
	AttendanceDateTime		SMALLDATETIME
)

DECLARE @LPIType AS INT
DECLARE @LPIBackupType AS int
declare @NHSid int 
set @NHSid =(select top 1 lkp_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Lookups where lkp_name = 'NHSNumber')
set @LPIType=(select top 1 lkp_id from [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.lookups where lkp_name = 'BCUW PMI Number')

;WITH CurrentAttendances AS (
SELECT DISTINCT
	(SELECT TOP 1 RTRIM(psi_system_id) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient_system_ids PSID WHERE PSID.psi_system_name=@LPIType AND psi_pid=pat_pid) AS LocalPatientIdentifier,
    RTRIM((SELECT TOP 1 LEFT(psi_system_id,10) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.patient_System_ids WHERE psi_system_name = @NHSid AND psi_pid=pat_pid)) AS NHSNumber,
	COALESCE(REPLACE((SELECT TOP 1 LEFT(psi_system_id,10) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.patient_System_ids WHERE psi_system_name = @NHSid AND psi_pid=pat_pid),' ',''),
	(SELECT TOP 1 RTRIM(psi_system_id) FROM [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.Patient_system_ids PSID WHERE PSID.psi_system_name=@LPIType AND psi_pid=pat_pid)) AS PatientIdentifier,
	UPPER(RTRIM(pat_surname) + ', ' + RTRIM(pat_forename)) AS PatientName, 
	pat_dob AS DateOfBirth,
    CAST(a.atd_arrivaldate AS DATE) AS ArrivalDate, 
	a.atd_arrivaldate AS ArrivalDateTime
FROM 
    [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.attendance_details a 
    inner join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.episodes on a.atd_epdid = epd_id 
    inner join [BCUED\BCUED_DB].EMIS_SYM_BCU_Live.dbo.patient on epd_pid = pat_pid 
WHERE 
    a.atd_arrivaldate < GETDATE() AND 
	NULLIF(a.atd_dischoutcome,0) IS NULL AND
    atd_deleted = 0 AND
	LEFT (a.atd_num,4)='LLGH'
)

INSERT INTO @CurrentAttendance(LocalPatientIdentifier, NHSNumber, PatientIdentifier, PatientName, BirthDate, ArrivalDate, ArrivalDateTime)
SELECT 
	LocalPatientIdentifier,ISNULL(NHSNumber,''),PatientIdentifier,PatientName,DateOfBirth,ArrivalDate,CA.ArrivalDateTime
FROM 
	CurrentAttendances CA
	LEFT JOIN [7A1A1SRVINFODW1].PCNS.dbo.PCNSX2 PCNS ON 
		CA.LocalPatientIdentifier = PCNS.LPI AND 
		CA.ArrivalDateTime = PCNS.ArrivalDateTime
WHERE
	DATEDIFF(YEAR, DateOfBirth, ArrivalDate) - (CASE WHEN DATEADD(YY,DATEDIFF(YEAR, DateOfBirth, ArrivalDate), DateOfBirth) > ArrivalDate THEN 1 ELSE 0 END) < 18 AND
	CA.LocalPatientIdentifier IS NOT NULL AND
	PCNS.LPI IS NULL




--This is the count of entries which is in the wh - it doesn't take into account the current attendance
;WITH ItemCounts AS
(
	SELECT CA.PatientIdentifier, ItemCount = Count(*) 
	FROM @CurrentAttendance CA 
	INNER JOIN Foundation.dbo.UnscheduledCare_Data_EDAttendance EDA ON CA.PatientIdentifier = CASE WHEN CA.NHSNumber!='' THEN EDA.NHSNumber ELSE EDA.LocalPatientIdentifier END
	WHERE (DATEDIFF(DAY,EDA.ArrivalDate,GETDATE()) < 365 OR DATEDIFF(DAY,EDA.DischargeDate,GETDATE()) < 365) AND AttendanceCategory!='02'
	GROUP BY PatientIdentifier
)

UPDATE CA SET CA.AttendanceCount = ItemCounts.ItemCount FROM @CurrentAttendance CA INNER JOIN ItemCounts ON CA.PatientIdentifier = ItemCounts.PatientIdentifier



--Put the current attendance into the attendances to be reported
INSERT INTO @PreviousAttendance(CurrentAttendanceId,Area,LocalPatientIdentifier,NHSNumber,PatientName,AttendanceDateTime)
SELECT RowId,'West',LocalPatientIdentifier,NHSNumber,PatientName,ArrivalDateTime FROM @CurrentAttendance WHERE AttendanceCount >= 1 --(the current one is the 4th - so they have had at least 3 prior attendances)

INSERT INTO @PreviousAttendance(CurrentAttendanceId,Area,LocalPatientIdentifier,NHSNumber,PatientName,AttendanceDateTime)
SELECT 
	CA.RowId,EDA.Area, EDA.LocalPatientIdentifier, EDA.NHSNumber, P.Surname+', '+P.Forename, 
	DATENAME(DAY,EDA.ArrivalDate) + ' ' + DATENAME(MONTH,EDA.ArrivalDate) + ' ' + DATENAME(YEAR,EDA.ArrivalDate) + ' ' + 
	DATENAME(HOUR,EDA.ArrivalTime) + ':' + DATENAME(MINUTE,EDA.ArrivalTime)
FROM 
	Foundation.dbo.UnscheduledCare_Data_EDAttendance EDA 
	LEFT JOIN Foundation.dbo.UnscheduledCare_Ref_Patient P ON EDA.PatientLinkId=P.PatientLinkId
	INNER JOIN @CurrentAttendance CA ON CA.PatientIdentifier = CASE WHEN CA.NHSNumber!='' THEN EDA.NHSNumber ELSE EDA.LocalPatientIdentifier END
WHERE 
	(DATEDIFF(DAY,EDA.ArrivalDate,GETDATE()) < 365 OR DATEDIFF(DAY,EDA.DischargeDate,GETDATE()) < 365) AND 
	AttendanceCategory!='02' AND
	CA.AttendanceCount >=1

--SELECT * FROM @CurrentAttendance
--SELECT * FROM @PreviousAttendance
--return

SELECT DISTINCT @ThisCurrentAttendance=MIN(CA.RowId), @MaxCurrentAttendance=MAX(CA.RowId) FROM @CurrentAttendance CA --WHERE CA.AttendanceCount IS NOT NULL
WHILE @ThisCurrentAttendance <= @MaxCurrentAttendance --There's some redundancy in here as we'll be cycling over Id's that aren't in the table but meh
	BEGIN
	--DECLARE @CountCheck AS INT = (SELECT COUNT(*) FROM @PreviousAttendance WHERE CurrentAttendanceId=@ThisCurrentAttendance)
	IF (SELECT AttendanceCount FROM @CurrentAttendance WHERE RowId=@ThisCurrentAttendance) IS NOT NULL  --@CountCheck !=0
		BEGIN
			SET @ThisCurrentRecipient= (SELECT MIN(RowId) FROM @Recipient)
			DECLARE @ThisLPI AS VARCHAR(50)
			DECLARE @ThisArrDate AS SMALLDATETIME
			DECLARE @BirthDate AS VARCHAR(50)
			
			SELECT 
				@ThisLPI=LocalPatientIdentifier, 
				@ThisArrDate=DATENAME(DAY,ArrivalDateTime) + ' ' + DATENAME(MONTH,ArrivalDateTime) + ' ' + DATENAME(YEAR,ArrivalDateTime) + ' ' + RIGHT('0' + CONVERT(VARCHAR(2),DATENAME(HOUR,ArrivalDateTime)),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATENAME(MINUTE,ArrivalDateTime)),2),
				@BirthDate=DATENAME(DAY,BirthDate)+' '+DATENAME(MONTH,BirthDate)+' '+DATENAME(YEAR,BirthDate)
			FROM
				@CurrentAttendance
			WHERE
				RowId=@ThisCurrentAttendance
			
			DECLARE @tableHTML VARCHAR(MAX)= 
			N'<style type="text/css">
			#box-table
			{
			font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
			font-size: 12px;
			text-align: center;
			border-collapse: collapse;
			border-top: 7px solid #9baff1;
			border-bottom: 7px solid #9baff1;
			}
			#box-table th
			{
			font-size: 13px;
			font-weight: normal;
			background: #b9c9fe;
			border-right: 2px solid #9baff1;
			border-left: 2px solid #9baff1;
			border-bottom: 2px solid #9baff1;
			color: #039;
			}
			#box-table td
			{
			border-right: 1px solid #aabcfe;
			border-left: 1px solid #aabcfe;
			border-bottom: 1px solid #aabcfe;
			color: #669;
			padding:5px 20px 5px 20px;
			}
			tr:nth-child(odd) { background-color:#eee; }
			tr:nth-child(even) { background-color:#fff; }
			</style>'+

				N'<H3><font color="Red">Minor with at least 1 previous attendance in the last 12 months</H3>' +
				N'<p><font color="MidnightBlue">Date of birth: '+@BirthDate+'</p>'+
				N'<table>
					<tr>
						<td style="vertical-align: top; width: 800px">' +
				N'<table id="box-table">' +
				N'	<tr>
						<th>Local patient identifier</th>
						<th>NHS number</th>
						<th>Name</th>
						<th>Area</th>
						<th>Attendance date/time</th>
					</tr>' +
				CAST
					(
						(
						SELECT 
							td=LocalPatientIdentifier,'',
							td=NHSNumber,'',
							td=PatientName,'',
							td=Area,'',
							td=DATENAME(DAY,AttendanceDateTime) + ' ' + DATENAME(MONTH,AttendanceDateTime) + ' ' + DATENAME(YEAR,AttendanceDateTime) + ' ' + 
							RIGHT('0' + CONVERT(VARCHAR(2),DATENAME(HOUR,AttendanceDateTime)),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATENAME(MINUTE,AttendanceDateTime)),2)
						FROM
							@PreviousAttendance PA
						WHERE
							CurrentAttendanceId = @ThisCurrentAttendance
						ORDER BY 
							AttendanceDateTime DESC
						FOR XML PATH('tr'),TYPE
						) 
						AS varchar(max)
					) + 
				N'</table></td></tr></table>'
	
	
				exec msdb.dbo.sp_send_dbmail 
				@from_address='Patient Contact Notification Service <BCU.InformationDepartment@wales.nhs.uk>',
				@reply_to='BCU.InformationDepartment@wales.nhs.uk' ,
					
					@recipients=@RecipientList,
					
					--@recipients='martin.parry2@wales.nhs.uk',
					--@copy_recipients='martin.parry2@wales.nhs.uk',
					@subject = 'BCU PATIENT CONTACT ALERT', 
					@body = @tableHTML,
					@body_format = 'HTML';
					
					INSERT INTO [7A1A1SRVINFODW1].PCNS.dbo.PCNSX2 (LPI, ArrivalDateTime, RecipientList, NotificationDateTime)
					VALUES (@ThisLPI, @ThisArrDate, @RecipientList, GETDATE())
					
					WHILE @ThisCurrentRecipient <= @ThisMaxRecipient
						BEGIN
							DECLARE @RecipientId AS INT
							DECLARE @RecipientTypeId AS INT
							SELECT @RecipientId=Id, @RecipientTypeId=TypeId FROM @Recipient WHERE RowId=@ThisCurrentRecipient
							INSERT INTO [7A1A1SRVINFODW1].PCNS.dbo.[Log] (
								SubscriptionId,RecipientId,RecipientTypeId,CategoryId,IdentifierTypeId,GroupId,PatientIdentifier,
								ContactArea,ContactSource,ContactType,ContactWard,ContactSite,ContactDateTime,NotificationSent,NotificationResult,FromFile
								)
								VALUES(0,@RecipientId,@RecipientTypeId,13,1,12,@ThisLPI,'West','Symphony','Emergency Department attendance','Emergency Department','Llandudno Hospital',@ThisArrDate,GetDate(),'Sent',null)
								SET @ThisCurrentRecipient+=1
						END
						
		END
		SET @ThisCurrentAttendance +=1
	END

END
GO
