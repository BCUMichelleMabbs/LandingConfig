SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_GPOH_Data_Consultation]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @FromDate AS DATETIME

SET @FromDate = '1 January 2018 08:00:00'
--SET @FromDate = CONVERT(VARCHAR(10),GETDATE() -1 ,120) + ' ' + '08:00:00'

SELECT
	CON.ConsultationRef,
	CON.CaseRef,
	CAST(CON.StartDate AS DATE) AS StartDate,
	CAST(CON.StartDate AS TIME(0)) AS StartTime,
	CAST(CON.EndDate AS DATE) AS EndDate,
	CAST(CON.EndDate AS TIME(0)) AS EndTime,
	CON.ProviderRef,
	CON.CaseTypeRef,
	CON.PriorityRef,
	CON.BeforeCaseTypeRef,
	CON.AfterStatus,
	CON.BeforeStatus,
	CON.LocationRef
FROM
	[SQL4\SQL4].Adastra3.dbo.[Case] C
	INNER JOIN [SQL4\SQL4].Adastra3.dbo.[Consultation] CON ON C.CaseRef=CON.CaseRef AND CON.Obsolete=0
WHERE
	C.ActiveDate+Landing_Config.dbo.GPOH_BSTOffset(C.ActiveDate) >= @FromDate
	
END
GO
