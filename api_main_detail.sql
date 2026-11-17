SET cc_detail_authorized = (SELECT CASE WHEN EXISTS(SELECT 1 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username))) WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14)) THEN 1 ELSE 0 END);
SELECT 'json' AS component,CASE WHEN $cc_detail_authorized<>'1' THEN N'{"authorized":false,"status":"unauthorized","message":"Sign in with an authorized CC operator account."}' ELSE
(
    SELECT
        CAST(1 AS bit) AS authorized,
        NULLIF(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))), '') AS regNo,
        NULLIF(LTRIM(RTRIM(CAST($event AS NVARCHAR(200)))), '') AS eventName,
        NULLIF(LTRIM(RTRIM(CAST($seqno AS NVARCHAR(100)))), '') AS seqno,
        JSON_QUERY((
            SELECT TOP (1)
                operator_info.id,
                operator_info.operator
            FROM ApplicationDb5.dbo.cc_operators operator_info
            WHERE operator_info.id = TRY_CONVERT(INT, sqlpage.cookie('operator'))
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS operator,
        JSON_QUERY((
            SELECT TOP (1)
                vehicle.Reg_no AS regNo,
                vehicle.Company AS company,
                vehicle.Fleet_Code AS fleet,
                vehicle.vehdesc AS vehicleDescription
            FROM ApplicationDb6.dbo.Vehicleinfo vehicle
            WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS vehicle,
        JSON_QUERY((
            SELECT TOP (1)
                COALESCE(NULLIF(LTRIM(RTRIM(CAST(local.Fleet_Code AS NVARCHAR(100)))), ''), 'N/A') AS fleetNo,
                COALESCE(NULLIF(LTRIM(RTRIM(local.MakeDesc)), ''), 'N/A') AS make,
                N'N/A' AS model,
                COALESCE(NULLIF(LTRIM(RTRIM(local.Colour)), ''), 'N/A') AS colour,
                COALESCE(NULLIF(LTRIM(RTRIM(local.ChassisNo)), ''), 'N/A') AS vin,
                COALESCE(NULLIF(LTRIM(RTRIM(local.EngineNo)), ''), 'N/A') AS engine
            FROM ApplicationDb6.dbo.Vehicleinfo local
            WHERE UPPER(LTRIM(RTRIM(local.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS vehicleInfo,
        JSON_QUERY((
            SELECT TOP (1)
                account.zoho_id AS zohoId,
                account.account_name AS accountName,
                company_map.escallation_no AS mappedEscalationNo
            FROM ApplicationDb6.dbo.Vehicleinfo vehicle
            LEFT JOIN ApplicationDb3.dbo.Companies company_map
                ON company_map.Company = vehicle.Company
               AND company_map.Fleet_Code = vehicle.Fleet_Code
            LEFT JOIN ApplicationDb5.dbo.Accounts_ZOHO account
                ON account.zoho_id = company_map.escallation_no
            WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS zoho,
        (
            SELECT TOP (1)
                company.customerid
            FROM ApplicationDb6.dbo.Company company
            WHERE UPPER(LTRIM(RTRIM(company.company))) = UPPER(LTRIM(RTRIM((
                SELECT TOP (1) vehicle.Company
                FROM ApplicationDb6.dbo.Vehicleinfo vehicle
                WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
            ))))
        ) AS customerId,
        -- Hard-coded CLIENT profiles from the existing escalation pages, served only after CC authorization.
        JSON_QUERY((
            SELECT TOP (1) CASE
                WHEN vehicle.Company = N'CLIENT_COMPANY_01' AND vehicle.Fleet_Code = N'SITE_01' THEN (SELECT N'site_1' AS id,N'Client Site 1' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 01',N'',N'',N'Configure private contact notes.'),
                        (2,N'Example Contact 02',N'',N'',N'Configure private contact notes.'),
                        (3,N'Example Contact 03',N'',N'',N'Configure private contact notes.')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                WHEN vehicle.Company = N'CLIENT_COMPANY_02' AND vehicle.Fleet_Code = N'SITE_02' THEN (SELECT N'site_2' AS id,N'Client Site 2' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 04',N'',N'',N''),
                        (2,N'Example Contact 05',N'',N'',N''),
                        (3,N'Example Contact 06',N'',N'',N'')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                WHEN vehicle.Company = N'CLIENT_COMPANY_01' AND vehicle.Fleet_Code IN (N'site_3 Isaac',N'site_3 IsaacB',N'site_3 IsaacM',N'site_3 IsaacN',N'site_3 Jacques') THEN (SELECT N'site_3' AS id,N'Client Site 3' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 07',N'',N'',N''),
                        (2,N'Example Contact 08',N'',N'',N''),
                        (3,N'Example Contact 09',N'',N'',N'')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                WHEN company.Company = N'CLIENT_COMPANY_03' THEN (SELECT N'site_4' AS id,N'CLIENT_COMPANY_03' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 04',N'',N'',N''),
                        (2,N'Example Contact 05',N'',N'',N''),
                        (3,N'Example Contact 06',N'',N'',N''),
                        (4,N'Example Contact 10',N'',N'',N''),
                        (5,N'Example Contact 11',N'',N'',N''),
                        (6,N'Example Contact 12',N'',N'',N''),
                        (7,N'Example Contact 13',N'',N'',N'')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                WHEN company.Company = N'CLIENT_COMPANY_01' THEN (SELECT N'site_5' AS id,N'CLIENT_COMPANY_01' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 04',N'',N'',N''),
                        (2,N'Example Contact 05',N'',N'',N''),
                        (3,N'Example Contact 06',N'',N'',N''),
                        (4,N'Example Contact 10',N'',N'',N''),
                        (5,N'Example Contact 11',N'',N'',N''),
                        (6,N'Example Contact 11',N'',N'',N'')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                WHEN company.Company = N'CLIENT_COMPANY_02' THEN (SELECT N'site_6' AS id,N'CLIENT_COMPANY_02' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 04',N'',N'',N''),
                        (2,N'Example Contact 05',N'',N'',N''),
                        (3,N'Example Contact 06',N'',N'',N''),
                        (4,N'Example Contact 10',N'',N'',N''),
                        (5,N'Example Contact 11',N'',N'',N'')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                WHEN TRY_CONVERT(int,company.customerid) = 451 THEN (SELECT N'site_5' AS id,N'CLIENT_COMPANY_01' AS title,N'Configure the private escalation policy before use.' AS instructions,
                    JSON_QUERY((SELECT contact.slot,contact.name,contact.number,contact.altNumber,contact.notes FROM (VALUES
                        (1,N'Example Contact 04',N'',N'',N''),
                        (2,N'Example Contact 05',N'',N'',N''),
                        (3,N'Example Contact 06',N'',N'',N''),
                        (4,N'Example Contact 10',N'',N'',N''),
                        (5,N'Example Contact 11',N'',N'',N''),
                        (6,N'Example Contact 11',N'',N'',N'')
                    ) contact(slot,name,number,altNumber,notes) ORDER BY contact.slot FOR JSON PATH)) AS dayContacts
                    FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
                ELSE NULL
            END
            FROM ApplicationDb6.dbo.Vehicleinfo vehicle
            OUTER APPLY (
                SELECT TOP (1) company_info.Company,company_info.customerid
                FROM ApplicationDb6.dbo.Company company_info
                WHERE company_info.Company = vehicle.Company
            ) company
            WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS nvarchar(100)))))
        )) AS clientEscalation,

        JSON_QUERY((
            SELECT TOP (1)
                CASE
                    WHEN dispatch.capital_air = 1 AND dispatch.ProviderB = 0 AND dispatch.provider_c = 0 THEN 'Dispatch Provider A'
                    WHEN dispatch.capital_air = 0 AND dispatch.ProviderB = 1 AND dispatch.provider_c = 0 THEN 'ProviderB'
                    WHEN dispatch.capital_air = 0 AND dispatch.ProviderB = 0 AND dispatch.provider_c = 1 THEN 'Provider C'
                    WHEN dispatch.capital_air = 1 AND dispatch.ProviderB = 1 AND dispatch.provider_c = 0 THEN 'Dispatch Provider A | ProviderB'
                    WHEN dispatch.capital_air = 1 AND dispatch.ProviderB = 0 AND dispatch.provider_c = 1 THEN 'Dispatch Provider A | Provider C'
                    WHEN dispatch.capital_air = 0 AND dispatch.ProviderB = 1 AND dispatch.provider_c = 1 THEN 'Provider C | ProviderB'
                    WHEN dispatch.capital_air = 1 AND dispatch.ProviderB = 1 AND dispatch.provider_c = 1 THEN 'Dispatch Provider A | Provider C | ProviderB'
                    WHEN dispatch.Company IS NULL THEN 'Dispatch Provider A | Provider C'
                    ELSE 'Dispatch Provider A | Provider C'
                END AS team
            FROM (
                SELECT TOP (1) vehicle.Company
                FROM ApplicationDb6.dbo.Vehicleinfo vehicle
                WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
            ) vehicle_lookup
            LEFT JOIN ApplicationDb1.dbo.dispatch_teams dispatch
                ON dispatch.Company = vehicle_lookup.Company
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS dispatch,
        JSON_QUERY((
            SELECT TOP (1)
                detail.id,
                detail.verification_password,
                detail.auth_person,
                detail.auth_notes,
                detail.group_notes,
                detail.gen_note,
                detail.d_c_name_1, detail.d_c_name_2, detail.d_c_name_3, detail.d_c_name_4, detail.d_c_name_5,
                detail.d_c_no_1, detail.d_c_no_2, detail.d_c_no_3, detail.d_c_no_4, detail.d_c_no_5,
                detail.d_c_alt_no_1, detail.d_c_alt_no_2, detail.d_c_alt_no_3, detail.d_c_alt_no_4, detail.d_c_alt_no_5,
                detail.d_c_notes_1, detail.d_c_notes_2, detail.d_c_notes_3, detail.d_c_notes_4, detail.d_c_notes_5,
                detail.n_c_name_1, detail.n_c_name_2, detail.n_c_name_3, detail.n_c_name_4, detail.n_c_name_5,
                detail.n_c_no_1, detail.n_c_no_2, detail.n_c_no_3, detail.n_c_no_4, detail.n_c_no_5,
                detail.n_c_alt_no_1, detail.n_c_alt_no_2, detail.n_c_alt_no_3, detail.n_c_alt_no_4, detail.n_c_alt_no_5,
                detail.n_c_notes_1, detail.n_c_notes_2, detail.n_c_notes_3, detail.n_c_notes_4, detail.n_c_notes_5,
                detail.we_c_name_1, detail.we_c_name_2, detail.we_c_name_3, detail.we_c_name_4, detail.we_c_name_5,
                detail.we_c_no_1, detail.we_c_no_2, detail.we_c_no_3, detail.we_c_no_4, detail.we_c_no_5,
                detail.we_c_alt_no_1, detail.we_c_alt_no_2, detail.we_c_alt_no_3, detail.we_c_alt_no_4, detail.we_c_alt_no_5,
                detail.we_c_notes_1, detail.we_c_notes_2, detail.we_c_notes_3, detail.we_c_notes_4, detail.we_c_notes_5,
                detail.po_notes,
                detail.jamming_notes,
                detail.panic_notes,
                detail.remote_panic_notes,
                detail.tamper_notes,
                detail.dph_notes,
                detail.cap_notes,
                detail.tilt_notes,
                detail.harness_t_notes,
                detail.gate_jam_notes,
                detail.trailer_dis_notes,
                detail.battery_dis_notes,
                detail.limp_geofence_notes,
                detail.fatigue_notes,
                detail.travel_stop_notes,
                detail.removed_notes,
                detail.limp_activate_notes,
                detail.max_time_exceed_notes,
                detail.moving_out_of_geofence_notes,
                CASE
                    WHEN CAST($event AS NVARCHAR(200)) = 'Battery Disconnect' THEN detail.battery_dis_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Trailer Disconnect' THEN detail.trailer_dis_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Panic On', 'Panic') THEN detail.panic_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Remote Panic On' THEN detail.remote_panic_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Tamper' THEN detail.tamper_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Fatigue Alert', 'Fatigue Event') THEN detail.fatigue_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Travel Stop' THEN detail.travel_stop_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Tilt' THEN detail.tilt_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Door Possible Hijack', 'Door Possible Hijack On') THEN detail.dph_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Jamming Detected' THEN detail.jamming_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Cargo Area Panic On', 'Cargo Area Panic') THEN detail.cap_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Harness Tamper' THEN detail.harness_t_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Limp Geofences Entrance' THEN detail.limp_geofence_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Gate Jam' THEN detail.gate_jam_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Removed' THEN detail.removed_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Limp Activate' THEN detail.limp_activate_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Max Time Exceeded' THEN detail.max_time_exceed_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Moving Out Of Geofence' THEN detail.moving_out_of_geofence_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'PO' THEN detail.po_notes
                    ELSE NULL
                END AS event_note
            FROM ApplicationDb1.dbo.el_escalation detail
            WHERE detail.id = COALESCE(
                (
                    SELECT TOP (1) info.id
                    FROM ApplicationDb1.dbo.el_info info
                    WHERE info.completed = 1
                      AND UPPER(LTRIM(RTRIM(info.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
                    ORDER BY info.id DESC
                ),
                (
                    SELECT TOP (1) info.id
                    FROM ApplicationDb1.dbo.el_info info
                    WHERE info.completed = 1
                      AND info.fleet_escalation = 1
                      AND info.Fleet_Code = (
                          SELECT TOP (1) vehicle.Fleet_Code
                          FROM ApplicationDb6.dbo.Vehicleinfo vehicle
                          WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
                      )
                      AND info.Company = (
                          SELECT TOP (1) vehicle.Company
                          FROM ApplicationDb6.dbo.Vehicleinfo vehicle
                          WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
                      )
                    ORDER BY info.id DESC
                )
            )
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS uniqueEscalation,
        JSON_QUERY((
            SELECT TOP (1)
                detail.zoho_id,
                detail.verification_password,
                detail.auth_person,
                detail.auth_notes,
                detail.group_notes,
                detail.d_c_name_1, detail.d_c_name_2, detail.d_c_name_3, detail.d_c_name_4, detail.d_c_name_5,
                detail.d_c_no_1, detail.d_c_no_2, detail.d_c_no_3, detail.d_c_no_4, detail.d_c_no_5,
                detail.d_c_alt_no_1, detail.d_c_alt_no_2, detail.d_c_alt_no_3, detail.d_c_alt_no_4, detail.d_c_alt_no_5,
                detail.d_c_notes_1, detail.d_c_notes_2, detail.d_c_notes_3, detail.d_c_notes_4, detail.d_c_notes_5,
                detail.n_c_name_1, detail.n_c_name_2, detail.n_c_name_3, detail.n_c_name_4, detail.n_c_name_5,
                detail.n_c_no_1, detail.n_c_no_2, detail.n_c_no_3, detail.n_c_no_4, detail.n_c_no_5,
                detail.n_c_alt_no_1, detail.n_c_alt_no_2, detail.n_c_alt_no_3, detail.n_c_alt_no_4, detail.n_c_alt_no_5,
                detail.n_c_notes_1, detail.n_c_notes_2, detail.n_c_notes_3, detail.n_c_notes_4, detail.n_c_notes_5,
                detail.we_c_name_1, detail.we_c_name_2, detail.we_c_name_3, detail.we_c_name_4, detail.we_c_name_5,
                detail.we_c_no_1, detail.we_c_no_2, detail.we_c_no_3, detail.we_c_no_4, detail.we_c_no_5,
                detail.we_c_alt_no_1, detail.we_c_alt_no_2, detail.we_c_alt_no_3, detail.we_c_alt_no_4, detail.we_c_alt_no_5,
                detail.we_c_notes_1, detail.we_c_notes_2, detail.we_c_notes_3, detail.we_c_notes_4, detail.we_c_notes_5,
                detail.po_notes,
                detail.jamming_notes,
                detail.panic_notes,
                detail.remote_panic_notes,
                detail.tamper_notes,
                detail.dph_notes,
                detail.cap_notes,
                detail.tilt_notes,
                detail.harness_t_notes,
                detail.gate_jam_notes,
                detail.trailer_dis_notes,
                detail.battery_dis_notes,
                detail.limp_geofence_notes,
                detail.fatigue_notes,
                detail.travel_stop_notes,
                detail.removed_notes,
                detail.limp_activate_notes,
                detail.max_time_exceed_notes,
                detail.moving_out_of_geofence_notes,
                detail.please_call_me_notes,
                CASE
                    WHEN CAST($event AS NVARCHAR(200)) = 'Battery Disconnect' THEN detail.battery_dis_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Trailer Disconnect' THEN detail.trailer_dis_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Panic On', 'Panic') THEN detail.panic_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Remote Panic On' THEN detail.remote_panic_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Tamper' THEN detail.tamper_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Fatigue Alert', 'Fatigue Event') THEN detail.fatigue_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Travel Stop' THEN detail.travel_stop_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Tilt' THEN detail.tilt_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Door Possible Hijack', 'Door Possible Hijack On') THEN detail.dph_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Jamming Detected' THEN detail.jamming_notes
                    WHEN CAST($event AS NVARCHAR(200)) IN ('Cargo Area Panic On', 'Cargo Area Panic') THEN detail.cap_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Harness Tamper' THEN detail.harness_t_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Limp Geofences Entrance' THEN detail.limp_geofence_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Gate Jam' THEN detail.gate_jam_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Removed' THEN detail.removed_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Limp Activate' THEN detail.limp_activate_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Max Time Exceeded' THEN detail.max_time_exceed_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Moving Out Of Geofence' THEN detail.moving_out_of_geofence_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'Please Call Me' THEN detail.please_call_me_notes
                    WHEN CAST($event AS NVARCHAR(200)) = 'PO' THEN detail.po_notes
                    ELSE NULL
                END AS event_note
            FROM ApplicationDb5.dbo.Zoho_Escalation_List detail
            WHERE TRY_CONVERT(NVARCHAR(100), detail.zoho_id) = (
                SELECT TOP (1) TRY_CONVERT(NVARCHAR(100), company_map.escallation_no)
                FROM ApplicationDb6.dbo.Vehicleinfo vehicle
                LEFT JOIN ApplicationDb3.dbo.Companies company_map
                    ON company_map.Company = vehicle.Company
                   AND company_map.Fleet_Code = vehicle.Fleet_Code
                WHERE UPPER(LTRIM(RTRIM(vehicle.Reg_no))) = UPPER(LTRIM(RTRIM(CAST($reg_no AS NVARCHAR(100)))))
            )
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS escalation
        ,
        JSON_QUERY((SELECT q.seqno AS caseId,CAST(CASE WHEN TRY_CONVERT(int,q.[close])=1 THEN 1 ELSE 0 END AS bit) AS closed,CAST(CASE WHEN (TRY_CONVERT(int,q.[close])=1 OR q.zoho_insert IN(0,3) OR EXISTS(SELECT 1 FROM ApplicationDb1.dbo.CCQuickLogSync completed_sync WHERE completed_sync.CaseID=q.seqno AND completed_sync.SyncState=N'Complete')) THEN 1 ELSE 0 END AS bit) AS completed,q.seat,
 CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(nvarchar(max),(SELECT q.reg_no,q.event,q.seat,q.cc_operator,q.c_name,q.c_number,q.comm_type,q.datetime_comm,q.comments,q.[close],q.zoho_insert,q.zoho_id,q.reference,
 JSON_QUERY((SELECT c.comm_id,c.comm_type,c.contact_name,c.contact_no,c.email_address,c.comments,c.cc_operator,c.datetime_comm,c.zoho_pushed,c.DisplayOrder FROM ApplicationDb1.dbo.quick_log_Comments c WHERE c.case_id=q.seqno ORDER BY c.comm_id FOR JSON PATH,INCLUDE_NULL_VALUES)) AS communications
 FOR JSON PATH,INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER))),2) AS snapshot,
 JSON_QUERY((SELECT CAST(0 AS int) AS commId,q.comm_type AS commType,q.c_name AS contactName,q.c_number AS contactNo,CAST(NULL AS nvarchar(200)) AS emailAddress,q.comments,q.cc_operator AS ccOperator,CONVERT(nvarchar(19),COALESCE(q.datetime_comm,q.datetime_opened),120) AS datetimeComm,CAST(CASE WHEN (q.zoho_insert=0 AND NULLIF(LTRIM(RTRIM(q.zoho_id)),N'') IS NOT NULL AND NULLIF(LTRIM(RTRIM(q.reference)),N'') IS NOT NULL) OR EXISTS(SELECT 1 FROM ApplicationDb1.dbo.CCQuickLogSync completed_sync WHERE completed_sync.CaseID=q.seqno AND completed_sync.SyncState=N'Complete') THEN 1 ELSE 0 END AS bit) AS zohoPushed FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)) AS initialCommunication
 FROM ApplicationDb5.dbo.CC_quick_log q WHERE q.seqno=TRY_CONVERT(int,$seqno) AND UPPER(LTRIM(RTRIM(q.reg_no)))=UPPER(LTRIM(RTRIM(CAST($reg_no AS nvarchar(100))))) AND q.event=CAST($event AS nvarchar(200)) FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)) AS quickLogCase,
        JSON_QUERY((
            SELECT
                comment.comm_id AS commId,
                comment.case_id AS caseId,
                comment.comm_type AS commType,
                comment.contact_name AS contactName,
                comment.contact_no AS contactNo,
                comment.email_address AS emailAddress,
                comment.comments AS comments,
                comment.cc_operator AS ccOperator,
                CONVERT(nvarchar(19),comment.datetime_comm,120) AS datetimeComm,
                comment.zoho_pushed AS zohoPushed,
                COALESCE(FORMAT(comment.zoho_pushed_datetime, 'yyyy-MM-dd HH:mm'), '-') AS zohoPushedDatetime
            FROM ApplicationDb1.dbo.quick_log_Comments comment JOIN ApplicationDb5.dbo.CC_quick_log parent_case ON parent_case.seqno=comment.case_id
            WHERE comment.case_id = TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(CAST($seqno AS NVARCHAR(100)))), ''))
            AND UPPER(LTRIM(RTRIM(parent_case.reg_no)))=UPPER(LTRIM(RTRIM(CAST($reg_no AS nvarchar(100)))))
            AND parent_case.event=CAST($event AS nvarchar(200))
            ORDER BY COALESCE(comment.DisplayOrder,comment.comm_id),comment.comm_id
            FOR JSON PATH
        )) AS quickLogComments
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) END AS contents;
