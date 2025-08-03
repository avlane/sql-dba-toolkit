-- Expected Agent alerts: severity 19 to 25 and errors 823, 824, 825 (I/O and corruption).
WITH expected AS
(
    SELECT sev AS severity, CAST(NULL AS INT) AS message_id, CONCAT('Severity ', sev) AS label
    FROM (VALUES (19), (20), (21), (22), (23), (24), (25)) AS s(sev)
    UNION ALL
    SELECT 0, m, CONCAT('Error ', m) FROM (VALUES (823), (824), (825)) AS e(m)
)
SELECT x.label AS expected_alert,
       CASE WHEN a.id IS NULL THEN 'MISSING' WHEN a.enabled = 0 THEN 'disabled' ELSE 'ok' END AS state,
       a.name AS alert_name,
       a.has_notification
FROM expected AS x
LEFT JOIN msdb.dbo.sysalerts AS a
       ON a.severity = x.severity AND a.message_id = ISNULL(x.message_id, 0)
ORDER BY x.severity, x.message_id;
