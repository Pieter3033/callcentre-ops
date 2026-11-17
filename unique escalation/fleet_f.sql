SELECT 'redirect' as component
       ,'fleet.sql?cid=' + :company_id as link
WHERE $cid is null

SELECT 'redirect' AS component,
       'duplicate_fleet.sql?cid=' + $cid + '&fid=' + :fleet_id AS link
WHERE EXISTS (
  SELECT 1
  FROM ApplicationDb1.dbo.el_info
  WHERE fleet_code = (SELECT TOP(1) Fleet_Code FROM Companies WHERE fleet_id = :fleet_id)
    AND Company = (SELECT TOP(1) Company FROM Companies WHERE company_id = $cid) AND Completed = 1
)




SELECT 'redirect' as component
       ,'insert_fleet_1_f.sql?cid=' + $cid + '&fid=' + :fleet_id as link
WHERE $cid is not null