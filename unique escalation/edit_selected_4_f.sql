INSERT INTO ApplicationDb1.dbo.el_escalation_edits
(edited_by
,[verification_password]
      ,[auth_person]
      ,[auth_notes]
      ,[group_notes]
,[po_notes]
      ,[jamming_notes]
      ,[panic_notes]
      ,[remote_panic_notes]
      ,[tamper_notes]
      ,[dph_notes]
      ,[cap_notes]
      ,[tilt_notes]
      ,[harness_t_notes]
      ,[gate_jam_notes]
      ,[trailer_dis_notes]
      ,[battery_dis_notes]
      ,[limp_geofence_notes]
      ,[fatigue_notes]
      ,[travel_stop_notes]
      ,[removed_notes]
      ,[limp_activate_notes]
      ,[max_time_exceed_notes]
      ,[moving_out_of_geofence_notes])
SELECT sqlpage.cookie('username')
,[verification_password]
      ,[auth_person]
      ,[auth_notes]
      ,[group_notes]
,[po_notes]
      ,[jamming_notes]
      ,[panic_notes]
      ,[remote_panic_notes]
      ,[tamper_notes]
      ,[dph_notes]
      ,[cap_notes]
      ,[tilt_notes]
      ,[harness_t_notes]
      ,[gate_jam_notes]
      ,[trailer_dis_notes]
      ,[battery_dis_notes]
      ,[limp_geofence_notes]
      ,[fatigue_notes]
      ,[travel_stop_notes]
      ,[removed_notes]
      ,[limp_activate_notes]
      ,[max_time_exceed_notes]
      ,[moving_out_of_geofence_notes]
FROM ApplicationDb1.dbo.el_escalation WHERE id = $id

UPDATE ApplicationDb1.dbo.el_escalation
SET
    [po_notes] = :po_n,
    [jamming_notes] = :jam_n,
    [panic_notes] = :panic_n,
    [remote_panic_notes] = :r_panic_n,
    [tamper_notes] = :tamper_n,
    [dph_notes] = :dph_n,
    [cap_notes] = :cap_n,
    [tilt_notes] = :tilt_n,
    [harness_t_notes] = :harness_n,
    [gate_jam_notes] = :gjam_n,
    [trailer_dis_notes] = :tdis_n,
    [battery_dis_notes] = :bdis_n,
    [limp_geofence_notes] = :limp_ge_n,
    [fatigue_notes] = :fat_n,
    [travel_stop_notes] = :ts_n,
    [removed_notes] = :rem_n,
    [limp_activate_notes] = :limp_ac_n,
    [max_time_exceed_notes] = :max_time_n,
    [moving_out_of_geofence_notes] = :mog_n,
    [verification_password] = :verif_p,
    [auth_person] = :auth_p,
    [auth_notes] = :auth_n,
    [group_notes] = :whatsapp_notes
WHERE
    id = $id

UPDATE ApplicationDb1.dbo.el_info set completed = 1 where id = $id

SELECT 'redirect' as component
    ,'edit_selected_4.sql?id=' + $id + '&val=1'as link
