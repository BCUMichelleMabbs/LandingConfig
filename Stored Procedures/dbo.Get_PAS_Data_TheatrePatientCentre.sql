SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_PAS_Data_TheatrePatientCentre]
*/
CREATE PROCEDURE [dbo].[Get_PAS_Data_TheatrePatientCentre]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [SSIS_LOADING].[Theatres].[dbo].[PAS_Data_TheatrePatientCentre]
END
GO
