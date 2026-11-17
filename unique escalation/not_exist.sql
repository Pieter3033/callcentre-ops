----------------------------------------------------------------------------------------------------------------
SELECT  'cookie' as component
       ,'regg' as name
       ,TRUE as remove


/**Default Shell component**/
SELECT 
       'shell_27'       AS component
      ,'fluid'          as layout
      ,''            AS title
      ,'not_exist.sql?=' + $    AS link
       ,'true'           AS sidebar
      ,'en-US'       AS language
      ,'arial'       AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
      ,' '           AS footer;

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
select 
    'alert'         as component,
    'Error!'        as title,
    'Reg: **' || $regg || '** does not exist' as description_md,
    'alert-circle'  as icon,
    'red'           as color;

select 
    'alert'                     as component,
    'Reminder!'                 as title,
    'If the registration matches exactly as it is on the system, please contact the site administrator.' as description_md,
    'alert-triangle'            as icon,
    'yellow'                    as color,
    'TRUE'                      as dismissible;
