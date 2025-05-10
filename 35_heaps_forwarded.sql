-- Heaps accumulate forwarded records when rows grow; every lookup then costs an extra read.
-- SAMPLED mode is needed to populate forwarded_record_count and can take a while on big heaps.
SELECT OBJECT_SCHEMA_NAME(ips.object_id) + '.' + OBJECT_NAME(ips.object_id) AS table_name,
       ips.page_count,
       ips.record_count,
       ips.forwarded_record_count,
       CAST(100.0 * ips.forwarded_record_count / NULLIF(ips.record_count, 0) AS DECIMAL(5,1)) AS forwarded_pct
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, 0, NULL, 'SAMPLED') AS ips
WHERE ips.index_id = 0
  AND ips.page_count > 100
ORDER BY ips.forwarded_record_count DESC;
-- Fix: ALTER TABLE ... REBUILD, or better, give the table a clustered index.
