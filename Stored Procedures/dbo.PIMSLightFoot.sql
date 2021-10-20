SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[PIMSLightFoot]  @StartDate datetime
,@EndDate Datetime

as

---Ward Transfers---
;with cte_w as(
Select 

pv.prvsp_Refno as SpellNo
,p.pasid as CRN
,pv.admit_dttm as AdmissionDate
,admet.main_code  as AdmissionMethod
,dismet.main_code  as DischargeMethod
,disde.main_code  as DischargeDestination
,sps.start_Dttm as StartDate
,CASE WHEN pv.disch_dttm is not null and pv.prvsn_end_flag = 'N' then pv.disch_Dttm else NULL END as DischargeDate
,CASE WHEN pv.admit_Dttm = sps.start_dttm then spec.main_ident else NULL END as Specialty
,CASE WHEN pv.admit_Dttm = sps.start_Dttm then pro.main_ident else NULL END as Clinician
,sp.code as WardName
,Row_Number() OVER (Partition by pv.prvsp_Refno order by sps.start_Dttm asc) As WardStayOrder



from [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.provider_spells pv
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.service_point_Stays sps
on sps.prvsp_Refno = pv.prvsp_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.patients p 
on p.patnt_Refno = pv.patnt_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.service_points sp
on sp.spont_Refno = sps.spont_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.specialties spec
on spec.spect_Refno = pv.spect_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.prof_Carers pro
on pro.proca_Refno = pv.proca_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.reference_Values admet
on admet.rfval_Refno = pv.admet_refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.reference_Values dismet
on dismet.rfval_Refno = pv.dismt_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.reference_Values disde
on disde.rfval_Refno = pv.disde_Refno


where 
pv.admit_Dttm between @StartDate and @EndDate 
and ISNULL(pv.archv_flag,'N') = 'N'
and ISNULL(sps.archv_flag,'N') = 'N'

)


--Clinician/Spec Transfers--

, cte_c as (

Select 

pv.prvsp_Refno as SpellNo
,p.pasid as CRN
,pv.admit_dttm as AdmissionDate
,admet.main_code as AdmissionMethod
,dismet.main_code   as DischargeMethod
,disde.main_code   as DischargeDestination
,pce.start_Dttm as StartDate
,CASE WHEN pv.disch_dttm is not null and pv.prvsn_end_flag = 'N' then pv.disch_Dttm else NULL END as DischargeDate
,spec.main_ident as Specialty
,pro.main_ident as Clinician
,CASE WHEN pv.admit_Dttm = pce.start_Dttm then sp.code else NULL END as WardName
,Row_Number() OVER (Partition by pv.prvsp_Refno order by pce.start_Dttm asc) As WardStayOrder



from [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.provider_spells pv
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.prof_Carer_episodes pce
on pce.prvsp_Refno = pv.prvsp_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.specialties spec 
on spec.spect_refno = pce.spect_refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.patients p 
on p.patnt_Refno = pv.patnt_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.prof_Carers pro
on pro.proca_Refno = pce.proca_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.service_points sp
on sp.spont_Refno = pv.spont_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.reference_Values admet
on admet.rfval_Refno = pv.admet_refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.reference_Values dismet
on dismet.rfval_Refno = pv.dismt_Refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.reference_Values disde
on disde.rfval_Refno = pv.disde_Refno


where 
pv.admit_Dttm between @StartDate and @EndDate 
and ISNULL(pv.archv_flag,'N') = 'N'
and ISNULL(pce.archv_flag,'N') = 'N'




)

--Combine

,cte_combine
as(

select *
from cte_w

union

select *
from cte_c
)

--EpisodeNos

,cte_ep as (

select 
pv.prvsp_Refno as SpellNo
,pe.prcae_Refno as EpisodeNo
,pe.start_dttm as EpisodeStart
,pe.End_dttm as EpisodeEnd
,pro.main_ident as Clinician

from [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.Provider_spells pv
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.prof_Carer_episodes pe
on pe.prvsp_Refno = pv.prvsp_refno
join [7A1AUSRVIPMSQLR\REPORTS].IPMREPORTS.dbo.prof_Carers pro
on pro.proca_Refno = pe.proca_Refno

where
pv.admit_Dttm between @StartDate and @EndDate 
and ISNULL(pv.archv_flag,'N') = 'N'
and ISNULL(pe.archv_flag,'N') = 'N'
)
--Staging
,cte_trans as (

select 

cc.SpellNo
,ce.EpisodeNo as EpisodeNo 
,CRN
,AdmissionDate
,DischargeDate
,AdmissionMethod 
,DischargeMethod 
,DischargeDestination
,StartDate as TransferDate
,Specialty
,cc.Clinician
,WardName
,ROW_Number() over (Partition by cc.SpellNo order by startdate asc)-1 as TransferNo

from cte_combine cc
left join cte_ep ce
on ce.SpellNo = cc.SpellNo 
and ce.EpisodeStart = cc.startdate
and ce.Clinician = cc.Clinician 



)
,cte_ward as (
select *,
CASE WHEN WardName is null 
then ISNULL(LAG(WardName ,1) over (Partition by SpellNo order by TransferDate asc),LAG(WardName ,2) over (Partition by SpellNo order by TransferDate asc)) 
else WardName 
END As Ward,
CASE WHEN WardName is not null then EpisodeNo else NULL end as EpisodeNumber

from cte_trans
)

,cte_epnumber as(

SELECT 
'West' as Area
,'PIMS' as Source
,CRN as LocalPatientIdentifier
,SpellNo as SpellNumber
,EpisodeNo as EpisodeNumber
--,EpisodeNo as OldEp
,AdmissionMethod 
,DischargeMethod 
,CONVERT(Date,TransferDate) as EventStartDate
,CONVERT(Time,TransferDate) as EventStartTime
,ISNULL(CONVERT(Date,LEAD(TransferDate,1) OVER (Partition by SPellNo order by TransferDate asc)),CONVERT(date,DischargeDate)) as EventEndDate
,ISNULL(CONVERT(Time,LEAD(TransferDate,1) OVER (Partition by SPellNo order by TransferDate asc)),CONVERT(Time,DischargeDate)) as EventEndTime
,CASE WHEN Clinician is null 
then ISNULL(ISNULL(ISNULL(ISNULL(LAG(Clinician,1) over (Partition by SpellNo order by TransferDate asc),LAG(Clinician,2) over (Partition by SpellNo order by TransferDate asc)),LAG(Clinician,3) over (Partition by SpellNo order by TransferDate asc)),LAG(Clinician,4) over (Partition by SpellNo order by TransferDate asc)),LAG(Clinician,5) over (Partition by SpellNo order by TransferDate asc))

else Clinician 
END As Consultant


,ISNULL(ISNULL(ISNULL(ISNULL(ISNULL(LAG(Ward,1) Over (Partition by SpellNo order by TransferDate asc),LAG(Ward,2) Over (Partition by SpellNo order by TransferDate asc)),LAG(Ward,3) Over (Partition by SpellNo order by TransferDate asc)),LAG(Ward,4) Over (Partition by SpellNo order by TransferDate asc)),LAG(Ward,5) Over (Partition by SpellNo order by TransferDate asc)),LAG(Ward,6) Over (Partition by SpellNo order by TransferDate asc)) as PreviousWard


,Ward 


,ISNULL(ISNULL(ISNULL(ISNULL(ISNULL(LEAD(Ward,1) Over (Partition by SpellNo order by TransferDate asc),LEAD(Ward,2) Over (Partition by SpellNo order by TransferDate asc)),LEAD(Ward,3) Over (Partition by SpellNo order by TransferDate asc)),LEAD(Ward,4) Over (Partition by SpellNo order by TransferDate asc)),LEAD(Ward,5) Over (Partition by SpellNo order by TransferDate asc)),LEAD(Ward,6) Over (Partition by SpellNo order by TransferDate asc)) as NextWard


,CASE WHEN Specialty is null 
then ISNULL(ISNULL(ISNULL(ISNULL(LAG(Specialty,1) over (Partition by SpellNo order by TransferDate asc),LAG(Specialty,2) over (Partition by SpellNo order by TransferDate asc)),LAG(Specialty,3) over (Partition by SpellNo order by TransferDate asc)),LAG(Specialty,4) over (Partition by SpellNo order by TransferDate asc)),LAG(Specialty,5) over (Partition by SpellNo order by TransferDate asc)) 
else Specialty
END As Specialty
,Getdate() as LastUpdated
,DischargeDestination 
,TransferNo 

--,[AdmissionDate]
--,[DischargeDate]
--,[TransferDate]
	 
FROM cte_ward



), cte_final as(

select 

Area
,Source
,LocalPatientIdentifier
,SpellNumber
,ISNULL(ISNULL(ISNULL(EpisodeNumber,LAG(EpisodeNumber,1) Over (Partition by SpellNumber,Consultant Order by CAST(EventStartDate as DATETIME) + CAST(EventStartTime as DATETIME) Asc)),LAG(EpisodeNumber,2) Over (Partition by SpellNumber,Consultant Order by CAST(EventStartDate as DATETIME) + CAST(EventStartTime as DATETIME) Asc)),LAG(EpisodeNumber,3) Over (Partition by SpellNumber,Consultant Order by CAST(EventStartDate as DATETIME) + CAST(EventStartTime as DATETIME) Asc)) As EpisodeNo
,NULL as PatientLinkIDEpisode 
,AdmissionMethod 
,DischargeMethod 
,EventStartDate 
,EventStartTime 
,EventEndDate 
,EventEndTime 
,Consultant 
,PreviousWard 
,Ward
,NextWard 
,Specialty 
,LastUpdated 
,DischargeDestination 
,TransferNo 



from cte_epnumber
)




select 

Area
,Source
,LocalPatientIdentifier
,SpellNumber
,'0' + CONVERT(varchar,ROW_NUMBER() over (Partition by LocalPatientIdentifier,SpellNumber,EpisodeNo order by CAST(EventStartDate as Datetime) + CAST(EventStartTime as Datetime))) as EpisodeNo
,CONVERT(varchar,SpellNumber)+'|'+'West'+'|'+'|'+'0' + CONVERT(varchar,ROW_NUMBER() over (Partition by LocalPatientIdentifier,SpellNumber,EpisodeNo order by CAST(EventStartDate as Datetime) + CAST(EventStartTime as Datetime)))+'|'+'PIMS'+'|'+'IPE' as PatientLinkIDEpisode 
,AdmissionMethod 
,DischargeMethod 
,EventStartDate 
,EventStartTime 
,EventEndDate 
,EventEndTime 
,Consultant 
,PreviousWard 
,Ward
,NextWard 
,Specialty 
,LastUpdated 
,DischargeDestination 
,TransferNo 

from cte_final 


order by SpellNumber,TransferNo 
GO
