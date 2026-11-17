SELECT 
       'shell_27'       AS component
       ,'true' as sidebar
       ,'fluid' as layout
      ,' ' AS title
      ,'dispatch_teams.sql'  AS link
      ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
      ,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
      ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,' ' AS footer
      ,'table_url_pass_dispatch.js' as javascript;

SELECT 'alert' AS component
      ,'### Deleted Dispatch Preference' AS description_md
      ,'alert-square-rounded' AS icon
      ,'red' AS color
      ,'TRUE' AS dismissible
      WHERE
$del IS NOT NUll

SELECT 'alert' AS component
      ,'### Added Dispatch Preference' AS description_md
      ,'alert-square-rounded' AS icon
      ,'Green' AS color
      ,'TRUE' AS dismissible
      WHERE
$com IS NOT NUll



SELECT 'alert' AS component
      ,'### Duplicate
* Company: **' + (SELECT TOP(1) Company FROM Companies WHERE Company_id = $dup) + '**
* Please delete the existing entry and create a new one if needed.
' AS description_md
      ,'alert-square-rounded' AS icon
      ,'red' AS color
      ,'TRUE' AS dismissible
      WHERE
$dup IS NOT NUll

select 
    'form' as component
    ,'dispatch_teams_f.sql' AS action
    ,'Add New' as title
    ,'Submit' AS validate
    ,'blue' AS validate_color

SELECT 
       'Company' AS label
       ,'company_el' AS name
       ,'select' AS type
       ,(SELECT DISTINCT Company AS label, Company_id AS value FROM Companies FOR JSON AUTO)AS options
       ,'TRUE' as required
       ,'TRUE' AS dropdown

select 
    'ca[]'              as name,
    'checkbox'                  as type,
    'Dispatch Provider A'                   as label;
select 
    'ProviderB[]' as name,
    'checkbox'     as type,
    'ProviderB'       as label;
select 
    'pandc[]' as name,
    'checkbox'     as type,
    'Provider C'     as label;
select 'divider' as component
SELECT 'table_dispatch_teams' AS component
       ,'TRUE' AS sort
       ,'icon' AS icon
       ,'TRUE' AS search
       ,'Unique Dispatch Preferences (Select one to Delete)' AS title

SELECT
 Company AS Company
,CASE WHEN capital_air = 0 THEN 'FALSE' ELSE 'TRUE' END AS "Dispatch Provider A"
,CASE WHEN ProviderB = 0 THEN 'FALSE' ELSE 'TRUE' END AS ProviderB
,CASE WHEN provider_c = 0 THEN 'FALSE' ELSE 'TRUE' END AS "Provider C"
,seqno as seqno
FROM ApplicationDb1.dbo.dispatch_teams
