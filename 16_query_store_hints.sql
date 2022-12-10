-- Query Store hints (SQL Server 2022, compatibility level 140 or higher) change a query's behaviour
-- without touching the application. This lists what has been set so it does not become folklore.
SELECT h.query_id,
       h.query_hint_text,
       h.last_query_hint_failure_reason_desc,
       h.query_hint_failure_count,
       h.source_desc,
       LEFT(qt.query_sql_text, 200) AS query_text
FROM sys.query_store_query_hints AS h
JOIN sys.query_store_query       AS q  ON q.query_id = h.query_id
JOIN sys.query_store_query_text  AS qt ON qt.query_text_id = q.query_text_id
ORDER BY h.query_hint_failure_count DESC, h.query_id;

-- Set one:   EXEC sys.sp_query_store_set_hints @query_id = 42, @query_hints = N'OPTION (MAXDOP 1)';
-- Remove it: EXEC sys.sp_query_store_clear_hints @query_id = 42;
