SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_PAS_Ref_ReferralSource]
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @Results AS TABLE(
	MainCode			VARCHAR(25),
	Name				VARCHAR(300),
	LocalCode			VARCHAR(25),
	LocalName			VARCHAR(300),
	Source				VARCHAR(8),
	Area					varchar(10)
	)


	INSERT INTO @Results(LocalCode,LocalName,Source, Area)
	SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
			SELECT distinct
			REFERRAL_CODE AS localCode,
			DESCRIPT AS LocalName,
			''WPAS'' AS Source,
			''Central'' as Area
		FROM 
			SREFER
	')

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
		SELECT * FROM OPENQUERY(WPAS_EAST,'
			SELECT distinct
				REFERRAL_CODE AS LocalCode,
				DESCRIPT AS LocalName,
				''Myrddin'' AS Source,
				''East'' as Area
			 FROM 
				SREFER
		')



INSERT INTO @Results(LocalCode,LocalName,Source, Area)
	SELECT DISTINCT
		ISNULL(MAIN_CODE,'-1') AS LocalCode,
			DESCRIPTION AS LocalName,
			'PIMS' as Source,
			'West' as Area
		FROM 
			[7A1AUSRVIPMSQL].[iPMProduction].[dbo].[REFERENCE_VALUES]
		WHERE
			RFVDM_CODE ='SORRF'


/*
INSERT INTO @Results(LocalCode,LocalName,Source, Area)
	(
	Select id, text, 'TherapyManager' AS Source, 'Central' as Area
	 
from [SQL4\SQL4].[physio].[dbo].Lists where Type='6'

	)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
	(
	Select id, text, 'TherapyManager' AS Source, 'East' as Area
	 
from [SQL4\SQL4].[physio].[dbo].Lists where Type='6'

	)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
	(
	Select id, text, 'TherapyManager' AS Source, 'West' as Area
	 
from [SQL4\SQL4].[physio].[dbo].Lists where Type='6'

	)






*/





UPDATE @Results SET
	R.MainCode = RS.MainCode,
	R.Name = RS.Name
FROM
	@Results R
	INNER JOIN Mapping.dbo.PAS_ReferralSource_Map RSM ON R.LocalCode=RSM.LocalCode AND R.Source=RSM.Source
	INNER JOIN Mapping.dbo.PAS_REFERRALSOURCE RS ON RSM.MainCode=RS.MainCode


SELECT * FROM @Results order by MainCode
END





GO
