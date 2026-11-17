-- SQLPage 0.25 wrapper: resolve only a fixed, server-controlled include path.
SET cc_submit_authorized = (SELECT CASE WHEN EXISTS (
 SELECT 1 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username)))
 WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN (7,8,14)
) THEN 1 ELSE 0 END);
SET cc_submit_ready = (SELECT CASE WHEN OBJECT_ID('ApplicationDb1.dbo.CCQuickLogRequests','U') IS NOT NULL
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
 THEN 1 ELSE 0 END);
SET cc_submit_route = (SELECT CASE WHEN $cc_submit_authorized='1' AND $cc_submit_ready='1' AND sqlpage.request_method()='POST'
 THEN N'CC_Escalation/quick_log_submit_ready.sql' ELSE N'CC_Escalation/quick_log_submit_unavailable.sql' END);
SELECT 'dynamic' AS component,sqlpage.run_sql($cc_submit_route) AS properties;
