
/* Reg_check
3 - Reg does not exist in DB
1 - Reg is in DB
*/

SELECT 'redirect' AS component
      ,'duplicate.sql?regg=' + $regg AS link
WHERE $regg in (SELECT DISTINCT [reg_no] FROM ApplicationDb1.dbo.[el_info] WHERE Completed = 1)

/*
Repair / Remove - not_exist
*/
SELECT 'redirect' AS component
      ,'not_exist.sql?regg=' + $regg AS link WHERE (SELECT TOP(1) exist 
                                            FROM Reg_Check 
                                            WHERE reg_no = $regg 
                                            ORDER BY TransDate DESC) = '3'
----------------------------------------------------------------------------------------------------------------
/*
Repair / Remove - Reg in DB
*/
SELECT 'redirect' AS component
      ,'loading_1_f.sql?regg=' + $regg AS link WHERE (SELECT TOP(1) exist 
                                            FROM Reg_Check 
                                            WHERE reg_no = $regg 
                                            ORDER BY TransDate DESC) = '1'
----------------------------------------------------------------------------------------------------------------
/**Default Shell component**/
SELECT 
       'shell_27'       AS component
      ,'fluid' as layout
      ,'Reg Checker' AS title
      ,'loading_1.sql?regg=' + $regg   AS link
,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
      ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,'Make it happen - Perfectly!' AS footer
      , 3 AS refresh;
----------------------------------------------------------------------------------------------------------------
SELECT 'alert' AS component
      ,'Please wait' AS title
      ,'Verifying Registration.' AS description
      ,'refresh-dot' AS icon
      ,'azure' AS color
----------------------------------------------------------------------------------------------------------------
SELECT 'loading' AS component
