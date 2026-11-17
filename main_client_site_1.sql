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
      ,('{"link":"info.sql?reg_no=' + $reg_no + '&event='+$event+'","title":"Information","icon":"info-hexagon"}') as menu_item
      ,' ' as footer
      ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
select 
    'datagrid_4'              as component,
    (SELECT TOP(1) Company FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) as title,
   'https://example.invalid/configure-endpoint' as image_url,
    'Account information' as description_md;
select 
    'Zoho Account'  as title,
    'Account on Zoho'as tooltip
    
  --  (SELECT top(1) account_name FROM ApplicationDb5.dbo.accounts_zoho WHERE Account_no = (SELECT top(1) acc_no FROM ApplicationDb3.dbo.companies where company = (SELECT top(1) company from ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) )) as description,
  --  'https://example.invalid/configure-endpoint' + (SELECT top(1) zoho_id FROM ApplicationDb5.dbo.accounts_zoho WHERE Account_no = (SELECT top(1) acc_no FROM ApplicationDb3.dbo.companies where company = (SELECT top(1) company from ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) )) as link
select 
    'MSTrack Company' as title,
     (SELECT TOP(1) Company FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) as description
 --    'https://example.invalid/configure-endpoint' + casT(SELECT top(1) customerid FROM ApplicationDb6.dbo.Company WHERE company = (SELECT top(1) company from ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) ) AS VARCHAR(MAX) AS customerid

SELECT 'Registration' as title
    ,$reg_no as description
    ,'yellow' as color

SELECT 'Fleet' as title
    ,(SELECT TOP(1) fleet_code FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) as description
 --   ,'azure' as color

SELECT 'Event' as title
    ,$event as description
    ,'yellow' as color

SELECT 'Vehicle Description' as title
    ,(SELECT TOP(1) vehdesc FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) as description

------------------------------------------------------------------------------

SELECT 'Dispatch Team' as title
      ,'ambulance' as icon
      ,CASE WHEN capital_air = 1 and ProviderB = 0 and provider_c = 0 THEN 'Dispatch Provider A' 
            WHEN capital_air = 0 and ProviderB = 1 and provider_c = 0 THEN 'ProviderB' 
            WHEN capital_air = 0 and ProviderB = 0 and provider_c = 1 THEN 'Provider C' 
            WHEN capital_air = 1 and ProviderB = 1 and provider_c = 0 THEN 'Dispatch Provider A | ProviderB' 
            WHEN capital_air = 1 and ProviderB = 0 and provider_c = 1 THEN 'Dispatch Provider A | Provider C' 
            WHEN capital_air = 0 and ProviderB = 1 and provider_c = 1 THEN 'Provider C | ProviderB' 
            WHEN capital_air = 1 and ProviderB = 1 and provider_c = 1 THEN 'Dispatch Provider A | Provider C | ProviderB' 
            WHEN capital_air = 0 and ProviderB = 0 and provider_c = 0 THEN 'Dispatch Provider A | Provider C'
            END as description
      ,'red' as color
FROM ApplicationDb1.dbo.dispatch_teams
WHERE Company =  (SELECT Company FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no)


SELECT 'Dispatch Team' as title
      ,'ambulance' as icon
      ,'Dispatch Provider A | Provider C' as description
      ,'red' as color
WHERE (SELECT TOP(1) Company FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) NOT IN (Select DISTINCT Company FROM ApplicationDb1.dbo.dispatch_teams)


------------------------------------------------------------------------------
------------------------------------------------------------------------------
SELECT 'alert_edited' AS component
     ,'Client Site 1' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,'* Follow the below escalation list between office hours Monday - Friday 06:00 - 19:00

      
* Follow the Zoho Escalation list for the CLIENT Subcontractor after hours (19:00 - 06:00) and Weekends' as description_md

------------------------------------------------------------------------------
select 
    'datagrid_4'              as component,
    'Day Contacts' as title
select 
    'Contact - 1' as title,
    'Example Contact 01'  as description,
    'cyan' as color



select 
    'Number - 1' as title,
    '' as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color

select 
    'Notes - 1' as title,
    'Configure private contact notes.' as description,
    'yellow' as color

select 
    'Alternative - 1' as title,
    ''   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color

---------------------------------------------------------------------------
select 
    'Contact - 2' as title,
    'Example Contact 02'  as description,
    'cyan' as color



select 
    'Number - 2' as title,
    '' as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color

select 
    'Notes - 2' as title,
    'Configure private contact notes.' as description,
    'yellow' as color

select 
    'Alternative - 2' as title,
    ''   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
---------------------------------------------------------------
select 
    'Contact - 3' as title,
    'Example Contact 03'  as description,
    'cyan' as color



select 
    'Number - 3' as title,
    '' as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color

select 
    'Notes - 3' as title,
    'Configure private contact notes.' as description,
    'yellow' as color

select 
    'Alternative - 3' as title,
    ''   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
----------------------------------------------------------------
