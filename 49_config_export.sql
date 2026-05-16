-- Produces one JSON document with sys.configurations. Save it per instance and diff the files,
-- or load two documents into variables and compare with OPENJSON.
SELECT @@SERVERNAME AS server_name,
       CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(40)) AS product_version,
       SYSUTCDATETIME() AS captured_utc,
       (SELECT c.name, c.value_in_use AS value
        FROM sys.configurations AS c
        ORDER BY c.name
        FOR JSON PATH) AS configuration
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
