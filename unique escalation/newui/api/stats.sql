WITH params AS (
    SELECT COALESCE(TRY_CONVERT(DATETIME2, NULLIF($start, ''), 126), DATEADD(DAY, -7, GETDATE())) AS effective_start,
           COALESCE(TRY_CONVERT(DATETIME2, NULLIF($end, ''), 126), GETDATE()) AS effective_end,
           NULLIF(LTRIM(RTRIM($operators)), '') AS requested_operators
),
selected_operators AS (
    SELECT DISTINCT LTRIM(RTRIM(split_values.value)) AS operator_name
    FROM params
    CROSS APPLY STRING_SPLIT(COALESCE(params.requested_operators, ''), ',') AS split_values
    WHERE LTRIM(RTRIM(split_values.value)) <> ''
),
filtered_rows AS (
    SELECT LTRIM(RTRIM(logs.cc_operator)) AS cc_operator,
           COALESCE(NULLIF(LTRIM(RTRIM(logs.[event])), ''), 'Unspecified') AS [event],
           COUNT(*) AS total_logs,
           MIN(logs.datetime_opened) AS first_log_at,
           MAX(logs.datetime_opened) AS last_log_at
    FROM ApplicationDb5.[dbo].[CC_quick_log] AS logs
    CROSS JOIN params
    WHERE logs.datetime_opened >= params.effective_start
      AND logs.datetime_opened <= params.effective_end
      AND ISNULL(LTRIM(RTRIM(logs.cc_operator)), '') <> ''
      AND (
          params.requested_operators IS NULL
          OR EXISTS (
              SELECT 1
              FROM selected_operators
              WHERE selected_operators.operator_name = LTRIM(RTRIM(logs.cc_operator))
          )
      )
    GROUP BY LTRIM(RTRIM(logs.cc_operator)),
             COALESCE(NULLIF(LTRIM(RTRIM(logs.[event])), ''), 'Unspecified')
),
event_totals AS (
    SELECT [event],
           SUM(total_logs) AS total_logs
    FROM filtered_rows
    GROUP BY [event]
)
SELECT 'json' AS component,
       (
           SELECT JSON_QUERY(
                      (
                          SELECT CONVERT(VARCHAR(19), params.effective_start, 126) AS [start],
                                 CONVERT(VARCHAR(19), params.effective_end, 126) AS [end],
                                 JSON_QUERY(
                                     COALESCE(
                                         '[' + (
                                             SELECT STRING_AGG('"' + STRING_ESCAPE(selected_operators.operator_name, 'json') + '"', ',')
                                             FROM selected_operators
                                         ) + ']',
                                         '[]'
                                     )
                                 ) AS [operators]
                          FROM params
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                      )
                  ) AS [filters],
                  JSON_QUERY(
                      COALESCE(
                          (
                              SELECT filtered_rows.cc_operator,
                                     filtered_rows.[event],
                                     filtered_rows.total_logs,
                                     CONVERT(VARCHAR(19), filtered_rows.first_log_at, 126) AS first_log_at,
                                     CONVERT(VARCHAR(19), filtered_rows.last_log_at, 126) AS last_log_at
                              FROM filtered_rows
                              ORDER BY filtered_rows.cc_operator ASC, filtered_rows.total_logs DESC, filtered_rows.[event] ASC
                              FOR JSON PATH
                          ),
                          '[]'
                      )
                  ) AS [rows],
                  JSON_QUERY(
                      COALESCE(
                          (
                              SELECT event_totals.[event],
                                     event_totals.total_logs
                              FROM event_totals
                              ORDER BY event_totals.total_logs DESC, event_totals.[event] ASC
                              FOR JSON PATH
                          ),
                          '[]'
                      )
                  ) AS [eventTotals]
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
       ) AS contents;
