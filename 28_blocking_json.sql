-- Same data as 06_blocking_tree.sql, flattened into a JSON document for an agent that ships it elsewhere.
SELECT (SELECT r.session_id,
               r.blocking_session_id,
               r.wait_type,
               r.wait_time AS wait_ms,
               r.wait_resource,
               DB_NAME(r.database_id) AS [database],
               s.login_name,
               s.host_name,
               s.program_name
        FROM sys.dm_exec_requests AS r
        JOIN sys.dm_exec_sessions AS s ON s.session_id = r.session_id
        WHERE r.blocking_session_id <> 0
        FOR JSON PATH) AS blocked_requests,
       SYSUTCDATETIME() AS captured_utc,
       @@SERVERNAME AS server_name
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
