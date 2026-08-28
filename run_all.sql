-- SQLCMD mode only (SSMS: Query > SQLCMD Mode, or sqlcmd -i). Runs the reports against the connected
-- instance and the current database. Reports needing a newer SQL Server than yours fail on their own
-- and the rest continue; 43 and 30 are left out because they use 2025 features, and 07 has one REGEXP_LIKE line to delete on older versions.
-- Instance level
:r 05_wait_stats_delta.sql
:r 21_memory.sql
:r 20_io_latency.sql
:r 25_scheduler_pressure.sql
:r 38_instance_settings.sql
:r 29_ag_health.sql
:r 39_agent_alerts.sql
:r 10_failed_jobs.sql
:r 07_backup_history.sql
:r 08_backup_gaps.sql
:r 18_log_space_reuse.sql
:r 19_checkdb_last_good.sql
-- Database level
:r 01_table_sizes.sql
:r 02_index_fragmentation.sql
:r 03_missing_indexes.sql
:r 04_unused_indexes.sql
:r 17_stats_freshness.sql
:r 32_orphaned_users.sql
:r 34_untrusted_constraints.sql
:r 47_database_options.sql
:r 48_isolation_settings.sql
:r 46_suspect_pages.sql
