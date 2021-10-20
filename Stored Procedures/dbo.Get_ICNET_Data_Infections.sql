SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_ICNET_Data_Infections] 

AS

BEGIN

SELECT 
	PatientIdentifier,
	CAST(SpecimenDate AS datetime) as [SpecimenDate],
	Ward as [SpecimenSubLocation],
	Hospital as [SpecimenLocation],
	NHSNumber,
	Organism,
	Type as [SpecimenType],
	SpecimenNumber,
	CAST(LastUpdate AS datetime) as [LastUpdate],
	COUNT(CASE WHEN Organism = 'CDIFF' THEN 1 ELSE NULL END) as [CDIFFCount],
	COUNT(CASE WHEN Organism = 'MRSA' THEN 1 ELSE NULL END) as [MRSACount],
	COUNT(CASE WHEN Organism = 'MSSA' THEN 1 ELSE NULL END) as [MSSACount],
	COUNT(CASE WHEN Organism = 'ECOLI' THEN 1 ELSE NULL END) as [ECOLICount],
	COUNT(CASE WHEN Organism = 'KLEBSIELLA' THEN 1 ELSE NULL END) as [KLEBSIELLACount],
	COUNT(CASE WHEN Organism = 'PSEUDOMONAS' THEN 1 ELSE NULL END) as [PSEUDOMONASCount]

FROM
	[SSIS_LOADING].[ICNET].[dbo].[ICNET]

GROUP BY
	PatientIdentifier,
	CAST(SpecimenDate AS datetime),
	Ward,
	Hospital,
	NHSNumber,
	Organism,
	Type,
	SpecimenNumber,
	CAST(LastUpdate AS datetime)

END
GO
