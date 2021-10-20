SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure
 [dbo].[Get_Covid_Ref_DeceasedLkUp]

 as 
 begin



truncate table Foundation.dbo.Covid_Ref_DeceasedLkup
DECLARE @Results AS TABLE(
	CRN		VARCHAR(20),
	NHS varchar(50),
	DischDate date,
	DoD  date,
	LastModifiedT datetime,
	LastModifiedP datetime,
	DisMethod varchar(5)

)

INSERT INTO @Results(CRN,NHS,DischDate,DoD,LastModifiedT,LastModifiedP,DisMethod)
SELECT * FROM OPENQUERY(WPAS_CENTRAL,'
	SELECT p.Caseno,p.nhs,t.disdate,p.deathdate,t.Last_Modify_Date,p.update_date,DisMethod
	 FROM 
		 patient p
		left join treatmnt t
		on p.caseno = t.caseno
		and dismethod = ''4''
		and disdate >= ''2020-03-01''

		where p.deathdate is not null 
		and p.deathdate >=''2020-03-01''
		
')


INSERT INTO @Results(CRN,NHS,DischDate,DoD,LastModifiedt,LastModifiedP,DisMethod)
SELECT * FROM OPENQUERY(WPAS_EAST,'
	SELECT p.Caseno,p.nhs,t.disdate,p.deathdate,t.Last_Modify_Date,p.update_date,DisMethod
	 FROM 
		 patient p
		left join treatmnt t
		on p.caseno = t.caseno
		and dismethod = ''4''
		and disdate >= ''2020-03-01''

		where p.deathdate is not null 
		and p.deathdate >=''2020-03-01''
		
')



INSERT INTO @Results(CRN,NHS,DischDate,DoD,LastModifiedt,LastModifiedP,DisMethod)
select 

*

from [7A1AUSRVIPMSQL].[iPMproduction].[dbo].BCU_Deaths






--------------------------------------


insert into Foundation.dbo.Covid_Ref_DeceasedLkup (CRN,NHS,DoD,DeceasedinHospital,LastModified)
select 
distinct CRN,NHS,DoD
--,CASE WHEN DischDate = DoD then 'Y' else 'N' end as DeceasedInHospital
,CASE WHEN DisMethod = '4' then 'Y' else 'N' end as DeceasedInHospital
,ISNULL(LastModifiedT,LastModifiedP)
from @Results 





END

GO
