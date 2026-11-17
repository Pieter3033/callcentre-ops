SELECT 'json' AS component,
       (
           SELECT
               'companies' AS DataType,
               (
                   SELECT
                       C.Company AS Company,
                       C.Fleet_Code AS Fleet,
                       COALESCE(AZ.[Account_Name], 'N/A') AS ZohoAccount,
                       AZ.[zoho_id] AS ZohoId,
                       CASE WHEN EXISTS (
                           SELECT 1
                           FROM ApplicationDb1.dbo.el_info EI
                           WHERE EI.Company = C.Company
                             AND EI.Fleet_Code = C.Fleet_Code
                             AND EI.completed = 1
                       ) THEN 1 ELSE 0 END AS HasUniqueEscalation,
                       (SELECT TOP (1) EI.ID
                        FROM ApplicationDb1.dbo.el_info EI
                        WHERE EI.Company = C.Company
                          AND EI.Fleet_Code = C.Fleet_Code
                          AND EI.completed = 1
                        ORDER BY EI.ID DESC) AS UniqueEscalationId
                   FROM ApplicationDb3.[dbo].[Companies] C
                   LEFT JOIN ApplicationDb5.[dbo].[Accounts_ZOHO] AZ
                       ON AZ.[zoho_id] = C.[escallation_no]
                   ORDER BY C.Company
                   FOR JSON PATH
               ) AS Rows
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
       ) AS contents;
