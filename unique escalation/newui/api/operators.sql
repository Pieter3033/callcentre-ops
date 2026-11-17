WITH operators AS (
    SELECT DISTINCT LTRIM(RTRIM(cc_operator)) AS operator_name
    FROM ApplicationDb5.[dbo].[CC_quick_log]
    WHERE ISNULL(LTRIM(RTRIM(cc_operator)), '') <> ''
)
SELECT 'json' AS component,
       (
           SELECT JSON_QUERY(
                      COALESCE(
                          '[' + (
                              SELECT STRING_AGG('"' + STRING_ESCAPE(operator_name, 'json') + '"', ',')
                              FROM operators
                          ) + ']',
                          '[]'
                      )
                  ) AS [operators]
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
       ) AS contents;
