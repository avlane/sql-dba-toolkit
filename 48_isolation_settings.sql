-- Row versioning settings. RCSI changes locking behaviour for every READ COMMITTED query, so know
-- which databases have it; snapshot isolation is opt-in per session.
SELECT d.name AS database_name,
       d.is_read_committed_snapshot_on AS rcsi,
       d.snapshot_isolation_state_desc,
       d.is_accelerated_database_recovery_on AS adr
FROM sys.databases AS d
WHERE d.database_id > 4
ORDER BY d.name;

-- Sessions currently using a non-default isolation level
SELECT s.session_id, s.login_name, s.program_name,
       CASE s.transaction_isolation_level
            WHEN 0 THEN 'Unspecified' WHEN 1 THEN 'ReadUncommitted' WHEN 2 THEN 'ReadCommitted'
            WHEN 3 THEN 'RepeatableRead' WHEN 4 THEN 'Serializable' WHEN 5 THEN 'Snapshot' END AS isolation_level
FROM sys.dm_exec_sessions AS s
WHERE s.is_user_process = 1
  AND s.transaction_isolation_level NOT IN (0, 2);
