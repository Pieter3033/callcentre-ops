-- Run only through SQLPage's active configured connection. This is entirely read-only.
SELECT 'json' AS component,(SELECT CONVERT(nvarchar(33),SYSDATETIMEOFFSET(),126) AS checkedAt,
 DB_NAME() AS configuredDatabase,CONVERT(nvarchar(128),SERVERPROPERTY('ServerName')) AS configuredServer,
 CAST(CASE WHEN OBJECT_ID('ApplicationDb1.dbo.CCQuickLogRequests','U') IS NOT NULL THEN 1 ELSE 0 END AS bit) AS requestsInstalled,
 CAST(CASE WHEN COL_LENGTH('ApplicationDb1.dbo.CCQuickLogSync','CreateInFlight') IS NOT NULL THEN 1 ELSE 0 END AS bit) AS queueInstalled,
 CAST(CASE WHEN COL_LENGTH('ApplicationDb1.dbo.quick_log_Comments','zoho_row_id') IS NOT NULL THEN 1 ELSE 0 END AS bit) AS commentTrackingInstalled,
 JSON_QUERY((SELECT q.zoho_insert AS flag,
 CASE WHEN NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NULL THEN 0 ELSE 1 END AS hasId,
 CASE WHEN NULLIF(LTRIM(RTRIM(q.reference)),N'') IS NULL THEN 0 ELSE 1 END AS hasReference,
 COUNT_BIG(*) AS records,MIN(q.datetime_opened) AS oldestOpened
 FROM ApplicationDb5.dbo.CC_quick_log q
 WHERE NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NULL OR NULLIF(LTRIM(RTRIM(q.reference)),N'') IS NULL
 GROUP BY q.zoho_insert,CASE WHEN NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NULL THEN 0 ELSE 1 END,
 CASE WHEN NULLIF(LTRIM(RTRIM(q.reference)),N'') IS NULL THEN 0 ELSE 1 END FOR JSON PATH)) AS incompleteGroups,
 JSON_QUERY((SELECT j.name,j.enabled,st.step_id,st.database_name,st.command FROM ApplicationDb4.dbo.sysjobs j
 JOIN ApplicationDb4.dbo.sysjobsteps st ON st.job_id=j.job_id WHERE j.name=N'CC_Quick_Log' FOR JSON PATH)) AS existingWorkerJob,
 (SELECT value_in_use FROM sys.configurations WHERE name=N'Ole Automation Procedures') AS existingOleAutomationEnabled
 FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) AS contents;
