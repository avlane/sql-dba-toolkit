-- sql-dba-toolkit
-- Run in the database you want to look at unless the header says otherwise.

SELECT s.name AS schema_name,
       t.name AS table_name,
       SUM(CASE WHEN p.index_id IN (0, 1) THEN p.row_count ELSE 0 END) AS row_count,
       CAST(SUM(p.reserved_page_count) * 8 / 1024.0 AS DECIMAL(18,2)) AS reserved_mb
FROM sys.dm_db_partition_stats AS p
JOIN sys.tables  AS t ON t.object_id = p.object_id
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name
ORDER BY reserved_mb DESC;
