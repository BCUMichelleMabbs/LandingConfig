SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Data_AmbulanceOnRouteLive]

AS
BEGIN
	SET NOCOUNT ON;

	 SELECT 
	 HospitalName as SiteName,
	 IncidentID,
	 Status,
	 NoOfCasualties as Casualties,
	 DueAt as DueAtHospital,
	 CASE WHEN HospitalName LIKE 'Ysbyty Glan Clwyd%' THEN '7A1A1'
	      WHEN HospitalName LIKE 'Wrexham Maelor%' THEN '7A1A4'
		  WHEN HospitalName LIKE 'Ysbyty Gwynedd%' THEN '7A1AU'
		  ELSE NULL END AS SiteCode,
     CAST(LeftSceneTime as date) as LeftSceneDate,
	 CAST(LeftSceneTime as time) as LeftSceneTime

	  FROM
		[SSIS_LOADING].[WAST].[dbo].[WAST_Live_OnRoute]
    
	WHERE HospitalName LIKE 'Ysbyty Glan Clwyd%' or HospitalName LIKE 'Wrexham Maelor%' or HospitalName LIKE 'Ysbyty Gwynedd%' 

	End
GO
