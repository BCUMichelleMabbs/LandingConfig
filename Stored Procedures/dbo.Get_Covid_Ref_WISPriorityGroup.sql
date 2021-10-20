SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Get_Covid_Ref_WISPriorityGroup] AS BEGIN



SELECT DISTINCT
v.PriorityGroupDerived as LocalCode,



CASE WHEN v.PriorityGroupDerived = 'P1.1' THEN 'P1.1 - Older adult resident in a care home'
WHEN v.PriorityGroupDerived = 'P1.2' THEN 'P1.2 - Care Home Worker'
WHEN v.PriorityGroupDerived = 'P2.1' THEN 'P2.1 - All those 80 years of age and over'
WHEN v.PriorityGroupDerived = 'P2.2' THEN 'P2.2 - Health care workers'
WHEN v.PriorityGroupDerived = 'P2.3' THEN 'P2.3 - Social care workers'
WHEN v.PriorityGroupDerived = 'P3' THEN 'P3 - All those 75 years of age and older'
WHEN v.PriorityGroupDerived = 'P4.1' THEN 'P4.1 - All those 70 years of age and over'
WHEN v.PriorityGroupDerived = 'P4.2' THEN 'P4.2 - High risk adults under 70 years of age'
WHEN v.PriorityGroupDerived = 'P5' THEN 'P5 - All those 65 years of age and over'
WHEN v.PriorityGroupDerived = 'P6' THEN 'P6 - Moderate risk adults 16 years to under 65 years of age'
WHEN v.PriorityGroupDerived = 'P7' THEN 'P7 - All those 60 years of age and over'
WHEN v.PriorityGroupDerived = 'P8' THEN 'P8 - All those 55 years of age and over'
WHEN v.PriorityGroupDerived = 'P9' THEN 'P9 - All those 50 years of age and over'
WHEN v.PriorityGroupDerived = 'P10a' THEN 'P10a - All those aged 40 - 49 years'
WHEN v.PriorityGroupDerived = 'P10b' THEN 'P10b - All those aged 30 - 39 years'
WHEN v.PriorityGroupDerived = 'P10c' THEN 'P10c - All those aged 18 - 29 years'
WHEN v.PriorityGroupDerived = 'P10d' THEN 'P10d - All those aged 16 - 17 years'
WHEN v.PriorityGroupDerived = 'P10e' THEN 'P10e - All those aged 12 - 15 years'
WHEN v.PriorityGroupDerived = 'P0.1' THEN 'P0.1 - Severely Immunosuppressed (Scheduled)'
WHEN v.PriorityGroupDerived = 'P0.2' THEN 'P0.2 - Severely Immunosuppressed (Manual)'
ELSE 'P10 - Rest of the population (Subject to Validation)' END as LocalName,



CASE WHEN PriorityGroupDerived = 'P10a' THEN 10.1
WHEN PriorityGroupDerived = 'P10b' THEN 10.2
WHEN PriorityGroupDerived = 'P10c' THEN 10.3
WHEN PriorityGroupDerived = 'P10d' THEN 10.4
WHEN PriorityGroupDerived = 'P10e' THEN 10.5
ELSE CAST(REPLACE(PriorityGroup,'P','') AS decimal(10,1)) END as SortOrder,




CASE WHEN v.PriorityGroupDerived = 'P1.1' THEN 'Older adult resident in a care home'
WHEN v.PriorityGroupDerived = 'P1.2' THEN 'Care Home Worker'
WHEN v.PriorityGroupDerived = 'P2.1' THEN 'All those 80 years of age and over'
WHEN v.PriorityGroupDerived = 'P2.2' THEN 'Health care workers'
WHEN v.PriorityGroupDerived = 'P2.3' THEN 'Social care workers'
WHEN v.PriorityGroupDerived = 'P3' THEN 'All those 75 years of age and older'
WHEN v.PriorityGroupDerived = 'P4.1' THEN 'All those 70 years of age and over'
WHEN v.PriorityGroupDerived = 'P4.2' THEN 'High risk adults under 70 years of age'
WHEN v.PriorityGroupDerived = 'P5' THEN 'All those 65 years of age and over'
WHEN v.PriorityGroupDerived = 'P6' THEN 'Moderate risk adults 16 years to under 65 years of age'
WHEN v.PriorityGroupDerived = 'P7' THEN 'All those 60 years of age and over'
WHEN v.PriorityGroupDerived = 'P8' THEN 'All those 55 years of age and over'
WHEN v.PriorityGroupDerived = 'P9' THEN 'All those 50 years of age and over'
WHEN v.PriorityGroupDerived = 'P10a' THEN 'All those aged 40 - 49 years'
WHEN v.PriorityGroupDerived = 'P10b' THEN 'All those aged 30 - 39 years'
WHEN v.PriorityGroupDerived = 'P10c' THEN 'All those aged 18 - 29 years'
WHEN v.PriorityGroupDerived = 'P10d' THEN 'All those aged 16 - 17 years'
WHEN v.PriorityGroupDerived = 'P10e' THEN 'All those aged 12 - 15 years'
WHEN v.PriorityGroupDerived = 'P0.1' THEN 'Severely Immunosuppressed (Scheduled)'
WHEN v.PriorityGroupDerived = 'P0.2' THEN 'Severely Immunosuppressed (Manual)'
ELSE 'Rest of the population (Subject to Validation)' END as Name,



CASE WHEN CHARINDEX('.', PriorityGroup) > 0 THEN RTRIM(left(PriorityGroup, CHARINDEX('.', PriorityGroup) - 1))
ELSE PriorityGroup END as MainCode,



'WIS' as Source,
'BCU' as Area



FROM Foundation.dbo.Covid_Data_WISVaccination v





ORDER BY SortOrder
--where RowNum=1
END
GO
