-- Global trace flags currently on. Compare with what the instance is supposed to have.
CREATE TABLE #tf (TraceFlag INT, [Status] INT, [Global] INT, [Session] INT);

INSERT INTO #tf
EXEC (N'DBCC TRACESTATUS(-1) WITH NO_INFOMSGS');

SELECT TraceFlag, [Global], [Session] FROM #tf ORDER BY TraceFlag;

DROP TABLE #tf;
