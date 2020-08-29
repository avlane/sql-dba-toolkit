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
