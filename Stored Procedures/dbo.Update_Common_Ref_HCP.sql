SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Update_Common_Ref_HCP]
@LoadGUID varchar(38)
as
begin


-- Reset Active Flag --
update [Foundation].[dbo].[Common_Ref_HCP] set Active = 'N'


--Active Flag Calculation--
;WITH CTE AS (

--IP Data
SELECT DISTINCT hcp.[MainCode],MAX(DateAdmitted) as LastActivity
FROM [Foundation].[dbo].[PAS_Data_Inpatient] ip
left join [Foundation].[dbo].[Common_Ref_HCP] Hcp on ip.HCPOfEpisode = hcp.LocalCode
WHERE HCPOfEpisode IS NOT NULL AND DateAdmitted <= GETDATE()
GROUP BY [MainCode]

UNION

--OP Data
SELECT DISTINCT hcp.[MainCode],MAX([AppointmentDate]) as LastActivity
FROM [Foundation].[dbo].[PAS_Data_Outpatient] op
left join [Foundation].[dbo].[Common_Ref_HCP] Hcp on op.AttendanceHCP = hcp.LocalCode
WHERE AppointmentDate <= GETDATE()
GROUP BY [MainCode]
)

,CTE2 as (
SELECT DISTINCT [MainCode],CASE WHEN LastActivity >= DateAdd(day,-365,GETDATE()) THEN 'Y' ELSE 'N' END AS Active
FROM CTE
WHERE [MainCode] IS NOT NULL
)


UPDATE h
SET h.Active = ISNULL(c.Active,'N')
FROM [Foundation].[dbo].[Common_Ref_HCP] h
JOIN CTE2 c on h.MainCode = c.[MainCode]

END
GO
