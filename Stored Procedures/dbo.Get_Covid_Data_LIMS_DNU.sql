SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Covid_Data_LIMS_DNU]

AS
BEGIN
	SET NOCOUNT ON;

	/*
       SELECT 
		   CRN
		  ,NHS
		  ,DoD
		  ,DeceasedInHospital
		  ,LastModified
		  ,ROW_NUMBER() Over (Partition by ISNULL(NHS,CRN),DOD order by DeceasedInHospital Desc) rn
	   
	   INTO #temp1

	   FROM Foundation.dbo.covid_ref_Deceasedlkup
	   */
       SELECT
		   c.[Visit_Number]
		  ,c.[NHS_Number]
		  ,c.[Hospital_Number]
		  ,c.[Sex]
		  ,c.[DoB]
		  ,c.[DoD]
		  ,NULL as DeceasedInHospital
		  ,c.[Postcode]
		  ,c.[Date_Of_Entry]
		  ,c.[Date_Of_Collection]
		  ,c.[Date_Of_Request]
		  ,c.[TestSet_Name]
		  ,c.[TestSet_Synonym]
		  ,c.[Test_Component]
		  ,c.[Test_Result]
		  ,c.[Date_Of_Receiving]
		  ,c.[CTHOS_Name]
		  ,c.[CTHOS_Code]
		  ,c.[ResultDetail]
		  ,c.[ResultSummary]
		  ,c.[Time_Of_Entry]
		  ,c.[Time_Of_Collection]
		  ,c.[Time_Of_Request]
		  ,c.[Time_Of_Receiving]
		  ,c.[Date_of_Authorisation]
		  ,c.[Time_of_Authorisation]
		  ,c.[StaffMember]
		  ,c.StaffOrg
		  ,NULL as StaffOrgType
		  ,NULL as StaffOrgName
		  ,c.StaffCategory
		  ,c.StaffSubCategory
		  ,c.NursingHomeName
		  ,c.NursingHomeAuthority
		  ,NULL as NursingHomeFlag
		  ,NULL as UniqueIdentifier
		  ,NULL as ImagingAttendanceDate
		  ,NULL as ImagingAttendanceTime
		  ,NULL as ImagingLocation
		  ,NULL as ImagingType
		  ,[EmployeeBirthDate]
		  ,[EmployeeAddress1PostalCode] as EmployeePostcode
		  ,[EmployeeLocationName] as EmployeeLocation
		  ,[OrganizationName] as EmployeeDept
		  ,[EmployeeOrganisationPostCode] as EmployeeLocationPostcode
		  ,EmployeeLocationCount
		  ,REPLACE(GPPractice,'7A1YY','') as GPPractice
		  ,EducationalOrg
		  ,NULL as PreviousTestDate
		  ,NULL as TestOrder
		  ,NULL as TestOrderPositives
		  ,c.[LastUpdateTime]
		  ,c.[TestingLabCode]
		  ,c.[TestingLabName]
		  ,c.[TestRationale]
		  ,c.[TestRationaleQualifier]
		  ,s.EmployeeFirstName + ' ' + s.EmployeeLastName as EmployeeName
		  ,s.AssignmentNumber as EmployeeAssignmentNumber
		  ,s.StaffGroup as EmployeeStaffGroup
		  ,s.Role as EmployeeRole
		  ,s.AssignmentCategory as EmployeeAssignmentCategory
		  ,s.BankPostHeld as EmployeeBankPostHeld
		  ,s.OrgL7 as EmployeeOrgL7
		  ,s.PersonType as EmployeePersonType
		  ,c.Forename + ' ' + c.Surname as PatientName
		  ,CASE WHEN c.NOTES LIKE '%5152%' and c.Notes LIKE '% 5152%' THEN '5152'
				WHEN c.NOTES LIKE '%5152%' and c.Notes NOT LIKE '%[0-9]'+ '5152%' THEN '5152'
				WHEN c.NOTES LIKE '%113%' and c.Notes LIKE '% 113%' THEN '113'
				WHEN c.NOTES LIKE '%113%' and c.Notes NOT LIKE '%[0-9]'+ '113%' THEN '113'
				ELSE NULL END AS IncNoFlag
		  ,s.ESRSiteFlag
		  ,s.Priority
		  ,NULL as PreviousTestResult
		  ,NULL as PreviousTestAuthDate
		  ,NULL as DoDModifiedDate
		  ,c.Forename
		  ,c.Surname

      FROM  [7A1A1SRVINFODW1].[Ardentia_HealthWare_5_Release].dbo.X_CV19 c
   
      LEFT JOIN Foundation.dbo.Covid_Ref_Staff s
      ON (s.[EmployeeFirstName] = c.forename COLLATE Database_default
	     and REPLACE(S.[EmployeeLastName],'-',' ') = REPLACE(c.Surname,'-',' ') COLLATE Database_default
		 and CONVERT(date,s.[EmployeeBirthDate]) = c.DoB  )
	  OR
		 (REPLACE(s.EmployeeAddress1PostalCode,' ','') = REPLACE(c.Postcode,' ','') COLLATE Database_default
		 and REPLACE(S.[EmployeeLastName],'-',' ') = REPLACE(c.Surname,'-',' ') COLLATE Database_default
		 and CONVERT(date,s.[EmployeeBirthDate]) = c.DoB  )

	  WHERE (c.nhs_number <> '1231231234' or c.NHS_number is null)-- and c.date_of_entry >= DATEADD(d, -15, getdate())
    
------------------------------------------------------------------------------------------------------------------------------
/*
--- Update Death Details from CTE #temp1
    
		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU
		SET DoD = dl.Dod
		,DeceasedInHospital = dl.DeceasedinHospital
		,DODModifiedDate = dl.LastModified

		FROM #temp1 dl

		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU l
		ON CASE WHEN (CTHOS_Code not like '7A1%' or Hospital_Number like '%Carmarthenshire%' or NHS_Number is not null) THEN dl.nhs 
		WHEN CASE WHEN Hospital_number like '%-%' and LEN(Hospital_number) > 1 and RIGHT(Hospital_Number,1) <> '-' THEN dl.CRN
		WHEN Hospital_number like '%,%' and LEN(Hospital_number) > 1 and RIGHT(Hospital_Number,1) <> ',' THEN dl.CRN ELSE NULL 
		END is not null THEN dl.CRN ELSE dl.NHS END

		= 

		CASE WHEN (CTHOS_Code not like '7A1%' or Hospital_Number like '%Carmarthenshire%' or NHS_Number is not null) THEN l.NHS_Number
		WHEN CASE WHEN Hospital_number like '%-%' and LEN(Hospital_number) > 1 and RIGHT(Hospital_Number,1) <> '-' THEN SUBSTRING(Hospital_number, CHARINDEX('-',Hospital_number)+1, len(Hospital_number))
		WHEN  Hospital_number like '%,%' and LEN(Hospital_number) > 1 and RIGHT(Hospital_Number,1) <> ',' THEN SUBSTRING(Hospital_number, CHARINDEX(',',Hospital_number)+1, len(Hospital_number)) 
		ELSE NULL END is not null THEN CASE WHEN Hospital_number like '%-%' and LEN(Hospital_number) > 1 and RIGHT(Hospital_Number,1) <> '-'
		THEN SUBSTRING(Hospital_number, CHARINDEX('-',Hospital_number)+1, len(Hospital_number))
		WHEN  Hospital_number like '%,%' and LEN(Hospital_number) > 1 and RIGHT(Hospital_Number,1) <> ',' THEN SUBSTRING(Hospital_number, CHARINDEX(',',Hospital_number)+1, len(Hospital_number)) 
		ELSE NULL END
		ELSE  l.NHS_Number
		END


		WHERE rn = 1 	
		
	  DROP TABLE #temp1 
 */
END
GO
