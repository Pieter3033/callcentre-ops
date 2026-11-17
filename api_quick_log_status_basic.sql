WITH access_check AS(SELECT CASE WHEN EXISTS(SELECT 1 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username))) WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14)) THEN 1 ELSE 0 END AS allowed)
SELECT 'json' AS component,(SELECT CAST(a.allowed AS bit) AS authorized,
 CASE WHEN a.allowed=0 THEN N'unauthorized' WHEN q.seqno IS NULL THEN N'not_found' ELSE N'ok' END AS status,
 CASE WHEN q.seqno IS NULL THEN N'Unavailable' ELSE N'Pending' END AS syncState,
 N'Zoho confirmation is not available for this workflow yet.' AS syncMessage,
 JSON_QUERY((SELECT c.comm_id AS commId,c.case_id AS caseId,c.comm_type AS commType,c.contact_name AS contactName,c.contact_no AS contactNo,
 c.email_address AS emailAddress,c.comments,c.cc_operator AS ccOperator,CONVERT(nvarchar(19),c.datetime_comm,120) AS datetimeComm,
 c.zoho_pushed AS zohoPushed FROM ApplicationDb1.dbo.quick_log_Comments c WHERE c.case_id=q.seqno ORDER BY c.comm_id FOR JSON PATH)) AS quickLogComments
 FROM access_check a LEFT JOIN ApplicationDb5.dbo.CC_quick_log q ON a.allowed=1 AND q.seqno=TRY_CONVERT(int,$seqno)
 AND UPPER(LTRIM(RTRIM(q.reg_no)))=UPPER(LTRIM(RTRIM(CAST($reg_no AS nvarchar(100))))) AND q.event=CAST($event AS nvarchar(200))
 FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) AS contents;
