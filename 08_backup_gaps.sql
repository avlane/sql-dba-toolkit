-- Databases with no recent full backup, or FULL/BULK_LOGGED databases with no recent log backup.
DECLARE @FullHours INT = 26;    -- a nightly full plus an hour of slack
DECLARE @LogMinutes INT = 60;

SELECT d.name AS database_name,
       d.recovery_model_desc,
       lf.last_full,
       ll.last_log,
       CASE WHEN lf.last_full IS NULL THEN 'NO FULL BACKUP EVER'
            WHEN lf.last_full < DATEADD(HOUR, -@FullHours, GETDATE()) THEN 'FULL BACKUP OVERDUE' END AS full_problem,
       CASE WHEN d.recovery_model_desc <> 'SIMPLE' AND ll.last_log IS NULL THEN 'NO LOG BACKUP EVER'
            WHEN d.recovery_model_desc <> 'SIMPLE' AND ll.last_log < DATEADD(MINUTE, -@LogMinutes, GETDATE()) THEN 'LOG BACKUP OVERDUE' END AS log_problem
FROM sys.databases AS d
OUTER APPLY (SELECT MAX(backup_finish_date) AS last_full FROM msdb.dbo.backupset WHERE database_name = d.name AND type = 'D' AND is_copy_only = 0) AS lf
OUTER APPLY (SELECT MAX(backup_finish_date) AS last_log  FROM msdb.dbo.backupset WHERE database_name = d.name AND type = 'L' AND is_copy_only = 0) AS ll
WHERE d.database_id <> 2
  AND d.state_desc = 'ONLINE'
  AND sys.fn_hadr_backup_is_preferred_replica(d.name) = 1   -- 1 for databases outside an AG too
  AND d.source_database_id IS NULL        -- database snapshots cannot be backed up
  AND ISNULL(d.is_in_standby, 0) = 0
  AND (lf.last_full IS NULL OR lf.last_full < DATEADD(HOUR, -@FullHours, GETDATE())
       OR (d.recovery_model_desc <> 'SIMPLE' AND (ll.last_log IS NULL OR ll.last_log < DATEADD(MINUTE, -@LogMinutes, GETDATE()))))
ORDER BY d.name;

-- Copy-only backups (taken by hand for a refresh, say) do not reset the differential base or the log chain,
-- so they must not make a database look protected.
