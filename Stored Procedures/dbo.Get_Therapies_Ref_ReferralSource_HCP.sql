SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_Therapies_Ref_ReferralSource_HCP]
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE
(
	ReferralSourceId  VARCHAR(20),
	Name              VARCHAR(36),
	Address		      VARCHAR(254),
	Postcode          VARCHAR(8),
	Code              VARCHAR(10),
	Type		      VARCHAR(20),
	PwExpire          DATE, 
	Discontinued      VARCHAR(20),
	Source            VARCHAR(20)
	)

INSERT INTO @Results(ReferralSourceId,Name,Address,Postcode,Code,Type,PwExpire,Discontinued, Source)
	(
	Select distinct ID, Name, Address, Postcode, code, type, PW_EXPIRE, DISCONTINUED, 
	'TherapyManager' AS Source
from [SQL4\SQL4].[physio].[dbo].REFFERINGINSTANCE

	)

SELECT * FROM @Results order by Source,ReferralSourceId


End

-- n.b. - Incomplete Data in THERAPY MANAGER TM
-- TM.REFFERINGINSTANCE.ID=KEY field USED IN TM.REFERRAL 
-- TM.REFFERINGINSTANCE.Code is the National HealthcareProfessional Code - THIS IS NOT COMPLETE !!!!!
GO
