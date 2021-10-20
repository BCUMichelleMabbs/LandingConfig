SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure

[dbo].[Get_Corporate_Data_PatientExperience]
as
begin


SELECT 
      TransferID,
      TransferResponseID,
	  CltNbr as ControlNumber,
	  devNbr as DeviceNumber,
	  DpyNbr as DeploymentNumber,
	  --RegNbr as RegionNumber,
	  SvyNbr as SurveyNumber,
	  --SvySeq as SurveySequence,
	  RspNbr as ResponseNumber,
	  QtnNbr as QuestionNumber,
	  AwrNbr as AnswerNumber,
	  CAST(SUBSTRING(DteCrt,7,4) + '-' + SUBSTRING(DteCrt,4,2) + '-' + SUBSTRING(DteCrt,1,2) as DATE)  as CreatedDate,
	  CAST(SUBSTRING(DteCrt, 12, 8) AS TIME(0)) as CreatedTime,
	  Active,
	  Username,
	  CAST(SUBSTRING(ChangedDate,7,4) + '-' + SUBSTRING(ChangedDate,4,2) + '-' + SUBSTRING(ChangedDate,1,2) as DATE) as ChangedDate,
	  CAST(SUBSTRING(ChangedDate, 12, 8) AS TIME(0))as ChangedTime,
	  LtnNbr as LocationNumber,
	  'Viewpoint' as Source,
	  'BCU' as Area,
	  AgeGroup,
	  AwrTxt as Answer,
	  UserType


	  
  FROM [SSIS_Loading].[PatientExperience].[dbo].[AgeBand]


  end
GO
