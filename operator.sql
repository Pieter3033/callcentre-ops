SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'operator.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end) as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end)+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,('{"link":"quick_create.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end)+'","title":"Quick Create","icon":"hexagon-plus"}') as menu_item
      ,' ' as footer
      ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
SELECT 'alert' AS component
      ,'Operator: ' + (SELECT operator from ApplicationDb5.dbo.cc_operators WHERE id = sqlpage.cookie('operator')) AS title
      ,'info-hexagon' AS icon
      ,'cyan' AS color
WHERE sqlpage.cookie('operator') is not null

SELECT 'alert' AS component
      ,'No Operator selected' AS title
      ,'info-hexagon' AS icon
      ,'orange' AS color
WHERE sqlpage.cookie('operator') is null

/**Form Component**/
SELECT 'form' AS component
      ,'operator_f.sql?reg_no='+ $reg_no + '&event='+$event AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color

SELECT 
       'Operator' AS label
       ,'operator' AS name
       ,'4' AS width
       ,(SELECT operator as label, id as value FROM ApplicationDb5.[dbo].[cc_operators] order by id FOR JSON AUTO) as options
       ,'TRUE' as required
       ,'TRUE' AS dropdown
       ,'select' AS type
