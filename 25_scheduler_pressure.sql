-- Runnable tasks waiting for CPU. Sustained runnable_tasks_count above 0 on several schedulers,
-- together with a high signal wait percentage, means CPU pressure.
SELECT scheduler_id,
       cpu_id,
       current_tasks_count,
       runnable_tasks_count,
       work_queue_count,
       pending_disk_io_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255          -- skip hidden schedulers
  AND status = N'VISIBLE ONLINE'
ORDER BY runnable_tasks_count DESC;

SELECT CAST(100.0 * SUM(signal_wait_time_ms) / NULLIF(SUM(wait_time_ms), 0) AS DECIMAL(5,2)) AS signal_wait_pct
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE N'SLEEP%' AND wait_type NOT LIKE N'%QUEUE%';
