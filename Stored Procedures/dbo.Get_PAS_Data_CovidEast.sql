SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_PAS_Data_CovidEast]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @SQL AS NVARCHAR(MAX)
SET @SQL='SELECT * FROM (
SELECT * FROM OPENQUERY(WPAS_EAST,''
	SELECT DISTINCT
		PKN.KEYNOTE_KEY AS UniqueIdentifier,
		PKN.CASENO AS LocalPatientIdentifier,
		START_DATE AS StartDate,
		END_DATE AS EndDate,
		KEYNOTE_ID AS KeynoteIdentifier,
		KEYNOTE_DESCRIPTION AS KeynoteDescription,
		EC.EVENT_DESCRIPTION AS EventDescription,
		''''East'''' AS Area,
		''''Myrddin'''' AS Source
	FROM
		PATKEYNOTE PKN
		LEFT JOIN EVENT_CODES EC ON PKN.KEYNOTE_ID=EC.EVENT_ID 
	WHERE
		PKN.KEYNOTE_ID IN(''''530'''',''''531'''',''''532'''',''''533'''',''''534'''',''''535'''') 
'')A1
UNION ALL
SELECT
	'''' AS UniqueIdentifier,
	'''' AS LocalPatientIdentifier,
	'''' AS StartDate,
	'''' AS EndDate,
	'''' AS KeynoteIdentifier,
	'''' AS KeynoteDescription,
	'''' AS EventDescription,
	'''' AS Area,
	'''' AS Source
)M2
WHERE UniqueIdentifier!='''''

EXEC SP_EXECUTESQL @SQL

END

GO
