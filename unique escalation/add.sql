/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'add.sql' as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
    --  ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
    --  ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
/**Tab Component**/
SELECT 
       'tab' AS component
      ,'TRUE'  AS center;

SELECT --Add User Tab
       'Add Escalation' AS title
      ,'TRUE' AS active
      ,'user-plus' AS icon
      ,'add.sql' as link;

SELECT --Delete User Tab
       'Edit Escalation' AS title
      ,'user-x' AS icon
      ,'edit.sql' AS link; --Reverts to Delete user

SELECT --Reset Password Tab
       'Delete Escalation' AS title
      ,'user-exclamation' AS icon
      ,'delete.sql' AS link;
--------------------------------------------------------
SELECT 'card' AS component

/**New JobCard**/
SELECT  'embed1.sql?_sqlpage_embed' AS embed
       ,6 as width
       ,'200' as height
       ,'gray-900' as background_color;

SELECT  'embed2.sql?_sqlpage_embed' AS embed
       ,6 as width
       ,'100' as height
       ,'gray-900' as background_color;

SELECT 'alert' AS component
      ,'Escalation Successfully created' AS title
      ,'> Company: **' + (SELECT Company FROM ApplicationDb1.dbo.el_info where id = $id) + '**' +
      ' 
> 
> ' + 
      CASE WHEN (select reg_escalation from ApplicationDb1.dbo.el_info where id = $id) = 1 THEN 'Registration: **' + (SELECT reg_no FROM ApplicationDb1.dbo.el_info where id = $id) + '**' ELSE 'Fleet: **' + (SELECT Fleet_code FROM ApplicationDb1.dbo.el_info where id = $id) + '**' end as description_md
      ,'info-hexagon' AS icon
      ,'green' AS color
      ,'TRUE' as dismissible
WHERE $id is not null



SELECT 'table_unique_escalation_add' AS component
       ,'TRUE' AS sort
       ,'icon' AS icon
       ,'TRUE' AS search
       ,'Active Escalations' AS title


/**Icons**/
SELECT
 CASE WHEN reg_escalation = 1 then 'Registration' WHEN fleet_escalation = 1 THEN 'Fleet' ELSE 'N/A' END AS 'Escalation Type'
,CASE WHEN reg_escalation = 1 then [reg_no] WHEN fleet_escalation = 1 THEN [fleet_code] ELSE 'N/A' END AS 'Escalation Ref'
,Company as Company
,uploaded_by as 'Created By'
,FORMAT(CAST(datetime_uploaded AS DATETIMEOFFSET), 'dd-MM-yyyy HH:mm') as 'Created Date'
FROM ApplicationDb1.dbo.el_info WHERE completed = 1
