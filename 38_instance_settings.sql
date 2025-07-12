-- The three settings that are wrong on most new installs.
SELECT c.name,
       CAST(c.value_in_use AS BIGINT) AS value_in_use,
       CASE c.name
            WHEN N'max server memory (MB)'
                 THEN CASE WHEN CAST(c.value_in_use AS BIGINT) >= 2147483647 THEN 'default (unlimited): set it'
                           ELSE 'physical memory is ' + CAST(i.physical_memory_kb / 1024 AS VARCHAR(20)) + ' MB' END
            WHEN N'max degree of parallelism'
                 THEN CASE WHEN CAST(c.value_in_use AS BIGINT) = 0 THEN 'default (all cores): review' ELSE 'set' END
            WHEN N'cost threshold for parallelism'
                 THEN CASE WHEN CAST(c.value_in_use AS BIGINT) = 5 THEN 'default (5): usually too low' ELSE 'set' END
       END AS comment
FROM sys.configurations AS c
CROSS JOIN sys.dm_os_sys_info AS i
WHERE c.name IN (N'max server memory (MB)', N'max degree of parallelism', N'cost threshold for parallelism');

SELECT cpu_count, hyperthread_ratio, softnuma_configuration_desc FROM sys.dm_os_sys_info;
