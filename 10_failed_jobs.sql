-- Failed job steps and job outcomes in the last N days, newest first.
DECLARE @Days INT = 7;

SELECT j.name AS job_name,
       h.step_id,
       h.step_name,
       msdb.dbo.agent_datetime(h.run_date, h.run_time) AS run_at,
       (h.run_duration / 10000) * 3600 + (h.run_duration / 100 % 100) * 60 + h.run_duration % 100 AS duration_sec,
       h.sql_message_id,
       h.sql_severity,
       h.message
FROM msdb.dbo.sysjobhistory AS h
JOIN msdb.dbo.sysjobs       AS j ON j.job_id = h.job_id
WHERE h.run_status = 0                                     -- 0 = failed
  AND msdb.dbo.agent_datetime(h.run_date, h.run_time) >= DATEADD(DAY, -@Days, GETDATE())
ORDER BY run_at DESC, h.step_id DESC;
