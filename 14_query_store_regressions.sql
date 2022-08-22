-- Queries whose average duration in the last few hours is much worse than their history.
-- Needs Query Store enabled on the database (SQL Server 2016+). Run in the database to check.
DECLARE @RecentHours   INT = 4;
DECLARE @HistoryDays   INT = 14;
DECLARE @MinExecutions INT = 20;
DECLARE @MinRatio      FLOAT = 2.0;

WITH rs AS
(
    SELECT p.query_id,
           i.start_time,
           r.count_executions,
           r.avg_duration * r.count_executions AS duration_sum
    FROM sys.query_store_runtime_stats          AS r
    JOIN sys.query_store_runtime_stats_interval AS i ON i.runtime_stats_interval_id = r.runtime_stats_interval_id
    JOIN sys.query_store_plan                   AS p ON p.plan_id = r.plan_id
    WHERE i.start_time >= DATEADD(DAY, -@HistoryDays, SYSDATETIMEOFFSET())
),
agg AS
(
    SELECT query_id,
           SUM(CASE WHEN start_time >= DATEADD(HOUR, -@RecentHours, SYSDATETIMEOFFSET()) THEN count_executions ELSE 0 END) AS recent_exec,
           SUM(CASE WHEN start_time >= DATEADD(HOUR, -@RecentHours, SYSDATETIMEOFFSET()) THEN duration_sum ELSE 0 END)     AS recent_dur,
           SUM(CASE WHEN start_time <  DATEADD(HOUR, -@RecentHours, SYSDATETIMEOFFSET()) THEN count_executions ELSE 0 END) AS hist_exec,
           SUM(CASE WHEN start_time <  DATEADD(HOUR, -@RecentHours, SYSDATETIMEOFFSET()) THEN duration_sum ELSE 0 END)     AS hist_dur
    FROM rs
    GROUP BY query_id
)
SELECT TOP (25)
       a.query_id,
       a.recent_exec,
       a.hist_exec,
       CAST(a.recent_dur / NULLIF(a.recent_exec, 0) / 1000.0 AS DECIMAL(18,1)) AS recent_avg_ms,
       CAST(a.hist_dur / NULLIF(a.hist_exec, 0) / 1000.0 AS DECIMAL(18,1))         AS history_avg_ms,
       CAST((a.recent_dur / a.recent_exec) / (a.hist_dur / NULLIF(a.hist_exec, 0)) AS DECIMAL(10,1)) AS slowdown_ratio,
       LEFT(qt.query_sql_text, 300) AS query_text
FROM agg AS a
JOIN sys.query_store_query      AS q  ON q.query_id = a.query_id
JOIN sys.query_store_query_text AS qt ON qt.query_text_id = q.query_text_id
WHERE a.recent_exec >= @MinExecutions
  AND a.hist_exec   >= @MinExecutions
  AND (a.recent_dur / a.recent_exec) >= @MinRatio * (a.hist_dur / NULLIF(a.hist_exec, 0))
ORDER BY slowdown_ratio DESC;
