-- sql-dba-toolkit
-- Run in the database you want to look at unless the header says otherwise.

-- The missing index DMVs are reset at every restart and only cover plans compiled since.
-- Treat the output as hints to review, never as a script to run blindly.
SELECT TOP (25)
       DB_NAME(mid.database_id) AS database_name,
       OBJECT_NAME(mid.object_id, mid.database_id) AS table_name,
       mid.equality_columns,
       mid.inequality_columns,
       mid.included_columns,
       migs.user_seeks,
       migs.user_scans,
       migs.avg_total_user_cost,
       migs.avg_user_impact,
       'CREATE NONCLUSTERED INDEX [IX_' + OBJECT_NAME(mid.object_id, mid.database_id) + '_'
           + CAST(mig.index_handle AS VARCHAR(10)) + '] ON '
           + mid.statement + ' ('
           + ISNULL(mid.equality_columns, '')
           + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ', ' ELSE '' END
           + ISNULL(mid.inequality_columns, '') + ')'
           + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_statement,
       CAST(migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS DECIMAL(20,0)) AS improvement_score
FROM sys.dm_db_missing_index_details     AS mid
JOIN sys.dm_db_missing_index_groups      AS mig  ON mig.index_handle = mid.index_handle
JOIN sys.dm_db_missing_index_group_stats AS migs ON migs.group_handle = mig.index_group_handle
WHERE mid.database_id = DB_ID()
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC;
