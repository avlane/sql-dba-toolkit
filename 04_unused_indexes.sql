-- sql-dba-toolkit
-- Run in the database you want to look at unless the header says otherwise.

-- Indexes that are written to but never read since the last restart.
-- sys.dm_db_index_usage_stats is cleared at restart, so check the uptime first.
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;

SELECT OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
       OBJECT_NAME(i.object_id)        AS table_name,
       i.name                          AS index_name,
       ISNULL(us.user_updates, 0)      AS user_updates,
       ISNULL(us.user_seeks + us.user_scans + us.user_lookups, 0) AS user_reads
FROM sys.indexes AS i
JOIN sys.tables  AS t ON t.object_id = i.object_id
LEFT JOIN sys.dm_db_index_usage_stats AS us
       ON us.object_id = i.object_id AND us.index_id = i.index_id AND us.database_id = DB_ID()
WHERE t.is_ms_shipped = 0
  AND i.index_id > 1
ORDER BY user_updates DESC;
