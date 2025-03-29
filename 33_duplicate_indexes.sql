-- Indexes on the same table with the same key columns (exact duplicates), or where one index's
-- keys are the leading part of another's (the shorter one is usually redundant).
WITH keys AS
(
    SELECT i.object_id, i.index_id, i.name AS index_name, i.is_unique, i.is_primary_key,
           (SELECT STRING_AGG(CAST(ic.column_id AS VARCHAR(10)) + CASE WHEN ic.is_descending_key = 1 THEN 'd' ELSE 'a' END, ',')
                   WITHIN GROUP (ORDER BY ic.key_ordinal)
            FROM sys.index_columns AS ic
            WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0) AS key_signature
    FROM sys.indexes AS i
    JOIN sys.tables  AS t ON t.object_id = i.object_id
    WHERE i.index_id > 0 AND i.is_hypothetical = 0 AND t.is_ms_shipped = 0
)
SELECT OBJECT_SCHEMA_NAME(a.object_id) + '.' + OBJECT_NAME(a.object_id) AS table_name,
       a.index_name AS index_a,
       b.index_name AS index_b,
       a.key_signature AS keys_a,
       b.key_signature AS keys_b,
       CASE WHEN a.key_signature = b.key_signature THEN 'duplicate' ELSE 'a is a prefix of b' END AS finding
FROM keys AS a
JOIN keys AS b ON b.object_id = a.object_id
              AND b.index_id <> a.index_id
              AND (b.key_signature = a.key_signature OR b.key_signature LIKE a.key_signature + ',%')
WHERE a.index_id < b.index_id OR a.key_signature <> b.key_signature
ORDER BY table_name, index_a;
