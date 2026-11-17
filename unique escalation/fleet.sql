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
   --   ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
      ,'test.js' as javascript
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
    --  ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------

--------------------------------------------------------


SELECT 
  'form' AS component,
  CASE WHEN $cid IS NULL THEN 'fleet_f.sql' ELSE 'fleet_f.sql?cid=' + $cid END  AS action,
  'Submit' AS validate;

-- Company dropdown
SELECT 
  'Company' AS label,
  'company_id' AS name,
  'select' AS type,
  'TRUE' as disabled,
  $cid as value,
  (SELECT DISTINCT Company as label, company_id as value FROM Companies WHERE company_id = $cid FOR JSON AUTO) AS options
  ,'Company is Locked' as description
  WHERE $cid is not null

SELECT 
  'Company' AS label,
  'company_id' AS name,
  'select' AS type,
  (SELECT DISTINCT Company as label, company_id as value FROM Companies FOR JSON AUTO) AS options
    ,'TRUE' as required
WHERE $cid is null

-- Fleet dropdown (starts empty)
SELECT 
  'Fleet' AS label,
  'fleet_id' AS name,
  'select' AS type,
  (SELECT fleet_id as value, fleet_code as label FROM Companies WHERE company_id = $cid FOR JSON AUTO) AS options,
  'fleet-select' AS id
WHERE $cid is not null


