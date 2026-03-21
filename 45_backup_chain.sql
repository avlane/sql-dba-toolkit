-- For each database in FULL or BULK_LOGGED recovery: log backups whose first_lsn does not
-- match the previous log backup's last_lsn. A mismatch is a hole in the chain; point-in-time
-- restore across it is impossible.
WITH logs AS
(
    SELECT b.database_name, b.backup_start_date, b.first_lsn, b.last_lsn,
           LAG(b.last_lsn) OVER (PARTITION BY b.database_name ORDER BY b.backup_start_date) AS prev_last_lsn
    FROM msdb.dbo.backupset AS b
    WHERE b.type = 'L'
      AND b.backup_start_date >= DATEADD(DAY, -14, GETDATE())
)
SELECT database_name, backup_start_date, first_lsn, prev_last_lsn
FROM logs
WHERE prev_last_lsn IS NOT NULL
  AND first_lsn <> prev_last_lsn
ORDER BY database_name, backup_start_date;
