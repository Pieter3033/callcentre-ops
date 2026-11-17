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
      ,('{"link":"zoho_link.html","title":"Link Escalations","icon":"circles-relation"}') as menu_item
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
      ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
select 
    'chart'             as component,
    'bar'               as type,
    'Quick Log Live Statistics' || ' (' || (SELECT COUNT(DISTINCT reference) from ApplicationDb5.[dbo].[CC_quick_log] where reference is not null) || ')' as title,
    'blue' as color,
    'TRUE'                as horizontal,
    '550'               as height,
    'TRUE'                as labels;
SELECT 
    CC_operator AS label,
    COUNT(DISTINCT reference) AS value
FROM ApplicationDb5.[dbo].[CC_quick_log] a
GROUP BY CC_operator
order by COUNT(reference);
