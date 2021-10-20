SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Cancer_Data_Tracker]
	
AS
BEGIN
	
	SET NOCOUNT ON;



select 'Started at '+CAST(GetDate() AS VARCHAR(50))

--This part is concerned with the values required for deriving the Suspected Tumour Site
--Am putting it in here for now until this becomes a dataset on the NWH
DECLARE @STS_Specialty AS TABLE(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Area				VARCHAR(10),
	Source				VARCHAR(10),
	SpecialtyCode		VARCHAR(10),
	SuspectedTumourSite	VARCHAR(50)
)
INSERT INTO @STS_Specialty(Area,Source,SpecialtyCode,SuspectedTumourSite) VALUES
--('East','100','Breast\Lower Gastrointestinal\Upper Gastrointestinal'),
('East','RTT','101','Urological'),
('East','RTT','120','Head & Neck'),
('East','RTT','130','Other'),
('East','RTT','140','Head & Neck'),
('East','RTT','141','Head & Neck'),
('East','RTT','170','Other'),
('East','RTT','301','Upper Gastrointestinal'),
('East','RTT','302','Other'),
('East','RTT','303','Haematological'),
('East','RTT','320','Other'),
('East','RTT','330','Skin'),
('East','RTT','340','Lung'),
('East','RTT','361','Other'),
('East','RTT','430','Other'),
('East','RTT','502','Gynaecological'),

('West','RTT','101','Urological'),
('West','RTT','120','Head & Neck'),
('West','RTT','130','Other'),
('West','RTT','140','Head & Neck'),
('West','RTT','141','Head & Neck'),
('West','RTT','170','Other'),
('West','RTT','301','Upper Gastrointestinal'),
('West','RTT','302','Other'),
('West','RTT','303','Haematological'),
('West','RTT','330','Skin'),
('West','RTT','340','Lung'),
('West','RTT','361','Other'),
('West','RTT','502','Gynaecological'),

('Central','RTT','101','Urological'),
('Central','RTT','103','Breast'),
('Central','RTT','104','Lower Gastrointestinal'),
('Central','RTT','110','Other'),
('Central','RTT','120','Head & Neck'),
('Central','RTT','130','Other'),
('Central','RTT','140','Head & Neck'),
('Central','RTT','141','Head & Neck'),
('Central','RTT','160','Skin'),
('Central','RTT','170','Other'),
('Central','RTT','301','Upper Gastrointestinal'),
('Central','RTT','302','Other'),
('Central','RTT','303','Haematological'),
('Central','RTT','330','Skin'),
('Central','RTT','340','Lung'),
('Central','RTT','361','Other'),
('Central','RTT','430','Other'),
('Central','RTT','502','Gynaecological'),

('Central','Radis','AE','Other'),
('Central','Radis','AMU','Other'),
('Central','Radis','ASP','Other'),
('Central','Radis','CARD','Other'),
('Central','Radis','EYES','Other'),
('Central','Radis','DENT','Head & Neck'),
('Central','Radis','DERM','Skin'),
('Central','Radis','DIAB','Other'),
('Central','Radis','ENT','Head & Neck'),
('Central','Radis','GAST','Upper Gastrointestinal'),
('Central','Radis','GER','Other'),
('Central','Radis','GM','Other'),
('Central','Radis','GS','Other'),
('Central','Radis','GYN','Gynaecological'),
('Central','Radis','HAEM','Haematological'),
('Central','Radis','MF','Head & Neck'),
('Central','Radis','NS','Other'),
('Central','Radis','OBS','Gynaecological'),
('Central','Radis','ONC','Other'),
('Central','Radis','OPH','Other'),
('Central','Radis','OPSY','Other'),
('Central','Radis','ORTH','Other'),
('Central','Radis','PAED','Other'),
('Central','Radis','PLAS','Skin'),
('Central','Radis','REN','Other'),
('Central','Radis','URO','Urological'),
('Central','Radis','XRAY','Other'),
('East','Radis','AE','Other'),
('East','Radis','CAR','Other'),
('East','Radis','CHPHY','Lung'),
('East','Radis','COLO','Lower Gastrointestinal'),
('East','Radis','COTE','Other'),
('East','Radis','DMAT','Skin'),
('East','Radis','ENDO','Upper Gastrointestinal'),
('East','Radis','ENT','Head & Neck'),
('East','Radis','GMED','Other'),
('East','Radis','GSUR','Other'),
('East','Radis','GYN','Gynaecological'),
('East','Radis','HCE','Other'),
('East','Radis','O','Head & Neck'),
('East','Radis','OBS','Other'),
('East','Radis','OBSG','Gynaecological'),
('East','Radis','ONC','Other'),
('East','Radis','OPTH','Other'),
('East','Radis','OS','Head & Neck'),
('East','Radis','PATH','Other'),
('East','Radis','PS','Other'),
('East','Radis','PSYCH','Other'),
('East','Radis','REN','Other'),
('East','Radis','RMAT','Other'),
('East','Radis','TO','Other'),
('East','Radis','TS','Lung'),
('East','Radis','URO','Urological'),
('East','Radis','YGCRESP','Lung'),
('West','Radis','CARD','Other'),
('West','Radis','DEN','Head & Neck'),
('West','Radis','DERM','Skin'),
('West','Radis','ENT','Head & Neck'),
('West','Radis','GENT','Upper Gastrointestinal'),
('West','Radis','GERI','Other'),
('West','Radis','HAEM','Haematological'),
('West','Radis','MAX','Head & Neck'),
('West','Radis','MED','Other'),
('West','Radis','NEPH','Other'),
('West','Radis','OBS','Gynaecological'),
('West','Radis','ONCO','Other'),
('West','Radis','OPTH','Other'),
('West','Radis','ORTH','Other'),
('West','Radis','PAED','Other'),
('West','Radis','PLAS','Other'),
('West','Radis','PSYCH','Other'),
('West','Radis','RAD','Other'),
('West','Radis','RHEUM','Other'),
('West','Radis','SURG','Other'),
('West','Radis','UROL','Urological')


--This table is for futher mapping based on consultant (currently only used by 100-General Surgery)
--23 April 2020 - extended for use with Gastro and Respiratory 
DECLARE @STS_Consultant AS TABLE(
	RowId				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Area				VARCHAR(10),
	Source				VARCHAR(10),
	ConsultantCode		VARCHAR(10),
	SuspectedTumourSite	VARCHAR(50),
	Specialty			VARCHAR(50)
)
INSERT INTO @STS_Consultant(Area,Source,ConsultantCode,SuspectedTumourSite,Specialty) VALUES
('East','RTT','AB','Upper Gastrointestinal','GeneralSurgery'),	--Mr A Baker
('East','Radis','BAAL','Upper Gastrointestinal','GeneralSurgery'),	--Mr A Baker
('East','RTT','ABS','Lower Gastrointestinal','GeneralSurgery'),	--Dr A Ben Sassi
('East','Radis','BENABS','Lower Gastrointestinal','GeneralSurgery'),	--Dr A Ben Sassi
('East','RTT','ADW','Other','GeneralSurgery'),	--Dr A D White
('East','Radis','ADW','Other','GeneralSurgery'),	--Dr A D White
('East','RTT','AOA','Other','GeneralSurgery'),	--Mr A Alalade
('East','Radis','ALALA','Gynaecological','GeneralSurgery'),	--Mr A Alalade
('East','RTT','BCLG','Breast','GeneralSurgery'),	--A Breast Care Consultant
('East','RTT','BJ6','Urological','GeneralSurgery'),	--Mr B Jameel
('East','Radis','JAMB','Urological','GeneralSurgery'),	--Mr B Jameel
('East','RTT','CLFB','Lower Gastrointestinal','GeneralSurgery'),	--Mr C Battersby
('East','Radis','BATT','Lower Gastrointestinal','GeneralSurgery'),	--Mr C Battersby
('East','RTT','CONSG','Lower Gastrointestinal','GeneralSurgery'),	--Mixed Clinician
('East','RTT','CRLG','Lower Gastrointestinal','GeneralSurgery'),	--A Colorectal Consultant
('East','RTT','DJST','Upper Gastrointestinal','GeneralSurgery'),	--Mr. D J Stewart
('East','Radis','STED','Upper Gastrointestinal','GeneralSurgery'),	--Mr. D J Stewart
('East','RTT','DNM','Upper Gastrointestinal','GeneralSurgery'),	--Mr. D N Monk
('East','Radis','MONK','Upper Gastrointestinal','GeneralSurgery'),	--Mr. D N Monk
('East','RTT','JDE','Upper Gastrointestinal','GeneralSurgery'),	--Mr. J D Evans
('East','Radis','EVJAM','Upper Gastrointestinal','GeneralSurgery'),	--Mr. J D Evans
('East','RTT','JKP','Upper Gastrointestinal','GeneralSurgery'),	--Mr. J K Pye
('East','Radis','JKP','Upper Gastrointestinal','GeneralSurgery'),	--Mr. J K Pye
('East','RTT','MPT','Lower Gastrointestinal','GeneralSurgery'),	--Mr. M P Thornton
('East','Radis','THORN','Lower Gastrointestinal','GeneralSurgery'),	--Mr. M P Thornton
('East','RTT','PARI','Upper Gastrointestinal','GeneralSurgery'),	--Mr. P A Richards
('East','Radis','RIPH','Upper Gastrointestinal','GeneralSurgery'),	--Mr. P A Richards
('East','RTT','UGLG','Upper Gastrointestinal','GeneralSurgery'),	--Upper GI Consultant
('East','RTT','UJK','Other','GeneralSurgery'),	--Miss U J Kirkpatrick
('East','Radis','KIUR','Other','GeneralSurgery'),	--Miss U J Kirkpatrick
('East','RTT','PC','Lower Gastrointestinal','GeneralSurgery'),	--Mr. P Chandran
('East','Radis','CHAP','Lower Gastrointestinal','GeneralSurgery'),	--Mr. P Chandran
('East','RTT','PM','Lower Gastrointestinal','GeneralSurgery'),	--Mr. P Marsh
('East','Radis','MAPJ','Lower Gastrointestinal','GeneralSurgery'),	--Mr. P Marsh
('East','RTT','RC','Breast','GeneralSurgery'),	--Mr. R Cochran
('East','Radis','COCR','Breast','GeneralSurgery'),	--Mr. R Cochran
('East','RTT','SABS','Upper Gastrointestinal','GeneralSurgery'),	--Mr S Sabanathan
('East','Radis','SABAN','Upper Gastrointestinal','GeneralSurgery'),	--Mr S Sabanathan
('East','RTT','TCG','Breast','GeneralSurgery'),	--Mr. T Gate
('East','Radis','GATI','Breast','GeneralSurgery'),	--Mr. T Gate
('East','RTT','VSLG','Other','GeneralSurgery'),	--Vascular Pooled Waiting list

('West','RTT','C6087887','Lower Gastrointestinal','GeneralSurgery'),	--Mr Baber Chaudhary
('West','Radis','CHAUDB','Lower Gastrointestinal','GeneralSurgery'),	--Mr Baber Chaudhary
('West','RTT','C3183328','Lower Gastrointestinal','GeneralSurgery'),	--Mr Nik Abdullah
('West','Radis','ABDUL','Lower Gastrointestinal','GeneralSurgery'),	--Mr Nik Abdullah
('West','RTT','C6053617','Lower Gastrointestinal','GeneralSurgery'),	--Mr Chris Houlden
('West','Radis','CH','Lower Gastrointestinal','GeneralSurgery'),		--Mr Chris Houlden
('West','RTT','C5206250','Lower Gastrointestinal','GeneralSurgery'),	--Mr Anil Lala
('West','Radis','LALAA','Lower Gastrointestinal','GeneralSurgery'),	--Mr Anil Lala
('West','RTT','C2654030','Lower Gastrointestinal','GeneralSurgery'),	--Mr Graham Whiteley
('West','Radis','WHITG','Lower Gastrointestinal','GeneralSurgery'),	--Mr Graham Whiteley
('West','RTT','C5206364','Lower Gastrointestinal','GeneralSurgery'),	--Mr Tarek Garsaa
('West','Radis','GARSAT','Lower Gastrointestinal','GeneralSurgery'),	--Mr Tarek Garsaa
('West','RTT','C4637835','Breast','GeneralSurgery'),		--Mr Ilyas Khattak
('West','Radis','KHATI','Breast','GeneralSurgery'),		--Mr Ilyas Khattak
('West','RTT','C3145690','Breast','GeneralSurgery'),		--Mr Paul McAleese
('West','Radis','PJGM','Breast','GeneralSurgery'),		--Mr Paul McAleese
('West','RTT','C7208968','Breast','GeneralSurgery'),		--Kleidi, Eleftheria
('West','Radis','ELK','Breast','GeneralSurgery'),		--Kleidi, Eleftheria
('West','RTT','C7478874','Lower Gastrointestinal','GeneralSurgery'),		--Gelber, Edgar
('West','Radis','GELE','Lower Gastrointestinal','GeneralSurgery'),		--Gelber, Edgar
('West','RTT','C4575508','Lower Gastrointestinal','GeneralSurgery'),		--S Sabanathan
('West','Radis','SABAS','Lower Gastrointestinal','GeneralSurgery'),		--S Sabanathan
('West','Radis','JOHNSJ','Breast','GeneralSurgery'),		--MR J JOHNSON
('West','Radis','MJH1','Breast','GeneralSurgery'),		--Miss M J Hwang
('West','RTT','C6052719','Breast','GeneralSurgery'),		--Miss M J Hwang

('Central','RTT','AM3','Lower Gastrointestinal','GeneralSurgery'),	--Mr Andrew Maw
('Central','Radis','AM3','Lower Gastrointestinal','GeneralSurgery'),	--Mr Andrew Maw
('Central','RTT','MAR','Lower Gastrointestinal','GeneralSurgery'),	--Mr Mahir Al-Rawi
('Central','Radis','MAR','Lower Gastrointestinal','GeneralSurgery'),	--Mr Mahir Al-Rawi
('Central','RTT','FA3','Lower Gastrointestinal','GeneralSurgery'),	--Mr Fayyaz Akbar
('Central','Radis','FA3','Lower Gastrointestinal','GeneralSurgery'),	--Mr Fayyaz Akbar
('Central','RTT','HIAH','Lower Gastrointestinal','GeneralSurgery'),	--Mr Hasan Hadi
('Central','Radis','HIAH','Lower Gastrointestinal','GeneralSurgery'),--Mr Hasan Hadi
('Central','RTT','AAK2','Lower Gastrointestinal','GeneralSurgery'),	--Mr Khan
('Central','Radis','AAK2','Lower Gastrointestinal','GeneralSurgery'),--Mr Khan
('Central','RTT','AMO','Lower Gastrointestinal','GeneralSurgery'),	--Mr Mownah
('Central','Radis','AMO','Lower Gastrointestinal','GeneralSurgery'),	--Mr Mownah
('Central','RTT','RJM1','Upper Gastrointestinal','GeneralSurgery'),	--Mr Richard Morgan
('Central','Radis','RJM1','Upper Gastrointestinal','GeneralSurgery'),--Mr Richard Morgan
('Central','RTT','BSR','Other','GeneralSurgery'),		--Mr Bangalore Ramanand
('Central','Radis','BSR','Other','GeneralSurgery'),		--Mr Bangalore Ramanand
('Central','RTT','WAS1','Breast','GeneralSurgery'),		--Mr Walid Samra
('Central','Radis','WAS1','Breast','GeneralSurgery'),	--Mr Walid Samra
('Central','RTT','MPE','Breast','GeneralSurgery'),		--Miss Mandana Pennick
('Central','Radis','MPE','Breast','GeneralSurgery'),		--Miss Mandana Pennick
('Central','Radis','PJGM','Breast','GeneralSurgery'),	--Mr Paul McAleese
('Central','RTT','BL1','Lower Gastrointestinal','GeneralSurgery'),	--Mr B Liu
('Central','RTT','MBA1','Lower Gastrointestinal','GeneralSurgery'),	--Mr Marius Barbulescu
('Central','RTT','RR1','Lower Gastrointestinal','GeneralSurgery'),	--Mr R R Rajagopal
('Central','Radis','SFUR','Lower Gastrointestinal','GeneralSurgery'),	--Mr S F U Rehman
('Central','RTT','SFUR','Lower Gastrointestinal','GeneralSurgery'),	--Mr S F U Rehman
('Central','Radis','RF2','Lower Gastrointestinal','GeneralSurgery'),	--Mr S F U Rehman
('Central','RTT','RF2','Lower Gastrointestinal','GeneralSurgery'),	--Mr S F U Rehman

--23 April 2020 - these are the new gastro and respiratory entries
--Most of them should have been caught by the specialties lookup above...
('Central','RTT','AB3','Upper Gastrointestinal','Gastro'),		--Dr A Baghomian
('Central','Radis','AB3','Upper Gastrointestinal','Gastro'),	--DR ARAM BAGHOMIAN
('Central','RTT','IAF','Upper Gastrointestinal','Gastro'),		--Dr  I A  Finnie
('Central','Radis','IAF','Upper Gastrointestinal','Gastro'),	--DR IAN FINNIE
('Central','RTT','RCE','Upper Gastrointestinal','Gastro'),		--Dr  RCE  Evans
('Central','Radis','RCE','Upper Gastrointestinal','Gastro'),	--MR RICHARD C EVANS
('Central','RTT','HY2','Upper Gastrointestinal','Gastro'),		--Dr Hamid Yousuf
('Central','Radis','HY2','Upper Gastrointestinal','Gastro'),	--DR HAMID YOUSEF
('Central','RTT','ZM2','Upper Gastrointestinal','Gastro'),		--Dr Zvonimir Miric
('Central','Radis','ZM2','Upper Gastrointestinal','Gastro'),	--DR ZVONIMIR MIRIC
('Central','Radis','COREC6','Lower Gastrointestinal','Gastro'),	--Kathryn Fisher
('Central','RTT','DM5','Lung','Respiratory'),		--Dr  D  Menzies
('Central','Radis','DM5','Lung','Respiratory'),		--DR DANIEL MENZIES
('Central','RTT','SA1','Lung','Respiratory'),		--Dr  S  Ambalavanan
('Central','Radis','SA1','Lung','Respiratory'),		--DR SAKKARAI AMBALAVANAN
('Central','RTT','RACP','Lung','Respiratory'),		--Dr  R A C   Poyner
('Central','Radis','RACP','Lung','Respiratory'),	--DR R A C POYNER
('Central','RTT','AHAH','Lung','Respiratory'),		--Dr Ahmed Hesham Abou-Haggar
('Central','Radis','AHAH','Lung','Respiratory'),	--DR AHMED.H ABOU-HAGGAR
('Central','Radis','SD8','Lung','Respiratory'),		--Dr Sarah Davies

('West','RTT','C6045380','Upper Gastrointestinal','Gastro'),	--Sutton, J
('West','RTT','G9301016','Upper Gastrointestinal','Gastro'),	--Sutton, J
('West','Radis','SUTTJ','Upper Gastrointestinal','Gastro'),		--DR J SUTTON
('West','RTT','C6162480','Upper Gastrointestinal','Gastro'),	--Newbould, Rachel
('West','Radis','RSN','Upper Gastrointestinal','Gastro'),		--DR R S NEWBOULD
('West','RTT','C3131242','Upper Gastrointestinal','Gastro'),	--Evans, R C
('West','Radis','EVANR','Upper Gastrointestinal','Gastro'),		--R CEIRI EVANS
('West','Radis','RCE','Upper Gastrointestinal','Gastro'),		--RICHARD C. EVANS
('West','RTT','C6026065','Upper Gastrointestinal','Gastro'),	--Magzoub Ahmed, Salah Mohamed
('West','Radis','SMMA','Upper Gastrointestinal','Gastro'),		--SALAH M. MAGZOUB AHMED
('West','RTT','C6055583','Upper Gastrointestinal','Gastro'),	--Brown, Robert
('West','Radis','RBR1','Upper Gastrointestinal','Gastro'),		--MR ROBERT BROWN
('West','RTT','C5203268','Upper Gastrointestinal','Gastro'),	--Gherghab, Mustafa Yahya
('West','Radis','MYG','Upper Gastrointestinal','Gastro'),		--DR M Y GHERGHAB
('West','RTT','C6060957','Lung','Respiratory'),	--Thahseen, A
('West','Radis','THAHA','Lung','Respiratory'),		--DR A THAHSEEN
('West','RTT','C6074925','Lung','Respiratory'),	--Kilduff, C
('West','Radis','KILC','Lung','Respiratory'),		--DR CLAIRE KILDUFF
('West','RTT','C4336323','Other','Other'),	--Elghenzai, S
('West','Radis','ELGHES','Other','Other'),		--DR S EL GHENZAI
('West','RTT','C7015016','Other','Other'),	--Martin, C O
('West','Radis','COM1','Other','Other'),		--DR C O MARTIN
('West','RTT','C2489188','Other','Other'),	--Bates, A B
('West','Radis','BATEA','Other','Other'),		--DR A BATES

('East','RTT','TM','Upper Gastrointestinal','Gastro'),	--Dr T Mathialahan
('East','Radis','MATH','Upper Gastrointestinal','Gastro'),		--DR T MATHIALAHAN
('East','RTT','PG','Upper Gastrointestinal','Gastro'),	--Dr P George
('East','Radis','GEP','Upper Gastrointestinal','Gastro'),		--DR P GEORGE
('East','RTT','HK','Upper Gastrointestinal','Gastro'),	--Dr H Khan
('East','Radis','KHH','Upper Gastrointestinal','Gastro'),		--DR H KHAN
('East','RTT','SRV','Upper Gastrointestinal','Gastro'),	--Dr S Venugopal
('East','Radis','VENU','Upper Gastrointestinal','Gastro'),		--DR SREEJITH VENUGOPAL
('East','RTT','NAM','Lung','Respiratory'),	--Dr N A McAndrew
('East','Radis','MCAN','Lung','Respiratory'),		--DR NEIL MCANDREW
('East','RTT','JPK','Lung','Respiratory'),	--Dr JP Kilbane
('East','Radis','KILBJ','Lung','Respiratory'),		--DR JAMES P KILBANE
('East','RTT','SDY','Lung','Respiratory'),	--Dr S Dyer
('East','Radis','DYERS','Lung','Respiratory'),		--DR SARAH DYER
('East','RTT','MS','Lung','Respiratory'),	--Dr M Steel
('East','Radis','STEM','Lung','Respiratory'),		--DR MARK STEEL
('East','RTT','EBR','Lung','Respiratory'),	--Dr E Brohan
('East','Radis','BROE','Lung','Respiratory'),		--DR E BROHAN
('East','RTT','SK1','Lung','Respiratory'),	--Dr S K Kelly
('East','Radis','KES','Lung','Respiratory')		--DR STEVEN KELLY



--SELECT DISTINCT SuspectedTumourSite FROM @STS_Specialty
--UNION
--SELECT DISTINCT SuspectedTumourSite FROM @STS_Consultant
--RETURN

--Had to do this when the new Single Cancer Pathway Tracker site was done, some f the lists got updated so rather
--than changing all the entries above it's easier to do this (and for future proofing) 
--For any new ones though just add them above as they should be, don't need to add stuff here, this is just for existing stuff
--DECLARE @TumourSiteUpdate AS TABLE(
--		OldName		VARCHAR(50),
--		NewName		VARCHAR(50)
--)
--INSERT INTO @TumourSiteUpdate VALUES
--('Breast','8 - Breast'),
--('Gynaecological','9 - Gynaecological'),
--('Haematological','11 - Haematological (exc Acute Leukaemia)'),
--('Head & Neck','1 - Head and Neck'),
--('Lower Gastrointestinal','3 - Lower GI'),
--('Lung','4 - Lung'),
--('Other','98 - Other'),
--('Skin','6 - Skin (exc BCC)'),
--('Upper Gastrointestinal','2 - Upper GI'),
--('Urological','10 - Urological')

--UPDATE @STS_Specialty SET SuspectedTumourSite=T.NewName FROM @STS_Specialty S INNER JOIN @TumourSiteUpdate T ON S.SuspectedTumourSite=T.OldName
--UPDATE @STS_Consultant SET SuspectedTumourSite=T.NewName FROM @STS_Consultant C INNER JOIN @TumourSiteUpdate T ON C.SuspectedTumourSite=T.OldName


DECLARE @EthnicMap AS TABLE(
	RowId		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Area		VARCHAR(10),
	Code		VARCHAR(5),
	MapTo		VARCHAR(200)
)
INSERT INTO @EthnicMap(Area,Code,MapTo) VALUES
('West','99','Z - Not stated'),
('West','A','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('West','B','B - Gypsy or Irish Traveller'),
('West','C','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('West','D','D - White and Black Caribbean'),
('West','E','E - White and Black African'),
('West','F','F - White and Asian'),
('West','G','G - Any other mixed background / multiple ethnic background'),
('West','H','H - Indian'),
('West','J','J - Pakistani'),
('West','K','K - Bangladeshi'),
('West','L','L - Any other Asian background'),
('West','M','M - Caribbean'),
('West','N','N - African'),
('West','P','P - Any other Black background'),
('West','R','R - Chinese'),
('West','S','S - Any other ethnic group'),
('West','T','T - Arab'),
('West','Z','Z - Not stated'),
('Central','AZ','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','DZ','D - White and Black Caribbean'),
('Central','EZ','E - White and Black African'),
('Central','FZ','F - White and Asian'),
('Central','GZ','G - Any other mixed background / multiple ethnic background'),
('Central','HZ','H - Indian'),
('Central','JZ','J - Pakistani'),
('Central','KZ','K - Bangladeshi'),
('Central','LZ','L - Any other Asian background'),
('Central','MZ','M - Caribbean'),
('Central','NZ','N - African'),
('Central','PZ','P - Any other Black background'),
('Central','RZ','R - Chinese'),
('Central','SZ','S - Any other ethnic group'),
('Central','ZZ','Z - Not stated'),
('Central','A1','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','A2','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AA','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AB','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AC','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AD','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AE','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AF','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AG','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AH','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AJ','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AK','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AL','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AM','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AN','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AP','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AQ','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AR','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AS','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AT','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AU','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AV','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AW','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','AX','G - Any other mixed background / multiple ethnic background'),
('Central','AY','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('Central','A3','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('East','AZ','A - Any White Background, including Welsh, English, Scottish, Northern Irish, Irish, British'),
('East','DZ','D - White and Black Caribbean'),
('East','EZ','E - White and Black African'),
('East','FZ','F - White and Asian'),
('East','GZ','G - Any other mixed background / multiple ethnic background'),
('East','HZ','H - Indian'),
('East','JZ','J - Pakistani'),
('East','KZ','K - Bangladeshi'),
('East','LZ','L - Any other Asian background'),
('East','MZ','M - Caribbean'),
('East','NZ','N - African'),
('East','PZ','P - Any other Black background'),
('East','RZ','R - Chinese'),
('East','SZ','S - Any other ethnic group'),
('East','ZZ','Z - Not stated')
--select * from @EthnicMap


DECLARE @Specialty AS TABLE(
	RowId			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Area			VARCHAR(10),
	Source			VARCHAR(10),
	SpecialtyCode	VARCHAR(10),
	Specialty		VARCHAR(50)
)
INSERT INTO @Specialty(SpecialtyCode,Area,Source,Specialty) VALUES
('AMU','Central','Radis','Other'),
('DIAB','Central','Radis','Other'),
('ENT','Central','Radis','ENT'),
('GAST','Central','Radis','Gastroenterology'),
('GER','Central','Radis','Other'),
('GM','Central','Radis','General Medicine'),
('GS','Central','Radis','General Surgery'),
('HAEM','Central','Radis','Haematology'),
('MF','Central','Radis','Oral Surgery'),
('REN','Central','Radis','Other'),
('URO','Central','Radis','Urology'),
('100999','Central','RTT','General Surgery'),
('103999','Central','RTT','Breast Surgery'),
('104999','Central','RTT','Colorectal Surgery'),
('101999','Central','RTT','Urology'),
('120999','Central','RTT','ENT'),
('140999','Central','RTT','Maxillo Facial'),
('301999','Central','RTT','Gastroenterology'),
('303999','Central','RTT','Haematology'),
('330999','Central','RTT','Dermatology'),
('340999','Central','RTT','Respiratory'),
('430999','Central','RTT','Other'),
('502999','Central','RTT','Gynaecology'),
('CAR','East','Radis','Other'),
('CHPHY','East','Radis','Respiratory'),
('COLO','East','Radis','Colorectal'),
('ENT','East','Radis','ENT'),
('GAST','East','Radis','Gastroenterology'),
('GMED','East','Radis','General Medicine'),
('GSUR','East','Radis','General Surgery'),
('GYN','East','Radis','Gynaecology'),
('HCE','East','Radis','Other'),
('MAX-FAX','East','Radis','Maxillo Facial'),
('OBSG','East','Radis','Gynaecology'),
('PLAS','East','Radis','Plastics'),
('TS','East','Radis','Thoracic surgery'),
('URO','East','Radis','Urology'),
('100999','East','RTT','General Surgery'),
('101029','East','RTT','Urology'),
('101039','East','RTT','Urology'),
('101999','East','RTT','Urology'),
('120999','East','RTT','ENT'),
('140999','East','RTT','Maxillo Facial'),
('301999','East','RTT','Gastroenterology'),
('303999','East','RTT','Haematology'),
('330999','East','RTT','Dermatology'),
('340999','East','RTT','Respiratory'),
('430999','East','RTT','Other'),
('502999','East','RTT','Gynaecology'),
('MED','West','Radis','General Medicine'),
('UROL','West','Radis','Urology'),
('1000','West','RTT','General Surgery'),
('1010','West','RTT','Urology'),
('1200','West','RTT','ENT'),
('1400','West','RTT','Oral Surgery'),
('1430','West','RTT','Oral Surgery'),
('3000','West','RTT','General Medicine'),
('3010','West','RTT','Gastroenterology'),
('3030','West','RTT','Haematology'),
('3300','West','RTT','Dermatology'),
('3400','West','RTT','Respiratory'),
('4300','West','RTT','Other'),
('5020','West','RTT','Gynaecology')




--SELECT DISTINCT SuspectedTumourSite FROM @STS_Specialty
--UNION
--SELECT DISTINCT SuspectedTumourSite FROM @STS_Consultant
--RETURN

--Drop the main data table if it already exists
DROP TABLE IF EXISTS Foundation.dbo.Cancer_Data_Tracker
--Recreate it
CREATE TABLE Foundation.dbo.Cancer_Data_Tracker(
	RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Area					VARCHAR(10),
	Source					VARCHAR(10),
	ItemIdentifier			VARCHAR(20),
	LocalPatientIdentifier	VARCHAR(10),
	NHSNumber				VARCHAR(10),
	NHSNumberStatus			VARCHAR(2),
	Forenames				VARCHAR(100),
	Surname					VARCHAR(100),
	DateOfBirth				DATE,
	Address					VARCHAR(175),
	Postcode				VARCHAR(8),
	RegisteredPractice		VARCHAR(6),
	Sex						VARCHAR(20),
	EthnicGroup				VARCHAR(2),
	EthnicDescription		VARCHAR(200),
	ConsultantCode			VARCHAR(10),
	Consultant				VARCHAR(100),
	SpecialtyCode			VARCHAR(10),
	Specialty				VARCHAR(50),
	SpecialtyDerived		VARCHAR(50),
	ReferralSentDate		DATE,
	DateOnList				DATE,
	TCIDate					DATE,
	Priority				VARCHAR(50),
	PriorityOfReferral		VARCHAR(10),
	SourceOfSuspicion		VARCHAR(20),
	SourceOfCancerReferral	VARCHAR(50),
	SuspectedTumourSite		VARCHAR(50),
	ReferralSource			VARCHAR(50),
	ReferralSourceLocalName	VARCHAR(100),
	ReferralSourceMainName	VARCHAR(100),
	NextStage				VARCHAR(50),
	Comments				VARCHAR(MAX),
	RunDate					DATE,
	AddToTracker			CHAR(1) DEFAULT('Y')
)

DECLARE @Cancer_Data_Tracker AS TABLE(
	RowId					INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Area					VARCHAR(10),
	Source					VARCHAR(10),
	ItemIdentifier			VARCHAR(20),
	LocalPatientIdentifier	VARCHAR(10),
	NHSNumber				VARCHAR(10),
	NHSNumberStatus			VARCHAR(2),
	Forenames				VARCHAR(100),
	Surname					VARCHAR(100),
	DateOfBirth				DATE,
	Address					VARCHAR(175),
	Postcode				VARCHAR(8),
	RegisteredPractice		VARCHAR(6),
	Sex						VARCHAR(1),
	EthnicGroup				VARCHAR(2),
	ConsultantCode			VARCHAR(10),
	Consultant				VARCHAR(100),
	SpecialtyCode			VARCHAR(10),
	Specialty				VARCHAR(50),
	ReferralSentDate		DATE,
	DateOnList				DATE,
	TCIDate					DATE,
	Priority				VARCHAR(50),
	PriorityOfReferral		VARCHAR(10),
	SuspectedTumourSite		VARCHAR(50),
	ReferralSource			VARCHAR(50),
	ReferralSourceLocalName	VARCHAR(100),
	ReferralSourceMainName	VARCHAR(100),
	Comments				VARCHAR(MAX),
	RunDate					DATE,
	AddToTracker			CHAR(1) DEFAULT('Y')
)


DECLARE @ReferralDate AS DATE=DATEADD(DAY,-7,GETDATE())
DECLARE @ReferralDateString AS VARCHAR(17)=DATENAME(DAY,@ReferralDate)+' '+DATENAME(MONTH,@ReferralDate)+' '+DATENAME(YEAR,@ReferralDate)
DECLARE @SQL AS NVARCHAR(MAX)

--DECLARE @Results AS TABLE(
--	RowId				INT PRIMARY KEY IDENTITY(1,1),
--	Area				VARCHAR(10),
--	Source				VARCHAR(10),
--	ItemIdentifier		VARCHAR(20),
--	LocalPatientIdentifier	VARCHAR(10),
--	NHSNumber				VARCHAR(10),
--	Forenames				VARCHAR(100),
--	Surname					VARCHAR(100),
--	DateOfBirth				DATE,
--	ConsultantCode			VARCHAR(10),
--	Consultant				VARCHAR(100),
--	SpecialtyCode			VARCHAR(10),
--	Specialty				VARCHAR(50),
--	DateOnList				DATE,
--	TCIDate					DATE,
--	Priority				VARCHAR(50)
--)


--Get the Radis data
SET @SQL='SELECT * FROM OPENQUERY(RADIS_CENTRAL,''
Select Distinct
	''''Central'''' AS Area,
	''''Radis'''' AS Source,
	--RequestID AS ItemIdentifier, --should be using requestID here but creates too many duplicates so replace with the patient id instead
	RadISNumber AS ItemIdentifier,
	ISNULL(NULLIF(RTRIM(HospitalNumber),''''''''),RadISNumber) AS LocalPatientIdentifier,
	NULLIF(RTRIM(NHSNumber),'''''''') AS NHSNumber,
	NULL AS NHSNumberStatus,
	Forename AS Forenames,
	Surname AS Surname,
	DateOfBirth AS DateOfBirth,
	RTRIM(Address1)+'''', ''''+RTRIM(Address2)+'''', ''''+RTRIM(Address3)+'''', ''''+RTRIM(Address4)+'''', ''''+RTRIM(Address5) AS Address,
	Postcode AS Postcode,
	NULL AS RegisteredPractice,
	Sex AS Sex,
	NULL AS EthnicGroup,
	ReferringDrCode AS ConsultantCode,
	ReferringDr AS Consultant,
	SpecialtyCode AS SpecialtyCode,
	SpecialtyDescription AS Specialty,
	ReferralDate AS ReferralSentDate,
	RequestReceivedDate AS DateOnList,
	AppointmentDate AS TCIDate,
	PriorityDescription AS Priority,
	NULL AS PriorityOfReferral,
	NULL AS SuspectedTumourSite,
	ReferralDescription AS ReferralSource,
	NULL AS ReferralSourceLocalName,
	NULL AS ReferralSourceMainName,
	NULL AS Comments,
	GetDate() AS RunDate,
	''''Y'''' AS AddToTracker
	
--Priority AS Priority,
--PriorityDetailDescription
--	ExamDescription,
--	ExamGroupCode,
--	PriorityCode,
--	RequestReceivedDate,
--	AttendanceDate
		
From
	Radis.dbo.RadISData
Where	
	CAST(RequestReceivedDate AS DATE)>='''''+@ReferralDateString+'''''
And
	ExamGroupCode in (''''CT'''',''''MR'''',''''NM'''',''''IS'''',''''I'''',''''US'''',''''U'''')
And
	ReferralType = 0
And
	RequestStatus NOT IN (''''3'''',''''5'''',''''10'''',''''11'''')
And
	PriorityDetailDescription = ''''URGENT SUSPECTED CANCER''''
'')'
INSERT INTO @Cancer_Data_Tracker
EXEC(@SQL)



SET @SQL='SELECT * FROM OPENQUERY(RADIS_EAST,''
Select Distinct
	''''East'''' AS Area,
	''''Radis'''' AS Source,
	--RequestID AS ItemIdentifier,  --should be using requestID here but creates too many duplicates so replace with the patient id instead
	RadISNumber AS ItemIdentifier,
	ISNULL(NULLIF(RTRIM(HospitalNumber),''''''''),RadISNumber) AS LocalPatientIdentifier,
	NULLIF(RTRIM(NHSNumber),'''''''') AS NHSNumber,
	NULL AS NHSNumberStatus,
	Forename AS Forenames,
	Surname AS Surname,
	DateOfBirth AS DateOfBirth,
	RTRIM(Address1)+'''', ''''+RTRIM(Address2)+'''', ''''+RTRIM(Address3)+'''', ''''+RTRIM(Address4)+'''', ''''+RTRIM(Address5) AS Address,
	Postcode AS Postcode,
	NULL AS RegisteredPractice,
	Sex AS Sex,
	NULL AS EthnicGroup,
	ReferringDrCode AS ConsultantCode,
	ReferringDr AS Consultant,
	SpecialtyCode AS SpecialtyCode,
	SpecialtyDescription AS Specialty,
	ReferralDate AS ReferralSentDate,
	RequestReceivedDate AS DateOnList,
	AppointmentDate AS TCIDate,
	PriorityDescription AS Priority,
	NULL AS PriorityOfReferral,
	NULL AS SuspectedTumourSite,
	ReferralDescription AS ReferralSource,
	NULL AS ReferralSourceLocalName,
	NULL AS ReferralSourceMainName,
	NULL AS Comments,
	GetDate() AS RunDate,
	''''Y'''' AS AddToTracker
From
	Radis.dbo.RadisData
Where	
	CAST(RequestReceivedDate AS DATE)>='''''+@ReferralDateString+'''''
And
	ExamGroupCode in (''''CT'''',''''MR'''',''''NM'''',''''IS'''',''''I'''',''''US'''',''''U'''')
And
	ReferralType = 0
And
	RequestStatus NOT IN (''''3'''',''''5'''',''''10'''',''''11'''')
And
	PriorityDetailDescription = ''''URGENT SUSPECTED CANCER''''
'')'
INSERT INTO @Cancer_Data_Tracker
EXEC(@SQL)


SET @SQL='SELECT * FROM OPENQUERY(RADIS_WEST,''
Select Distinct
	''''West'''' AS Area,
	''''Radis'''' AS Source,
	--RequestID AS ItemIdentifier,  --should be using requestID here but creates too many duplicates so replace with the patient id instead
	RadISNumber AS ItemIdentifier,
	ISNULL(NULLIF(RTRIM(HospitalNumber),''''''''),RadISNumber) AS LocalPatientIdentifier,
	NULLIF(RTRIM(NHSNumber),'''''''') AS NHSNumber,
	NULL AS NHSNumberStatus,
	Forename AS Forenames,
	Surname AS Surname,
	DateOfBirth AS DateOfBirth,
	RTRIM(Address1)+'''', ''''+RTRIM(Address2)+'''', ''''+RTRIM(Address3)+'''', ''''+RTRIM(Address4)+'''', ''''+RTRIM(Address5) AS Address,
	Postcode AS Postcode,
	NULL AS RegisteredPractice,
	Sex AS Sex,
	NULL AS EthnicGroup,
	ReferringDrCode AS ConsultantCode,
	ReferringDr AS Consultant,
	SpecialtyCode AS SpecialtyCode,
	SpecialtyDescription AS Specialty,
	ReferralDate AS ReferralSentDate,
	RequestReceivedDate AS DateOnList,
	AppointmentDate AS TCIDate,
	PriorityDescription AS Priority,
	NULL AS PriorityOfReferral,
	NULL AS SuspectedTumourSite,
	ReferralDescription AS ReferralSource,
	NULL AS ReferralSourceLocalName,
	NULL AS ReferralSourceMainName,
	NULL AS Comments,
	GetDate() AS RunDate,
	''''Y'''' AS AddToTracker
From
	Radis.dbo.RadisData
Where	
	CAST(RequestReceivedDate AS DATE)>='''''+@ReferralDateString+'''''
And
	ExamGroupCode in (''''CT'''',''''MR'''',''''NM'''',''''IS'''',''''I'''',''''US'''',''''U'''')
And
	ReferralType = 0
And
	RequestStatus NOT IN (''''3'''',''''5'''',''''10'''',''''11'''')
And
	PriorityDetailDescription = ''''URGENT SUSPECTED CANCER''''
'')'
INSERT INTO @Cancer_Data_Tracker
EXEC(@SQL)



--Get the RTT daily snapshot data
--East
INSERT INTO @Cancer_Data_Tracker
SELECT
	'East' AS Area,
	'RTT' AS Source,
	LINKID AS ItemIdentifier,
	CASENO AS LocalPatientIdentifier,
	NULLIF(RTRIM(NHS),'') AS NHSNumber,
	NULL AS NHSNumberStatus,
	RTRIM(SUBSTRING(FULLNAME,CHARINDEX(',',FULLNAME)+2,LEN(FULLNAME))) AS Forenames,
	LEFT(FULLNAME,CHARINDEX(',',FULLNAME)-1) AS Surname,
	BIRTHDATE AS DateOfBirth,
	LEFT(ADDRESS,175) AS Address,
	LEFT(POSTCODE,8) AS Postcode,
	LEFT(REG_PRAC,6) AS RegisteredPractice,
	LEFT(SEX,1) AS Sex,
	NULL AS EthnicGroup,
	CONS AS ConsultantCode,
	ALL_NAME AS Consultant,
	SPEC AS SpecialtyCode,
	MAIN_SPEC_NAME AS Specialty,
	--'' AS SuspectedTumourSite,
	DAT_REF AS ReferralSentDate,
	DATONSYS AS DateOnList,
	--RTT_START_DATE AS RTTStart,
	TRT_DATE AS TCIDate,
	--'' AS Referrer,
	NULLIF(RTRIM(priority),'') AS Priority,
	NULL AS PriorityOfReferral,
	NULL AS SuspectedTumourSite,
	SOURCE_REFER AS ReferralSource,
	NULL AS ReferralSourceLocalName,
	NULL AS ReferralSourceMainName,
	NULL AS Comments,
	GetDate() AS RunDate,
	'Y' AS AddToTracker
FROM
	[NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.East_WPAS_RTT
WHERE
	Specialty_Name LIKE 'Cancer%' AND
	RTT_Status='PO'

UNION ALL

--Centre
SELECT
	'Central' AS Area,
	'RTT' AS Source,
	LINKID AS ItemIdentifier,
	CASENO AS LocalPatientIdentifier,
	NULLIF(RTRIM(NHS),'') AS NHSNumber,
	NULL AS NHSNumberStatus,
	RTRIM(SUBSTRING(FULLNAME,CHARINDEX(',',FULLNAME)+2,LEN(FULLNAME))) AS Forenames,
	LEFT(FULLNAME,CHARINDEX(',',FULLNAME)-1) AS Surname,
	BIRTHDATE AS DateOfBirth,
	LEFT(ADDRESS,175) AS Address,
	LEFT(POSTCODE,8) AS Postcode,
	LEFT(REG_PRAC,6) AS RegisteredPractice,
	LEFT(SEX,1) AS Sex,
	NULL AS EthnicGroup,
	CONS AS ConsultantCode,
	ALL_NAME AS Consultant,
	SPEC AS SpecialtyCode,
	MAIN_SPEC_NAME AS Specialty,
	--'' AS SuspectedTumourSite,
	DAT_REF AS ReferralSentDate,
	DATONSYS AS DateOnList,
	--RTT_START_DATE AS RTTStart,
	TRT_DATE AS TCIDate,
	--'' AS Referrer,
	NULLIF(RTRIM(priority),'') AS Priority,
	NULL AS PriorityOfReferral,
	NULL AS SuspectedTumourSite,
	SOURCE_REFER AS ReferralSource,
	NULL AS ReferralSourceLocalName,
	NULL AS ReferralSourceMainName,
	NULL AS Comments,
	GetDate() AS RunDate,
	'Y' AS AddToTracker
FROM
	[NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.WPAS_RTT_SP
WHERE
	Specialty_Name LIKE '%USC%' AND
	RTT_Status='PO'

UNION ALL

--West
SELECT
	'West' AS Area,
	'RTT' AS Source,
	CAST(r.refrl_refno AS VARCHAR(20)) AS ItemIdentifier,
	r.pasid AS LocalPatientIdentifier,
	NULLIF(RTRIM(p.nhs_identifier),'') AS NHSNumber,
	NULL AS NHSNumberStatus,
	p.forename AS Forenames,
	p.surname AS Surname,
	dttm_of_birth AS DateOfBirth,
	NULL AS Address,
	NULL AS Postcode,
	NULL AS RegisteredPractice,
	NULL AS Sex,
	NULL AS EthnicGroup,
	cons_code AS ConsultantCode,
	consultant AS Consultant,
	r.spect_code AS SpecialtyCode,
	r.specialty AS Specialty,
	--'' AS SuspectedTumourSite,
	r.sent_dttm AS ReferralSentDate,
	r.start AS DateOnList,
	r.booked_dttm AS TCIDate,
	--'' AS Referrer,
	NULLIF(RTRIM(r.priority),'') AS Priority,
	NULL AS PriorityOfReferral,
	NULL AS SuspectedTumourSite,
	Source AS ReferralSource,
	Source AS ReferralSourceLocalName,
	Source AS ReferralSourceMainName,
	NULL AS Comments,
	GetDate() AS RunDate,
	'Y' AS AddToTracker
FROM
	[NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.[Vw_West_RTT_PO] r
	join [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.patients as p on r.pasid = p.pasid
WHERE
	Priority='High Risk ? Cancer' 
--SELECT
--	'West' AS Area,
--	'RTT' AS Source,
--	CAST(r.refrl_refno AS VARCHAR(20)) AS ItemIdentifier,
--	r.pasid AS LocalPatientIdentifier,
--	NULLIF(RTRIM(p.nhs_identifier),'') AS NHSNumber,
--	NULL AS NHSNumberStatus,
--	p.forename AS Forenames,
--	p.surname AS Surname,
--	dttm_of_birth AS DateOfBirth,
--	NULL AS Address,
--	NULL AS Postcode,
--	NULL AS RegisteredPractice,
--	NULL AS Sex,
--	NULL AS EthnicGroup,
--	cons_code AS ConsultantCode,
--	consultant AS Consultant,
--	s.main_ident AS SpecialtyCode,
--	r.specialty AS Specialty,
--	--'' AS SuspectedTumourSite,
--	r.start AS DateOnList,
--	r.booked_dttm AS TCIDate,
--	--'' AS Referrer,
--	NULLIF(RTRIM(r.priority),'') AS Priority,
--	NULL AS PriorityOfReferral,
--	NULL AS SuspectedTumourSite,
--	NULL AS ReferralSource,
--	NULL AS ReferralSourceLocalName,
--	NULL AS ReferralSourceMainName,
--	NULL AS Comments,
--	GetDate() AS RunDate,
--	'Y' AS AddToTracker
--FROM
--	[NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.rtt_refs r
--	join [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.patients as p on r.pasid = p.pasid
--	join [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.specialties s on s.description = r.specialty
--WHERE
--	Priority='High Risk ? Cancer' AND
--	status='PO'


--SELECT * FROM @Cancer_Data_Tracker
--RETURN






UPDATE
	@Cancer_Data_Tracker
SET
	LocalPatientIdentifier=NHSNumber
WHERE
	LocalPatientIdentifier IS NULL AND
	NHSNumber IS NOT NULL

--Update the suspected tumour sites based on the specialty or, in the case of General Surgery, the consultant
UPDATE
	@Cancer_Data_Tracker
SET
	SuspectedTumourSite=S.SuspectedTumourSite
FROM
	@Cancer_Data_Tracker T
	INNER JOIN @STS_Specialty S ON T.Area=S.Area AND T.Source=S.Source AND S.SpecialtyCode=
		CASE 
			WHEN T.Source='RTT' THEN LEFT(T.SpecialtyCode,3)
			WHEN T.Source='Radis' THEN T.SpecialtyCode
		END

--Update the suspected tumour site based on the consultant (general surgery)
UPDATE
	@Cancer_Data_Tracker
SET
	SuspectedTumourSite=C.SuspectedTumourSite
FROM
	@Cancer_Data_Tracker T
	INNER JOIN @STS_Consultant C ON 
		T.Area=C.Area AND 
		T.Source=C.Source AND 
		(LEFT(T.SpecialtyCode,3)='100' OR T.SpecialtyCode IN('GS','GSUR','SURG')) AND 
		T.ConsultantCode=C.ConsultantCode AND
		C.Specialty='GeneralSurgery'

--Update the suspected tumour site based just on the consultant
UPDATE
	@Cancer_Data_Tracker
SET
	SuspectedTumourSite=C.SuspectedTumourSite
FROM
	@Cancer_Data_Tracker T
	INNER JOIN @STS_Consultant C ON 
		T.Area=C.Area AND 
		T.Source=C.Source AND 
		(LEFT(T.SpecialtyCode,3)='300' OR T.SpecialtyCode IN('GM','GMED','MED')) AND
		T.ConsultantCode=C.ConsultantCode AND
		C.Specialty IN('Gastro','Respiratory','Other')
--select distinct consultant,consultantcode,Area,specialtycode,Specialty from Cancer_Data_SCP where ConsultantCode in (
----'AB3','AB3','IAF','IAF','RCE','RCE','HY2','HY2','ZM2','ZM2','DM5','DM5','SA1','SA1','RACP','RACP','AHAH','AHAH'--,--Central
----'C6045380','G9301016','SUTTJ','C6162480','RSN','C3131242','EVANR','RCE','C6026065','SMMA','C6055583','RBR1','C6060957','THAHA','C6074925','KILC','C4336323','ELGHES','C7015016','COM1','C2489188','BATEA','C5203268','MYG'--,--West
--'TM','MATH','PG','GEP','HK','KHH','SRV','VENU','NAM','MCAN','JPK','KILBJ','SDY','DYERS','SEE NOTES','SEE NOTES','MS','STEM','EBR','BROE'--East
--)
--order by specialty,ConsultantCode


--26 June 2020 at the request of Harriet Rees
--The below should really go in the main lookups above but quick fix
--(they're both for pooled waiting lists)
--5 March 2021 - at the request of Harriet Rees the gastro entry changed to upper gi
UPDATE
	@Cancer_Data_Tracker
SET
	SuspectedTumourSite='Upper Gastrointestinal'
WHERE
	Area='West' AND
	Source='RTT' AND
	LEFT(SpecialtyCode,3)='301' AND
	ConsultantCode='C9999301'

UPDATE
	@Cancer_Data_Tracker
SET
	SuspectedTumourSite='Lower Gastrointestinal'
WHERE
	Area='West' AND
	Source='RTT' AND
	LEFT(SpecialtyCode,3)='100' AND
	ConsultantCode='C9999100'


UPDATE
	@Cancer_Data_Tracker
SET
	SuspectedTumourSite='Other'
WHERE
	NULLIF(RTRIM(SuspectedTumourSite),'') IS NULL

UPDATE
	@Cancer_Data_Tracker
SET
	TCIDate=NULL
WHERE
	TCIDate='1 JANUARY 1900'


UPDATE
	@Cancer_Data_Tracker
SET
	ReferralSourceLocalName=RS.LocalName,
	ReferralSourceMainName=RS.Name
FROM
	@Cancer_Data_Tracker CT
	INNER JOIN Foundation.dbo.PAS_Ref_ReferralSource RS ON 
		CT.Area=RS.Area AND
		RS.Source IN('WPAS','Myrddin') AND --Radis isn't currently in the ReferralSource table
		CT.ReferralSource=RS.LocalCode





--So now we've got the data as we need it we need to further refine it by getting distinct records
--As we'll get duplicate records from Radis anyway and also duplicates from Radis and RTT for patients with duplicate suspected tumour sites 
--(ie, the same patient being identified with the same suspected tumour site in Radis and RTT)
/* * * *
CHANGE REQUESTED
From Caroline Wiliams email 4 March 2021
still only take the first record if the duplicate records are from different sources (ie RADIS and RTT) but if the duplicate records are both from RTT we would like both
1 April 2021 - had Teams chat with CW to talk through how this would affect the process and agreed that we are now adding all RTT records (with their own date on list etc, not the min(dateonlist))
Any Radis records which don't match on Area,CRN and STS will then be added
* * * */
--ORIGINAL
--INSERT INTO Cancer_Data_Tracker(Area,LocalPatientIdentifier,SuspectedTumourSite,RunDate,AddToTracker)
--SELECT DISTINCT Area,LocalPatientIdentifier,SuspectedTumourSite,RunDate,AddToTracker FROM @Cancer_Data_Tracker WHERE AddToTracker='Y' 
--ORDER BY Area,LocalPatientIdentifier
--6537

--('G143838','G228858','G265157','G307201','G366549')

--Get the RTT records first using Area,LPI,STS and referral date - that gives us the distinct rtt referrals
--Now add the radis records based on Area,LPI and STS only, so if they already exist as an RTT entry then don't add them - then update the referral date
INSERT INTO Foundation.dbo.Cancer_Data_Tracker(Area,LocalPatientIdentifier,SuspectedTumourSite,ReferralSentDate,DateOnList,Source,RunDate,AddToTracker)
SELECT DISTINCT Area,LocalPatientIdentifier,SuspectedTumourSite,ReferralSentDate,DateOnList,Source,RunDate,AddToTracker 
FROM @Cancer_Data_Tracker 
WHERE AddToTracker='Y' AND Source='RTT'
UNION ALL
SELECT DISTINCT C1.Area,C1.LocalPatientIdentifier,C1.SuspectedTumourSite,C1.ReferralSentDate,C1.DateOnList,C1.Source,C1.RunDate,C1.AddToTracker 
FROM @Cancer_Data_Tracker C1
LEFT JOIN @Cancer_Data_Tracker C2 ON C1.Area=C2.Area AND C1.LocalPatientIdentifier=C2.LocalPatientIdentifier AND C1.SuspectedTumourSite=C2.SuspectedTumourSite AND C2.Source='RTT' AND C2.AddToTracker='Y'
WHERE C1.AddToTracker='Y' AND C1.Source='Radis' AND C2.Area IS NULL AND C2.LocalPatientIdentifier IS NULL AND C2.SuspectedTumourSite IS NULL
ORDER BY Area,LocalPatientIdentifier
--6585

--OR generate the whole distinct records in one go, we end up with a few extra
--INSERT INTO Cancer_Data_Tracker
--SELECT DISTINCT * FROM @Cancer_Data_Tracker WHERE AddToTracker='Y' AND Source='RTT'
--UNION ALL
--SELECT DISTINCT C1.*
--FROM @Cancer_Data_Tracker C1
--LEFT JOIN @Cancer_Data_Tracker C2 ON C1.Area=C2.Area AND C1.LocalPatientIdentifier=C2.LocalPatientIdentifier AND C1.SuspectedTumourSite=C2.SuspectedTumourSite AND C2.Source='RTT' and C2.AddToTracker='Y'
--WHERE C1.AddToTracker='Y' AND C1.Source='Radis' AND C2.Area IS NULL AND C2.LocalPatientIdentifier IS NULL AND C2.SuspectedTumourSite IS NULL
--ORDER BY Area,LocalPatientIdentifier
--6591	


--Area,LocalPatientIdentifier,SuspectedTumourSite,RunDate,AddToTracker
--Area,LocalPatientIdentifier,SuspectedTumourSite,DateOnList,Source,RunDate,AddToTracker

--Now we need to update those distinct records with the rest of the data
--In some cases it will matter which record we use from the original dataset but some it won't
UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	--Source=O.Source,
	ItemIdentifier=O.ItemIdentifier,
	Forenames=O.Forenames,
	Surname=O.Surname,
	DateOfBirth=O.DateOfBirth,
	Address=O.Address,
	Postcode=O.Postcode,
	Sex=O.Sex,
	RegisteredPractice=O.RegisteredPractice,
	ConsultantCode=O.ConsultantCode,
	Consultant=O.Consultant,
	SpecialtyCode=O.SpecialtyCode,
	Specialty=O.Specialty,
	--DateOnList=(SELECT MIN(DateOnList) FROM @Cancer_Data_Tracker innerO WHERE innerO.LocalPatientIdentifier=O.LocalPatientIdentifier AND innerO.SuspectedTumourSite=O.SuspectedTumourSite),
	--TCIDate=(SELECT MIN(TCIDate) FROM @Cancer_Data_SCP innerO WHERE innerO.LocalPatientIdentifier=O.LocalPatientIdentifier AND innerO.SuspectedTumourSite=O.SuspectedTumourSite AND innerO.TCIDate>=O.DateOnList),
	TCIDate=(SELECT MIN(TCIDate) FROM @Cancer_Data_Tracker innerO WHERE innerO.LocalPatientIdentifier=O.LocalPatientIdentifier AND innerO.SuspectedTumourSite=O.SuspectedTumourSite AND innerO.TCIDate>=CAST(GETDATE() AS DATE)),
	Priority=O.Priority,
	ReferralSource=O.ReferralSource,
	ReferralSourceLocalName=O.ReferralSourceLocalName,
	ReferralSourceMainName=O.ReferralSourceMainName,
	PriorityOfReferral=
		CASE
			WHEN
				(O.Area IN('Central','East') AND O.Source='RTT') AND
				O.ReferralSourceMainName IN('Referral from General Medical Practitioner','General Dental Practitioner','Referral from an Optometrist') THEN 'USC'
			WHEN
				(O.Area ='West' AND O.Source='RTT') AND
				O.ReferralSourceMainName IN('General Practitioner','Dentist') THEN 'USC'
			ELSE
				'NUSC'
		END,
	SourceOfSuspicion=
		CASE
			WHEN
				(O.Area IN('Central','East') AND O.Source='RTT') AND
				O.ReferralSourceMainName IN('Referral from General Medical Practitioner','General Dental Practitioner','Referral from an Optometrist') THEN '1 - Referral from GP'
			WHEN
				(O.Area ='West' AND O.Source='RTT') AND
				O.ReferralSourceMainName IN('General Practitioner','Dentist') THEN '1 - Referral from GP'
			ELSE
				NULL
		END,
	SourceOfCancerReferral=
		CASE
			WHEN
				(O.Area IN('Central','East') AND O.Source='RTT') AND
				O.ReferralSourceMainName IN('Referral from General Medical Practitioner','General Dental Practitioner','Referral from an Optometrist') THEN '3 - Referral from a General Medical Practitioner'
			WHEN
				(O.Area ='West' AND O.Source='RTT') AND
				O.ReferralSourceMainName IN('General Practitioner','Dentist') THEN '3 - Referral from a General Medical Practitioner'
			ELSE
				NULL
		END
FROM
	Foundation.dbo.Cancer_Data_Tracker C
	INNER JOIN @Cancer_Data_Tracker O ON 
		C.Area=O.Area AND
		C.LocalPatientIdentifier=O.LocalPatientIdentifier AND 
		C.SuspectedTumourSite=O.SuspectedTumourSite AND
		C.AddToTracker=O.AddToTracker AND
		C.Source=O.Source AND 
		C.DateOnList=O.DateOnList
		--O.DateOnList=(SELECT MIN(DateOnList) FROM @Cancer_Data_SCP innerO WHERE innerO.LocalPatientIdentifier=O.LocalPatientIdentifier AND innerO.SuspectedTumourSite=O.SuspectedTumourSite)

UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NextStage='New Outpatient'
WHERE
	PriorityOfReferral='USC'

UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NHSNumber=O.NHSNumber
FROM
	Foundation.dbo.Cancer_Data_Tracker C
	INNER JOIN @Cancer_Data_Tracker O ON C.LocalPatientIdentifier=O.LocalPatientIdentifier
WHERE
	O.NHSNumber IS NOT NULL

--Added to the main query above
--UPDATE
--	Cancer_Data_SCP
--SET
--	TCIDate=(SELECT MIN(TCIDate) FROM @Cancer_Data_SCP innerO WHERE innerO.LocalPatientIdentifier=O.LocalPatientIdentifier AND innerO.SuspectedTumourSite=O.SuspectedTumourSite AND innerO.TCIDate>=O.DateOnList)	
--FROM
--	Cancer_Data_SCP C
--	INNER JOIN @Cancer_Data_SCP O ON C.LocalPatientIdentifier=O.LocalPatientIdentifier AND C.SuspectedTumourSite=O.SuspectedTumourSite 

UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NHSNumberStatus=X.NHSNumberStatus,
	EthnicGroup=X.Ethnicity,
	RegisteredPractice=COALESCE(CT.RegisteredPractice,X.RegisteredPractice)
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN 
		OPENQUERY([WPAS_CENTRAL_NEWPORT],'
			SELECT DISTINCT
				P.NHS AS NHSNumber,
				P.CASENO AS LocalPatientIdentifier,
				NULLIF(P.CERTIFIED,'''') AS NHSNumberStatus,
				COALESCE(NULLIF(TRIM(P.ETHNIC_ORIGIN),''''),''ZZ'') AS Ethnicity,
				P.GP_PRACTICE AS RegisteredPractice
			FROM 
				PATIENT P
		')X ON
			CT.NHSNumber=X.NHSNumber AND CT.Area='Central'
			

UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NHSNumberStatus=X.NHSNumberStatus,
	EthnicGroup=X.Ethnicity,
	RegisteredPractice=COALESCE(CT.RegisteredPractice,X.RegisteredPractice)
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN 
		OPENQUERY(WPAS_EAST,'
			SELECT DISTINCT
				P.NHS AS NHSNumber,
				P.CASENO AS LocalPatientIdentifier,
				NULLIF(P.CERTIFIED,'''') AS NHSNumberStatus,
				COALESCE(NULLIF(TRIM(P.ETHNIC_ORIGIN),''''),''ZZ'') AS Ethnicity,
				P.GP_PRACTICE AS RegisteredPractice
			FROM 
				PATIENT P
		')X ON 
			CT.NHSNumber=X.NHSNumber AND CT.Area='East'



UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NHSNumberStatus=X.NHSNumberStatus,
	EthnicGroup=X.Ethnicity,
	RegisteredPractice=COALESCE(CT.RegisteredPractice,X.RegisteredPractice)
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN 
		OPENQUERY([WPAS_CENTRAL_NEWPORT],'
			SELECT DISTINCT
				P.NHS AS NHSNumber,
				P.CASENO AS LocalPatientIdentifier,
				NULLIF(P.CERTIFIED,'''') AS NHSNumberStatus,
				COALESCE(NULLIF(TRIM(P.ETHNIC_ORIGIN),''''),''ZZ'') AS Ethnicity,
				P.GP_PRACTICE AS RegisteredPractice
			FROM 
				PATIENT P
		')X ON
			CT.LocalPatientIdentifier=X.LocalPatientIdentifier AND CT.Area='Central' AND CT.NHSNumber IS NULL
			

UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NHSNumberStatus=X.NHSNumberStatus,
	EthnicGroup=X.Ethnicity,
	RegisteredPractice=COALESCE(CT.RegisteredPractice,X.RegisteredPractice)
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN 
		OPENQUERY(WPAS_EAST,'
			SELECT DISTINCT
				P.NHS AS NHSNumber,
				P.CASENO AS LocalPatientIdentifier,
				NULLIF(P.CERTIFIED,'''') AS NHSNumberStatus,
				COALESCE(NULLIF(TRIM(P.ETHNIC_ORIGIN),''''),''ZZ'') AS Ethnicity,
				P.GP_PRACTICE AS RegisteredPractice
			FROM 
				PATIENT P
		')X ON 
			CT.LocalPatientIdentifier=X.LocalPatientIdentifier AND CT.Area='East' AND CT.NHSNumber IS NULL



--GET THE ADDITIONAL PIMS STUFF, SIGH.....
DECLARE 
	@cityp_natgp numeric(10,0),
	@hityp_natnl numeric(10,0),
	@prtyp_gmprc numeric(10,0)

set @cityp_natgp = (	
					select RFVAL_REFNO
					from [7A1AUSRVIPMSQL].[iPMProduction].dbo.REFERENCE_VALUES
					where 
						RFVDM_CODE='CITYP'
					and MAIN_CODE='NATGP'
					and isnull(ARCHV_FLAG,'N')='N'
					)

set @hityp_natnl = (	
					select RFVAL_REFNO
					from [7A1AUSRVIPMSQL].[iPMProduction].dbo.REFERENCE_VALUES
					where 
						RFVDM_CODE='HITYP'
					and MAIN_CODE='NATNL'
					and isnull(ARCHV_FLAG,'N')='N'
					)
	
set @prtyp_gmprc = (	
					select RFVAL_REFNO
					from [7A1AUSRVIPMSQL].[iPMProduction].dbo.REFERENCE_VALUES
					where 
						RFVDM_CODE='PRTYP'
					and MAIN_CODE='GMPRC'
					and isnull(ARCHV_FLAG,'N')='N'
					)

-- ****************************************************************************************************
-- Create table and extract non activity date dependent data from Pims
-- ****************************************************************************************************

DECLARE @PimsResults AS TABLE(
	LocalPatientIdentifier	VARCHAR(30),
	NHSNumber				VARCHAR(30),
	Gender					VARCHAR(10),
	Address					VARCHAR(500),
	Postcode				VARCHAR(10),
	RegisteredPractice		VARCHAR(20),
	PatientRefNo			VARCHAR(50),
	ReferralDate			DATE,
	NHSNumberStatus			VARCHAR(5),
	EthnicCode				VARCHAR(10),
	EthnicMainCode			VARCHAR(10),
	Ethnicity				varchar(50)
)

INSERT INTO @PimsResults(
	LocalPatientIdentifier,
	NHSNumber,
	Gender,
	PatientRefNo,
	ReferralDate,
	NHSNumberStatus,
	EthnicCode,
	EthnicMainCode,
	Ethnicity 
)

SELECT 
	P.PASID,
	P.NHS_IDENTIFIER,
	S.MAIN_CODE,
	P.PATNT_REFNO,
	ct.DateOnList,
	NNNTS_code,	
	ethgr_refno,
	ISNULL(RV.MAIN_CODE,'Z'),
	RV.DESCRIPTION


FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.PATIENTS P ON CT.LocalPatientIdentifier = P.PASID AND CT.Area='West'  --getting 
	LEFT JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.REFERENCE_VALUES S ON P.SEXXX_REFNO = S.RFVAL_REFNO
	LEFT JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.[REFERENCE_VALUES] RV ON ethgr_refno=RV.rfval_refno and RV.RFVDM_CODE ='ETHGR'


-- ****************************************************************************************************
-- Update address details
-- ****************************************************************************************************

UPDATE 
	@PimsResults
SET
	Address = ISNULL(A.LINE1,'')+', '+ISNULL(A.LINE2,'')+', '+ISNULL(A.LINE3,'')+', '+ISNULL(A.LINE4,''),
	Postcode=A.PCODE
FROM
	@PimsResults R
	INNER JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.ADDRESS_ROLES AR ON R.PatientRefNo=	AR.PATNT_REFNO
	INNER JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.ADDRESSES A ON AR.ADDSS_REFNO = A.ADDSS_REFNO
WHERE
	AR.ROTYP_CODE = 'HOME' AND
	A.ADTYP_CODE = 'POSTL' AND 
	CAST(R.ReferralDate AS DATE) BETWEEN CAST(AR.START_DTTM AS DATE) AND ISNULL(CAST(AR.END_DTTM AS DATE),CAST(R.ReferralDate AS DATE)) AND
	ISNULL(AR.ARCHV_FLAG,'N')='N' AND
	ISNULL(A.ARCHV_FLAG,'N')='N'

-- ****************************************************************************************************
-- Update GP details
-- ****************************************************************************************************

UPDATE
	@PimsResults
SET
	RegisteredPractice = heorg.identifier
FROM
	@PimsResults R
	INNER JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.patient_prof_carers patproca ON R.PatientRefNo = patproca.PATNT_REFNO
	INNER JOIN [7A1AUSRVIPMSQL].[iPMProduction].dbo.health_organisation_ids heorg ON patproca.HEORG_REFNO = heorg.HEORG_REFNO
WHERE
	patproca.PRTYP_REFNO = @prtyp_gmprc AND
	heorg.HITYP_REFNO = @hityp_natnl AND
	CAST(R.referralDate AS DATE) BETWEEN CAST(patproca.START_DTTM  AS DATE) AND ISNULL(CAST(patproca.END_DTTM AS DATE),CAST(R.ReferralDate AS DATE)) AND
	CAST(R.ReferralDate  AS DATE) BETWEEN CAST(heorg.START_DTTM  AS DATE) AND ISNULL(CAST(heorg.END_DTTM AS DATE),CAST(R.ReferralDate AS DATE)) AND
	ISNULL(patproca.ARCHV_FLAG,'N')='N' AND
	ISNULL(heorg.ARCHV_FLAG,'N')='N'



--AND NOW WE CAN ADD THESE FIELDS TO THE MAIN RESULT SET
UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NHSNumberStatus=PR.NHSNumberStatus,
	Address=LEFT(PR.Address,175),
	Postcode=PR.Postcode,
	Sex=PR.Gender,
	EthnicGroup=PR.EthnicMainCode,
	RegisteredPractice=LEFT(PR.RegisteredPractice,6)
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN @PimsResults PR ON CT.LocalPatientIdentifier=PR.LocalPatientIdentifier AND CT.Area='West'


--Update the ethnic codes from the systems to what the Sharepoint list is expecting
UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	EthnicDescription=E.MapTo
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	INNER JOIN @EthnicMap E ON CT.EthnicGroup=E.Code AND CT.Area=E.Area

--Update the sex codes from the systems to what the Sharepoint list is expecting
UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	Sex=
		CASE Sex
			WHEN 'F' THEN '2 - Female'
			WHEN 'M' THEN '1 - Male'
			ELSE '9 - Not Specified'
		END

--THIS SECTION REMOVED WHEN THIS SCRIPT BECAME CT_GETDATA AND STOPPED JUST GETTING FOR SCP
--Further update to the AddToTracker flag
--UPDATE
--	Cancer_Data_SCP
--SET
--	AddToTracker='N'
--WHERE
--	Source='RTT' AND 
--	(
--		(
--			ReferralSource IN ('1','2') AND
--			RIGHT(SpecialtyCode,3)='999'
--		)
--		OR
--			ReferralSource='G'
--	)


--Don't add patients already known to Oncology to the tracker
UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	AddToTracker='N'
WHERE
	Source='Radis' AND 
		(SpecialtyCode IN ('ONC','ONCO')) --OR
		--(SpecialtyCode='PAED' AND Area='Central')
	--Waiting on Katie to confirm the paed thing - 
	--A further question to ask is about that West have left Paeds in but Central want it taking out....
	--Take out the paed central rule of this statement (agreed by Caroline and Katie 16 Jan 2020)

--Update the NextStage field to 'Diagnostic - Radiology' where the Source=Radis
--Am doing this here as if it changes then it's easier to remove/change
UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	NextStage='Diagnostic - Radiology'
WHERE
	Source='Radis'



UPDATE
	Foundation.dbo.Cancer_Data_Tracker
SET
	SpecialtyDerived=ISNULL(S.Specialty,'Not mapped')
FROM
	Foundation.dbo.Cancer_Data_Tracker CT
	LEFT JOIN @Specialty S ON CT.Area=S.Area AND CT.Source=S.Source AND CT.SpecialtyCode=S.SpecialtyCode


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
DONE
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
--SELECT distinct Area,Source,ReferralSource,ReferralSourceLocalName,ReferralSourceMainName FROM Cancer_Data_Tracker order by area, source
--SELECT DISTINCT SpecialtyCode,Specialty,Area,Source FROM Cancer_Data_Tracker order by area, source
--select 'Finished at '+CAST(GetDate() AS VARCHAR(50))
--SELECT * FROM Cancer_Data_Tracker WHERE ReferralSentDate IS NULL
--SELECT * FROM Cancer_Data_Tracker WHERE ConsultantCode='RF2'
--select * from Foundation.dbo.Cancer_Data_Tracker where source='RTT' order by tcidate
--SELECT DISTINCT PriorityOfReferral FROM Cancer_Data_Tracker CT order by PriorityOfReferral
--LEFT JOIN @EthnicMap E ON CT.Area=E.Area AND CT.EthnicGroup=E.Code
--WHERE E.MapTo IS NULL

--SELECT COUNT(*),Area,AddToTracker FROM Cancer_Data_SCP WHERE Source='RTT'  GROUP BY Area,AddToTracker ORDER BY Area,AddToTracker --AND Area='Central'

--All details taken from the record which has the earliest dateonlist except for the following:
--nhsnuMBER - FIRST WHERE NOT NULL, REGARDLESS OF SOURCE
--TCIDate = First tcidate after todays date, REGARDLESS OF SOURCE


--SELECT
--	COUNT(*),LocalPatientIdentifier 
--FROM
--	@Cancer_Data_SCP
--GROUP BY
--	LocalPatientIdentifier
--HAVING COUNT(*)>1
--ORDER BY
--	Count(*) desc

--SELECT distinct specialtycode,specialty FROM Cancer_Data_SCP order by specialty, SpecialtyCode


	

--LEFT JOIN Foundation.dbo.PAS_Ref_ReferralSource RS ON 
--		CT.Area=RS.Area AND
--		RS.Source IN('WPAS','Myrddin','Pims') AND --Radis isn't currently in the ReferralSource table
--		CT.ReferralSource=RS.LocalCode
--WHERE 
	--CT.Source='RTT'
	--AND 
--	CT.ReferralSourceLocalName IS NULL
--ORDER BY CT.Area,Source,referralSource,CT.ReferralSourceLocalName,ReferralSourceMainName --WHERE Source='Radis'
--where

--	Area='West' AND
--	Source='RTT' AND
--	LEFT(SpecialtyCode,3)='301' AND
--	ConsultantCode='C9999301'

--WHERE	AddToTracker='Y'--ReferralSource='G'
--SELECT * FROM Cancer_Data_SCP WHERE LocalPatientIdentifier ='G044554'

--SELECT COUNT(*),Area,Source,AddToTracker FROM Cancer_Data_Tracker GROUP BY Area,Source,AddToTracker
--ORDER BY Area,Source,AddToTracker


--NOTES FOR THE CHANGE
--CAN DELETE THESE WHEN WE'RE DONE
--THESE ARE THE FIELDS WE NEED TO ADD
--FROM AN EMAIL FROM CAROLINE ON FRIDAY 6 NOVEMBER 2020
--NHS number – add to column called NHS Number																		- ALREADY IN
--NHS number status indicator – add to column called NHS Number Status												- 
--Address – add to column called Patients Address																	-	
--Postcode – add to column called Patients Postcode																	-
--Code of registered GP practice – add to column called Code of Registered GP Practice								-
--Sex (at birth) – add to column called Sex (At Birth) with drop down options 1-Male, 2-Female, 9-Not Specified		-
--Ethnic Group – add to column called Ethnic Group with drop down options A-Z which I hope are the same as on WPAS?	-


--RTT STUFF - FOR REFERENCE
--East
--SELECT TOP (100) * FROM [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.East_WPAS_RTT

--Central
--SELECT TOP 100 * FROM [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.WPAS_RTT_SP

--West
--SELECT TOP (100) * FROM [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.rtt_refs r
--	join [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.patients as p on r.pasid = p.pasid
--	join [NWWINTEGRATION.CYMRU.NHS.UK].[RTTdata].dbo.specialties s on s.description = r.specialty


	
   
END

GO
