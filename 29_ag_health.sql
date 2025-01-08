-- One row per database per replica as seen from this instance. Empty on instances without Always On.
SELECT ag.name AS ag_name,
       ar.replica_server_name,
       ars.role_desc,
       ars.connected_state_desc,
       ars.synchronization_health_desc AS replica_health,
       DB_NAME(drs.database_id) AS database_name,
       drs.synchronization_state_desc,
       drs.synchronization_health_desc AS db_health,
       drs.log_send_queue_size AS log_send_queue_kb,
       drs.redo_queue_size AS redo_queue_kb,
       drs.last_commit_time
FROM sys.availability_groups AS ag
JOIN sys.availability_replicas AS ar ON ar.group_id = ag.group_id
JOIN sys.dm_hadr_availability_replica_states AS ars ON ars.replica_id = ar.replica_id
LEFT JOIN sys.dm_hadr_database_replica_states AS drs ON drs.replica_id = ar.replica_id
ORDER BY ag.name, ar.replica_server_name, database_name;
