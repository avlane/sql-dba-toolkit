-- sql-dba-toolkit
-- Run in the database you want to look at unless the header says otherwise.

WITH sizes AS
(
    SELECT p.object_id,
           SUM(CASE WHEN p.index_id IN (0, 1) THEN p.row_count ELSE 0 END)                                    AS row_count,
           SUM(CASE WHEN p.index_id IN (0, 1)
                    THEN p.in_row_data_page_count + p.lob_used_page_count + p.row_overflow_used_page_count ELSE 0 END) AS data_pages,
           SUM(p.used_page_count)     AS used_pages,
           SUM(p.reserved_page_count) AS reserved_pages
    FROM sys.dm_db_partition_stats AS p
    GROUP BY p.object_id
)
SELECT s.name AS schema_name,
       t.name AS table_name,
       z.row_count,
       CAST(z.reserved_pages * 8 / 1024.0 AS DECIMAL(18,2))                  AS reserved_mb,
       CAST(z.data_pages * 8 / 1024.0 AS DECIMAL(18,2))                      AS data_mb,
       CAST((z.used_pages - z.data_pages) * 8 / 1024.0 AS DECIMAL(18,2))     AS index_mb,
       CAST((z.reserved_pages - z.used_pages) * 8 / 1024.0 AS DECIMAL(18,2)) AS unused_mb
FROM sizes AS z
JOIN sys.tables  AS t ON t.object_id = z.object_id
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
ORDER BY z.reserved_pages DESC;
