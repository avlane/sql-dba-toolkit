-- Database users whose login no longer exists (typical after restoring to another server).
SELECT dp.name AS orphaned_user, dp.type_desc, dp.create_date,
       'ALTER USER ' + QUOTENAME(dp.name) + ' WITH LOGIN = ' + QUOTENAME(dp.name) + ';' AS repair_statement
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON sp.sid = dp.sid
WHERE dp.type IN ('S', 'U', 'G')
  AND sp.sid IS NULL
  AND dp.authentication_type_desc <> 'NONE'                 -- skip users without login
  AND dp.authentication_type_desc <> 'DATABASE'             -- contained users have no server login by design
  AND dp.name NOT IN (N'guest', N'INFORMATION_SCHEMA', N'sys', N'dbo')
  AND dp.sid IS NOT NULL
ORDER BY dp.name;
