-- Data and log file autogrowths still in the default trace (it keeps 5 files of 20 MB).
-- Many small growths mean the file growth setting is too low.
DECLARE @path NVARCHAR(260) = (SELECT REVERSE(SUBSTRING(REVERSE([path]), CHARINDEX('\', REVERSE([path])), 260)) + N'log.trc'
                               FROM sys.traces WHERE is_default = 1);

SELECT t.DatabaseName,
       t.[FileName],
       te.name AS event_name,
       t.StartTime,
       t.Duration / 1000 AS duration_ms,
       t.IntegerData * 8 / 1024 AS growth_mb
FROM sys.fn_trace_gettable(@path, DEFAULT) AS t
JOIN sys.trace_events AS te ON te.trace_event_id = t.EventClass
WHERE t.EventClass IN (92, 93)           -- 92 = Data File Auto Grow, 93 = Log File Auto Grow
ORDER BY t.StartTime DESC;
