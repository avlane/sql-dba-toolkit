-- Takes two snapshots of sys.dm_os_wait_stats and reports what happened in between.
-- Cumulative numbers since startup hide what is slow right now; the delta does not.
DECLARE @SampleSeconds INT = 30;
DECLARE @delay CHAR(8) = CONVERT(CHAR(8), DATEADD(SECOND, @SampleSeconds, 0), 108);

SELECT wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms
INTO #before
FROM sys.dm_os_wait_stats;

WAITFOR DELAY @delay;

WITH delta AS
(
SELECT a.wait_type,
       a.waiting_tasks_count - b.waiting_tasks_count AS waiting_tasks,
       a.wait_time_ms - b.wait_time_ms               AS wait_time_ms,
       a.signal_wait_time_ms - b.signal_wait_time_ms AS signal_wait_ms
FROM sys.dm_os_wait_stats AS a
JOIN #before AS b ON b.wait_type = a.wait_type
WHERE a.wait_time_ms - b.wait_time_ms > 0
  AND a.wait_type NOT IN (
      N'SLEEP_TASK', N'SLEEP_SYSTEMTASK', N'SLEEP_BPOOL_FLUSH', N'LAZYWRITER_SLEEP', N'CHECKPOINT_QUEUE',
      N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT', N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN',
      N'BROKER_TO_FLUSH', N'BROKER_TASK_STOP', N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
      N'WAITFOR', N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
      N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE', N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
      N'DIRTY_PAGE_POLL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_WORK_QUEUE', N'HADR_CLUSAPI_CALL',
      N'HADR_TIMER_TASK', N'HADR_LOGCAPTURE_WAIT', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
      N'QDS_ASYNC_QUEUE', N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'SP_SERVER_DIAGNOSTICS_SLEEP',
      N'PREEMPTIVE_XE_GETTARGETSTATE', N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT',
      N'SOS_WORK_DISPATCHER', N'PARALLEL_REDO_WORKER_WAIT_WORK', N'PARALLEL_REDO_DRAIN_WORKER',
      N'HADR_NOTIFICATION_DEQUEUE', N'HADR_FABRIC_CALLBACK', N'QDS_SHUTDOWN_QUEUE', N'MEMORY_ALLOCATION_EXT',
      N'PVS_PREALLOCATE', N'SQLTRACE_WAIT_ENTRIES', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'XTP_PREEMPTIVE_TASK',
      N'REDO_THREAD_PENDING_WORK', N'UCS_SESSION_REGISTRATION', N'PREEMPTIVE_OS_FLUSHFILEBUFFERS')
)
SELECT wait_type,
       CASE
            WHEN wait_type LIKE N'PAGEIOLATCH%'   THEN 'Waiting for a data page to be read from disk'
            WHEN wait_type LIKE N'PAGELATCH%'     THEN 'In-memory page contention (tempdb allocation pages, hot rows)'
            WHEN wait_type = N'WRITELOG'          THEN 'Waiting for the transaction log flush'
            WHEN wait_type = N'CXPACKET' OR wait_type = N'CXCONSUMER' THEN 'Parallelism; check MAXDOP and cost threshold'
            WHEN wait_type = N'SOS_SCHEDULER_YIELD' THEN 'CPU pressure: tasks yielding to wait for a scheduler'
            WHEN wait_type LIKE N'LCK_M%'         THEN 'Blocking: waiting for a lock'
            WHEN wait_type = N'ASYNC_NETWORK_IO'  THEN 'Client is slow to consume results'
            WHEN wait_type = N'RESOURCE_SEMAPHORE' THEN 'Queries waiting for a memory grant'
            WHEN wait_type LIKE N'HADR_SYNC_COMMIT' THEN 'Synchronous AG commit waiting on a replica'
       END AS explanation,
       waiting_tasks,
       wait_time_ms,
       wait_time_ms - signal_wait_ms AS resource_wait_ms,
       signal_wait_ms,
       CAST(100.0 * wait_time_ms / NULLIF(SUM(wait_time_ms) OVER (), 0) AS DECIMAL(5,2)) AS pct_of_total
FROM delta
ORDER BY wait_time_ms DESC;

DROP TABLE #before;
