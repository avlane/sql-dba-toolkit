-- PAGELATCH waits on tempdb pages 2:x:1 (PFS), 2:x:2 (GAM) and 2:x:3 (SGAM) mean allocation contention.
SELECT wt.session_id,
       wt.wait_type,
       wt.wait_duration_ms,
       wt.resource_description,
       CASE WHEN wt.resource_description LIKE N'2:%:1' OR wt.resource_description LIKE N'2:%:8088' THEN 'PFS'
            WHEN wt.resource_description LIKE N'2:%:2' THEN 'GAM'
            WHEN wt.resource_description LIKE N'2:%:3' THEN 'SGAM' END AS allocation_page
FROM sys.dm_os_waiting_tasks AS wt
WHERE wt.wait_type LIKE N'PAGELATCH%'
  AND wt.resource_description LIKE N'2:%';

-- Are the tempdb data files equally sized? Unequal files defeat proportional fill.
SELECT name, CAST(size * 8 / 1024.0 AS DECIMAL(18,1)) AS size_mb, growth, is_percent_growth
FROM tempdb.sys.database_files
WHERE type_desc = N'ROWS'
ORDER BY name;
