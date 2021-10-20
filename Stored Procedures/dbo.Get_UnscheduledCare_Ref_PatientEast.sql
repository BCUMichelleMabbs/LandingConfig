SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_UnscheduledCare_Ref_PatientEast]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	EXEC('
	USE Wrexham_Live
	EXEC dbo.Get_UnscheduledCare_Ref_PatientEast
	'
	) AT [RYPA4SRVSQL0014.CYMRU.NHS.UK];

END

		
GO
