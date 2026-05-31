-- Produces one JSON document with sys.configurations. Save it per instance and diff the files,
-- or load two documents into variables and compare with OPENJSON.
SELECT @@SERVERNAME AS server_name,
       CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(40)) AS product_version,
       SYSUTCDATETIME() AS captured_utc,
       (SELECT c.name, CAST(c.value_in_use AS BIGINT) AS value
        FROM sys.configurations AS c
        ORDER BY c.name
        FOR JSON PATH) AS configuration
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

-- Compare two exports (paste the JSON into the variables):
-- DECLARE @a NVARCHAR(MAX) = N'...', @b NVARCHAR(MAX) = N'...';
-- SELECT a.name, a.value AS value_a, b.value AS value_b
-- FROM OPENJSON(@a, '$.configuration') WITH (name NVARCHAR(100), value BIGINT) AS a
-- JOIN OPENJSON(@b, '$.configuration') WITH (name NVARCHAR(100), value BIGINT) AS b ON b.name = a.name
-- WHERE a.value <> b.value;
