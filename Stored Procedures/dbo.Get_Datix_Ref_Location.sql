SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Datix_Ref_Location]
AS
BEGIN	
SET NOCOUNT ON;

-- EJ 09/12/2020 ATTEMPT TO FIX BLANK MEASURES IN N.I.I.P - YGC WARD 12 APPEARING UNDER UNNKOWN AREA AND CENTRAL CAUSES CLASH

SELECT DISTINCT
ISNULL(NULLIF(inc_organisation,''),-1) as [Area Code]
,CASE inc_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END  as [Area Description]
,ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1)  as [Site Code]
,ISNULL(l1.description,CASE inc_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END)  as [Site Description]
,ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),inc_organisation),-1)  as [Location Code]
,CASE WHEN 
	ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),inc_organisation),-1) IN ('GEN01','GEN02','GEN03','GEN04','GEN05','GEN06','GEN07','GEN08','GEN09','GEN10','GEN11','GEN12','GEN13','GEN14','GEN15','GEN16')
		THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ISNULL(l2.description,l1.description),CASE inc_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END), ' (secondary care)', ''), ' (Area)', ''), ' (corporate)', ''), ' (secondary)', ''), ' (corpoprate)', '') 
			 + CASE WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) IN ( 'ACU01','BCUHBW') THEN ', YG' WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) in ( 'ACU02','BCUHBC') THEN ', YGC'  WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'ACU05' THEN ', LLGH' WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) in ( 'ACU03','BCUHBE') THEN ', WM' ELSE NULL END
		ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ISNULL(l2.description,l1.description),CASE inc_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END), ' (secondary care)', ''), ' (Area)', ''), ' (corporate)', ''), ' (secondary)', ''), ' (corpoprate)', '') END as [Location Description]
,'Datix' as [Source]
,ISNULL(CASE WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'ACU01' THEN 'LL57 2PW'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'ACU02' THEN 'LL18 5UJ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'ACU03' THEN 'LL13 7TD'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'ACU04' THEN 'LL22 8DP'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'ACU05' THEN 'LL30 1LB'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'BYN' THEN 'LL33 0HH'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH01' THEN 'LL29 8AY'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH02' THEN 'CH5 1XS'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH03' THEN 'LL16 3ES'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH04' THEN 'CH6 5ER'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH05' THEN 'LL17 0RX'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH06' THEN 'CH8 7TZ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH07' THEN 'LL20 8SP'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH08' THEN 'LL19 9RD'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH09' THEN 'LL18 3AS'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH10' THEN 'LL15 1PS'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH11' THEN 'LL14 5LN'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH12' THEN 'CH7 1XG'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH13' THEN 'LL53 6TT'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH14' THEN 'LL77 7PP'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH15' THEN 'LL40 1NT'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH16' THEN 'LL55 2YE'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH17' THEN 'LL41 3DW'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH18' THEN 'LL36 9HH'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH19' THEN 'LL49 9AQ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH20' THEN 'LL65 2QA'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'COMH21' THEN 'LL13 0LH'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'HMPB' THEN 'LL13 9QE'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'MH01' THEN 'LL57 2PW'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'MH02' THEN 'LL18 5UJ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'MH03' THEN 'LL13 7TD'
WHEN ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) = 'MH05' THEN 'LL13 7TD'
ELSE '' END, '') as [Postcode],
CASE WHEN ISNULL(NULLIF(inc_organisation,''),-1) <> '-1' AND ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),inc_organisation),-1) IN (
	'GEN01','GEN03','MHS14','WARD2A','WARD2B','WARD4D','YGC001','YGC008','YGC011','YGC019',
'YGC025','YGC044','YGC048','YGC064','YGC065','YGC066','YGC067','YGC068','YGC070','YGC071',
'YGC072','YGC073','YGC074','YGC075','YGC076','YGC077','YGC078','YGC080','YGC089','YGC090','YGC098',
'YGC100','YGC103','YGC104','ABH07','LLGH01','LLGH02','LLGH05','LLGH08','CTC01','CBCH01','CBCH02',
'DBCH03','HOL01','HOL02','RUTH02','ABT05','ABT06','ABT09','ABT10','CYNNYD','MHS14','MHS25',
'NWAS1','GEN01','WM001','WM006','WM009','WM011','WM014','WM016','WM018','WM021','WM032','WM033',
'WM036','WM041','WM043','WM051','WM054','WM056','WM063','WM068','WM073','WM079','WM090','WM092','WM095',
'WM096','WM098','WM099','WM113','WM119','WPDU','DSD01','DSD03','HOL01','HOL02','CEIRIO','MLD01',
'MLD02','PENL01','HEDD01','HEDD02','HEDD03','MHS31','HEOP01','HEOP02','GEN01','GEN03','YG003',
'YG006','YG011','YG013','YG016','YG017','YG022','YG024','YG026','YG027','YG028','YG031','YG040',
'YG047','YG049','YG055','YG059','YG064','YG079','YG080','BYN05','BYN14','BYN22','BYN28','BYN29','BYN30',
'BYN31','BBH03','CEFH01','DBDH01','YE03','YE04','TWMH01','YA12','YPS01','YPS03','HER01','HER02',
'HER07','TLL01','TLL03','TLL05', 'AMUASS','AMUSHO','HMP01','HMP02','HMP03','HMP04','HMP05','HMP06','HMP07','HMP08','HMP09','HMP10','HMP11','HMP12','HMP13','HMP14','HMP15','HMP16', 'FIELD2','YGC087') THEN '1'
WHEN ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),inc_organisation),-1) = 'DN' AND ISNULL(NULLIF(ISNULL(l1.code,inc_organisation),''),-1) LIKE 'COMH%' THEN '1' ELSE '' END as [InpatientArea]


FROM [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[incidents_main] i
LEFT JOIN [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_locactual] l2 on i.inc_locactual = l2.code
LEFT JOIN [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_unit] l1 on i.inc_unit = l1.code


UNION

SELECT DISTINCT
ISNULL(NULLIF(com_organisation,''),-1) as [Area Code]
,CASE com_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END  as [Area Description]
,ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1)  as [Site Code]
,ISNULL(l1.description,CASE com_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END)  as [Site Description]
,ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),com_organisation),-1)  as [Location Code]
,CASE WHEN 
	ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),com_organisation),-1) IN ('GEN01','GEN02','GEN03','GEN04','GEN05','GEN06','GEN07','GEN08','GEN09','GEN10','GEN11','GEN12','GEN13','GEN14','GEN15','GEN16')
		THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ISNULL(l2.description,l1.description),CASE com_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END), ' (secondary care)', ''), ' (Area)', ''), ' (corporate)', ''), ' (secondary)', ''), ' (corpoprate)', '') 
			 + CASE WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) IN ( 'ACU01','BCUHBW') THEN ', YG' WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) in ( 'ACU02','BCUHBC') THEN ', YGC'  WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'ACU05' THEN ', LLGH' WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) in ( 'ACU03','BCUHBE') THEN ', WM' ELSE NULL END
		ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ISNULL(l2.description,l1.description),CASE com_organisation WHEN 'BCUHBW' THEN 'West' WHEN 'BCUHBC' THEN 'Central' WHEN 'BCUHBE' THEN 'East' ELSE 'Unknown' END), ' (secondary care)', ''), ' (Area)', ''), ' (corporate)', ''), ' (secondary)', ''), ' (corpoprate)', '') END as [Location Description]
,'Datix' as [Source]
,ISNULL(CASE WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'ACU01' THEN 'LL57 2PW'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'ACU02' THEN 'LL18 5UJ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'ACU03' THEN 'LL13 7TD'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'ACU04' THEN 'LL22 8DP'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'ACU05' THEN 'LL30 1LB'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'BYN' THEN 'LL33 0HH'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH01' THEN 'LL29 8AY'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH02' THEN 'CH5 1XS'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH03' THEN 'LL16 3ES'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH04' THEN 'CH6 5ER'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH05' THEN 'LL17 0RX'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH06' THEN 'CH8 7TZ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH07' THEN 'LL20 8SP'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH08' THEN 'LL19 9RD'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH09' THEN 'LL18 3AS'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH10' THEN 'LL15 1PS'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH11' THEN 'LL14 5LN'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH12' THEN 'CH7 1XG'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH13' THEN 'LL53 6TT'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH14' THEN 'LL77 7PP'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH15' THEN 'LL40 1NT'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH16' THEN 'LL55 2YE'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH17' THEN 'LL41 3DW'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH18' THEN 'LL36 9HH'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH19' THEN 'LL49 9AQ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH20' THEN 'LL65 2QA'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'COMH21' THEN 'LL13 0LH'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'HMPB' THEN 'LL13 9QE'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'MH01' THEN 'LL57 2PW'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'MH02' THEN 'LL18 5UJ'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'MH03' THEN 'LL13 7TD'
WHEN ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) = 'MH05' THEN 'LL13 7TD'
ELSE '' END, '') as [Postcode],
CASE WHEN ISNULL(NULLIF(com_organisation,''),-1) <> '-1' AND ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),com_organisation),-1) IN (
	'GEN01','GEN03','MHS14','WARD2A','WARD2B','WARD4D','YGC001','YGC008','YGC011','YGC019',
'YGC025','YGC044','YGC048','YGC064','YGC065','YGC066','YGC067','YGC068','YGC070','YGC071',
'YGC072','YGC073','YGC074','YGC075','YGC076','YGC077','YGC078','YGC080','YGC089','YGC090','YGC098',
'YGC100','YGC103','YGC104','ABH07','LLGH01','LLGH02','LLGH05','LLGH08','CTC01','CBCH01','CBCH02',
'DBCH03','HOL01','HOL02','RUTH02','ABT05','ABT06','ABT09','ABT10','CYNNYD','MHS14','MHS25',
'NWAS1','GEN01','WM001','WM006','WM009','WM011','WM014','WM016','WM018','WM021','WM032','WM033',
'WM036','WM041','WM043','WM051','WM054','WM056','WM063','WM068','WM073','WM079','WM090','WM092','WM095',
'WM096','WM098','WM099','WM113','WM119','WPDU','DSD01','DSD03','HOL01','HOL02','CEIRIO','MLD01',
'MLD02','PENL01','HEDD01','HEDD02','HEDD03','MHS31','HEOP01','HEOP02','GEN01','GEN03','YG003',
'YG006','YG011','YG013','YG016','YG017','YG022','YG024','YG026','YG027','YG028','YG031','YG040',
'YG047','YG049','YG055','YG059','YG064','YG079','YG080','BYN05','BYN14','BYN22','BYN28','BYN29','BYN30',
'BYN31','BBH03','CEFH01','DBDH01','YE03','YE04','TWMH01','YA12','YPS01','YPS03','HER01','HER02',
'HER07','TLL01','TLL03','TLL05', 'AMUASS','AMUSHO','HMP01','HMP02','HMP03','HMP04','HMP05','HMP06',
'HMP07','HMP08','HMP09','HMP10','HMP11','HMP12','HMP13','HMP14','HMP15','HMP16','FIELD2','YGC087') THEN '1'
WHEN ISNULL(ISNULL(NULLIF(ISNULL(l2.code,l1.code),''),com_organisation),-1) = 'DN' AND ISNULL(NULLIF(ISNULL(l1.code,com_organisation),''),-1) LIKE 'COMH%' THEN '1' ELSE '' END as [InpatientArea]

FROM [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[compl_main] c
LEFT JOIN [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_unit] l1 on c.com_unit = l1.code
LEFT JOIN [7A1AUSRVDTXSQL2].[datixcrm].[dbo].[code_locactual] l2 on c.com_locactual = l2.code

ORDER BY [Location Code]

END
GO
