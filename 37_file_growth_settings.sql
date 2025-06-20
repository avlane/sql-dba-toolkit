-- Percent growth gets slower as files grow; tiny fixed increments cause many autogrowths.
-- Log growth in particular should be a fixed size between 64 MB and 1 GB.
SELECT DB_NAME(database_id) AS database_name,
       name AS logical_name,
       type_desc,
       CAST(size * 8 / 1024.0 AS DECIMAL(18,1)) AS size_mb,
       CASE WHEN is_percent_growth = 1 THEN CAST(growth AS VARCHAR(10)) + ' %'
            ELSE CAST(CAST(growth * 8 / 1024.0 AS DECIMAL(18,1)) AS VARCHAR(20)) + ' MB' END AS growth_setting,
       CASE WHEN growth = 0 THEN 'autogrowth disabled'
            WHEN is_percent_growth = 1 THEN 'percent growth'
            WHEN growth * 8 / 1024.0 < 64 THEN 'increment under 64 MB'
            WHEN type_desc = 'LOG' AND growth * 8 / 1024.0 > 1024 THEN 'log increment over 1 GB' END AS finding
FROM sys.master_files
WHERE database_id <> 2
  AND (growth = 0 OR is_percent_growth = 1 OR growth * 8 / 1024.0 < 64
       OR (type_desc = 'LOG' AND growth * 8 / 1024.0 > 1024))
ORDER BY database_name, logical_name;
