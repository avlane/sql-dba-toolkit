-- What is using tempdb: user objects, internal objects (sorts, spools, hashes) or the version store?
SELECT CAST(SUM(user_object_reserved_page_count) * 8 / 1024.0 AS DECIMAL(18,1))      AS user_objects_mb,
       CAST(SUM(internal_object_reserved_page_count) * 8 / 1024.0 AS DECIMAL(18,1))  AS internal_objects_mb,
       CAST(SUM(version_store_reserved_page_count) * 8 / 1024.0 AS DECIMAL(18,1))    AS version_store_mb,
       CAST(SUM(unallocated_extent_page_count) * 8 / 1024.0 AS DECIMAL(18,1))        AS free_mb,
       CAST(SUM(total_page_count) * 8 / 1024.0 AS DECIMAL(18,1))                     AS total_mb
FROM tempdb.sys.dm_db_file_space_usage;

-- Sessions using the most tempdb right now (allocations minus deallocations, in MB)
SELECT TOP (15)
       su.session_id,
       s.login_name,
       s.program_name,
       CAST((su.user_objects_alloc_page_count - su.user_objects_dealloc_page_count) * 8 / 1024.0 AS DECIMAL(18,1)) AS user_mb,
       CAST((su.internal_objects_alloc_page_count - su.internal_objects_dealloc_page_count) * 8 / 1024.0 AS DECIMAL(18,1)) AS internal_mb
FROM sys.dm_db_session_space_usage AS su
JOIN sys.dm_exec_sessions AS s ON s.session_id = su.session_id
WHERE s.is_user_process = 1
ORDER BY (su.user_objects_alloc_page_count - su.user_objects_dealloc_page_count)
       + (su.internal_objects_alloc_page_count - su.internal_objects_dealloc_page_count) DESC;
