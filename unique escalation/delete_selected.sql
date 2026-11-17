/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'delete_selected.sql?id=' + $id as link
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
      ,'cc_escalation_delete.js' AS javascript;
    --  ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
/**Tab Component**/
SELECT 
       'tab' AS component
      ,'TRUE'  AS center;

SELECT --Add User Tab
       'Add Escalation' AS title
     -- ,'TRUE' AS active
      ,'user-plus' AS icon
      ,'add.sql' as link;

SELECT --Delete User Tab
       'Edit Escalation' AS title
      ,'user-x' AS icon
      ,'edit.sql' AS link; --Reverts to Delete user

SELECT --Reset Password Tab
       'Delete Escalation' AS title
      ,'user-exclamation' AS icon
      ,'TRUE' as active
      ,'delete.sql' AS link;
--------------------------------------------------------
------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Delete Escalation' AS title
      ,'> Company: **' + (SELECT TOP(1) Company FROM ApplicationDb1.dbo.el_info Where id = $id) + '**
>
> '+'Reference - '+CASE WHEN (select reg_escalation from ApplicationDb1.dbo.el_info where id = $id) = 0 then 'Fleet: **' + (SELECT Fleet_Code FROM ApplicationDb1.dbo.el_info WHERE id = $id) else 'Registration: **' + (SELECT reg_no FROM ApplicationDb1.dbo.el_info where id = $id) END +'**'as description_md
      ,'alert-hexagon' AS icon
      ,'red' AS color
------------------------------------------------------------------------


/**Form Component**/
SELECT 'form' AS component
      ,'delete_f.sql?id=' + $id AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color

SELECT 
       'CONFIRM' AS label
       ,'confirm' AS name
       ,'Type "Confirm" to delete the escalation.' as description
       ,'...' AS placeholder
       ,'4' AS width
       ,'TRUE' as required


SELECT 'alert' AS component
      ,'Escalation not deleted!' AS title
      ,'Please make sure to type the word "Confirm"' as description_md
      ,'info-hexagon' AS icon
      ,'yellow' AS color
      ,'TRUE' as dismissible
WHERE $not_val is not null
--------------------------------------------------------
/**Table Component**/
SELECT 'table_cc_delete' AS component
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
,id
FROM ApplicationDb1.dbo.el_info WHERE completed = 1
