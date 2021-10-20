SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Get_Covid_Ref_VaccinationSite]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	ActiveFrom							Date,	--Local - from system
	[Address1] [varchar](400) NULL,
	[Address2] [varchar](400) NULL,
	[Address3] [varchar](400) NULL,
	[Address4] [varchar](400) NULL, 
	[Address5] [varchar](400) NULL, 
	ContactNumber [varchar](30) NULL,
	MainCode							varchar(10),	--Mapping   WisCode
	Name								varchar(300),	--Mapping   Name
	[Postcode] [varchar](100) NULL,
	SiteCode							varchar(50),		--Mapping
	SiteName							varchar(200),	--Mapping
	Source							varchar(10),	--Local - from system
	LocationType [varchar](200) NULL,
	wCode [varchar](100) NULL,
	District [varchar](100) NULL,
	SiteArea [varchar](100) NULL,
	SiteAreaOrder [varchar](100) NULL
)

INSERT INTO @Results(ActiveFrom,Address1,Address2,Address3,Address4,Address5,ContactNumber,MainCode,Name,PostCode,SiteCode,SiteName,Source,LocationType,wCode,District,SiteArea,SiteAreaOrder)
	(
	SELECT
	   Convert(Date,[ActiveFrom]) as ActiveFrom
	         ,[Address1]
      ,[Address2]
      ,[Address3]
      ,[Address4]
      ,[Address5]
	  ,[ContactNumber]
	  ,[WISCode] as MainCode
      ,[LocationName] as Name
      ,s.[Postcode]
      ,[LHB] as SiteCode
	  ,'BCU' as SiteName
	  ,'WIS' as Source
	  ,LocationType
	  ,wCode
	  ,p.District
	  ,	CASE WHEN p.District in ('Isle of Anglesey','Gwynedd') THEN 'West'
       WHEN p.District in ('Conwy','Denbighshire') THEN 'Centre'
       WHEN p.District in ('Flintshire','Wrexham') THEN 'East'
       ELSE 'Other' END AS SiteArea, 
       CASE WHEN p.District in ('Isle of Anglesey','Gwynedd') THEN '1'
       WHEN p.District in ('Conwy','Denbighshire') THEN '2'
       WHEN p.District in ('Flintshire','Wrexham') THEN '3'
       ELSE '4' END AS SiteAreaOrder 
	  FROM [7A1A1SRVINFONDR].[Covid_Vaccination].[dbo].[WIS_Locations] S
	--  [Mapping].[dbo].[Covid_VaccinationSite]
       LEFT JOIN Foundation.dbo.Common_Ref_Postcode p on REPLACE(s.Postcode,' ','') = p.PostcodeNoSpace

	--WHERE LHB = '7A1'
	)
	--INSERT INTO [Foundation].[dbo].[Covid_Ref_VaccinationSite](MainCode,Name,Address1,Address2,Address3,Address4,Address5,PostCode,ContactNumber,SiteCode,SiteName,ActiveFrom,Source)

SELECT * FROM @Results order by Source,Name

End
GO
