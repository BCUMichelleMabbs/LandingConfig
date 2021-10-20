SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Data_WardMeasures]
AS
BEGIN
SET NOCOUNT ON;

;With DaysSince_CTE as (
SELECT 
	m1.inc_unit as [Unit],
	m1.inc_locactual as [Location], 
	DATEDIFF(DD, MAX(m1.inc_dincident),CAST(GETDATE() as date)) as [DaysSinceLastIncident],
	(SELECT DATEDIFF(DD, MAX(m2.inc_dincident),CAST(GETDATE() as date)) FROM [7a1ausrvdtxsql2].[Datixcrm].dbo.incidents_main m2 WHERE m2.inc_clin_detail = 'FALLS' and m1.inc_locactual = m2.inc_locactual and m1.inc_unit = m2.inc_unit and m2.rep_approved <> 'REJECT') AS [DaysSinceLastFall],
	(SELECT DATEDIFF(DD, MAX(m2.inc_dincident), CAST(GETDATE() as date)) FROM [7a1ausrvdtxsql2].[Datixcrm].dbo.incidents_main m2 left join [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v2 on v2.cas_id = m2.recordid and v2.field_id = 11 WHERE v2.udv_string = 'Y' and m1.inc_locactual = m2.inc_locactual and m1.inc_unit = m2.inc_unit and m2.rep_approved <> 'REJECT') AS [DaysSinceLastHAPU],
	(SELECT DATEDIFF(DD, MAX(m2.inc_dincident), CAST(GETDATE() as date)) FROM [7a1ausrvdtxsql2].[Datixcrm].dbo.incidents_main m2 WHERE m2.inc_carestage = 'MEDIC' and m1.inc_locactual = m2.inc_locactual and m1.inc_unit = m2.inc_unit and m2.rep_approved <> 'REJECT') AS [DaysSinceLastMedicationError]

FROM 
	[7a1ausrvdtxsql2].[Datixcrm].dbo.incidents_main m1 

WHERE m1.rep_approved <> 'REJECT'

GROUP BY 
	m1.inc_unit,
	m1.inc_locactual
),

BedDays_CTE as (

SELECT 
	Ward,
	loc.DatixHospitalCode,
	loc.DatixWardCode,
	COUNT(*) AS [Occupied Bed Days]

FROM 
	[Foundation].[dbo].[PAS_Data_InpatientHourly] inp
	LEFT JOIN	[Foundation].[dbo].[Common_Ref_Location_DONOTUSE] loc 	ON	inp.Ward = loc.LocalCode

WHERE
	SnapshotDateTime >= DATEADD(DD, -31, CAST(GETDATE() as date))
	AND
	DATEPART(HH, SnapshotDateTime) = '00'

GROUP BY
	Ward,
	loc.DatixHospitalCode,
	loc.DatixWardCode
)

SELECT
	m.inc_locactual  as [Location],
	COUNT(CASE WHEN inc_dincident >= DATEADD(DD, -31, CAST(GETDATE() as date)) THEN 1 ELSE NULL END) as [IncidentsInLast30Days],
	COUNT(CASE WHEN inc_dincident >= DATEADD(DD, -31, CAST(GETDATE() as date)) AND inc_clin_detail = 'FALLS' THEN 1 ELSE NULL END) as [FallsInLast30Days],
	COUNT(CASE WHEN inc_dincident >= DATEADD(DD, -31, CAST(GETDATE() as date)) AND v2.udv_string = 'Y' THEN 1 ELSE NULL END) as [HAPUInLast30Days],
	COUNT(CASE WHEN inc_dincident >= DATEADD(DD, -31, CAST(GETDATE() as date)) AND inc_carestage = 'MEDIC' THEN 1 ELSE NULL END) as [MedicationErrorsInLast30Days],
	ISNULL(CONVERT(VARCHAR, ds.DaysSinceLastIncident),99999) as [DaysSinceLastIncident],
	ISNULL(CONVERT(VARCHAR, ds.DaysSinceLastFall),99999) as DaysSinceLastFall, 
	ISNULL(CONVERT(VARCHAR, ds.DaysSinceLastHAPU),99999) as DaysSinceLastHAPU,
	ISNULL(CONVERT(VARCHAR, ds.DaysSinceLastMedicationError),99999) as DaysSinceLastMedicationError,
	ISNULL(CONVERT(int, bd.[Occupied Bed Days]),0) as [OccupiedBedDays],
    'Datix' as [Source],
	m.inc_unit

FROM 
	[7a1ausrvdtxsql2].[Datixcrm].dbo.incidents_main m
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v on v.cas_id = m.recordid and v.field_id = 1 and v.group_id = 10
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v2 on v2.cas_id = m.recordid and v2.field_id = 11
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v3 on v3.cas_id = m.recordid and v3.field_id = 85
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v4 on v4.cas_id = m.recordid and v4.field_id = 171
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v5 on v5.cas_id = m.recordid and v5.field_id = 3 and v5.group_id = 12
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v6 on v6.cas_id = m.recordid and v6.field_id = 2 and v6.group_id = 12
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v7 on v7.cas_id = m.recordid and v7.field_id = 31 
	LEFT JOIN [7a1ausrvdtxsql2].[Datixcrm].[dbo].[udf_values] v8 on v8.cas_id = m.recordid and v8.field_id = 203
	LEFT JOIN DaysSince_CTE ds ON m.inc_locactual=ds.Location and m.inc_unit = ds.Unit
	LEFT JOIN BedDays_CTE bd ON m.inc_locactual=bd.DatixWardCode and m.inc_unit = bd.DatixHospitalCode

WHERE
	m.inc_locactual   IS NOT NULL
	AND m.inc_locactual  <> ''
	AND m.rep_approved <> 'REJECT'

GROUP BY	
	m.inc_unit,
	m.inc_locactual,
	ds.DaysSinceLastIncident,
	ds.DaysSinceLastFall,
	ds.DaysSinceLastHAPU,
	ds.DaysSinceLastMedicationError,
	bd.[Occupied Bed Days]

End
GO
