-- Shows every blocking chain as a tree, head blocker first.
WITH blocked AS
(
    SELECT DISTINCT r.blocking_session_id AS head
    FROM sys.dm_exec_requests AS r
    WHERE r.blocking_session_id <> 0
      AND r.blocking_session_id NOT IN (SELECT session_id FROM sys.dm_exec_requests WHERE blocking_session_id <> 0)
),
tree AS
(
    SELECT s.session_id, CAST(0 AS INT) AS blocked_by, 0 AS lvl, CAST(RIGHT('0000' + CAST(s.session_id AS VARCHAR(5)), 5) AS VARCHAR(400)) AS sort_path
    FROM sys.dm_exec_sessions AS s
    JOIN blocked AS b ON b.head = s.session_id
    UNION ALL
    SELECT r.session_id, CAST(r.blocking_session_id AS INT), t.lvl + 1, CAST(t.sort_path + '.' + RIGHT('0000' + CAST(r.session_id AS VARCHAR(5)), 5) AS VARCHAR(400))
    FROM sys.dm_exec_requests AS r
    JOIN tree AS t ON t.session_id = r.blocking_session_id
)
SELECT REPLICATE('    ', t.lvl) + CAST(t.session_id AS VARCHAR(10)) AS session_tree,
       t.blocked_by,
       s.login_name,
       s.host_name,
       s.program_name,
       r.wait_type,
       r.wait_time AS wait_ms,
       DB_NAME(r.database_id) AS database_name
FROM tree AS t
JOIN sys.dm_exec_sessions AS s ON s.session_id = t.session_id
LEFT JOIN sys.dm_exec_requests AS r ON r.session_id = t.session_id
ORDER BY t.sort_path;
