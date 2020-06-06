-- Takes two snapshots of sys.dm_os_wait_stats and reports what happened in between.
-- Cumulative numbers since startup hide what is slow right now; the delta does not.
DECLARE @SampleSeconds INT = 30;
DECLARE @delay CHAR(8) = CONVERT(CHAR(8), DATEADD(SECOND, @SampleSeconds, 0), 108);

SELECT wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms
INTO #before
FROM sys.dm_os_wait_stats;

WAITFOR DELAY @delay;

SELECT a.wait_type,
       a.waiting_tasks_count - b.waiting_tasks_count AS waiting_tasks,
       a.wait_time_ms - b.wait_time_ms               AS wait_time_ms,
       a.signal_wait_time_ms - b.signal_wait_time_ms AS signal_wait_ms
FROM sys.dm_os_wait_stats AS a
JOIN #before AS b ON b.wait_type = a.wait_type
WHERE a.wait_time_ms - b.wait_time_ms > 0
ORDER BY wait_time_ms DESC;

DROP TABLE #before;
