UPDATE [DATABASE_SERVER].ApplicationDb2.dbo.company
SET FleetSageReference = :new_zoho_id
WHERE RecNo = (
  SELECT TOP (1) Fleet_id
  FROM ApplicationDb3.dbo.Companies
  WHERE Company = :company AND Fleet_Code = :fleet_code
);

UPDATE ApplicationDb3.dbo.Companies
SET escallation_no = :new_zoho_id
WHERE Company = :company AND Fleet_Code = :fleet_code;

INSERT INTO ApplicationDb1.dbo.mapping_log (
    log_datetime,
    company,
    fleet_code,
    old_zoho_account,
    new_zoho_account,
    username
)
SELECT
    DATEADD(HOUR, 2, SYSUTCDATETIME()),
    C.Company,
    C.Fleet_Code,
    AZ_old.Account_Name,
    AZ_new.Account_Name,
    sqlpage.cookie('username')
FROM ApplicationDb3.dbo.Companies C
LEFT JOIN ApplicationDb5.dbo.Accounts_ZOHO AZ_old
    ON AZ_old.zoho_id = C.escallation_no
LEFT JOIN ApplicationDb5.dbo.Accounts_ZOHO AZ_new
    ON AZ_new.zoho_id = :new_zoho_id
WHERE C.Company = :company AND C.Fleet_Code = :fleet_code;

SELECT 'json' AS component,
       (
           SELECT
               'ok' AS status
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
       ) AS contents;
