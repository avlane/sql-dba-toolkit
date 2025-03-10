-- Database users whose login no longer exists (typical after restoring to another server).
SELECT dp.name AS orphaned_user, dp.type_desc, dp.create_date,
       'ALTER USER ' + QUOTENAME(dp.name) + ' WITH LOGIN = ' + QUOTENAME(dp.name) + ';' AS repair_statement
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON sp.sid = dp.sid
WHERE dp.type IN ('S', 'U', 'G')
  AND sp.sid IS NULL
ORDER BY dp.name;
