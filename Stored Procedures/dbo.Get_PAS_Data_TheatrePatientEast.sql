SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
[Landing_Config].[dbo].[Get_PAS_Data_TheatrePatientEast]
*/
CREATE PROCEDURE [dbo].[Get_PAS_Data_TheatrePatientEast]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [SSIS_LOADING].[Theatres].[dbo].[PAS_Data_TheatrePatientEast]
END
GO
