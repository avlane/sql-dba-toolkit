-- Run in a DBA utility database (it creates one small table). Takes a baseline of sys.configurations
-- the first time, then reports every setting whose value differs from that baseline.
IF OBJECT_ID(N'dbo.ConfigBaseline', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ConfigBaseline
    (
        configuration_id INT           NOT NULL PRIMARY KEY,
        name             NVARCHAR(35)  NOT NULL,
        value_in_use     SQL_VARIANT   NOT NULL,
        captured_at      DATETIME2(0)  NOT NULL DEFAULT (SYSDATETIME())
    );

    INSERT INTO dbo.ConfigBaseline (configuration_id, name, value_in_use)
    SELECT configuration_id, name, value_in_use FROM sys.configurations;

    PRINT 'Baseline captured. Run again later to see drift.';
END

SELECT c.name,
       b.value_in_use AS baseline_value,
       c.value_in_use AS current_value,
       b.captured_at  AS baseline_taken
FROM sys.configurations AS c
JOIN dbo.ConfigBaseline AS b ON b.configuration_id = c.configuration_id
WHERE CAST(c.value_in_use AS BIGINT) <> CAST(b.value_in_use AS BIGINT)
ORDER BY c.name;

-- Settings that exist now but not in the baseline (new after a version upgrade)
SELECT c.name, c.value_in_use AS current_value
FROM sys.configurations AS c
WHERE NOT EXISTS (SELECT 1 FROM dbo.ConfigBaseline AS b WHERE b.configuration_id = c.configuration_id);
