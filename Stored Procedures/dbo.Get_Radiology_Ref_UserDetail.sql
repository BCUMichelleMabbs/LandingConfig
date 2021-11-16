SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Get_Radiology_Ref_UserDetail]
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Results AS TABLE(
	Source				VARCHAR(15),
	Area				VARCHAR(15),
	UserDetailID		VARCHAR(100),
	UserID				VARCHAR(100),
	Surname				VARCHAR(50),
	Forenames			VARCHAR(100),
	Title				VARCHAR(100),
	Active				 int,
	RoleID				VARCHAR(100),
	JobDescription		VARCHAR(100)

)


INSERT INTO @Results(Source,Area,UserDetailID,UserID,Surname,Forenames,Title,Active,RoleID,JobDescription)
SELECT
	'Radis' AS Source,
	'Central' AS Area,
	PK_Userdetail_ID as UserDetailID,
	UserID,
	Surname,
	Forenames,
	Title,
	Active,
	fk_Role_ID   as  RoleID,
	JobDescription

FROM 
	[RADIS_CENTRAL].[RadisReporting].dbo.UserDetail


INSERT INTO @Results(Source,Area,UserDetailID,UserID,Surname,Forenames,Title,Active,RoleID,JobDescription)
SELECT
'Radis' AS Source,
	'East' AS Area,
	PK_Userdetail_ID as UserDetailID,
	UserID,
	Surname,
	Forenames,
	Title,
	Active,
	fk_Role_ID   as  RoleID,
	JobDescription
	
FROM
	[RADIS_EAST].[RadisReporting].dbo.UserDetail


INSERT INTO @Results(Source,Area,UserDetailID,UserID,Surname,Forenames,Title,Active,RoleID,JobDescription)
SELECT
	PK_Userdetail_ID as UserDetailID,
	UserID,
	Surname,
	Forenames,
	Title,
	Active,
	fk_Role_ID   as  RoleID,
	JobDescription,
	'Radis' AS Source,
	'West' AS Area
FROM
	[RADIS_WEST].[RadisReporting].dbo.UserDetail

--UPDATE 
--	@Results
--SET
--	MainCode=LocalCode,
--	Name=LocalName

SELECT * FROM @Results ORDER BY Area
end
GO
