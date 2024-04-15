-- Databases using accelerated database recovery (SQL Server 2019+) and the size of their
-- persistent version store. A PVS that keeps growing usually means an old open transaction.
SELECT d.name AS database_name,
       d.is_accelerated_database_recovery_on AS adr_on,
       CAST(pvs.persistent_version_store_size_kb / 1024.0 AS DECIMAL(18,1)) AS pvs_mb,
       pvs.current_aborted_transaction_count,
       pvs.oldest_active_transaction_id,
       pvs.online_index_version_store_size_kb
FROM sys.databases AS d
LEFT JOIN sys.dm_tran_persistent_version_store_stats AS pvs ON pvs.database_id = d.database_id
WHERE d.is_accelerated_database_recovery_on = 1
ORDER BY pvs.persistent_version_store_size_kb DESC;

-- Oldest open transactions in this instance
SELECT TOP (5) s.session_id, s.login_name, at.transaction_begin_time,
       DATEDIFF(MINUTE, at.transaction_begin_time, GETDATE()) AS minutes_open
FROM sys.dm_tran_active_transactions AS at
JOIN sys.dm_tran_session_transactions AS st ON st.transaction_id = at.transaction_id
JOIN sys.dm_exec_sessions AS s ON s.session_id = st.session_id
ORDER BY at.transaction_begin_time;
