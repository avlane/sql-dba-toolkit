-- Latest full, differential and log backup per database, from msdb.
SELECT d.name AS database_name,
       d.recovery_model_desc,
       MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS last_full,
       MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END) AS last_diff,
       MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS last_log
FROM sys.databases AS d
LEFT JOIN msdb.dbo.backupset AS b ON b.database_name = d.name
WHERE d.database_id <> 2          -- tempdb is never backed up
GROUP BY d.name, d.recovery_model_desc
ORDER BY d.name;


-- Detail for the most recent full backup of each database
SELECT x.database_name,
       x.backup_finish_date,
       DATEDIFF(SECOND, x.backup_start_date, x.backup_finish_date)  AS duration_sec,
       CAST(x.backup_size / 1048576.0 AS DECIMAL(18,1))             AS size_mb,
       CAST(x.compressed_backup_size / 1048576.0 AS DECIMAL(18,1))  AS compressed_mb,
       CAST(100.0 * (1 - x.compressed_backup_size / NULLIF(x.backup_size, 0)) AS DECIMAL(5,1)) AS compression_pct,
       mf.physical_device_name
FROM (
    SELECT b.*, ROW_NUMBER() OVER (PARTITION BY b.database_name ORDER BY b.backup_finish_date DESC) AS rn
    FROM msdb.dbo.backupset AS b
    WHERE b.type = 'D'
) AS x
JOIN msdb.dbo.backupmediafamily AS mf ON mf.media_set_id = x.media_set_id
WHERE x.rn = 1
ORDER BY x.database_name;
