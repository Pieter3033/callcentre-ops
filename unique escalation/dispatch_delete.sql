SELECT 
       'shell_27'       AS component
       ,'true' as sidebar
       ,'fluid' as layout
      ,' ' AS title
      ,'dispatch_teams.sql'  AS link
      ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
      ,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
      ,('{"link":"dispatch_teams.sql","title":"Dispatch Teams","icon":"ambulance"}') as menu_item
      ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,' ' AS footer;


SELECT 'alert_edited_2' AS component
      ,'Delete Dispatch Preference' AS title
      ,'file-description' AS icon
      ,'red' AS color
      ,'### Duplicate
* Company: **' + (SELECT TOP(1) Company FROM ApplicationDb1.dbo.dispatch_teams WHERE seqno = $) + '**
' AS description_md


SELECT
       'dispatch_delete_f.sql?=' + $ AS link
      ,'Red' AS color
      ,'Delete' AS title


-------------------------------------------------------------------------------------
SELECT 'table_dispatch_teams' AS component
       ,'TRUE' AS sort
       ,'icon' AS icon
       ,'TRUE' AS search
       ,'Selected Record' AS title

SELECT
 Company AS Company
,CASE WHEN capital_air = 0 THEN 'FALSE' ELSE 'TRUE' END AS "Dispatch Provider A"
,CASE WHEN ProviderB = 0 THEN 'FALSE' ELSE 'TRUE' END AS ProviderB
,CASE WHEN provider_c = 0 THEN 'FALSE' ELSE 'TRUE' END AS "Provider C"
,seqno as seqno
FROM ApplicationDb1.dbo.dispatch_teams WHERE seqno = $
