-- Jobs whose most recent successful run took much longer than their usual run.
WITH runs AS
(
    SELECT h.job_id,
           msdb.dbo.agent_datetime(h.run_date, h.run_time) AS run_at,
           (h.run_duration / 10000) * 3600 + (h.run_duration / 100 % 100) * 60 + h.run_duration % 100 AS duration_sec
    FROM msdb.dbo.sysjobhistory AS h
    WHERE h.step_id = 0 AND h.run_status = 1            -- job outcome rows, succeeded
),
ranked AS
(
    SELECT *, ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY run_at DESC) AS rn FROM runs
)
SELECT j.name AS job_name,
       latest.run_at,
       latest.duration_sec AS latest_sec,
       CAST(AVG(CASE WHEN r.rn > 1 THEN r.duration_sec * 1.0 END) AS DECIMAL(18,1)) AS usual_sec,
       CAST(latest.duration_sec / NULLIF(AVG(CASE WHEN r.rn > 1 THEN r.duration_sec * 1.0 END), 0) AS DECIMAL(10,1)) AS ratio
FROM ranked AS r
JOIN ranked AS latest ON latest.job_id = r.job_id AND latest.rn = 1
JOIN msdb.dbo.sysjobs AS j ON j.job_id = r.job_id
WHERE r.rn <= 30
GROUP BY j.name, latest.run_at, latest.duration_sec
HAVING COUNT(*) > 5
   AND latest.duration_sec > 3 * AVG(CASE WHEN r.rn > 1 THEN r.duration_sec * 1.0 END)
   AND latest.duration_sec > 60
ORDER BY ratio DESC;
