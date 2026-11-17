/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'reg.sql' as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
     -- ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
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
/**Form Component**/
SELECT 'form' AS component
      ,'reg_f.sql?'AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color

SELECT 
       'Registration' AS label
       ,'regg' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'TRUE' as required
       ,'Make sure the Registration matches the one on the system' AS description

