-- SQL Server's own CPU use versus everything else on the box, one row per minute, last 60 minutes.
DECLARE @now BIGINT = (SELECT ms_ticks FROM sys.dm_os_sys_info);

SELECT TOP (60)
       DATEADD(MILLISECOND, -1 * (@now - rb.[timestamp]), GETDATE()) AS sample_time,
       rb.rec.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'INT') AS sql_cpu_pct,
       rb.rec.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'INT')         AS system_idle_pct,
       100 - rb.rec.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'INT')
           - rb.rec.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'INT') AS other_cpu_pct
FROM (
    SELECT [timestamp], CAST(record AS XML) AS rec
    FROM sys.dm_os_ring_buffers
    WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
      AND record LIKE N'%<SystemHealth>%'
) AS rb
ORDER BY rb.[timestamp] DESC;
