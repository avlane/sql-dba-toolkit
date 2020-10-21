-- SQLCMD mode only. Prints each report one after the other for the current database.
:r 01_table_sizes.sql
:r 02_index_fragmentation.sql
:r 03_missing_indexes.sql
:r 04_unused_indexes.sql
:r 06_blocking_tree.sql
:r 07_backup_history.sql
:r 08_backup_gaps.sql
-- 05_wait_stats_delta.sql is left out: it sleeps for 30 seconds.
