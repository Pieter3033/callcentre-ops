/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'main.sql' as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end)+'","title":"Event","icon":"alert-hexagon"}') as menu_item
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
      ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
SELECT 'alert' AS component
      ,$reg_no + ' - ' + $event AS title
      ,'info-hexagon' AS icon
      ,'azure' AS color


SELECT 'alert' AS component
      ,'Zoho Reference' AS title
,'The "Zoho ID" will always take you to the single record.
* Zoho OB: **' || (SELECT TRIM(Reference) FROM ApplicationDb5.dbo.CC_quick_log WHERE seqno = $seqno) ||'**
* Zoho ID: **' || (SELECT TRIM(zoho_id) FROM ApplicationDb5.dbo.CC_quick_log WHERE seqno = $seqno) || '**
' AS description_md
      ,'info-hexagon' AS icon
      ,'yellow' AS color
WHERE $seqno is not null
--------------------------------------------------------
/**Form Component**/
SELECT 'form' AS component
      ,'quick_create_f.sql?reg_no='+ $reg_no + '&event='+$event AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color
WHERE $seqno is null

SELECT 
       'Operator' AS label
       ,'operator' AS name
       ,'4' AS width
       ,(SELECT operator as label, id as value FROM ApplicationDb5.[dbo].[cc_operators] order by id FOR JSON AUTO) as options
       ,'TRUE' as required
       ,'TRUE' AS dropdown
       ,'select' AS type
WHERE $seqno is null

SELECT 
       'Seat' AS label
       ,'seat' AS name
       ,'4' AS width
       ,(SELECT seat as label, id as value FROM ApplicationDb5.[dbo].[cc_seats] order by id FOR JSON AUTO) as options
       ,'TRUE' as required
       ,'TRUE' AS dropdown
       ,'select' AS type
WHERE $seqno is null
SELECT 
       'Incident Type' AS label
       ,'incident_type' AS name
       ,'4' AS width
       ,(SELECT incident_type as label, id as value FROM ApplicationDb5.[dbo].[CC_incident_types] order by id FOR JSON AUTO) as options
       ,'TRUE' as required
       ,'TRUE' AS dropdown
       ,'select' AS type
WHERE $seqno is null
SELECT 
       'Contact Name' AS label
       ,'ccc_name' AS name
       ,'Name' AS placeholder
       ,'4' AS width
       ,'TRUE' as required
       ,'Client Name' AS description
WHERE $seqno is null
/**Client contact input**/
SELECT 'Contact Number' AS label
      ,'ccc_number' AS name
      ,'Number' AS placeholder
      ,'4' AS width
      ,'text' AS type
      ,'TRUE' AS required
       ,'TRUE' AS autocomplete
      ,'^[+]?\d+$' AS pattern /*Accepts Only numbers and a optional +*/
      ,'Client Number' as description
WHERE $seqno is null
SELECT 
       'Comms' AS label
       ,'comms' AS name
       ,'4' AS width
       ,(SELECT type as label, id as value FROM ApplicationDb5.[dbo].[CC_comm_types] order by id FOR JSON AUTO) as options
       ,'TRUE' as required
       ,'TRUE' AS dropdown
       ,'select' AS type
       ,'Communication Type' as description
WHERE $seqno is null
SELECT
        'Date' AS label
       ,'date' AS name
       ,'date' AS type
       ,'2' AS width
       ,'Of communication' as description
       ,'TRUE' as required
WHERE $seqno is null
/**Time**/
SELECT
        'Time' AS label
       ,'time' AS name
       ,'time' AS type
       ,'2' AS width
       ,'TRUE' as required
  WHERE $seqno is null
/**SRF Notes**/
SELECT  'Comments' AS label
       ,'cc_comments' AS name
       ,'...' AS placeholder
       ,'TRUE' AS required
       ,'textarea' AS type WHERE $seqno is null

select 
    'Close Case' as label,
    'close'    as name,
    'checkbox' as type,
    'Note: This will close the Open Case' as description
