-- Average read and write latency per database file since the instance started.
-- Rough guide: data files under 20 ms is acceptable, log files should be under 5 ms.
SELECT DB_NAME(vfs.database_id) AS database_name,
       mf.name AS logical_name,
       mf.type_desc,
       vfs.num_of_reads,
       vfs.num_of_writes,
       CAST(vfs.io_stall_read_ms  * 1.0 / NULLIF(vfs.num_of_reads, 0)  AS DECIMAL(10,1)) AS avg_read_ms,
       CAST(vfs.io_stall_write_ms * 1.0 / NULLIF(vfs.num_of_writes, 0) AS DECIMAL(10,1)) AS avg_write_ms,
       CAST(vfs.num_of_bytes_read / 1048576.0 AS DECIMAL(18,0))    AS read_mb,
       CAST(vfs.num_of_bytes_written / 1048576.0 AS DECIMAL(18,0)) AS written_mb,
       mf.physical_name
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
ORDER BY (vfs.io_stall_read_ms + vfs.io_stall_write_ms) DESC;
