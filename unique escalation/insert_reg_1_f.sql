INSERT INTO ApplicationDb1.dbo.el_escalation
(
      [d_c_name_1],   [d_c_name_2],   [d_c_name_3],   [d_c_name_4],   [d_c_name_5],
      [d_c_no_1],     [d_c_no_2],     [d_c_no_3],     [d_c_no_4],     [d_c_no_5],
      [d_c_alt_no_1], [d_c_alt_no_2], [d_c_alt_no_3], [d_c_alt_no_4], [d_c_alt_no_5],
      [d_c_notes_1],  [d_c_notes_2],  [d_c_notes_3],  [d_c_notes_4],  [d_c_notes_5],
      [n_c_name_1],   [n_c_name_2],   [n_c_name_3],   [n_c_name_4],   [n_c_name_5],
      [n_c_no_1],     [n_c_no_2],     [n_c_no_3],     [n_c_no_4],     [n_c_no_5],
      [n_c_alt_no_1], [n_c_alt_no_2], [n_c_alt_no_3], [n_c_alt_no_4], [n_c_alt_no_5],
      [n_c_notes_1],  [n_c_notes_2],  [n_c_notes_3],  [n_c_notes_4],  [n_c_notes_5],
      [we_c_name_1],  [we_c_name_2],  [we_c_name_3],  [we_c_name_4],  [we_c_name_5],
      [we_c_no_1],    [we_c_no_2],    [we_c_no_3],    [we_c_no_4],    [we_c_no_5],
      [we_c_alt_no_1],[we_c_alt_no_2],[we_c_alt_no_3],[we_c_alt_no_4],[we_c_alt_no_5],
      [we_c_notes_1], [we_c_notes_2], [we_c_notes_3], [we_c_notes_4], [we_c_notes_5], 
      [id]
)
SELECT
    :day_1_n,   :day_2_n,   :day_3_n,   :day_4_n,   :day_5_n,
    :day_1_c,   :day_2_c,   :day_3_c,   :day_4_c,   :day_5_c,
    :day_1_ac,  :day_2_ac,  :day_3_ac,  :day_4_ac,  :day_5_ac,
    :day_1_notes, :day_2_notes, :day_3_notes, :day_4_notes, :day_5_notes,
    :night_1_n, :night_2_n, :night_3_n, :night_4_n, :night_5_n,
    :night_1_c, :night_2_c, :night_3_c, :night_4_c, :night_5_c,
    :night_1_ac,:night_2_ac,:night_3_ac,:night_4_ac,:night_5_ac,
    :night_1_notes, :night_2_notes, :night_3_notes, :night_4_notes, :night_5_notes,
    :we_1_n,    :we_2_n,    :we_3_n,    :we_4_n,    :we_5_n,
    :we_1_c,    :we_2_c,    :we_3_c,    :we_4_c,    :we_5_c,
    :we_1_ac,   :we_2_ac,   :we_3_ac,   :we_4_ac,   :we_5_ac,
    :we_1_notes,:we_2_notes,:we_3_notes,:we_4_notes,:we_5_notes,
    id_sub.id
FROM
    (SELECT TOP 1 id FROM ApplicationDb1.dbo.el_info WHERE reg_no = $regg ORDER BY datetime_uploaded DESC) AS id_sub
WHERE NOT EXISTS
(
    SELECT 1 FROM ApplicationDb1.dbo.el_escalation e WHERE e.id = id_sub.id
);

SELECT 'redirect' as component
       ,'insert_reg_2.sql?regg=' + $regg + '&id=' + (SELECT TOP(1) CAST(ID as nvarchar(max)) FROM ApplicationDb1.dbo.el_info WHERE reg_no = $regg order by datetime_uploaded desc) as link