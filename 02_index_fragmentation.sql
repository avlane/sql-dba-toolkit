-- sql-dba-toolkit
-- Run in the database you want to look at unless the header says otherwise.

-- LIMITED mode reads only the upper levels of each index, so it is cheap enough for most databases.
-- Fragmentation of indexes under about 1000 pages (8 MB) is noise: they often live in mixed extents
-- and a rebuild does not change the number.
DECLARE @MinPages INT = 1000;

SELECT OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
       OBJECT_NAME(ips.object_id)        AS table_name,
       i.name                            AS index_name,
       ips.index_type_desc,
       ips.avg_fragmentation_in_percent,
       ips.page_count,
       CASE WHEN ips.avg_fragmentation_in_percent >= 30 THEN 'REBUILD'
            WHEN ips.avg_fragmentation_in_percent >= 5  THEN 'REORGANIZE'
            ELSE 'ok' END AS recommendation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
JOIN sys.indexes AS i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_id > 0
  AND ips.page_count >= @MinPages
ORDER BY ips.avg_fragmentation_in_percent DESC, ips.page_count DESC;
