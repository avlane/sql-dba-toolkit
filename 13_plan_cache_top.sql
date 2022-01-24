-- Top 20 statements by total CPU since their plan was cached.
SELECT TOP (20)
       qs.total_worker_time / 1000                      AS total_cpu_ms,
       qs.execution_count,
       qs.total_worker_time / 1000 / NULLIF(qs.execution_count, 0)     AS avg_cpu_ms,
       qs.total_elapsed_time / 1000 / NULLIF(qs.execution_count, 0)    AS avg_elapsed_ms,
       qs.total_logical_reads / NULLIF(qs.execution_count, 0)          AS avg_logical_reads,
       qs.creation_time,
       DB_NAME(st.dbid) AS database_name,
       SUBSTRING(st.text, qs.statement_start_offset / 2 + 1,
                 (CASE WHEN qs.statement_end_offset = -1 THEN DATALENGTH(st.text) ELSE qs.statement_end_offset END
                  - qs.statement_start_offset) / 2 + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_worker_time DESC;
