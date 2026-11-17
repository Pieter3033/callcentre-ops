INSERT INTO ApplicationDb1.dbo.el_escalation_edits
(     edited_by 
    ,[we_c_name_1]
      ,[we_c_name_2]
      ,[we_c_name_3]
      ,[we_c_name_4]
      ,[we_c_name_5]
      ,[we_c_no_1]
      ,[we_c_no_2]
      ,[we_c_no_3]
      ,[we_c_no_4]
      ,[we_c_no_5]
      ,[we_c_alt_no_1]
      ,[we_c_alt_no_2]
      ,[we_c_alt_no_3]
      ,[we_c_alt_no_4]
      ,[we_c_alt_no_5]
      ,[we_c_notes_1]
      ,[we_c_notes_2]
      ,[we_c_notes_3]
      ,[we_c_notes_4]
      ,[we_c_notes_5])
SELECT sqlpage.cookie('username')
      ,[we_c_name_1]
      ,[we_c_name_2]
      ,[we_c_name_3]
      ,[we_c_name_4]
      ,[we_c_name_5]
      ,[we_c_no_1]
      ,[we_c_no_2]
      ,[we_c_no_3]
      ,[we_c_no_4]
      ,[we_c_no_5]
      ,[we_c_alt_no_1]
      ,[we_c_alt_no_2]
      ,[we_c_alt_no_3]
      ,[we_c_alt_no_4]
      ,[we_c_alt_no_5]
      ,[we_c_notes_1]
      ,[we_c_notes_2]
      ,[we_c_notes_3]
      ,[we_c_notes_4]
      ,[we_c_notes_5]
FROM ApplicationDb1.dbo.el_escalation WHERE id = $id


UPDATE ApplicationDb1.dbo.el_escalation
SET 
    [we_c_name_1]   = :we_1_n,
    [we_c_name_2]   = :we_2_n,
    [we_c_name_3]   = :we_3_n,
    [we_c_name_4]   = :we_4_n,
    [we_c_name_5]   = :we_5_n,
    [we_c_no_1]     = :we_1_c,
    [we_c_no_2]     = :we_2_c,
    [we_c_no_3]     = :we_3_c,
    [we_c_no_4]     = :we_4_c,
    [we_c_no_5]     = :we_5_c,
    [we_c_alt_no_1] = :we_1_ac,
    [we_c_alt_no_2] = :we_2_ac,
    [we_c_alt_no_3] = :we_3_ac,
    [we_c_alt_no_4] = :we_4_ac,
    [we_c_alt_no_5] = :we_5_ac,
    [we_c_notes_1]  = :we_1_notes,
    [we_c_notes_2]  = :we_2_notes,
    [we_c_notes_3]  = :we_3_notes,
    [we_c_notes_4]  = :we_4_notes,
    [we_c_notes_5]  = :we_5_notes
WHERE id = $id;


UPDATE ApplicationDb1.dbo.el_info set completed = 1 where id = $id

SELECT 'redirect' as component
    ,'edit_selected_3.sql?id=' + $id + '&val=1' as link
