----------------------------------------------------------------------------------------------------------------
/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       --,'insert_reg_1.sql?regg=' + $regg as link
       ,CASE WHEN $fid is null then 'insert_reg_1.sql?regg=' + $regg ELSE 'insert_reg_1.sql?fid=' + $fid END as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
----------------------------------------------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Escalation Setup' AS title
      ,'Registration: **' + $regg + '**' as description_md
      ,'info-hexagon' AS icon
      ,'azure' AS color
WHERE $regg is not null

SELECT 'alert' AS component
      ,'Escalation Setup' AS title
      ,'> Company: **' + (SELECT TOP(1) Company FROM Companies where fleet_id = $fid) + '**
>
> Fleet: **' + (SELECT TOP(1) Fleet_code from companies where fleet_id = $fid) + '**' as description_md
      ,'info-hexagon' AS icon
      ,'azure' AS color
WHERE $fid is not null

/**Form Component**/
SELECT 'form' AS component
      ,CASE WHEN $regg is not null then 'insert_reg_1_f.sql?regg=' + $regg ELSE 'fleet_insert_1_f.sql?fid=' + $fid end AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color

SELECT 'header' AS type, 'Day Contacts' AS label, 'The First Contact is compulsary.' AS description


SELECT 
       'Name - 1' AS label
       ,'day_1_n' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'TRUE' as required

SELECT 
       'Number - 1' AS label,
       'day_1_c' AS name,
       '...' AS placeholder,
       '4' AS width,
       'TRUE' AS required,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern


SELECT 
       'Alternative Number - 1' AS label
       ,'day_1_ac' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' AS pattern
SELECT 
       'Notes - 1' AS label
       ,'day_1_notes' AS name
       ,'...' AS placeholder
       ,'12' AS width
      ,'textarea' as type
--------------------------------------------------------
SELECT 'separator' AS type  

SELECT 
       'Name - 2' AS label
       ,'day_2_n' AS name
       ,'...' AS placeholder
       ,'4' AS width

SELECT 
       'Number - 2' AS label
       ,'day_2_c' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 2' AS label
       ,'day_2_ac' AS name
       ,'...' AS placeholder
       ,'4' AS width
,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 2' AS label
       ,'day_2_notes' AS name
       ,'...' AS placeholder
       ,'12' AS width
      ,'textarea' as type
--------------------------------------------------------
SELECT 'separator' AS type  

SELECT 
       'Name - 3' AS label,
       'day_3_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 3' AS label,
       'day_3_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 3' AS label,
       'day_3_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 3' AS label,
       'day_3_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
-----------------------------------------
SELECT 'separator' AS type  

SELECT 
       'Name - 4' AS label,
       'day_4_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 4' AS label,
       'day_4_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 4' AS label,
       'day_4_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 4' AS label,
       'day_4_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type

--------------------------------------------------------
SELECT 'separator' AS type  

SELECT 
       'Name - 5' AS label,
       'day_5_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 5' AS label,
       'day_5_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 5' AS label,
       'day_5_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 5' AS label,
       'day_5_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type

--------------------------------------------------------
SELECT 'separator' AS type  
SELECT 'separator' AS type  

select 
    'header'  as type,
    'Night Contacts' as label;
--------------------------------------------------------

SELECT 
       'Name - 1' AS label
       ,'night_1_n' AS name
       ,'...' AS placeholder
       ,'4' AS width

SELECT 
       'Number - 1' AS label
       ,'night_1_c' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 1' AS label
       ,'night_1_ac' AS name
       ,'...' AS placeholder
       ,'4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 1' AS label
       ,'night_1_notes' AS name
       ,'...' AS placeholder
       ,'12' AS width
      ,'textarea' as type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 2' AS label,
       'night_2_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 2' AS label,
       'night_2_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 2' AS label,
       'night_2_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 2' AS label,
       'night_2_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 3' AS label,
       'night_3_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 3' AS label,
       'night_3_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 3' AS label,
       'night_3_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 3' AS label,
       'night_3_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 4' AS label,
       'night_4_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 4' AS label,
       'night_4_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 4' AS label,
       'night_4_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 4' AS label,
       'night_4_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 5' AS label,
       'night_5_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 5' AS label,
       'night_5_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 5' AS label,
       'night_5_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 5' AS label,
       'night_5_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------

SELECT 'separator' AS type 
SELECT 'separator' AS type 

select 
    'header'  as type,
    'Weekend Contacts' as label;
--------------------------------------------------------
SELECT 
       'Name - 1' AS label,
       'we_1_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 1' AS label,
       'we_1_c' AS name,
       '...' AS placeholder,
       '4' AS width,
       '^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern


SELECT 
       'Alternative Number - 1' AS label,
       'we_1_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 1' AS label,
       'we_1_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 2' AS label,
       'we_2_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 2' AS label,
       'we_2_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 2' AS label,
       'we_2_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 2' AS label,
       'we_2_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 3' AS label,
       'we_3_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 3' AS label,
       'we_3_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 3' AS label,
       'we_3_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 3' AS label,
       'we_3_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 4' AS label,
       'we_4_n' AS name,
       '...' AS placeholder,
       '4' AS width
       

SELECT 
       'Number - 4' AS label,
       'we_4_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 4' AS label,
       'we_4_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 4' AS label,
       'we_4_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
--------------------------------------------------------
SELECT 'separator' AS type 

SELECT 
       'Name - 5' AS label,
       'we_5_n' AS name,
       '...' AS placeholder,
       '4' AS width

SELECT 
       'Number - 5' AS label,
       'we_5_c' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Alternative Number - 5' AS label,
       'we_5_ac' AS name,
       '...' AS placeholder,
       '4' AS width
       ,'^(0\\d{9}|\\+27[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{4}|(\\+263|00263)[\\s-]?\\d{2}[\\s-]?\\d{3}[\\s-]?\\d{3})$' as pattern

SELECT 
       'Notes - 5' AS label,
       'we_5_notes' AS name,
       '...' AS placeholder,
       '12' AS width,
       'textarea' AS type
