-- Mail that failed to send in the last 7 days, with the reason.
SELECT f.mailitem_id,
       f.send_request_date,
       f.recipients,
       f.subject,
       l.description AS failure_reason
FROM msdb.dbo.sysmail_faileditems AS f
LEFT JOIN msdb.dbo.sysmail_event_log AS l ON l.mailitem_id = f.mailitem_id
WHERE f.send_request_date >= DATEADD(DAY, -7, GETDATE())
ORDER BY f.send_request_date DESC;
