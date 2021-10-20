SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_IG_Data_RecordInventory]
AS
BEGIN
SET NOCOUNT ON;

	SELECT 
	[req_id] as ID
,[user_username] as UserUsername
,nullif([user_personaltitle],'') as UserTitle
,[user_givenname] as UserForename
,[user_surname] as UserSurname
,[user_email] as UserEmail
,[user_jobtitle] as UserJobTitle
,nullif([user_office],'-') as UserOffice
,[user_company] as UserCompany
,[user_department] as UserDepartment
,[user_site] as UserSite
,[user_telephone] as UserTelephone
,nullif([user_bleep],'') as UserBleep
,nullif([user_mobile],'') as UserMobile
,nullif([user_fax],'') as UserFax
,nullif([proxy_name],'') as ProxyName
,nullif([proxy_username],'') as ProxyUsername
,nullif([proxy_email],'') as ProxyEmail
,nullif([proxy_jobtitle],'') as ProxyJobTitle
,nullif([proxy_array],'["","","",""]') as ProxyArray
,nullif([iao_name],'') as IAOName
,nullif([iao_username],'') as IAOUsername
,nullif([iao_email],'') as IAOEmail
,nullif([iao_jobtitle],'') as IAOJobTitle
,[iao_array] as IAOArray
,nullif([iaa_name],'') as IAAName
,nullif([iaa_username],'') as IAAUsername
,nullif([iaa_email],'') as IAAEmail
,nullif([iaa_jobtitle],'') as IAAJobTitle
,nullif([iaa_array],'["","","",""]') as IAAAray
,[category] as Category
,case when [status] = '' then 'Unknown' else [status] end as Status
,[area] as AreaOwner
,[record_name] as Name
,[record_rmcop_id] as RMCOP
,cast(cast('01/' + cast([record_date] as varchar) as varchar)as date) as CreatedDate
,case when [record_destruction_date] = '' then null else cast(cast('01/' + cast([record_destruction_date] as varchar) as varchar) as date) end as DestructionDate
,[record_company] as Company
,[record_site] as Site
,[record_department] as Department
,[purpose] as Purpose
,[type] as Type
,case when len([location]) < 1 then null else [location]  end as Storage
,nullif([type_details],'') as StorageDetail
,case when len([format]) < 1 then null else [format] end as StorageFormat
,[naming] as NamingConvention
,case when [duplicate] is null then 'Unknown' when [duplicate] = '' then 'Unknown' else [duplicate] end as DuplicateHeld
,case when [duplicate_details] = '' then null when len([duplicate_details]) = 1 then null else [duplicate_details]  end as DuplicateDetail
,nullif([volume],'') as Volume
,case when [retention_corp] is null then 'Unknown' when [retention_corp] = '' then 'Unknown' else [retention_corp] end as CorporateRetention
,case when [retention_health] is null then 'Unknown' when [retention_health] = '' then 'Unknown' else [retention_health] end as HealthRecordRetention
,case when len([disposal_details]) <= 1 then null else [disposal_details] end as DisposalDetail
,case when [store_permanent] is null then 'Unknown' when [store_permanent] = '' then 'Unknown' else [store_permanent] end as PermanentPreservation
,case when len([store_permanent_details]) <=1 then null else [store_permanent_details] end as PermanentPreservationDetail
,case when [space] is null then 'Unknown' when len([space]) <= 1 then 'Unknown' else [space] end as SufficientStorage
,case when len([space_details]) <=1 then null else [space_details] end as SufficientStorageDetail
,case when [store_security] is null then 'Unknown' when len([store_security]) <=1 then 'Unknown' else [store_security] end as StorageSecurity
,case when [data_quality]  is null then 'Unknown' when len([data_quality]) <=1 then 'Unknown' else [data_quality] end as DataQualityAssurance
,isnull([pii],'Unknown') as PII
,case when len([pii_details]) <= 1 then null else [pii_details] end as PIIDetail
,Isnull([sensitive_pii],'Unknown') as SensitivePII
,nullif([sensitive_pii_details],'') as SensitivePIIDetail
,isnull([sensitive_business_info],'Unknown') as SensitiveBusinessInfo
,nullif([sensitive_business_info_details],'') as SensitiveBusinessInfoDetail
,isnull([restricted],'Unknown') as RestrictedAccess
,nullif([restricted_details],'') as RestrictedAccessDetail
,[review] as ReviewSchedule
,CONVERT(date, case when last_review = '' then null else CONVERT(varchar,SUBSTRING(last_review,7,4) + '-' + SUBSTRING(last_review,4,2) + '-'+ SUBSTRING(last_review,1,2),105) end + ' 00:00:00.000') as LastReviewDate
,CONVERT(date, case when next_review = '' then null else CONVERT(varchar,SUBSTRING(next_review,7,4) + '-' + SUBSTRING(next_review,4,2) + '-'+ SUBSTRING(next_review,1,2),105) end + ' 00:00:00.000') as NextReviewDate
,case when REPLACE(REPLACE(REPLACE(shared,'["',''),'"]',''),'","',',') is null then 'Unknown' when REPLACE(REPLACE(REPLACE(shared,'["',''),'"]',''),'","',',') = '[]' then 'Unknown' else REPLACE(REPLACE(REPLACE(shared,'["',''),'"]',''),'","',',') end as Sharing
,nullif([shared_details],'') as SharingDetail
,nullif([shared_method],'') as SharingMethod
,case when [agreement] is null then 'Unknown' when [agreement] = '' then 'Unknown' else [agreement] end as SharingAgreement
,case when [consent] is null then 'Unknown' when [consent] = '' then 'Unknown' else [consent] end as Consent
,nullif([consent_details],'') as ConsentDetail
,case when len([legal_grounds]) <=1 then null else [legal_grounds] end as LegalGrounds
,isnull([dataflow],'Unknown') as Dataflow
,case when [processing_statement] = '' then 'Unknown' else isnull([processing_statement],'Unknown') end as ProcessingStatement
,isnull([audit],'Unknown') as AuditCapability
,isnull([audit_viewers],'Unknown') as AuditViewers
,isnull([audit_reviewed],'Unknown') as AuditReviewed
,nullif([audit_reviewed_details],'') as AuditReviewedDetail
,case when len([risk]) <=1 then null else [risk] end as Risk
,isnull([offsite],'Unknown') as AllowedOffsite
,isnull([transport],'Unknown') as Transport
,nullif([transport_details],'') as TransportDetail
,nullif([transport_agreement],'') as TransportAgreement
,case when len([actions_details]) <=1 then null else [actions_details] end as ActionRequired
,isnull([training],'Unknown') as TrainingRequired
,case when len([comments_details]) <=1 then null else [comments_details] end as Comment
,case when len([attachments_names]) <=1 then null else [attachments_names] end as Attachment

  FROM [sql3.core.cd-tr.wales.nhs.uk\sql3].[IT_Portal].[dbo].[igi_record]

  end
GO
