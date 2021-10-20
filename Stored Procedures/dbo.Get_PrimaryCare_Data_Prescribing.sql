SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Get_PrimaryCare_Data_Prescribing]

as 
begin

SELECT 


CONVERT(varchar,[PracticeID],20) as PracticeID
      ,CONVERT(varchar,[BNFCode],30) as BNFCode
     
     
      ,CONVERT(Decimal(10,4),[NIC]) as NIC
      ,CONVERT(Decimal(10,4),[ActCost]) as ActualCost
      ,CONVERT(int,[Quantity]) as Quantity
      ,CONVERT(Decimal(10,4),[DDD]) as DDD
     ,CONVERT(Decimal(10,4),[ADQ]) as ADQ
     ,CONVERT(date,Period+'01') as Period
     
     
  FROM [SSIS_Loading].[BNF].[dbo].[GPPrescribingData]
where HB = '7A1'

END
GO
