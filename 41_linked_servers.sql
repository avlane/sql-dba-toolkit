-- Linked servers with their provider, data source and how logins are mapped.
SELECT s.name AS linked_server,
       s.product,
       s.provider,
       s.data_source,
       s.is_data_access_enabled,
       s.is_rpc_out_enabled,
       s.modify_date,
       ll.uses_self_credential,
       ll.remote_name
FROM sys.servers AS s
LEFT JOIN sys.linked_logins AS ll ON ll.server_id = s.server_id AND ll.local_principal_id = 0
WHERE s.is_linked = 1
ORDER BY s.name;
