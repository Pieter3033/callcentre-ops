SET cc_status_route=(SELECT CASE WHEN OBJECT_ID('ApplicationDb1.dbo.CCQuickLogSync','U') IS NOT NULL AND COL_LENGTH('ApplicationDb1.dbo.quick_log_Comments','DisplayOrder') IS NOT NULL
 THEN N'CC_Escalation/api_quick_log_status_ready.sql' ELSE N'CC_Escalation/api_quick_log_status_basic.sql' END);
SELECT 'dynamic' AS component,sqlpage.run_sql($cc_status_route) AS properties;
