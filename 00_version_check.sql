-- Prints the instance version and which feature groups the toolkit can use here.
SELECT SERVERPROPERTY('ProductVersion')      AS product_version,
       SERVERPROPERTY('ProductMajorVersion') AS major_version,   -- 13 = 2016, 14 = 2017, 15 = 2019, 16 = 2022, 17 = 2025
       SERVERPROPERTY('Edition')             AS edition,
       SERVERPROPERTY('EngineEdition')       AS engine_edition;

SELECT feature, available
FROM (VALUES
        (N'Query Store reports (14, 16, 24)',             CASE WHEN CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 13 THEN 1 ELSE 0 END),
        (N'Persistent version store (23)',                CASE WHEN CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 15 THEN 1 ELSE 0 END),
        (N'Query Store hints and DATETRUNC (10, 16)',     CASE WHEN CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 16 THEN 1 ELSE 0 END),
        (N'REGEXP functions (SQL Server 2025)',           CASE WHEN CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 17 THEN 1 ELSE 0 END)
     ) AS f(feature, available);
