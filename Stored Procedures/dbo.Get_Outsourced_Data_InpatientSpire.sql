SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Outsourced_Data_InpatientSpire]
	
AS
BEGIN
	
	SET NOCOUNT ON;

--DECLARE @thisDate AS CHAR(8)=CAST(DATENAME(YEAR,GETDATE())AS CHAR(4))+CAST(DATEPART(MONTH,GETDATE()) AS CHAR(2))+RIGHT('00'+CAST(DATEPART(DAY,GETDATE())AS VARCHAR(2)),2)
--DECLARE @targetPath VARCHAR(100)='D:\FileLanding\Outsourcing\Spire\APC'
--DECLARE @toFile VARCHAR(50)='SpireAPC.csv'

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
--DECLARE @thisFile VARCHAR(50)=(SELECT TOP 1 Name FROM @Files)
--DECLARE @typeFile VARCHAR(500)='type '+@targetPath+'\'+@thisFile+' >> '+@targetPath+'\'+@toFile
--EXEC sys.xp_cmdshell @typeFile
----EXEC sp_configure 'xp_cmdshell',0;RECONFIGURE;

SELECT 
NHSNumber AS NHSNumber,Person_Family_Name AS Surname,Person_Given_Name AS Forename,
CAST(Person_Birth_Date AS DATE)AS DateOfBirth,Consultant_Code AS ConsultantNationalCode,ConsultantName,Specialty AS TreatmentSpecialty,
CAST(Start_Date_Hospital_Provider_Spell AS DATE)AS AdmissionDate,NULL AS ProcedureOutcome,CAST(Discharge_Date_Hospital_Provider_Spell AS DATE)AS DischargeDate,
NULL AS DischargeTime,NULL AS DischargeLocation,Outcome,Diagnosis_Codes AS DiagnosticCodes,Procedure_code AS ProcedureCodes,'Spire' AS Source,'BCU' AS Area,Spire_Case_Number AS ProviderCaseNumber,
Case_Type AS CaseType FROM(
SELECT *FROM OPENROWSET('MSDASQL','Driver={Microsoft Access Text Driver (*.txt, *.csv)}; Extended Properties="HDR=NO"',
'SELECT Spire_Case_Number,CStr(NHS_Number)AS NHSNumber,Person_Family_Name,Person_Given_Name,Person_Birth_Date,Consultant_Code,REPLACE(Consultant_Name,''|'','','') AS ConsultantName,
Specialty,Start_Date_Hospital_Provider_Spell,Discharge_Date_Hospital_Provider_Spell,Case_Type,Outcome,Diagnosis_Codes,Procedure_code
from D:\FileLanding\OUTSOURCING\SPIRE\APC\SpireAPC.csv'))X



END

GO
