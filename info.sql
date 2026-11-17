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
      ,('{"link":"main.sql?reg_no=' + $reg_no + '&event='+$event+'","title":"Event","icon":"alert-hexagon"}') as menu_item
      ,' ' as footer
      ,'Make it happen - Perfectly!' AS footer;
--------------------------------------------------------
SELECT 'alert_edited' AS component
      ,'Vehicle information' AS title
      ,'info-square' AS icon
      ,'azure' AS color

SELECT 'datagrid_4' AS component

SELECT 'Company' AS title
       ,(SELECT TOP(1) local.Company
FROM Companies AS local
JOIN [DATABASE_SERVER].ApplicationDb2.dbo.vehicleinfo AS remote
    ON local.Company = remote.Company
WHERE remote.reg_no = $reg_no) AS description
       ,'cyan' AS color

SELECT 'Registration' AS title
       ,(SELECT Reg_no FROM Jobcard_info WHERE JC_num = $) AS description
       ,'cyan' AS color

SELECT 'Fleet' AS title
      ,(SELECT Fleet FROM jobcard_info WHERE JC_num = $) AS description
      ,'vimeo' AS color
