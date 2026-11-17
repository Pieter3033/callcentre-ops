SELECT 
       'shell_27'       AS component
       ,'true' as sidebar
       ,'fluid' as layout
      ,'SRF' AS title
      ,'duplicate_fleet.sql?cid=' + $cid + '&fid=' + $fid    AS link
      ,('{"link":"main.sql","title":"Main Menu","icon":"category"}') as menu_item
      ,('{"link":"add.sql","title":"Unique Escalation","icon":"info-hexagon"}') as menu_item
      ,'en-US'       AS language
      ,'arial'     AS font
      ,'16'          AS font_size
      ,'wave-saw-tool'        AS icon
      ,'dark'        AS theme
      ,'logowhite_3.png' AS image
      ,' ' AS footer;

----------------------------------------------------------------------------------------------------------------

SELECT 'alert' AS component
      ,'Duplicate Alert!' AS title
      ,'> Company: **' + (SELECT TOP(1) Company FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $regg) + '**
>
> Registration: **' + $regg + '**
> 
> a Escalation for this registration already exists, please edit the escalation.' as description_md
      ,'info-hexagon' AS icon
      ,'yellow' AS color
