-- Top 20 query shapes by total CPU. Ad hoc statements that differ only in literals share a
-- query_hash, so grouping on it shows the real cost of a pattern that fills the cache with one-off plans.
SELECT TOP (20)
       SUM(qs.total_worker_time) / 1000                                   AS total_cpu_ms,
       SUM(qs.execution_count)                                            AS execution_count,
       SUM(qs.total_worker_time) / 1000 / NULLIF(SUM(qs.execution_count), 0)  AS avg_cpu_ms,
       SUM(qs.total_elapsed_time) / 1000 / NULLIF(SUM(qs.execution_count), 0) AS avg_elapsed_ms,
       SUM(qs.total_logical_reads) / NULLIF(SUM(qs.execution_count), 0)   AS avg_logical_reads,
       COUNT(*)                                                           AS plans_in_cache,
       MIN(qs.creation_time)                                              AS oldest_plan,
       CONVERT(VARCHAR(18), qs.query_hash, 1)                             AS query_hash,
       MAX(SUBSTRING(st.text, qs.statement_start_offset / 2 + 1,
                 (CASE WHEN qs.statement_end_offset = -1 THEN DATALENGTH(st.text) ELSE qs.statement_end_offset END
                  - qs.statement_start_offset) / 2 + 1))                  AS sample_statement
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
GROUP BY qs.query_hash
ORDER BY SUM(qs.total_worker_time) DESC;
