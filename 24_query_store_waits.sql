-- Which wait categories hurt the most in Query Store over the last 24 hours, and which queries cause them.
-- Wait capture is on by default for Query Store since SQL Server 2017.
SELECT TOP (25)
       q.query_id,
       ws.wait_category_desc,
       CAST(SUM(ws.total_query_wait_time_ms) AS BIGINT) AS total_wait_ms,
       LEFT(qt.query_sql_text, 200) AS query_text
FROM sys.query_store_wait_stats AS ws
JOIN sys.query_store_runtime_stats_interval AS i ON i.runtime_stats_interval_id = ws.runtime_stats_interval_id
JOIN sys.query_store_plan AS p ON p.plan_id = ws.plan_id
JOIN sys.query_store_query AS q ON q.query_id = p.query_id
JOIN sys.query_store_query_text AS qt ON qt.query_text_id = q.query_text_id
WHERE i.start_time >= DATEADD(HOUR, -24, SYSDATETIMEOFFSET())
  AND ws.wait_category_desc NOT IN (N'Unknown', N'Idle')
GROUP BY q.query_id, ws.wait_category_desc, qt.query_sql_text
ORDER BY total_wait_ms DESC;
