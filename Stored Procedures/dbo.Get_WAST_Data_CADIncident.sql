SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_WAST_Data_CADIncident]

AS
BEGIN
	SET NOCOUNT ON;
select
	      AgeOfPatient
      ,CallConnectedDateTime
      ,CallPickupDateTime
      ,ChiefComplaintEstablishedDateTime
      ,DispatchCodeAndSuffix
      ,DispatchCodeDescription
      ,DispatchCodeEstablishedDateTime
      ,GeographyKey
      ,IncidentDate
      ,IncidentDateTime
 ,IncidentID
      ,IncidentLastUpdate
      ,IncidentLocationConfirmedDateTime
      ,IncidentLocationEasting
      ,IncidentLocationNorthing
      ,IncidentStopCode
      ,IncidentStopCodeDescription
      ,IncidentTypeDescription
      ,LatestTimeDispatchCodeEstablished
      ,LHBCode
      ,MPDSPriorityType
      ,NamePartLastWhere3PlusNames
      ,NatureOfIncident
      ,NatureOfIncidentDescription
      ,PatientSex
      ,PROQAEnterDateTime
      ,PROQAExitDateTime
      ,StatsCurrentCensusHealthOrganisationCode
      ,StatsCurrentCensusHealthOrganisationName
      ,StatsCurrentCensusLocalAuthorityCode
      ,StatsCurrentCensusLocalAuthorityName
      ,StatsCurrentCensusLowerSuperOutputAreaCode

  FROM  [7A1A1SRVINFONDR].[WAST].[dbo].[CADIncident]
  where IncidentDate >= dateadd(month,-1,convert(date,getdate())) --run the lastmonths data

End
GO
