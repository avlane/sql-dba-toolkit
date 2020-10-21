# sql-dba-toolkit

A collection of T-SQL scripts I use for routine DBA checks: sizes, indexes, waits, blocking and backups. Each script is standalone, read-only, and safe to run on a production instance.

Developed against SQL Server 2016 to 2019.

## Scripts

| Script | Purpose |
|---|---|
| `01_table_sizes.sql` | rows, data, index and unused space per table |
| `02_index_fragmentation.sql` | fragmentation with a reorganize or rebuild hint |
| `03_missing_indexes.sql` | missing index suggestions with a score and CREATE text |
| `04_unused_indexes.sql` | non-unique indexes with writes but no reads |
| `05_wait_stats_delta.sql` | waits over a 30 second window, benign waits removed |
| `06_blocking_tree.sql` | blocking chains as a tree with SQL text |
| `07_backup_history.sql` | latest full, differential and log backups |
| `08_backup_gaps.sql` | databases missing backups |
| `run_all.sql` | SQLCMD runner for the database-scoped reports |

Index fragmentation reads pages, and wait stats waits; everything else only reads catalog views and DMVs.
