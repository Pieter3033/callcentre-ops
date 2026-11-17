/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'edit_selected_2.sql?id=' + $id as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      --,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
     -- ,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
      ,' ' as footer
       ,'cc_escalation_delete.js' AS javascript;
    --  ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
/**Tab Component**/
SELECT 
       'tab' AS component
      ,'TRUE'  AS center;

SELECT --Add User Tab
       'Day Escalation' AS title
      ,'sun' AS icon
      ,'edit_selected_1.sql?id=' + $id as link
     

SELECT --Delete User Tab
       'Night Escalation' AS title
      ,'moon' AS icon
      ,'edit_selected_2.sql?id=' + $id AS link
 ,'TRUE' AS active

SELECT --Reset Password Tab
       'Weekend Escalation' AS title
      ,'calendar-event' AS icon
      ,'edit_selected_3.sql?id=' + $id AS link;
      
SELECT 
       'General Notes' AS title
      ,'layers-intersect' AS icon
      ,'edit_selected_4.sql?id=' + $id AS link;
------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Updated Escalation' AS title
      ,'info-hexagon' AS icon
      ,'TRUE' as dismissible
      ,'green' AS color
WHERE $val is not null
------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Edit Escalation' AS title
      ,'> Company: **' + (SELECT TOP(1) Company FROM ApplicationDb1.dbo.el_info Where id = $id) + '**
>
> '+'Reference - '+CASE WHEN (select reg_escalation from ApplicationDb1.dbo.el_info where id = $id) = 0 then 'Fleet: **' + (SELECT Fleet_Code FROM ApplicationDb1.dbo.el_info WHERE id = $id) else 'Registration: **' + (SELECT reg_no FROM ApplicationDb1.dbo.el_info where id = $id) END +'**'as description_md
      ,'info-hexagon' AS icon
      ,'azure' AS color
------------------------------------------------------------------------
/**Form Component**/
SELECT 'form' AS component
      ,'edit_selected_2_f.sql?id=' + $id AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color

SELECT 'header' AS type, 'Night Contacts' AS label, 'These fields are not compulsary.' AS description

SELECT 
       'Name - 1' AS label
       ,'night_1_n' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,(SELECT [n_c_name_1] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Number - 1' AS label
       ,'night_1_c' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern
       ,(SELECT [n_c_no_1] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Alternative Number - 1' AS label
       ,'night_1_ac' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern
       ,(SELECT [n_c_alt_no_1] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Notes - 1' AS label
       ,'night_1_notes' AS name
       ,'...' AS placeholder
       ,'12' AS width
      ,'textarea' as type
      ,(SELECT [n_c_notes_1] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value
--------------------------------------------------------
SELECT 'separator' AS type 

-- NIGHT CONTACT 2
SELECT 
       'Name - 2' AS label,
       'night_2_n' AS name,
       '...' AS placeholder,
       '4' AS width,
       (SELECT [n_c_name_2] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Number - 2' AS label,
       'night_2_c' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_no_2] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Alternative Number - 2' AS label,
       'night_2_ac' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_alt_no_2] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Notes - 2' AS label,
       'night_2_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type,
       (SELECT [n_c_notes_2] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

--------------------------------------------------------
SELECT 'separator' AS type 

-- NIGHT CONTACT 3
SELECT 
       'Name - 3' AS label,
       'night_3_n' AS name,
       '...' AS placeholder,
       '4' AS width,
       (SELECT [n_c_name_3] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Number - 3' AS label,
       'night_3_c' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_no_3] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Alternative Number - 3' AS label,
       'night_3_ac' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_alt_no_3] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Notes - 3' AS label,
       'night_3_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type,
       (SELECT [n_c_notes_3] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

--------------------------------------------------------
SELECT 'separator' AS type 

-- NIGHT CONTACT 4
SELECT 
       'Name - 4' AS label,
       'night_4_n' AS name,
       '...' AS placeholder,
       '4' AS width,
       (SELECT [n_c_name_4] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Number - 4' AS label,
       'night_4_c' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_no_4] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Alternative Number - 4' AS label,
       'night_4_ac' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_alt_no_4] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Notes - 4' AS label,
       'night_4_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type,
       (SELECT [n_c_notes_4] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

--------------------------------------------------------
SELECT 'separator' AS type 

-- NIGHT CONTACT 5
SELECT 
       'Name - 5' AS label,
       'night_5_n' AS name,
       '...' AS placeholder,
       '4' AS width,
       (SELECT [n_c_name_5] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Number - 5' AS label,
       'night_5_c' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_no_5] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Alternative Number - 5' AS label,
       'night_5_ac' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern,
       (SELECT [n_c_alt_no_5] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value

SELECT 
       'Notes - 5' AS label,
       'night_5_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type,
       (SELECT [n_c_notes_5] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) AS value
