INSERT INTO ApplicationDb5.[dbo].[CC_operators]
(      [operator]
      ,[id])
VALUES
(
:operator
,(SELECT TOP (1) [id]
  FROM ApplicationDb5.[dbo].[CC_operators] order by id desc) + 1

)

SELECT 'redirect' as component
,'add_operator.sql' AS link