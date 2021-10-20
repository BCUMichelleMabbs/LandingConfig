SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure  [dbo].[Get_CasenoteTracking_Data_CurrentLocation] as begin 


select 


			a.CRN AS LocalPatientIdentifier,
			a.[Name] AS PatientName,
			a.DOB AS DateOfBirth,
			a.[Type]  AS NoteType,
			a.Volume,
			a.FileNote ,
			a.Barcode ,
			a.RFID,
			a.[Location],
			a.LastRefreshed AS CensusDate,
			  Case when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1)) = 'East' then 'East'
  when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1)) = 'EAST' then 'East'
  when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1))='WEST' then 'West'
   when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1))='West' then 'West'
      when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1))='Cent' then 'Central'
      when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1))='CENT' then 'Central'
	        when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1))='Central' then 'Central'
      when SUBSTRING(a.[Location],1,(CHARINDEX(' ',a.[Location] + ' ')-1))='CENTRAL' then 'Central'

      else 'Unknown' end as Area,

			'IFIT' AS Source,
				  p.LastMoved
			FROM [7A1A4SRVIFDB01].[iFIT_DM].[dbo].[CodedDataExtract] a
				Inner join [7A1A4SRVIFDB01].[iFIT].[dbo].[PUK_Item] p with (NOLOCK) on a.CRN=p.Ora_ClientKey and a.Barcode=p.SerialNo

 

end
GO
