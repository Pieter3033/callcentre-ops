INSERT INTO ApplicationDb1.dbo.el_escalation_edits
(     edited_by 
,[n_c_name_1]
      ,[n_c_name_2]
      ,[n_c_name_3]
      ,[n_c_name_4]
      ,[n_c_name_5]
      ,[n_c_no_1]
      ,[n_c_no_2]
      ,[n_c_no_3]
      ,[n_c_no_4]
      ,[n_c_no_5]
      ,[n_c_alt_no_1]
      ,[n_c_alt_no_2]
      ,[n_c_alt_no_3]
      ,[n_c_alt_no_4]
      ,[n_c_alt_no_5]
      ,[n_c_notes_1]
      ,[n_c_notes_2]
      ,[n_c_notes_3]
      ,[n_c_notes_4]
      ,[n_c_notes_5]
)
SELECT sqlpage.cookie('username')
,[n_c_name_1]
      ,[n_c_name_2]
      ,[n_c_name_3]
      ,[n_c_name_4]
      ,[n_c_name_5]
      ,[n_c_no_1]
      ,[n_c_no_2]
      ,[n_c_no_3]
      ,[n_c_no_4]
      ,[n_c_no_5]
      ,[n_c_alt_no_1]
      ,[n_c_alt_no_2]
      ,[n_c_alt_no_3]
      ,[n_c_alt_no_4]
      ,[n_c_alt_no_5]
      ,[n_c_notes_1]
      ,[n_c_notes_2]
      ,[n_c_notes_3]
      ,[n_c_notes_4]
      ,[n_c_notes_5]
FROM ApplicationDb1.dbo.el_escalation WHERE id = $id

UPDATE ApplicationDb1.dbo.el_escalation
SET 
    [n_c_name_1]   = :night_1_n,
    [n_c_name_2]   = :night_2_n,
    [n_c_name_3]   = :night_3_n,
    [n_c_name_4]   = :night_4_n,
    [n_c_name_5]   = :night_5_n,
    [n_c_no_1]     = :night_1_c,
    [n_c_no_2]     = :night_2_c,
    [n_c_no_3]     = :night_3_c,
    [n_c_no_4]     = :night_4_c,
    [n_c_no_5]     = :night_5_c,
    [n_c_alt_no_1] = :night_1_ac,
    [n_c_alt_no_2] = :night_2_ac,
    [n_c_alt_no_3] = :night_3_ac,
    [n_c_alt_no_4] = :night_4_ac,
    [n_c_alt_no_5] = :night_5_ac,
    [n_c_notes_1]  = :night_1_notes,
    [n_c_notes_2]  = :night_2_notes,
    [n_c_notes_3]  = :night_3_notes,
    [n_c_notes_4]  = :night_4_notes,
    [n_c_notes_5]  = :night_5_notes
WHERE id = $id;


SELECT 'redirect' as component
      ,'edit_selected_2.sql?id=' + $id + '&val=1' as link