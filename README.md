# sql-dba-toolkit

A collection of T-SQL scripts I use for routine DBA checks: sizes, indexes, waits, blocking, backups, jobs, memory and security hygiene. Each script is standalone and read-only, and safe to run on a production instance (index fragmentation and the heap check read pages, and the wait stats delta sleeps for 30 seconds).

Originally written for SQL Server 2016 to 2019; newer features are marked per script and noted below.

## Scripts

| Script | Purpose | Needs |
|---|---|---|
| `00_version_check.sql` | version and available feature groups | any |
| `01_table_sizes.sql` | rows, data, index, unused space, compression | any |
| `02_index_fragmentation.sql` | fragmentation with a reorganize or rebuild hint | any |
| `03_missing_indexes.sql` | missing index suggestions with CREATE text | any |
| `04_unused_indexes.sql` | non-unique indexes with writes but no reads | any |
| `05_wait_stats_delta.sql` | waits over a sample window, benign waits removed | any |
| `06_blocking_tree.sql` | blocking chains as a tree | any |
| `07_backup_history.sql`, `08_backup_gaps.sql` | last backups and missing backups | any, AG aware |
| `09_db_files.sql` | file sizes and volume free space | 2008 R2 SP1 |
| `10_failed_jobs.sql` | failed Agent jobs, per-hour buckets | per-hour part needs 2022 |
| `11_vlf_counts.sql` | VLFs per database | 2016 SP2 |
| `12_tempdb_usage.sql`, `27_tempdb_contention.sql` | tempdb space and allocation contention | any |
| `13_plan_cache_top.sql` | top query shapes by CPU | any |
| `14_query_store_regressions.sql`, `24_query_store_waits.sql` | Query Store reports | 2016, waits 2017 |
| `15_config_drift.sql` | baseline of sys.configurations and drift | any |
| `16_query_store_hints.sql` | Query Store hints | 2022 |
| `17_stats_freshness.sql` | stale statistics | any |
| `18_log_space_reuse.sql` | log use and reuse wait | 2012 |
| `19_checkdb_last_good.sql` | last good CHECKDB | 2016 |
| `20_io_latency.sql`, `21_memory.sql`, `25_scheduler_pressure.sql` | I/O, memory, CPU pressure | any |
| `22_job_duration_outliers.sql` | jobs running much longer than usual | any |
| `23_adr_version_store.sql` | accelerated database recovery | 2019 |
| `26_autogrowth_events.sql` | autogrowths from the default trace | default trace on |
| `28_blocking_json.sql` | blocking as JSON | 2016 |
| `29_ag_health.sql` | availability group health | Always On |
| `30` to `42` | error log logins, privileged members, orphaned users, duplicate indexes, untrusted constraints, forwarded heap records, single-use plans, file growth, instance settings, Agent alerts, Database Mail, linked servers, trace flags | any |
| `43_optimized_locking.sql` | optimized locking status | 2025 |
| `44_forced_plan_failures.sql` | Query Store forced plans that fail | 2016 |
| `45_backup_chain.sql` | log backup LSN chain holes | any |
| `46_suspect_pages.sql` | damaged pages recorded by the engine | any |
| `47_database_options.sql` | auto_close, auto_shrink, page_verify, TRUSTWORTHY | any |
| `48_isolation_settings.sql` | RCSI, snapshot, session isolation levels | any |
| `49_config_export.sql` | `sys.configurations` as JSON | 2016 |
| `50_compat_level_lag.sql` | databases below the model compatibility level | any |
| `51_cpu_history.sql` | SQL versus other CPU, last hour | any |
| `run_all.sql` | SQLCMD runner | any |

## Sample output

`01_table_sizes.sql`:

```
schema_name  table_name    row_count  reserved_mb  data_mb  index_mb  unused_mb  data_compression
-----------  ------------  ---------  -----------  -------  --------  ---------  ----------------
dbo          OrderLines    4812033    612.88       401.20   205.31    6.37       PAGE
dbo          Orders        1204118    188.45       120.62   66.70     1.13       ROW
dbo          Customers     82110      14.38        9.12     5.00      0.26       NONE
```

`37_file_growth_settings.sql`:

```
database_name  logical_name  type_desc  size_mb  growth_setting  finding
-------------  ------------  ---------  -------  --------------  ---------------
Staging        Staging_log   LOG        512.0    10 %            percent growth
ReportingDW    ReportingDW   ROWS       8192.0   1.0 MB          increment under 64 MB
```

## SQL Server 2025 notes

- `07_backup_history.sql` has an optional `REGEXP_LIKE` database filter and `30_error_log_failed_logins.sql` extracts client addresses with `REGEXP_SUBSTR`. Both need compatibility level 170. On older versions remove those parts.
- `43_optimized_locking.sql` reads `DATABASEPROPERTYEX(..., 'IsOptimizedLockingOn')`, which returns NULL before SQL Server 2025.

## More sample output

`05_wait_stats_delta.sql` over a 30 second window on a busy reporting server:

```
wait_type          explanation                                       waiting_tasks  wait_time_ms  resource_wait_ms  signal_wait_ms  pct_of_total
-----------------  ------------------------------------------------  -------------  ------------  ----------------  --------------  ------------
PAGEIOLATCH_SH     Waiting for a data page to be read from disk      18422          61840         61790             50              38.20
CXPACKET           Parallelism; check MAXDOP and cost threshold      9021           34115         33870             245             21.07
SOS_SCHEDULER_YIELD CPU pressure: tasks yielding to wait for ...     52010          12480         210               12270           7.71
WRITELOG           Waiting for the transaction log flush             3315           9832          9710              122             6.07
```
