-- Why is the log not truncating? log_reuse_wait_desc says what it is waiting for.
SELECT d.name AS database_name,
       d.recovery_model_desc,
       d.log_reuse_wait_desc,
       CAST(ls.total_log_size_in_bytes / 1048576.0 AS DECIMAL(18,1)) AS log_size_mb,
       CAST(ls.used_log_space_in_bytes / 1048576.0 AS DECIMAL(18,1)) AS log_used_mb,
       CAST(ls.used_log_space_in_percent AS DECIMAL(5,1))            AS log_used_pct
FROM sys.databases AS d
CROSS JOIN sys.dm_db_log_space_usage AS ls
WHERE d.database_id = DB_ID();

-- All databases, from the classic counter (no per-database context needed)
DBCC SQLPERF(LOGSPACE);

-- Databases whose log cannot be reused for a reason other than nothing/checkpoint
SELECT name, log_reuse_wait_desc
FROM sys.databases
WHERE log_reuse_wait_desc NOT IN (N'NOTHING', N'CHECKPOINT');
