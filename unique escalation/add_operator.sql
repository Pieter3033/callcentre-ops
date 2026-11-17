/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'add.sql' as link
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
    --  ,'Make it happen - Perfectly!' AS footer;
/**Form Component**/
SELECT 'form' AS component
      ,'add_operator_f.sql' AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color
WHERE $seqno is null

SELECT 
       'Add Operator' AS label
       ,'operator' AS name
       ,'4' AS width


SELECT 'table_unique_escalation_add' AS component
       ,'TRUE' AS sort
       ,'icon' AS icon
       ,'TRUE' AS search
       ,'CC Operators' AS title


/**Icons**/
SELECT
operator, id
FROM ApplicationDb5.[dbo].[CC_operators]
