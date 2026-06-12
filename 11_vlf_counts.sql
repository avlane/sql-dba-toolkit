-- Many small VLFs slow down startup, restore and log backups. A few hundred is fine; thousands are not.
-- sys.dm_db_log_info needs SQL Server 2016 SP2 or later.
SELECT d.name AS database_name,
       COUNT(*) AS vlf_count,
       SUM(CASE WHEN li.vlf_active = 1 THEN 1 ELSE 0 END) AS active_vlfs,
       CAST(SUM(li.vlf_size_mb) AS DECIMAL(18,1)) AS log_size_mb,
       CAST(AVG(li.vlf_size_mb) AS DECIMAL(18,2)) AS avg_vlf_mb,
       CASE WHEN SUM(li.vlf_size_mb) < 1024  THEN 8
            WHEN SUM(li.vlf_size_mb) < 8192  THEN 16
            ELSE 32 END AS suggested_vlf_target,
       CASE WHEN COUNT(*) > 1000 THEN 'FIX NOW'
            WHEN COUNT(*) > 300  THEN 'watch'
            ELSE 'ok' END AS verdict
FROM sys.databases AS d
CROSS APPLY sys.dm_db_log_info(d.database_id) AS li
WHERE d.state_desc = 'ONLINE'
GROUP BY d.name
ORDER BY vlf_count DESC;
