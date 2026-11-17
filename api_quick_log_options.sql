WITH operator_user AS (
 SELECT TOP(1) s.session_id,u.Username,u.Name,u.Surname
 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username)))
 WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14)
 ORDER BY u.Seqno
), readiness AS (
 SELECT CAST(CASE WHEN OBJECT_ID('ApplicationDb1.dbo.CCQuickLogRequests','U') IS NOT NULL
 AND COL_LENGTH('ApplicationDb1.dbo.CCQuickLogSync','CreateInFlight') IS NOT NULL
 AND COL_LENGTH('ApplicationDb1.dbo.quick_log_Comments','zoho_row_id') IS NOT NULL
 AND COL_LENGTH('ApplicationDb1.dbo.quick_log_Comments','DisplayOrder') IS NOT NULL
 AND COL_LENGTH('ApplicationDb1.dbo.quick_log_Comments','SubmissionID') IS NOT NULL
 AND OBJECT_ID('ApplicationDb1.dbo.CCQuickLog_Http','P') IS NOT NULL
 AND OBJECT_ID('ApplicationDb1.dbo.CCQuickLog_NormalizePhone','FN') IS NOT NULL
 AND EXISTS(SELECT 1 FROM ApplicationDb1.sys.objects f JOIN ApplicationDb1.sys.sql_modules m ON m.object_id=f.object_id WHERE f.name=N'CCQuickLog_NormalizePhone' AND f.type=N'FN' AND m.definition LIKE N'%CC_QUICK_LOG_PHONE_20261006%')
 AND EXISTS(SELECT 1 FROM ApplicationDb1.sys.procedures p JOIN ApplicationDb1.sys.sql_modules m ON m.object_id=p.object_id WHERE p.name=N'CC_Q' AND m.definition LIKE N'%CC_QUICK_LOG_V2_20261006%')
 AND EXISTS(SELECT 1 FROM ApplicationDb1.sys.triggers t JOIN ApplicationDb1.sys.sql_modules m ON m.object_id=t.object_id WHERE t.name=N'CCQuickLogRequests_Insert' AND t.is_disabled=0 AND m.definition LIKE N'%CC_QUICK_LOG_EDITABLE_20261006%')
 AND EXISTS(SELECT 1 FROM ApplicationDb5.sys.procedures p JOIN ApplicationDb5.sys.sql_modules m ON m.object_id=p.object_id WHERE p.name=N'CC_quick_log_sp' AND m.definition LIKE N'%CC_QUICK_LOG_CLOSED_ONLY_20261006%')
 THEN 1 ELSE 0 END AS bit) AS enabled
), account_readiness AS (
 SELECT CAST(CASE WHEN COL_LENGTH(N'ApplicationDb1.dbo.CCQuickLogSync',N'AccountZohoID') IS NOT NULL
 AND EXISTS(SELECT 1 FROM ApplicationDb1.sys.triggers t JOIN ApplicationDb1.sys.sql_modules m ON m.object_id=t.object_id WHERE t.name=N'CCQuickLogRequests_Insert' AND t.is_disabled=0 AND m.definition LIKE N'%CC_QUICK_LOG_ACCOUNT_20261116%')
 AND EXISTS(SELECT 1 FROM ApplicationDb5.sys.procedures p JOIN ApplicationDb5.sys.sql_modules m ON m.object_id=p.object_id WHERE p.name=N'CC_quick_log_sp' AND m.definition LIKE N'%CC_QUICK_LOG_ACCOUNT_20261116%') THEN 1 ELSE 0 END AS bit) AS enabled
)
SELECT 'json' AS component,(SELECT
 CAST(CASE WHEN EXISTS(SELECT 1 FROM operator_user) THEN 1 ELSE 0 END AS bit) AS authorized,
 CASE WHEN EXISTS(SELECT 1 FROM operator_user) THEN N'ok' ELSE N'unauthorized' END AS status,
 CAST(CASE WHEN EXISTS(SELECT 1 FROM operator_user) THEN readiness.enabled ELSE 0 END AS bit) AS submissionEnabled,
 CAST(CASE WHEN EXISTS(SELECT 1 FROM operator_user) AND account_readiness.enabled=1 THEN 1 ELSE 0 END AS bit) AS accountSelectionEnabled,
 CASE WHEN readiness.enabled=0 THEN N'Submission is temporarily unavailable. You can still save a draft in this browser.' END AS message,
 (SELECT CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(nvarchar(max),N'CCQuickLog:'+session_id)),2) FROM operator_user) AS csrfToken,
 JSON_QUERY((SELECT Username AS username,COALESCE(NULLIF(LTRIM(RTRIM(CONCAT(Name,N' ',Surname))),N''),Username) AS name FROM operator_user FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)) AS operator,
 JSON_QUERY((SELECT id AS value,seat AS label FROM ApplicationDb5.dbo.cc_seats WHERE LTRIM(RTRIM(ISNULL(seat,N''))) NOT IN(N'',N'...') AND EXISTS(SELECT 1 FROM operator_user) ORDER BY id FOR JSON PATH)) AS seats,
 JSON_QUERY((SELECT type AS value,type AS label FROM ApplicationDb5.dbo.CC_comm_types WHERE type NOT IN(N'',N'...') AND EXISTS(SELECT 1 FROM operator_user) ORDER BY id FOR JSON PATH)) AS commTypes
 FROM readiness CROSS JOIN account_readiness FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) AS contents;
