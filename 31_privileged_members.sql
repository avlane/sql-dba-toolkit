-- Who can do anything? Server-level sysadmins first, then db_owner in the current database.
SELECT r.name AS server_role, m.name AS member, m.type_desc, m.is_disabled, m.create_date
FROM sys.server_role_members AS rm
JOIN sys.server_principals AS r ON r.principal_id = rm.role_principal_id
JOIN sys.server_principals AS m ON m.principal_id = rm.member_principal_id
WHERE r.name IN (N'sysadmin', N'securityadmin', N'serveradmin')
ORDER BY r.name, m.name;

SELECT DB_NAME() AS database_name, r.name AS database_role, m.name AS member, m.type_desc
FROM sys.database_role_members AS rm
JOIN sys.database_principals AS r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals AS m ON m.principal_id = rm.member_principal_id
WHERE r.name IN (N'db_owner', N'db_securityadmin')
ORDER BY r.name, m.name;
