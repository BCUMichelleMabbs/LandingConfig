SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Update_Common_Ref_Location]
@LoadGUID varchar(38)
as
begin


Update [Foundation].[dbo].[Common_Ref_Location]
set 

Active = d.Active
,CommunityHospital = d.CommunityHospital  
,DatixHospitalCode  = d.DatixHospitalCode
,DatixWardCode  = D.DatixWardCode
,DTOCWardCode = d.Dtoc
,ERostering = d.ERostering
,ESR = d.Esr
,ESROrg = d.esrorg
,HCMSWardCode = d.HCMSWardCode
,HospitalCodeName = d.HospitalCodeName
,HospitalNameCode = d.HospitalNameCode
,HospitalShortName = d.HospitalShortName
,ICNETHospitalCode = D.ICNETHospitalCode
,ICNETWardCode = d.ICNET
,LiveDataHospitalCode = D.LiveDataHospitalCode
,Location = d.Location
,LocationCode = d.LocationCode
,OldLiveDataHospitalCode = d.OldLiveDataHospitalCode
,Organisation = d.organisation
,Specialty = d.Specialty
,WardCodeName = d.WardCodeName
,WardNameCode = D.WardNameCode

from [BCUINFO\BCUDATAWAREHOUSE].Dimension.dbo.Common_Location_NA d
inner join [Foundation].[dbo].[Common_Ref_Location] f
on f.NationalHospitalCode = d.NationalHospitalCode
and f.LocalCode = d.PasWardCode


end
GO
