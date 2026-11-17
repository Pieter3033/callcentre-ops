SELECT 'json' AS component,
       (
           SELECT
               (
                   SELECT
                       AZ.[zoho_id] AS id,
                       AZ.[Account_Name] AS label
                   FROM ApplicationDb5.[dbo].[Accounts_ZOHO] AZ
                   WHERE AZ.[zoho_id] IS NOT NULL
                     AND AZ.[Account_Name] IS NOT NULL
                     AND AZ.[Account_no] IS NOT NULL
                   ORDER BY AZ.[Account_Name]
                   FOR JSON PATH
               ) AS Rows
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
       ) AS contents;
