-- Pages SQL Server has flagged as damaged (823, 824, 825 errors). An empty result is the goal.
-- event_type: 1 = 823 or 824, 2 = bad checksum, 3 = torn page, 4 = restored, 5 = repaired, 7 = deallocated by DBCC
SELECT DB_NAME(sp.database_id) AS database_name,
       sp.file_id,
       sp.page_id,
       sp.event_type,
       sp.error_count,
       sp.last_update_date
FROM msdb.dbo.suspect_pages AS sp
ORDER BY sp.last_update_date DESC;
