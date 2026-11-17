----------------------------------------------------------------------------------------------------------------
/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
--  ,'insert_reg_2.sql?regg=' + $regg + '&id=' + $id as link
 ,CASE WHEN $regg is not null then 'insert_reg_2.sql?regg=' + $regg + '&id=' + $id ELSE 'insert_reg_2.sql?id=' + $id END as link
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
----------------------------------------------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Escalation Setup' AS title
      ,'> Registration: **' + (SELECT Reg_no FROM ApplicationDb1.dbo.el_info where id = $id)+ '**
>
> The below sections are not compulsary.' as description_md
      ,'info-hexagon' AS icon
      ,'azure' AS color
WHERE (SELECT reg_escalation FROM ApplicationDb1.dbo.el_info where id = $id) = 1

SELECT 'alert' AS component
      ,'Escalation Setup' AS title
      ,'> Company: **' + (SELECT TOP(1) Company FROM Companies where fleet_code = (SELECT fleet_code from ApplicationDb1.dbo.el_info where id = $id)) + '**
>
> Fleet: **' + (SELECT TOP(1) Fleet_code from ApplicationDb1.dbo.el_info where id = $id) + '**
>
> The below sections are not Compulsary' as description_md
      ,'info-hexagon' AS icon
      ,'azure' AS color
WHERE (SELECT reg_escalation FROM ApplicationDb1.dbo.el_info where id = $id) = 0

/**Form Component**/
SELECT 'form' AS component
      ,'insert_reg_2_f.sql?id=' + $id AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color;


SELECT 'header' AS type, 'General Notes' AS label

SELECT 
       'Authorization Person' AS label
       ,'auth_p' AS name
       ,'...' AS placeholder
       ,'6' AS width
       ,'The Person who may authorize certain actions specified in Authorization Notes' as description

SELECT 
       'Verification Password' AS label
       ,'verif_p' AS name
       ,'...' AS placeholder
       ,'6' AS width
       ,'A word or Phrase that is used to confirm the legitimacy of the call.' as description

SELECT 
       'Authorization Notes' AS label
       ,'auth_n' AS name
       ,'...' AS placeholder
       ,'6' AS width
       ,'textarea' as type
       ,'Authorization Notes' as description

SELECT 
       'WhatsApp Group Notes' AS label
       ,'whatsapp_notes' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'6' AS width

SELECT 
       'General Note (Registration Specific)' AS label
       ,'gen_note' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'6' AS width

SELECT 
       'Purchase Order Notes' AS label
       ,'po_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'6' AS width

SELECT 'separator' AS type
SELECT 'header' AS type, 'Event Specific Notes' AS label

SELECT 
       'Jamming Detected Notes' AS label
       ,'jam_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Panic Notes' AS label
       ,'panic_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Remote Panic Notes' AS label
       ,'r_panic_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Tamper Notes' AS label
       ,'tamper_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Door Possible Hijack Notes' AS label
       ,'dph_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Cargo Area Panic Notes' AS label
       ,'cap_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Tilt Notes' AS label
       ,'tilt_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Harness Tamper Notes' AS label
       ,'harness_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Gate Jamming Notes' AS label
       ,'gjam_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Trailer Disconnect Notes' AS label
       ,'tdis_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Battery Disconnect Notes' AS label
       ,'bdis_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Limp Geofence Entrance Notes' AS label
       ,'limp_ge_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Fatigue Alert Notes' AS label
       ,'fat_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Travel Stop Notes' AS label
       ,'ts_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Removed Notes' AS label
       ,'rem_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Limp Activated Notes' AS label
       ,'limp_ac_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Max Time Exceeded in Geofence Notes' AS label
       ,'max_time_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width

SELECT 
       'Moving Out of Geofence Notes' AS label
       ,'mog_n' AS name
       ,'...' AS placeholder
       ,'textarea' as type
       ,'4' AS width
