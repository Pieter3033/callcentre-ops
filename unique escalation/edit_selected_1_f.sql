INSERT INTO ApplicationDb1.dbo.el_escalation_edits
(     edited_by 
      ,[d_c_name_1]
      ,[d_c_name_2]
      ,[d_c_name_3]
      ,[d_c_name_4]
      ,[d_c_name_5]
      ,[d_c_no_1]
      ,[d_c_no_2]
      ,[d_c_no_3]
      ,[d_c_no_4]
      ,[d_c_no_5]
      ,[d_c_alt_no_1]
      ,[d_c_alt_no_2]
      ,[d_c_alt_no_3]
      ,[d_c_alt_no_4]
      ,[d_c_alt_no_5]
      ,[d_c_notes_1]
      ,[d_c_notes_2]
      ,[d_c_notes_3]
      ,[d_c_notes_4]
      ,[d_c_notes_5])
SELECT sqlpage.cookie('username')
      ,[d_c_name_1]
      ,[d_c_name_2]
      ,[d_c_name_3]
      ,[d_c_name_4]
      ,[d_c_name_5]
      ,[d_c_no_1]
      ,[d_c_no_2]
      ,[d_c_no_3]
      ,[d_c_no_4]
      ,[d_c_no_5]
      ,[d_c_alt_no_1]
      ,[d_c_alt_no_2]
      ,[d_c_alt_no_3]
      ,[d_c_alt_no_4]
      ,[d_c_alt_no_5]
      ,[d_c_notes_1]
      ,[d_c_notes_2]
      ,[d_c_notes_3]
      ,[d_c_notes_4]
      ,[d_c_notes_5]
FROM ApplicationDb1.dbo.el_escalation WHERE id = $id

UPDATE ApplicationDb1.dbo.el_escalation
SET 
    [d_c_name_1] = :day_1_n,
    [d_c_name_2] = :day_2_n,
    [d_c_name_3] = :day_3_n,
    [d_c_name_4] = :day_4_n,
    [d_c_name_5] = :day_5_n,
    [d_c_no_1]   = :day_1_c,
    [d_c_no_2]   = :day_2_c,
    [d_c_no_3]   = :day_3_c,
    [d_c_no_4]   = :day_4_c,
    [d_c_no_5]   = :day_5_c,
    [d_c_alt_no_1] = :day_1_ac,
    [d_c_alt_no_2] = :day_2_ac,
    [d_c_alt_no_3] = :day_3_ac,
    [d_c_alt_no_4] = :day_4_ac,
    [d_c_alt_no_5] = :day_5_ac,
    [d_c_notes_1]  = :day_1_notes,
    [d_c_notes_2]  = :day_2_notes,
    [d_c_notes_3]  = :day_3_notes,
    [d_c_notes_4]  = :day_4_notes,
    [d_c_notes_5]  = :day_5_notes
WHERE id = $id;

SELECT 'redirect' as component
      ,'edit_selected_1.sql?id=' + $id + '&val=1' as link