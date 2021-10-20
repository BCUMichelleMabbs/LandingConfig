SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[Get_ESR_Ref_Organisation]

as
begin
SELECT distinct LTRIM(o.OrgName) as Organisation 

,o2.OrgName as [ParentOrganisation]

	  ,LoadDate as RetrivalDate




  FROM Foundation.dbo.ESR_Data_Organisation o
  join Foundation.dbo.ESR_Data_Organisation o2
  on o2.OrganisationID = o.ParentOrgID 

  end


GO
