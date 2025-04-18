-- Foreign keys and check constraints that are disabled or not trusted. The optimizer ignores
-- untrusted constraints, which costs plan quality (join elimination, contradiction detection).
SELECT OBJECT_SCHEMA_NAME(fk.parent_object_id) + '.' + OBJECT_NAME(fk.parent_object_id) AS table_name,
       fk.name AS constraint_name,
       'FOREIGN KEY' AS kind,
       fk.is_disabled,
       fk.is_not_trusted,
       'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
         + ' WITH CHECK CHECK CONSTRAINT ' + QUOTENAME(fk.name) + ';' AS fix_statement
FROM sys.foreign_keys AS fk
WHERE fk.is_not_trusted = 1 OR fk.is_disabled = 1
UNION ALL
SELECT OBJECT_SCHEMA_NAME(cc.parent_object_id) + '.' + OBJECT_NAME(cc.parent_object_id),
       cc.name,
       'CHECK',
       cc.is_disabled,
       cc.is_not_trusted,
       'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(cc.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(cc.parent_object_id))
         + ' WITH CHECK CHECK CONSTRAINT ' + QUOTENAME(cc.name) + ';'
FROM sys.check_constraints AS cc
WHERE cc.is_not_trusted = 1 OR cc.is_disabled = 1
ORDER BY table_name, constraint_name;
