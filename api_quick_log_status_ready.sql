WITH access_check AS(SELECT CASE WHEN EXISTS(SELECT 1 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username))) WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14)) THEN 1 ELSE 0 END AS allowed)
SELECT 'json' AS component,(SELECT CAST(a.allowed AS bit) AS authorized,
 CASE WHEN a.allowed=0 THEN N'unauthorized' WHEN q.seqno IS NULL THEN N'not_found' ELSE N'ok' END AS status,
 CASE WHEN q.seqno IS NULL THEN NULL
 WHEN sync.CaseID IS NULL AND NULLIF(q.zoho_id,N'') IS NOT NULL AND NULLIF(q.reference,N'') IS NOT NULL AND q.zoho_insert=0 THEN N'Complete'
 WHEN sync.CaseID IS NULL AND q.zoho_insert=0 AND NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NOT NULL THEN N'Unconfirmed'
 WHEN sync.CaseID IS NULL AND (q.zoho_insert=3 OR (NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NULL AND (q.zoho_insert=0 OR q.datetime_opened<(SELECT modify_date FROM ApplicationDb5.sys.objects WHERE object_id=OBJECT_ID('ApplicationDb5.dbo.CC_quick_log_sp','P'))))) THEN N'Uncertain'
 ELSE COALESCE(sync.SyncState,N'Pending') END AS syncState,
 CASE WHEN sync.CaseID IS NULL AND (q.zoho_insert=3 OR (NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NULL AND (q.zoho_insert=0 OR q.datetime_opened<(SELECT modify_date FROM ApplicationDb5.sys.objects WHERE object_id=OBJECT_ID('ApplicationDb5.dbo.CC_quick_log_sp','P'))))) THEN N'This historical case must be reconciled before it can be queued for Zoho.' ELSE sync.LastError END AS syncMessage,
 NULLIF(LTRIM(RTRIM(q.reference)),N'') AS zohoOb,
 JSON_QUERY((SELECT c.comm_id AS commId,c.case_id AS caseId,c.comm_type AS commType,c.contact_name AS contactName,c.contact_no AS contactNo,
 c.email_address AS emailAddress,c.comments,c.cc_operator AS ccOperator,CONVERT(nvarchar(19),c.datetime_comm,120) AS datetimeComm,
 c.zoho_pushed AS zohoPushed FROM ApplicationDb1.dbo.quick_log_Comments c WHERE c.case_id=q.seqno ORDER BY COALESCE(c.DisplayOrder,c.comm_id),c.comm_id FOR JSON PATH)) AS quickLogComments
 FROM access_check a LEFT JOIN ApplicationDb5.dbo.CC_quick_log q ON a.allowed=1 AND q.seqno=TRY_CONVERT(int,$seqno)
 AND UPPER(LTRIM(RTRIM(q.reg_no)))=UPPER(LTRIM(RTRIM(CAST($reg_no AS nvarchar(100))))) AND q.event=CAST($event AS nvarchar(200))
 LEFT JOIN ApplicationDb1.dbo.CCQuickLogSync sync ON sync.CaseID=q.seqno
 FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) AS contents;
