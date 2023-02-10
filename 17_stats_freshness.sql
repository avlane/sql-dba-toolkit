-- Statistics that have changed a lot since their last update. modification_counter counts row
-- changes to the leading column since the update.
SELECT OBJECT_SCHEMA_NAME(s.object_id) AS schema_name,
       OBJECT_NAME(s.object_id)        AS table_name,
       s.name                          AS stats_name,
       sp.last_updated,
       sp.rows,
       sp.rows_sampled,
       sp.modification_counter,
       CAST(100.0 * sp.modification_counter / NULLIF(sp.rows, 0) AS DECIMAL(10,1)) AS pct_modified
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
JOIN sys.tables AS t ON t.object_id = s.object_id
WHERE t.is_ms_shipped = 0
  AND sp.modification_counter > 0
  AND sp.rows > 1000
ORDER BY pct_modified DESC;
