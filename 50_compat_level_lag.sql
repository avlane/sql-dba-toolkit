-- Databases left on an old compatibility level after an upgrade or restore. Raising it is a
-- change with plan consequences (test with Query Store), but lagging forever forgoes optimizer fixes.
SELECT d.name AS database_name,
       d.compatibility_level,
       m.model_level AS instance_default,
       m.model_level - d.compatibility_level AS levels_behind
FROM sys.databases AS d
CROSS JOIN (SELECT compatibility_level AS model_level FROM sys.databases WHERE name = N'model') AS m
WHERE d.database_id > 4
  AND d.compatibility_level < m.model_level
ORDER BY levels_behind DESC, d.name;
