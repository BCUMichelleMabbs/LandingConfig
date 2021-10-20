SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Update_Covid_Data_LIMS_DNU]
@LoadGUID varchar(38)
AS
BEGIN
	SET NOCOUNT ON;

	
----- UPDATEs UniqueIdentifier field 

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET UniqueIdentifier = 
		CASE WHEN NHS_Number IS NOT NULL THEN NHS_Number
			 WHEN Hospital_Number in (' ', ',') THEN ISNULL(NHS_Number,CONVERT(varchar,DOB)+'-'+ISNULL(REPLACE(Postcode,' ',''),'ZZZZ'))
			 WHEN RIGHT(Hospital_Number,1) <> ',' THEN SUBSTRING(Hospital_number, CHARINDEX(',',Hospital_number)+1, len(Hospital_number))
			 ELSE CONVERT(varchar,DOB)+'-'+ISNULL(REPLACE(Postcode,' ',''),'ZZZZ')
		END
--------------------------------------------------------------------------------------------------	

----- UPDATEs Imaging Details

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET  ImagingAttendanceDate = i.AttendanceDate 
			,ImagingAttendanceTime = i.AttendanceTime
			,ImagingLocatiON = i.LocatiON 
			,ImagingType = i.ImagingType 

		FROM Foundation.dbo.Covid_Data_Imaging i
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU l
		ON l.NHS_Number = i.NHS COLLATE Database_Default and i.AttendanceDate >= DATEADD(Week,-1,l.Date_of_entry)
--------------------------------------------------------------------------------------------------		

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU  
		SET  ImagingAttendanceDate = i.AttendanceDate 
			,ImagingAttendanceTime = i.AttendanceTime
			,ImagingLocatiON = i.LocatiON 
			,ImagingType = i.ImagingType 

		FROM Foundation.dbo.Covid_Data_Imaging i
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU l
		ON CASE WHEN Hospital_Number in ('WDS,','LIMS,') THEN NULL 
		WHEN l.Hospital_Number like '%-%' and LEN(l.Hospital_Number) > 1 THEN ISNULL(SUBSTRING(l.Hospital_Number, CHARINDEX('-',l.Hospital_Number)+1, len(l.Hospital_Number)),'')
		WHEN l.Hospital_Number like '%,%' and LEN(l.Hospital_Number) > 1 THEN ISNULL(SUBSTRING(l.Hospital_Number, CHARINDEX(',',l.Hospital_Number)+1, len(l.Hospital_Number)),'')
		END = i.crn COLLATE Database_Default and i.AttendanceDate >= DATEADD(Week,-1,l.Date_of_entry)

--------------------------------------------------------------------------------------------------	

-----UPDATEs Nursing Home Details

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU  
		SET NursingHomeFlag = 'Y' 
		WHERE NursingHomeName is not null 

--------------------------------------------------------------------------------------------------	

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU  
		SET NursingHomeFlag = 'Y'
		WHERE REPLACE(Postcode,' ','') in (SELECT REPLACE(Postcode,' ','') 
		FROM Foundation.dbo.Covid_Ref_NursingHomes 
		WHERE postcode is not null 
		)

--------------------------------------------------------------------------------------------------	

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET NursingHomeFlag = 'N'
		WHERE NursingHomeFlag <> 'Y'

--------------------------------------------------------------------------------------------------	

----- UPDATEs Testing Details

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET TestOrder = RN
		FROM (SELECT visit_number,ROW_NUMBER() over (PartitiON by UniqueIdentifier order by date_of_entry desc) as rn
		FROM Foundation.dbo.Covid_Data_LIMS_DNU ) as x
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU  l
		ON l.Visit_Number = x.Visit_Number 

--------------------------------------------------------------------------------------------------	

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU  
		SET TestOrderPositives = RN
		FROM (SELECT visit_number,ROW_NUMBER() over (PartitiON by UniqueIdentifier order by date_of_entry asc) as rn
		FROM Foundation.dbo.Covid_Data_LIMS_DNU  
		WHERE ResultSummary = 'Positive') as x
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU  l
		ON l.Visit_Number = x.Visit_Number 

--------------------------------------------------------------------------------------------------	

----- UPDATEs Last Test (Most recent - 1) TestEntryDate

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET Foundation.dbo.Covid_Data_LIMS_DNU.PreviousTestDate = l2.Date_of_Entry

		FROM Foundation.dbo.Covid_Data_LIMS_DNU 
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU l2
        ON l2.UniqueIdentifier = Foundation.dbo.Covid_Data_LIMS_DNU.UniqueIdentifier 
		and Foundation.dbo.Covid_Data_LIMS_DNU.TestOrder +1 = l2.TestOrder 

--------------------------------------------------------------------------------------------------	

----- UPDATEs Staff Org Type

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU
		SET StaffOrgType = CASE WHEN StaffOrg like '% - %' THEN RTRIM(SUBSTRING(StaffOrg,0,CHARINDEX('-',StaffOrg,0))) 
		ELSE StaffOrg END 

--------------------------------------------------------------------------------------------------	

----- UPDATEs Staff Org Name

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU
		SET StaffOrgName = CASE WHEN StaffOrg like '% - %' THEN LTRIM(SUBSTRING(StaffOrg,CHARINDEX('-',StaffOrg)+1,LEN(StaffOrg)))
		ELSE StaffOrg END 

--------------------------------------------------------------------------------------------------	

----- UPDATEs Last Test (Most recent - 1) Result

		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET Foundation.dbo.Covid_Data_LIMS_DNU.PreviousTestResult = l2.ResultSummary

		FROM Foundation.dbo.Covid_Data_LIMS_DNU 
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU l2
		ON l2.UniqueIdentifier = Foundation.dbo.Covid_Data_LIMS_DNU.UniqueIdentifier 
		and Foundation.dbo.Covid_Data_LIMS_DNU.TestOrder +1 = l2.TestOrder 

--------------------------------------------------------------------------------------------------	

----- UPDATEs Last Test (Most recent - 1) Authorisation Date
		
		UPDATE Foundation.dbo.Covid_Data_LIMS_DNU 
		SET Foundation.dbo.Covid_Data_LIMS_DNU.PreviousTestAuthDate = l2.Date_of_Authorisation

		FROM Foundation.dbo.Covid_Data_LIMS_DNU 
		INNER JOIN Foundation.dbo.Covid_Data_LIMS_DNU l2
		ON l2.UniqueIdentifier = Foundation.dbo.Covid_Data_LIMS_DNU.UniqueIdentifier 
		and Foundation.dbo.Covid_Data_LIMS_DNU.TestOrder +1 = l2.TestOrder 





 
END
GO
