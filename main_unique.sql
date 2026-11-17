SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'main_unique.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end) as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
     -- ,('{"link":"info.sql?reg_no=' + $reg_no + '&event='+$event+'","title":"Information","icon":"info-hexagon"}') as menu_item
      ,('{"link":"quick_create.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end)+'","title":"Quick Create","icon":"hexagon-plus"}') as menu_item
      ,('{"link":"operator.sql?reg_no=' + $reg_no + '&event='+$event+(CASE WHEN $seqno is null then '' else '&seqno=' end)+(CASE WHEN $seqno is null then '' else $seqno end)+'","title":"Operator","icon":"user-hexagon"}') as menu_item
     
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
    'Account on Zoho'as tooltip,
    (SELECT top(1) account_name FROM ApplicationDb5.dbo.accounts_zoho WHERE Account_no = (SELECT top(1) acc_no FROM ApplicationDb3.dbo.companies where company = (SELECT top(1) company from ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) )) as description,
    'https://example.invalid/configure-endpoint' + (SELECT top(1) zoho_id FROM ApplicationDb5.dbo.accounts_zoho WHERE Account_no = (SELECT top(1) acc_no FROM ApplicationDb3.dbo.companies where company = (SELECT top(1) company from ApplicationDb6.dbo.vehicleinfo where reg_no = $reg_no) )) as link
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

select 
    'Authorization Person' as title,
    [auth_person]   as description,
    'exclamation-circle'        as icon
    ,'red' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE auth_person <> '' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Authorization Notes Person' as title,
    [auth_notes]   as description,
    'exclamation-circle'        as icon,
    'red' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE auth_notes <> '' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Verification Password' as title,
    [verification_password]   as description,
    'exclamation-circle'        as icon
    ,'red' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE verification_password <> '' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Group Notes' as title,
    [group_notes]   as description,
    'exclamation-circle'        as icon
    ,'red' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE group_notes <> '' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

--Registration specific, will not work on other main displays
select 
    'General Note (Registration Specific)' as title,
    [gen_note]   as description,
    'exclamation-circle'        as icon
    ,'red' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE gen_note <> '' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
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
SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [battery_dis_notes] = '' THEN 'No Client notes for event' ELSE battery_dis_notes END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Battery Disconnect' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [trailer_dis_notes] = '' THEN 'No Client notes for event' ELSE [trailer_dis_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Trailer Disconnect'  AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
-------------------------

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [panic_notes] = '' THEN 'No Client notes for event' ELSE [panic_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Panic On' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
----------------------------------
SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [remote_panic_notes] = '' THEN 'No Client notes for event' ELSE [remote_panic_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Remote Panic On' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [tamper_notes] = '' THEN 'No Client notes for event' ELSE [tamper_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Tamper' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [fatigue_notes] = '' THEN 'No Client notes for event' ELSE [fatigue_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Fatigue Alert' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------
	

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [travel_stop_notes] = ''THEN 'No Client notes for event' ELSE [travel_stop_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Travel Stop' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------

------------------------------------------------------------------------------

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [tilt_notes] = '' THEN 'No Client notes for event' ELSE [tilt_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Tilt' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)----------------------------------------------------

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [dph_notes] IS NULL THEN 'No Client notes for event' ELSE [dph_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Door Possible Hijack' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------


SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [dph_notes] = '' THEN 'No Client notes for event' ELSE [dph_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Door Possible Hijack On' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------


SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [jamming_notes] = '' THEN 'No Client notes for event' ELSE [jamming_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Jamming Detected' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------
SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [cap_notes] = '' THEN 'No Client notes for event' ELSE [cap_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Cargo Area Panic On' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------

SELECT 'alert_edited' AS component
     ,$event + ' - Notes' AS title
     ,'alert-hexagon' AS icon
      ,'azure' AS color
      ,CASE WHEN [cap_notes] = '' THEN 'No Client notes for event' ELSE [cap_notes] END as description
      FROM ApplicationDb1.dbo.el_escalation
    WHERE $event = 'Cargo Area Panic' AND id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)
------------------------------------------------------------------------------

select 
    'datagrid_4'              as component,
    'Day Contacts' as title
select 
    'Contact - 1' as title,
    [d_c_name_1]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Number - 1' as title,
    [d_c_no_1] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 1' as title,
    [d_c_notes_1] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 1' as title,
    [d_c_alt_no_1]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

---------------------------------------------------------------------------

select 
    'Contact - 2' as title,
    [d_c_name_2]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 2' as title,
    [d_c_no_2] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 2' as title,
    [d_c_notes_2] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 2' as title,
    [d_c_alt_no_2]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

---------------------------------------------------------------
select 
    'Contact - 3' as title,
    [d_c_name_3]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 3' as title,
    [d_c_no_3] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 3' as title,
    [d_c_notes_3] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 3' as title,
    [d_c_alt_no_3]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------------


select 
    'Contact - 4' as title,
    [d_c_name_4]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 4' as title,
    [d_c_no_4] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 4' as title,
    [d_c_notes_4] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 4' as title,
    [d_c_alt_no_4]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------


select 
    'Contact - 5' as title,
    [d_c_name_5]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 5' as title,
    [d_c_no_5] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 5' as title,
    [d_c_notes_5] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 5' as title,
    [d_c_alt_no_5]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------

select 
    'datagrid_4'              as component,
    'Night Contacts' as title
select 
    'Contact - 1' as title,
    [n_c_name_1]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 1' as title,
    [n_c_no_1] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 1' as title,
    [n_c_notes_1] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 1' as title,
    [n_c_alt_no_1]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

---------------------------------------------------------------------------

select 
    'Contact - 2' as title,
    [n_c_name_2]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 2' as title,
    [n_c_no_2] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 2' as title,
    [n_c_notes_2] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 2' as title,
    [n_c_alt_no_2]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

---------------------------------------------------------------
select 
    'Contact - 3' as title,
    [n_c_name_3]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 3' as title,
    [n_c_no_3] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 3' as title,
    [n_c_notes_3] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 3' as title,
    [n_c_alt_no_3]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------------


select 
    'Contact - 4' as title,
    [n_c_name_4]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 4' as title,
    [n_c_no_4] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 4' as title,
    [n_c_notes_4] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 4' as title,
    [n_c_alt_no_4]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------


select 
    'Contact - 5' as title,
    [n_c_name_5]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 5' as title,
    [n_c_no_5] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 5' as title,
    [n_c_notes_5] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 5' as title,
    [n_c_alt_no_5]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------


select 
    'datagrid_4'              as component,
    'Weekend Contacts' as title
select 
    'Contact - 1' as title,
    [we_c_name_1]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 1' as title,
    [we_c_no_1] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 1' as title,
    [we_c_notes_1] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 1' as title,
    [we_c_alt_no_1]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

---------------------------------------------------------------------------

select 
    'Contact - 2' as title,
    [we_c_name_2]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 2' as title,
    [we_c_no_2] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 2' as title,
    [we_c_notes_2] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 2' as title,
    [we_c_alt_no_2]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

---------------------------------------------------------------
select 
    'Contact - 3' as title,
    [we_c_name_3]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 3' as title,
    [we_c_no_3] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 3' as title,
    [we_c_notes_3] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 3' as title,
    [we_c_alt_no_3]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------------


select 
    'Contact - 4' as title,
    [we_c_name_4]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 4' as title,
    [we_c_no_4] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 4' as title,
    [we_c_notes_4] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 4' as title,
    [we_c_alt_no_4]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------


select 
    'Contact - 5' as title,
    [we_c_name_5]   as description,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)



select 
    'Number - 5' as title,
    [we_c_no_5] as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)


select 
    'Notes - 5' as title,
    [we_c_notes_5] as description,
    'yellow' as color
FROM ApplicationDb1.dbo.el_escalation
WHERE id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

select 
    'Alternative - 5' as title,
    [we_c_alt_no_5]   as phone,
   'https://example.invalid/configure-endpoint' as image_url,
    'cyan' as color
FROM ApplicationDb1.dbo.el_escalation
where id = (SELECT id from ApplicationDb1.dbo.el_info where reg_no = $reg_no)

----------------------------------------------------------
