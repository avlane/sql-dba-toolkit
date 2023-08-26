-- LastGoodCheckDbTime is 1900-01-01 when CHECKDB has never completed cleanly (or the page-verify
-- state was reset), so treat that as "never".
SELECT d.name AS database_name,
       d.page_verify_option_desc,
       CASE WHEN CAST(DATABASEPROPERTYEX(d.name, 'LastGoodCheckDbTime') AS DATETIME) <= '19000101' THEN NULL
            ELSE CAST(DATABASEPROPERTYEX(d.name, 'LastGoodCheckDbTime') AS DATETIME) END AS last_good_checkdb,
       DATEDIFF(DAY, CAST(DATABASEPROPERTYEX(d.name, 'LastGoodCheckDbTime') AS DATETIME), GETDATE()) AS days_since
FROM sys.databases AS d
WHERE d.state_desc = 'ONLINE'
  AND d.database_id <> 2
ORDER BY days_since DESC;
