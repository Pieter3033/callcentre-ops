SELECT 'redirect' as component
      ,'delete_selected.sql?id=' + $id +'&not_val=0' as link
WHERE UPPER(:confirm) <> 'CONFIRM'

UPDATE ApplicationDb1.dbo.el_info set completed = -1 WhERE id = $id

INSERT INTO ApplicationDb1.dbo.[deleted_escalations]
( [id]
      ,[deleted_by])
VALUES
(
 $id
,sqlpage.cookie('username')
)

SELECT 'redirect' as component
      ,'delete.sql?id=' + $id +'&val=1' as link