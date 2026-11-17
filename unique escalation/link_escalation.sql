SELECT  'cookie' as component
       ,'regg' as name
       ,TRUE as remove


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
      ,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
      ,('{"link":"dispatch_teams.sql","title":"Dispatch Teams","icon":"ambulance"}') as menu_item
      ,('{"link":"add_operator.sql","title":"CC Operators","icon":"user"}') as menu_item
      ,('{"link":"link_escalation.sql","title":"Link Escalations","icon":"circles-relation"}') as menu_item
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
      ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------

SELECT 'table_unique_escalation_add' AS component
       ,'TRUE' AS sort
       ,'icon' AS icon
       ,'TRUE' AS search
       ,'Active Escalations' AS title


SELECT
    C.Company AS "Company",
    C.Fleet_Code AS "Fleet",
    COALESCE(AZ.[Account_Name], 'N/A') AS "Zoho Account"
FROM ApplicationDb3.[dbo].[Companies] C
LEFT JOIN ApplicationDb5.[dbo].[Accounts_ZOHO] AZ
    ON AZ.[zoho_id] = C.[escallation_no]

order by company
