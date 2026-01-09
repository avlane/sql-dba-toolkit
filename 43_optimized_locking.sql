-- SQL Server 2025: optimized locking (TID locking and lock after qualification) needs accelerated
-- database recovery and is most effective with RCSI. Shows where it is on and what it depends on.
SELECT d.name AS database_name,
       CAST(DATABASEPROPERTYEX(d.name, 'IsOptimizedLockingOn') AS INT) AS optimized_locking_on,
       d.is_accelerated_database_recovery_on AS adr_on,
       d.is_read_committed_snapshot_on AS rcsi_on,
       d.snapshot_isolation_state_desc
FROM sys.databases AS d
WHERE d.state_desc = N'ONLINE'
  AND d.database_id > 4
ORDER BY d.name;
-- NULL in optimized_locking_on means the instance is older than SQL Server 2025.
