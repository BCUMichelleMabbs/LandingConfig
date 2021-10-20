SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_PAS_Ref_Session]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	MainCode		VARCHAR(20),
	Name			VARCHAR(100),
	LocalCode		VARCHAR(20),
	LocalName		VARCHAR(100),
	Source			VARCHAR(8),
	Area			varchar(10)
)

INSERT INTO @Results(LocalCode,LocalName,Source, Area)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT DISTINCT
		SESSIONKEY AS LocalCode,
		NAME AS LocalName,
		''WPAS'' AS Source,
		''Central''  as Area
	 FROM 
		SESSIONS
	')


INSERT INTO @Results(LocalCode,LocalName,Source, Area)	
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT DISTINCT
		SESSIONKEY AS LocalCode,
		NAME AS LocalName,
		''Myrddin'' AS Source,
		''East'' as Area
	 FROM 
		SESSIONS
	')

;with cte as (
	select distinct 
		sps.code as LocalCode
		,CASE WHEN sps.code like 'C-%' then sps.code else sps.DESCRIPTION END as LocalName
		,'PiMS' as Source
		,'West' as Area
		,Row_Number() over(Partition by sps.code order by sps.create_dttm desc) RN
	from [7A1AUSRVIPMSQL].[iPMProduction].[dbo].SERVICE_POINT_SESSIONS sps
		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].SERVICE_POINTs sp
		on sp.SPONT_REFNO = sps.SPONT_REFNO 
		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].Specialties spec
		on spec.SPECT_REFNO = sps.SPECT_REFNO 
		join [7A1AUSRVIPMSQL].[iPMProduction].[dbo].prof_Carers pro
		on pro.PROCA_REFNO = sp.PROCA_REFNO 
	where ISNULL(sps.archv_flag,'N') = 'N'
		and sps.template_flag = 'Y'
) 
INSERT INTO @Results (LocalCode,LocalName,Source, Area)	
select LocalCode,LocalName,Source , Area
from cte where RN = 1




	UPDATE @Results SET MainCode =
	case 

			when LocalName like '%Adhoc%' then 'Adhoc'
			when LocalName like '%Ad hoc%' then 'Adhoc'
			when LocalName like '%Ad-hoc%' then 'Adhoc'

			when LocalName like '%WLI%' then 'Adhoc'
			when LocalName like '%W.L.I%' then 'Adhoc'
			when LocalName like '%Waiting%' then 'Adhoc'
			when LocalName like '%Waitining%' then 'Adhoc'
			
			when LocalName like '%200%' then 'Adhoc'
			when LocalName like '%201%' then 'Adhoc'
			when LocalName like '%.20%' then 'Adhoc'
			when LocalName like '% 20%' then 'Adhoc'
			when LocalName like '%/08%' then 'Adhoc'
			when LocalName like '%.08%' then 'Adhoc'
			when LocalName like '%/09%' then 'Adhoc'
			when LocalName like '%.09%' then 'Adhoc'
			when LocalName like '% 09%' then 'Adhoc'
			when LocalName like '%/10%' then 'Adhoc'
			when LocalName like '%.10%' then 'Adhoc'
			when LocalName like '%10 %' then 'Adhoc'
			when LocalName like '% 10%' then 'Adhoc'
			when LocalName like '%.11%' then 'Adhoc'
			when LocalName like '%. 11%' then 'Adhoc'
			when LocalName like '%.12%' then 'Adhoc'
			when LocalName like '%/12%' then 'Adhoc'
			when LocalName like '%/13%' then 'Adhoc'
			when LocalName like '%.13%' then 'Adhoc'
			when LocalName like '% 13%' then 'Adhoc'
			when LocalName like '%13 %' then 'Adhoc'
			when LocalName like '%300713%' then 'Adhoc'
			when LocalName like '%.14%' then 'Adhoc'
			when LocalName like '%/14%' then 'Adhoc'
			when LocalName like '% 14%' then 'Adhoc'
			when LocalName like '%.15%' then 'Adhoc'
			when LocalName like '%/15%' then 'Adhoc'
			when LocalName like '% 15%' then 'Adhoc'
			when LocalName like '%.16%' then 'Adhoc'
			when LocalName like '%/16%' then 'Adhoc'
			when LocalName like '% 16%' then 'Adhoc'
			when LocalName like '%.17%' then 'Adhoc'
			when LocalName like '%/17%' then 'Adhoc'
			when LocalName like '%.18%' then 'Adhoc'
			when LocalName like '%/18%' then 'Adhoc'
			when LocalName like '%.19%' then 'Adhoc'
			when LocalName like '%/19%' then 'Adhoc'
			when LocalName like '% 19%' then 'Adhoc'

			when LocalName like '%one off%' then 'Adhoc'
			when LocalName like '%out of regular%' then 'Adhoc'
			when LocalName like '%outside of regular%' then 'Adhoc'
			when LocalName like '%outside regular%' then 'Adhoc'
			when LocalName like '%Temporary%' then 'Adhoc'
			when LocalName like '%Additional%' then 'Adhoc'
			when LocalName is null then 'Adhoc'

			when LocalName like '%January%' then 'Adhoc'
			when LocalName like '%February%' then 'Adhoc'
			when LocalName like '%March%' then 'Adhoc'
			when LocalName like '%April%' then 'Adhoc'
			when LocalName like '%May%' then 'Adhoc'
			when LocalName like '%June%' then 'Adhoc'
			when LocalName like '%July%' then 'Adhoc'
			when LocalName like '%Aug%' then 'Adhoc'
			when LocalName like '%Sept%' then 'Adhoc'
			when LocalName like '%Oct %' then 'Adhoc'
			when LocalName like '%Nov %' then 'Adhoc'
			when LocalName like '%Dec %' then 'Adhoc'

			when LocalName like '%Consent%' then 'Consent'

			

			when LocalName like '%Community echo%' then 'Regular'
			when LocalName like '%Community centre%' then 'Regular'
			when LocalName like '%Community heart%' then 'Regular'
			when LocalName like '%Community IV Suite%' then 'Regular'

			when LocalName like '%Home%' then 'Home Visit'
			when LocalName like '%HV %' then 'Home Visit'
			when LocalName like '%HV-%' then 'Home Visit'
			when LocalName like '%Community%' then 'Home Visit'
			when LocalName like '%Com Visit%' then 'Home Visit'
			when LocalName like '%Comm Visit%' then 'Home Visit'

			when LocalName like '%Haemophilia%' then 'Regular'
			when LocalName like '%MOP%' then 'Minor Ops'
			when LocalName like '%Minor Op%' then 'Minor Ops'
			when LocalName like '%Theatre%' then 'Minor Ops'

			when LocalName like '%Pre Op%' then 'Pre-Op Assessment'
			when LocalName like '%PreOp%' then 'Pre-Op Assessment'
			when LocalName like '%Pre-Op%' then 'Pre-Op Assessment'
			when LocalName like '%Pre- Op%' then 'Pre-Op Assessment'
			when LocalName like '%Pre -Op%' then 'Pre-Op Assessment'
			when LocalName like '%PRE - OP%' then 'Pre-Op Assessment'
			when LocalName like '%Poac%' then 'Pre-Op Assessment'

			when LocalName like '%Private Hosp%' then 'Private Hospital'
			when LocalName like '%Nuffield%' then 'Private Hospital'
			when LocalName like '%Private Hosp%' then 'Private Hospital'
			when LocalName like '%Yale%' then 'Private Hospital'
			when LocalName like '%Spire%' then 'Private Hospital'
			when LocalName like '%Shrewsbury%' then 'Private Hospital'
			when LocalName like '%Murrayfield%' then 'Private Hospital'

			when LocalName like '%Private Patient%' then 'Private Patient'
			when LocalName like '% PP %' then 'Private Patient'
			when LocalName like '%-PP%' then 'Private Patient'
			
			when LocalName like '%Ward-%' then 'Ward'
			when LocalName like '% Ward%' then 'Ward'
			when LocalName like '% Ward %' then 'Ward'
			when LocalName like '%Wards %' then 'Ward'
			when LocalName like '%Ward Disch%' then 'Ward'
			when LocalName like '%Pasteur%' then 'Ward'
			when LocalName like '%Day Case%' then 'Ward'
			when LocalName like '%IV Suite%' then 'Ward'
			when LocalName like '%Day Unit%' then 'Ward'
			when LocalName like '%MDU%' then 'Ward'
			when LocalName = 'Ward' then 'Ward'

			when LocalName like '%TEL%' then 'Attend Anywhere'
			when LocalName like '%VID%' then 'Attend Anywhere'
			when LocalName like '%Telephone%' then 'Attend Anywhere'

			when LocalName like '%OBD %' then 'None Face to Face'
			when LocalName like '% OBD%' then 'None Face to Face'
			when LocalName = 'OBD' then 'None Face to Face'
			when LocalName like '%Office%' then 'None Face to Face'
			

			when LocalName = 'Exercise Test Clinic' then 'Regular'
			when LocalName = 'SPIROMETRY TESTING CLINIC' then 'Regular'
			when LocalName = 'Patch Test Clinic' then 'Regular'
			when LocalName = 'Lung Function Test Clinic' then 'Regular'
			when LocalName = 'Prink testing' then 'Regular'


			when LocalName like '%Test Liz%' then 'System Testing'
			when LocalName like '%Test Cl%' then 'System Testing'
			when LocalName like '%Testing%' then 'System Testing'
			when LocalName like '%Dummy%' then 'System Testing'
			when LocalName like '%Do Not%' then 'System Testing'
			when LocalName like '%Delet%' then 'System Testing'
			when LocalName like '%Dunny%' then 'System Testing'
			when LocalName like '%Martin test%' then 'System Testing'
			when LocalName like '%test test%' then 'System Testing'

			when LocalName like '%test%' then 'Regular'
			when LocalName like '%1st%' then 'Regular'
			when LocalName like '%2nd%' then 'Regular'
			when LocalName like '%3rd%' then 'Regular'
			when LocalName like '%4th%' then 'Regular'
			when LocalName like '%5th%' then 'Regular'
			when LocalName like '%Week%' then 'Regular'
			when LocalName like '%Month%' then 'Regular'
			when LocalName like '%Alt%' then 'Regular'
			when LocalName like '%Wk%' then 'Regular'
			when LocalName like '%all day%' then 'Regular'
			when LocalName like '%allday%' then 'Regular'
			when LocalName like '%Daily%' then 'Regular'
			when LocalName like '%Evening%' then 'Regular'
			when LocalName like '%Morning%' then 'Regular'
			when LocalName like '%afternoon%' then 'Regular'
			when LocalName like '%pm%' then 'Regular'
			when LocalName like '%Mon%'  then 'Regular'
			when LocalName like '%Tue%'  then 'Regular'
			when LocalName like '%Wed%'  then 'Regular'
			when LocalName like '%Thu%'  then 'Regular'
			when LocalName like '%Fri%'  then 'Regular'
			when LocalName like '%Saturday%'  then 'Regular'
			when LocalName like '%-N%'   then 'Regular'
			when LocalName like '%-R%'   then 'Regular'
			when LocalName like '%N/R%'   then 'Regular'
			when LocalName like '%follow%'   then 'Regular'
			when LocalName like '%Review%'   then 'Regular'
			when LocalName like '%am%' then 'Regular'
			when LocalName like '%new%' then 'Regular'
			
			when LocalName like '%extra%'  then 'Regular'
			when LocalName like '%Urgent%' then 'Regular'
			when LocalName like '%USC%' then 'Regular'
			when LocalName like '%group%' then 'Regular'
			when LocalName like '%clinic%' then 'Regular'
			when LocalName like '%Pilot%'   then 'Regular'
			when LocalName like '%Room%'   then 'Regular'


			when LocalName like '%trauma%'  then 'Regular'
			when LocalName like '%emerg%'  then 'Regular'
			when LocalName like '%Rapid Access%' then 'Regular'
			when LocalName like '%ortho%'  then 'Regular'
			when LocalName like '%cardio%'  then 'Regular'
			when LocalName like '%Uro%' then 'Regular'
			when LocalName like '%eye%'  then 'Regular'
			when LocalName like '%oral%'  then 'Regular'
			when LocalName like '%gen surg%'  then 'Regular'
			when LocalName like '%surgical%'  then 'Regular'
			when LocalName like '%paed%'  then 'Regular'
			when LocalName like '%Physio%'  then 'Regular'
			when LocalName like '%Phyio%'  then 'Regular'
			when LocalName like '%Diab%'  then 'Regular'
			when LocalName like '%CAMHS%' then 'Regular'
			when LocalName like '%Podiat%' then 'Regular'
			when LocalName like '%Derm%' then 'Regular'
			when LocalName like '%Psyc%' then 'Regular'
			when LocalName like '%Dent%' then 'Regular'
			when LocalName like '%medic%' then 'Regular'
			when LocalName like '%Gynae%' then 'Regular'
			when LocalName like '%Oncol%' then 'Regular'
			when LocalName like '%General%' then 'Regular'
			when LocalName like '%ENT%' then 'Regular'
			when LocalName like '%Endo%' then 'Regular'
			when LocalName like '%Max%' then 'Regular'
			when LocalName like '%EMI%' then 'Regular'
			when LocalName like '%Pain%' then 'Regular'
			when LocalName like '%Gast%' then 'Regular'
			when LocalName like '%Haem%' then 'Regular'
			when LocalName like '%Obs%' then 'Regular'
			when LocalName like '%Ophth%' then 'Regular'
			when LocalName like '%Opthal%' then 'Regular'
			when LocalName like '%Rheum%' then 'Regular'
			when LocalName like '%Renal%' then 'Regular'
			when LocalName like '%Dial%' then 'Regular'
			when LocalName like '%Rehab%' then 'Regular'
			when LocalName like '%Neph%' then 'Regular'
			when LocalName like '%Occ%' then 'Regular'
			when LocalName like '%Resp%'   then 'Regular'
			when LocalName like '%otology%'   then 'Regular'
			when LocalName like '%Vasc%'   then 'Regular'


			when LocalName like '%Bala%'    then 'Regular'
			when LocalName like '%deeside%'    then 'Regular'
			when LocalName like '%Wxm%'    then 'Regular'
			when LocalName like '%Wrexham%'    then 'Regular'
			when LocalName like '%Aston%'    then 'Regular'
			when LocalName like '%ablett%'    then 'Regular'
			when LocalName like '%Broughton%'    then 'Regular'
			when LocalName like '%Buckley%'    then 'Regular'
			when LocalName like '%Mold%'    then 'Regular'
			when LocalName like '%Flint%'    then 'Regular'
			when LocalName like '%Chirk%'    then 'Regular'
			when LocalName like '%Connah%'    then 'Regular'
			when LocalName like '%Holywell%'    then 'Regular'
			when LocalName like '%Swn%'    then 'Regular'
			when LocalName like '%Plas%'    then 'Regular'
			when LocalName like '%Corwen%'    then 'Regular'
			when LocalName like '%Coed%'    then 'Regular'
			when LocalName like '%Grosvenor%'    then 'Regular'
			when LocalName like '%Ysgol%'    then 'Regular'
			when LocalName like '%YGC%'    then 'Regular'
			when LocalName like '%Clwyd%'    then 'Regular'
			when LocalName like '%LLan%'    then 'Regular'
			when LocalName like '%county hall%'    then 'Regular'
			when LocalName like '%pwll%'    then 'Regular'
			when LocalName like '%Binwydden%'    then 'Regular'
			when LocalName like '%Strath%'    then 'Regular'
			when LocalName like '%Ty %'    then 'Regular'
			when LocalName like '%Bryn%'    then 'Regular'
			when LocalName like '%Crescent%'    then 'Regular'
			when LocalName like '%Hillcrest%'    then 'Regular'
			when LocalName like '%Abergele%'    then 'Regular'
			when LocalName like '%Rhos%'    then 'Regular'
			when LocalName like '%Rhyl%'    then 'Regular'
			when LocalName like '%cab%'    then 'Regular'
			when LocalName like '%overton%'    then 'Regular'
			when LocalName like '%road%'    then 'Regular'
			when LocalName like '%Surgery%'    then 'Regular'
			when LocalName like '%Powys%'    then 'Regular'
			when LocalName like '%Borras%'    then 'Regular'
			when LocalName like '%World%'    then 'Regular'
			when LocalName like '%Dolg%'    then 'Regular'
			when LocalName like '%School%'    then 'Regular'
			when LocalName like '%Hospital%'    then 'Regular'
			when LocalName like '%Colwyn%'    then 'Regular'
			when LocalName like '%Fairholme%'    then 'Regular'
			when LocalName like '%helyg%'    then 'Regular'
			when LocalName like '%Maelor%'    then 'Regular'
			when LocalName like '%prac%'    then 'Regular'
			when LocalName like '%Grove%'    then 'Regular'
			when LocalName like '%Oakleigh%'    then 'Regular'
			when LocalName like '%Cefn%'    then 'Regular'
			when LocalName like '%RJAH%'    then 'Regular'
			when LocalName like '%quay%'    then 'Regular'
			when LocalName like '%Prestatyn%'    then 'Regular'
			when LocalName like '%Glyn%'    then 'Regular'
			when LocalName like '%Mynydd%'    then 'Regular'
			when LocalName like '%Queen%'    then 'Regular'
			when LocalName like '%Royal%'    then 'Regular'
			when LocalName like '%heddfan%'    then 'Regular'
			when LocalName like '%ruabon%'    then 'Regular'
			when LocalName like '%hergest%'    then 'Regular'
			when LocalName like '%llgh%'    then 'Regular'
			when LocalName like '%allt%'    then 'Regular'
			when LocalName like '%doc fic%'    then 'Regular'
			when LocalName like '%alaw%'    then 'Regular'
			

			when LocalName like '%Nurse%'   then 'Regular'
			when LocalName like '%Staff%'   then 'Regular'
			when LocalName like '%Band%'   then 'Regular'
			when LocalName like '%Dr%'   then 'Regular'
			when LocalName like '%Cons%'   then 'Regular'
			when LocalName like '%registrar%'   then 'Regular'
			when LocalName like '%Souza%'   then 'Regular'
			when LocalName like '%SHO%'   then 'Regular'
			when LocalName like '%rota%'   then 'Regular'
			when LocalName like '%senior%'   then 'Regular'
			when LocalName like '%Junior%'   then 'Regular'
			when LocalName like '%Prof%'   then 'Regular'
			when LocalName like '%Mr %'   then 'Regular'
			when LocalName like '%Ms %'   then 'Regular'
			when LocalName like '%Miss%'   then 'Regular'
			when LocalName like '%Specialist%'   then 'Regular'
			when LocalName like '%ashton%'   then 'Regular'
			when LocalName like '%Liaison%'   then 'Regular'
			when LocalName like '%Kumar%'   then 'Regular'
			when LocalName like '%Clerk%'   then 'Regular'
			when LocalName like '%Dawn%'   then 'Regular'
			when LocalName like '%Lewis%'   then 'Regular'
			when LocalName like '%Sing%'   then 'Regular'
			when LocalName like '%Doctor%'   then 'Regular'
			when LocalName like '%Registrar%'   then 'Regular'
			when LocalName like '%Locum%'   then 'Regular'
			when LocalName like '%Thynn%'   then 'Regular'
			when LocalName like '%grade%'   then 'Regular'
			when LocalName like '%gp%'   then 'Regular'
			when LocalName like '%Karayi%'   then 'Regular'

			
			when LocalName like '%aware%'   then 'Regular'
			when LocalName like '%Adult%'   then 'Regular'
			when LocalName like '%Rectal%'   then 'Regular'
			when LocalName like '%Accu%'   then 'Regular'
			when LocalName like '%Acup%'   then 'Regular'
			when LocalName like '%Acne%'   then 'Regular'
			when LocalName like '%Allerg%'   then 'Regular'
			when LocalName like 'Ant%'   then 'Regular'
			when LocalName like '%Smear%'   then 'Regular'
			when LocalName like '%Arrh%'   then 'Regular'
			when LocalName like '%Asthma%'   then 'Regular'
			when LocalName like 'B%' then 'Regular'
			when LocalName like '%Bariatric%'   then 'Regular'
			when LocalName like '%Biopsy%'   then 'Regular'
			when LocalName like '%Care%'   then 'Regular'
			when LocalName like '%Cataract%'   then 'Regular'
			when LocalName like '%Catheter%'   then 'Regular'
			when LocalName like '%Clas%'   then 'Regular'
			when LocalName like '%Cleft%'   then 'Regular'
			when LocalName like '%Colp%'   then 'Regular'
			when LocalName like '%combine%'   then 'Regular'
			when LocalName like '%Cont%'   then 'Regular'
			when LocalName like '%Conn%'   then 'Regular'
			when LocalName like '%cpap%' then 'Regular'
			when LocalName like '%OPD%'   then 'Regular'
			when LocalName like '%Cyst%'   then 'Regular'
			when LocalName like '%crht%'   then 'Regular'
			when LocalName like '%diet%'   then 'Regular'
			when LocalName like '%dise%'   then 'Regular'
			when LocalName like '%dvt%'   then 'Regular'
			when LocalName like 'E%'   then 'Regular'
			when LocalName like '%HTT%'   then 'Regular'
			when LocalName like '%MDT%'   then 'Regular'
			when LocalName like 'F%'   then 'Regular'
			when LocalName like '%Glau%'   then 'Regular'
			when LocalName like '%Hyper%'   then 'Regular'
			when LocalName like '%Hyg%'   then 'Regular'
			when LocalName like '%Hyster%'   then 'Regular'
			when LocalName like '%Hear%'   then 'Regular'
			when LocalName like '%HV%' then 'Regular'
			when LocalName like '%immun%'   then 'Regular'
			when LocalName like '%ins%'   then 'Regular'
			when LocalName like '%irlens%'   then 'Regular'
			when LocalName like '%fert%'   then 'Regular'
			when LocalName like '%joint%'  then 'Regular'
			when LocalName like '%laser%'   then 'Regular'
			when LocalName like '%Learn%'   then 'Regular'
			when LocalName like '%Lesion%'   then 'Regular'
			when LocalName like '%Liver%'   then 'Regular'
			when LocalName like '%low %'   then 'Regular'
			when LocalName like '%LIU%'  then 'Regular'
			when LocalName like '%Lymph%'   then 'Regular'
			when LocalName like '%Mannitol%'   then 'Regular'
			when LocalName like '%MHT%'   then 'Regular'
			when LocalName like '%one stop%'   then 'Regular'
			when LocalName like '%Opti%'   then 'Regular'
			when LocalName like '%Ostrich%'   then 'Regular'
			when LocalName like '%Pathlab%'   then 'Regular'
			when LocalName like '%Quick%'   then 'Regular'
			when LocalName like '%Therap%'   then 'Regular'
			when LocalName like '%Retina%'   then 'Regular'
			when LocalName like '%Rhin%'   then 'Regular'
			when LocalName like '%Sleep%'   then 'Regular'
			when LocalName like '%Scan%'   then 'Regular'
			when LocalName like '%Spiro%'   then 'Regular'
			when LocalName like '%Thyroid%'   then 'Regular'
			when LocalName like '%Thoracic%'   then 'Regular'
			when LocalName like '%Walk%'   then 'Regular'
			when LocalName like '%Weight%'   then 'Regular'
			when LocalName like '%vulval%'   then 'Regular'
			when LocalName like '%voice%'   then 'Regular'
			when LocalName like '%valve%'   then 'Regular'
			when LocalName like '%session%'   then 'Regular'
			when LocalName like '%Trans%'   then 'Regular'
			when LocalName like '%Service%'   then 'Regular'
			
			
			
			

	else null
	end 

	UPDATE @Results SET
	R.MainCode = S.MainCode,
	R.Name = S.Name
FROM
	@Results R
	--INNER JOIN Mapping.dbo.PAS_Session_Map SM ON R.LocalCode=SM.LocalCode AND R.Source=SM.Source
	INNER JOIN Mapping.dbo.PAS_Session S ON r.MainCode=S.MainCode


SELECT * FROM @Results
--where MainCode is null
order by maincode
END
GO
