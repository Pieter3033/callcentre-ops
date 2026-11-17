DELETE FROM ApplicationDb1.dbo.el_info where completed = 0 and (SELECT TOP(1) fleet_code from Companies WHERE fleet_id = $fid) IN (SELECT DISTINCT Fleet_code FROM ApplicationDb1.dbo.el_info)

INSERT INTO ApplicationDb1.[dbo].[el_info](reg_no, fleet_code, company, fleet_escalation, uploaded_by)
VALUES
(
'N/A'
,LTRIM(RTRIM((SELECT TOP(1) fleet_code from Companies WHERE fleet_id = $fid)))
,LTRIM(RTRIM((SELECT TOP(1) company from Companies WHERE company_id = $cid)))
,1
,sqlpage.cookie('username')
)

SELECT 'redirect' as component
       ,'insert_reg_1.sql?fid=' + $fid as link