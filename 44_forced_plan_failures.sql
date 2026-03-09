-- Plans forced in Query Store that have failed to force. A failing forced plan means the query
-- is running on whatever plan the optimizer picks, usually the one the force was meant to avoid.
SELECT q.query_id,
       p.plan_id,
       p.is_forced_plan,
       p.force_failure_count,
       p.last_force_failure_reason_desc,
       LEFT(qt.query_sql_text, 200) AS query_text
FROM sys.query_store_plan AS p
JOIN sys.query_store_query AS q ON q.query_id = p.query_id
JOIN sys.query_store_query_text AS qt ON qt.query_text_id = q.query_text_id
WHERE p.is_forced_plan = 1
  AND p.force_failure_count > 0
ORDER BY p.force_failure_count DESC;
