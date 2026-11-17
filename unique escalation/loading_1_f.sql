INSERT INTO ApplicationDb1.[dbo].[el_info](reg_no, fleet_code, company, reg_escalation, uploaded_by)
VALUES
(
 $regg
,(SELECT TOP(1) fleet_code from ApplicationDb6.dbo.vehicleinfo where reg_no = $regg)
,(SELECT TOP(1) Company FROM ApplicationDb6.dbo.vehicleinfo where reg_no = $regg)
,1
,sqlpage.cookie('username')
)

SELECT 'redirect' as component
       ,'insert_reg_1.sql?regg=' + $regg as link