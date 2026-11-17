/**Default Shell component**/
SELECT 
       'shell_27'       AS component
       ,'dark' as sidebar_theme
       ,'edit_selected_4.sql?id=' + $id as link
      ,'horizontal' as layout
       ,'true' as sidebar
     ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
   --   ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
   --   ,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
     -- ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'&seqno='+$seqno+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
       ,'cc_escalation_delete.js' AS javascript;
    --  ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
/**Tab Component**/
SELECT 
       'tab' AS component
      ,'TRUE'  AS center;

SELECT --Add User Tab
       'Day Escalation' AS title
      ,'sun' AS icon
      ,'edit_selected_1.sql?id=' + $id as link

SELECT --Delete User Tab
       'Night Escalation' AS title
      ,'moon' AS icon
      ,'edit_selected_2.sql?id=' + $id AS link; --Reverts to Delete user

SELECT --Reset Password Tab
       'Weekend Escalation' AS title
      ,'calendar-event' AS icon
      ,'edit_selected_3.sql?id=' + $id AS link


SELECT 
       'General Notes' AS title
      ,'layers-intersect' AS icon
      ,'edit_selected_4.sql?id=' + $id AS link
       ,'TRUE' AS active  
------------------------------------------------------------------------

------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Updated Escalation' AS title
      ,'info-hexagon' AS icon
      ,'TRUE' as dismissible
      ,'green' AS color
WHERE $val is not null
------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Edit Escalation' AS title
      ,'> Company: **' + (SELECT TOP(1) Company FROM ApplicationDb1.dbo.el_info Where id = $id) + '**
>
> '+'Reference - '+CASE WHEN (select reg_escalation from ApplicationDb1.dbo.el_info where id = $id) = 0 then 'Fleet: **' + (SELECT Fleet_Code FROM ApplicationDb1.dbo.el_info WHERE id = $id) else 'Registration: **' + (SELECT reg_no FROM ApplicationDb1.dbo.el_info where id = $id) END +'**'as description_md
      ,'info-hexagon' AS icon
      ,'azure' AS color
------------------------------------------------------------------------


SELECT 'form' AS component
      ,'edit_selected_4_f.sql?id=' + $id AS action
      ,'Submit' AS validate
      ,'blue' AS validate_color

SELECT 'header' AS type, 'General Notes' AS label, 'These details are not compulsary.' AS description

SELECT 
       'Authorization Person' AS label,
       'auth_p' AS name,
       '...' AS placeholder,
       '6' AS width,
       'The Person who may authorize certain actions specified in Authorization Notes' as description,
       (SELECT [auth_person] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Verification Password' AS label,
       'verif_p' AS name,
       '...' AS placeholder,
       '6' AS width,
       'A word or Phrase that is used to confirm the legitimacy of the call.' as description,
       (SELECT [verification_password] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Authorization Notes' AS label,
       'auth_n' AS name,
       '...' AS placeholder,
       '6' AS width,
       'textarea' as type,
       'Authorization Notes' as description,
       (SELECT [auth_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'WhatsApp Group Notes' AS label,
       'whatsapp_notes' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '6' AS width,
       (SELECT [group_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Purchase Order Notes' AS label,
       'po_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '6' AS width,
       (SELECT [po_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 'separator' AS type 

SELECT 'header' AS type, 'Event Specific Notes' AS label

SELECT 
       'Jamming Detected Notes' AS label,
       'jam_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [jamming_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Panic Notes' AS label,
       'panic_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [panic_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Remote Panic Notes' AS label,
       'r_panic_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [remote_panic_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Tamper Notes' AS label,
       'tamper_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [tamper_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Door Possible Hijack Notes' AS label,
       'dph_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [dph_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Cargo Area Panic Notes' AS label,
       'cap_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [cap_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Tilt Notes' AS label,
       'tilt_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [tilt_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Harness Tamper Notes' AS label,
       'harness_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [harness_t_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Gate Jamming Notes' AS label,
       'gjam_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [gate_jam_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Trailer Disconnect Notes' AS label,
       'tdis_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [trailer_dis_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Battery Disconnect Notes' AS label,
       'bdis_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [battery_dis_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Limp Geofence Entrance Notes' AS label,
       'limp_ge_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [limp_geofence_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Fatigue Alert Notes' AS label,
       'fat_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [fatigue_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Travel Stop Notes' AS label,
       'ts_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [travel_stop_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Removed Notes' AS label,
       'rem_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [removed_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Limp Activated Notes' AS label,
       'limp_ac_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [limp_activate_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Max Time Exceeded in Geofence Notes' AS label,
       'max_time_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [max_time_exceed_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value

SELECT 
       'Moving Out of Geofence Notes' AS label,
       'mog_n' AS name,
       '...' AS placeholder,
       'textarea' as type,
       '4' AS width,
       (SELECT [moving_out_of_geofence_notes] FROM ApplicationDb1.dbo.el_escalation WHERE id = $id) as value
