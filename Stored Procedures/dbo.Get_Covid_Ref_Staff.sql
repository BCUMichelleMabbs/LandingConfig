SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Get_Covid_Ref_Staff]

 as 
 begin

 SELECT DISTINCT
 
	[EmployeeFirstName],
	[EmployeeLastName],
	CAST([EmployeeBirthDate] AS DATE) AS [EmployeeBirthDate],
	[EmployeeAddress1PostalCode],
	[EmployeeLocationName],
	[OrganizationName],
	[AssignmentNumber],
	[PrimaryAssignmentFlag],
	[StaffGroup],
	[Role],
	[AssignmentCategory],
	[OrgL7],
	[PersonType],
	[OrgL5],
	[PositionNumber],
	[OrgL4],
	[OrgL6],
	[EmployeeNumber],
	[AssignmentStatus],
	CAST([AssignmentEffectiveStartDate] AS DATE) AS [AssignmentEffectiveStartDate],
	CAST([AssignmentEffectiveEndDate] AS DATE) AS [AssignmentEffectiveEndDate],
	CAST([EmployeeEffectiveStartDate] AS DATE) AS [EmployeeEffectiveStartDate],
	CAST([EmployeeEffectiveEndDate] AS DATE) AS [EmployeeEffectiveEndDate],
	CASE	WHEN OrgL5 = '050 Ysbyty Maelor Wrexham (HX41) L5' THEN 'East Acute'
			WHEN OrgL5 = '050 Womens (HX78) L5' AND OrgL6 = '050 Womens East (WX01) L6' AND OrgL7 <> '050 Community East (WX11) L7' THEN 'East Acute'
			WHEN OrgL4 = '050 Area Teams (AX00) L4' AND OrgL5 = '050 East Area (AX41) L5' AND OrgL6 = '050 Elderley Medicines East (AX46) L6' THEN 'East Acute'
			WHEN OrgL4 = '050 Area Teams (AX00) L4' AND OrgL6 = '050 Childrens East (AX47) L6' AND OrgL7 = '050 Acute East (AXC3) L7' THEN 'East Acute'
			WHEN OrgL4 = '050 Area Teams (AX00) L4' AND OrgL5 = '050 East Area (AX41) L5' AND OrgL6 = '050 Community Medicine East (AX44) L6' AND (OrganizationName LIKE '050 E Maelor%' OR OrganizationName LIKE '%YWM%') THEN 'East Acute'
			WHEN OrgL5 = '050 North Wales Wide Hospital Services (HX79) L5' AND OrgL6 = '050 North Wales Cancer Services (HX97) L6' AND OrganizationName LIKE '%YMW%' THEN 'East Acute'
			WHEN OrganizationName IN ('050 E Maelor Catering (R390)','050 E Maelor Domestic Services (R510)','050 E Maelor Linen Services (R511)','050 E Maelor Portering (R650)','050 E Supplies Materials Management (R302)', '050 E Operational Estates - East Area (S410)') THEN 'East Acute'
			WHEN LEFT(EmployeeLocationName,3) = '050' THEN 'Central'
			WHEN LEFT(EmployeeLocationName,3) = '010' THEN 'West'
			ELSE 'East Area'
	END AS [ESRSiteFlag]

FROM [SSIS_LOADING].[Covid].[dbo].[Covid_Ref_Staff]

WHERE 1 = 1
AND PrimaryAssignmentFlag = 'Y'
AND CAST([EmployeeEffectiveStartDate] AS DATE) IS NOT NULL


END

GO
