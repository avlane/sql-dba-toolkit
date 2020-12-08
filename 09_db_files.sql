SELECT DB_NAME(f.database_id) AS database_name,
       f.name AS logical_name,
       f.type_desc,
       CAST(f.size * 8 / 1024.0 AS DECIMAL(18,1)) AS size_mb,
       CASE WHEN f.is_percent_growth = 1 THEN CAST(f.growth AS VARCHAR(10)) + ' %'
            ELSE CAST(CAST(f.growth * 8 / 1024.0 AS DECIMAL(18,1)) AS VARCHAR(20)) + ' MB' END AS growth,
       v.volume_mount_point,
       CAST(v.total_bytes / 1073741824.0 AS DECIMAL(18,1))     AS volume_gb,
       CAST(v.available_bytes / 1073741824.0 AS DECIMAL(18,1)) AS volume_free_gb,
       CAST(100.0 * v.available_bytes / v.total_bytes AS DECIMAL(5,1)) AS volume_free_pct
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS v
ORDER BY volume_free_pct, database_name, f.file_id;


-- Space used inside the files of the CURRENT database
SELECT name AS logical_name,
       type_desc,
       CAST(size * 8 / 1024.0 AS DECIMAL(18,1))                                  AS size_mb,
       CAST(FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024.0 AS DECIMAL(18,1))      AS used_mb,
       CAST((size - FILEPROPERTY(name, 'SpaceUsed')) * 8 / 1024.0 AS DECIMAL(18,1)) AS free_mb
FROM sys.database_files;
