SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Outsourced_Data_OutpatientSpire]
	
AS
BEGIN
	
	SET NOCOUNT ON;

--DECLARE @thisDate AS CHAR(8)=CAST(DATENAME(YEAR,GETDATE())AS CHAR(4))+CAST(DATEPART(MONTH,GETDATE()) AS CHAR(2))+RIGHT('00'+CAST(DATEPART(DAY,GETDATE())AS VARCHAR(2)),2)
--DECLARE @targetPath VARCHAR(100)='D:\FileLanding\Outsourcing\Spire\OP'
--DECLARE @toFile VARCHAR(50)='SpireOP.csv'

----Check if the target already exists
--DECLARE @iFileExists INT
--DECLARE @target VARCHAR(200)=@targetPath+'\'+@toFile
--DECLARE @delTarget VARCHAR(200)='del '+@targetPath+'\'+@toFile
----EXEC sp_configure 'xp_cmdshell',1;RECONFIGURE;

--EXEC master..xp_fileexist @delTarget,@iFileExists OUTPUT
--IF @iFileExists=1 BEGIN EXEC sys.xp_cmdshell @delTarget END

----Get the name of the source file
--DECLARE @statement AS VARCHAR(200)='DIR /B '+@targetPath+'\*'+@thisDate+'*'
--DECLARE @Files AS TABLE(Name VARCHAR(50))
--INSERT INTO @Files EXEC xp_cmdshell @statement

--EXEC @Result= xp_cmdshell @statement

--DECLARE @thisFile VARCHAR(50)=(SELECT TOP 1 Name FROM @Files)
--DECLARE @typeFile VARCHAR(500)='type '+@targetPath+'\'+@thisFile+' >> '+@targetPath+'\'+@toFile
--EXEC sys.xp_cmdshell @typeFile
--EXEC sp_configure 'xp_cmdshell',0;RECONFIGURE;

SELECT 
NHSNumber AS NHSNumber,Person_Family_Name AS Surname,Person_Given_Name AS Forename,
CAST(Person_Birth_Date AS DATE)AS DateOfBirth,Consultant_Code AS ConsultantNationalCode,ConsultantName,Specialty AS TreatmentSpecialty,
CAST(Appointment_Date AS DATE)AS AttendanceDate,CAST(LEFT(STUFF(RIGHT('000000'+CAST(Appointment_time AS VARCHAR(6)),6),3,0,':'),5)AS TIME)AttendanceTime,
NULL AttendStatus,NULL CancellationDate,Appointment_medium AS ConsultationMethod,First_attendance AS AttendanceCategory,Outcome,NULL FollowUpTargetDate,'Spire','BCU',Spire_Case_Number AS ProviderCaseNumber FROM(
select *from openrowset('MSDASQL','Driver={Microsoft Access Text Driver (*.txt, *.csv)}; Extended Properties="HDR=NO"',
'SELECT Spire_Case_Number,CStr(NHS_Number)AS NHSNumber,Person_Family_Name,Person_Given_Name,Person_Birth_Date,Consultant_Code,REPLACE(Consultant_Name,''|'','','') AS ConsultantName,
Specialty,Appointment_Date,Appointment_time,Appointment_medium,First_Attendance,Outcome,Outpatient_Procedure_Code
from D:\FileLanding\OUTSOURCING\SPIRE\OP\SpireOP.csv'))X

--select *from openrowset('MSDASQL','Driver={Microsoft Access Text Driver (*.txt, *.csv)}; Extended Properties="HDR=NO"',
--'SELECT Spire_Case_Number,CStr(NHS_Number)AS NHSNumber,Person_Family_Name AS Surname,Person_Given_Name AS Forename,
--CDate(Person_Birth_Date)AS DateOfBirth,Consultant_Code AS ConsultantNationalCode,
--REPLACE(Consultant_Name,''|'','','') AS ConsultantName,Specialty AS TreatmentSpecialty,
--CDate(Appointment_Date) AS AttendanceDate,Appointment_time AS AttendanceTime,NULL AS AttendStatus, NULL AS CancellationDate,
--Appointment_medium AS ConsultationMethod,First_Attendance AS AttendanceCategory,Outcome,NULL AS FollowUpTargetDate,''Spire'' AS Source,
--''BCU'' AS Area,Spire_Case_Number AS ProviderCaseNumber
--from D:\FileLanding\OUTSOURCING\SPIRE\OP\SpireOP.csv')



END

GO
