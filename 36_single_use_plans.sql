-- Plans used exactly once are wasted cache. A high share suggests ad hoc literals;
-- consider parameterization or the 'optimize for ad hoc workloads' server option.
SELECT cp.objtype,
       COUNT(*) AS plans,
       SUM(CASE WHEN cp.usecounts = 1 THEN 1 ELSE 0 END) AS single_use_plans,
       CAST(SUM(CASE WHEN cp.usecounts = 1 THEN cp.size_in_bytes ELSE 0 END) / 1048576.0 AS DECIMAL(18,1)) AS single_use_mb,
       CAST(SUM(cp.size_in_bytes) / 1048576.0 AS DECIMAL(18,1)) AS total_mb
FROM sys.dm_exec_cached_plans AS cp
GROUP BY cp.objtype
ORDER BY single_use_mb DESC;

SELECT name, value_in_use FROM sys.configurations WHERE name = N'optimize for ad hoc workloads';
