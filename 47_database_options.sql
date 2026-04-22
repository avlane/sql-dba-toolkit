-- Options that are almost always a mistake on a production database.
SELECT d.name AS database_name,
       d.compatibility_level,
       d.is_auto_close_on,
       d.is_auto_shrink_on,
       d.page_verify_option_desc,
       d.is_auto_create_stats_on,
       d.is_auto_update_stats_on,
       d.is_trustworthy_on,
       CASE WHEN d.is_auto_close_on = 1 THEN 'auto_close on; ' ELSE '' END
     + CASE WHEN d.is_auto_shrink_on = 1 THEN 'auto_shrink on; ' ELSE '' END
     + CASE WHEN d.page_verify_option_desc <> N'CHECKSUM' THEN 'page_verify is not CHECKSUM; ' ELSE '' END
     + CASE WHEN d.is_auto_update_stats_on = 0 THEN 'auto update statistics off; ' ELSE '' END
     + CASE WHEN d.is_trustworthy_on = 1 AND d.database_id > 4 THEN 'TRUSTWORTHY on; ' ELSE '' END AS findings
FROM sys.databases AS d
WHERE d.database_id > 4
  AND (d.is_auto_close_on = 1 OR d.is_auto_shrink_on = 1 OR d.page_verify_option_desc <> N'CHECKSUM'
       OR d.is_auto_update_stats_on = 0 OR d.is_trustworthy_on = 1)
ORDER BY d.name;
