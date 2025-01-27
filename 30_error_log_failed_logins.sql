-- Reads the current error log for failed logins. xp_readerrorlog arguments:
-- log number (0 = current), log type (1 = SQL Server), search string 1, search string 2.
CREATE TABLE #log (LogDate DATETIME, ProcessInfo NVARCHAR(50), [Text] NVARCHAR(MAX));

INSERT INTO #log
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed';

SELECT CAST(LogDate AS DATE) AS log_day,
       COUNT(*) AS failures,
       MIN(LogDate) AS first_seen,
       MAX(LogDate) AS last_seen
FROM #log
GROUP BY CAST(LogDate AS DATE)
ORDER BY log_day DESC;

SELECT TOP (50) LogDate, [Text] FROM #log ORDER BY LogDate DESC;

DROP TABLE #log;
