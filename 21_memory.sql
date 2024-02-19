-- Page life expectancy (seconds a page stays in the buffer pool). Per NUMA node rows are included.
SELECT RTRIM(object_name) AS counter_object, RTRIM(instance_name) AS numa_node, cntr_value AS ple_seconds
FROM sys.dm_os_performance_counters
WHERE counter_name = N'Page life expectancy'
  AND object_name LIKE N'%Buffer%';

-- Top memory consumers
SELECT TOP (15)
       type AS clerk_type,
       CAST(SUM(pages_kb) / 1024.0 AS DECIMAL(18,1)) AS memory_mb
FROM sys.dm_os_memory_clerks
GROUP BY type
ORDER BY SUM(pages_kb) DESC;

-- Target versus committed memory
SELECT CAST(committed_kb / 1024.0 AS DECIMAL(18,0))        AS committed_mb,
       CAST(committed_target_kb / 1024.0 AS DECIMAL(18,0)) AS target_mb
FROM sys.dm_os_sys_info;
