-- The INSTEAD OF INSERT trigger validates and saves the whole request atomically.
-- This file must perform no direct writes to case or comment tables.
-- Explicit accounts require the prepared account-aware queue; old exact retries remain valid.
SET cc_account_supported = (SELECT CASE WHEN COL_LENGTH(N'ApplicationDb1.dbo.CCQuickLogSync',N'AccountZohoID') IS NOT NULL
 AND EXISTS(SELECT 1 FROM ApplicationDb1.sys.triggers t JOIN ApplicationDb1.sys.sql_modules m ON m.object_id=t.object_id WHERE t.name=N'CCQuickLogRequests_Insert' AND t.is_disabled=0 AND m.definition LIKE N'%CC_QUICK_LOG_ACCOUNT_20261116%')
 AND EXISTS(SELECT 1 FROM ApplicationDb5.sys.procedures p JOIN ApplicationDb5.sys.sql_modules m ON m.object_id=p.object_id WHERE p.name=N'CC_quick_log_sp' AND m.definition LIKE N'%CC_QUICK_LOG_ACCOUNT_20261116%') THEN 1 ELSE 0 END);
SET cc_account_replay = (SELECT CASE WHEN EXISTS(
 SELECT 1 FROM ApplicationDb1.dbo.CCQuickLogRequests r JOIN ApplicationDb3.dbo.Current_session s ON LOWER(LTRIM(RTRIM(r.Username)))=LOWER(LTRIM(RTRIM(s.Username)))
 WHERE r.SubmissionID=TRY_CONVERT(uniqueidentifier,:submission_id) AND s.session_id=sqlpage.cookie('session')
) THEN 1 ELSE 0 END);
INSERT INTO ApplicationDb1.dbo.CCQuickLogRequests
 (SubmissionID,InputSession,InputCsrf,InputCaseID,InputRegNo,InputEvent,InputSeat,InputComments)
SELECT TRY_CONVERT(uniqueidentifier,:submission_id),sqlpage.cookie('session'),:csrf_token,:case_id,:reg_no,:event,:seat,(SELECT 3 AS version,:case_snapshot AS baseSnapshot,JSON_QUERY(:comments_json) AS rows,CASE WHEN :account_context_version='1' THEN NULLIF(LTRIM(RTRIM(CAST(:zoho_account_id AS nvarchar(200)))),N'') END AS accountId FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
WHERE sqlpage.request_method()='POST'
 AND (NULLIF(LTRIM(RTRIM(CAST(:zoho_account_id AS nvarchar(200)))),N'') IS NULL OR $cc_account_replay='1' OR (:account_context_version='1' AND $cc_account_supported='1'))
 AND TRY_CONVERT(uniqueidentifier,:submission_id) IS NOT NULL
 AND EXISTS(SELECT 1 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username)))
 WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14)
 AND :csrf_token=CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(nvarchar(max),N'CCQuickLog:'+s.session_id)),2));

SELECT 'json' AS component,(SELECT
 CAST(CASE WHEN r.SubmissionID IS NOT NULL THEN 1 ELSE 0 END AS bit) AS success,
 CASE WHEN r.SubmissionID IS NOT NULL THEN N'saved' ELSE N'invalid_request' END AS status,
 r.CaseID AS caseId,r.SavedCount AS insertedComments,CONVERT(nvarchar(36),r.SubmissionID) AS submissionId,
 CASE WHEN r.SubmissionID IS NOT NULL THEN N'All communications saved. Zoho confirmation is pending.' ELSE N'The request could not be saved. Sign in again and check the entries.' END AS message
 FROM (SELECT 1 AS n) seed OUTER APPLY(SELECT TOP(1) request.SubmissionID,request.CaseID,request.SavedCount
 FROM ApplicationDb1.dbo.CCQuickLogRequests request JOIN ApplicationDb3.dbo.Current_session s ON LOWER(LTRIM(RTRIM(request.Username)))=LOWER(LTRIM(RTRIM(s.Username)))
 JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username)))
 WHERE request.SubmissionID=TRY_CONVERT(uniqueidentifier,:submission_id) AND s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14)
 AND :csrf_token=CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(nvarchar(max),N'CCQuickLog:'+s.session_id)),2)) r
 FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) AS contents;
