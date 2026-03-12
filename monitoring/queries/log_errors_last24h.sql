-- ============================================================
-- log_errors_last24h.sql
-- Journalisation catégorisée : alertes et erreurs — 24 dernières heures
-- Projet : DWH ShopNow Marketplace
-- Critère C16 : Journalisation catégorisée alertes/erreurs
-- Base : Azure SQL Database (sql-server-rg-e6-sbuasa / dwh-shopnow)
-- ============================================================


-- ------------------------------------------------------------
-- REQUÊTE 1 — Événements critiques (connexions échouées, deadlocks, throttling)
-- Source : sys.event_log (Azure SQL — disponible sans droits admin)
-- ------------------------------------------------------------
SELECT
    event_time,
    event_type,
    database_name,
    server_principal_name,
    CASE
        WHEN event_type IN ('deadlock', 'throttling')              THEN 'ALERTE'
        WHEN event_type = 'connection_failed'                      THEN 'ATTENTION'
        ELSE                                                             'INFO'
    END AS severite
FROM sys.event_log
WHERE event_time >= DATEADD(HOUR, -24, GETUTCDATE())
  AND event_type IN (
      'connection_failed',
      'deadlock',
      'throttling',
      'connection_successful'   -- inclus pour ratio ok/total
  )
ORDER BY event_time DESC;


-- ------------------------------------------------------------
-- REQUÊTE 2 — Sessions bloquantes actives
-- Source : sys.dm_exec_requests
-- ------------------------------------------------------------
SELECT
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time / 1000.0        AS wait_time_sec,
    r.total_elapsed_time / 1000.0 AS elapsed_sec,
    SUBSTRING(t.text, 1, 200)   AS query_extrait,
    CASE
        WHEN r.wait_time > 30000 THEN 'ALERTE'    -- > 30 s
        WHEN r.wait_time > 10000 THEN 'ATTENTION' -- > 10 s
        ELSE                          'OK'
    END AS severite
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0   -- sessions effectivement bloquées
ORDER BY r.wait_time DESC;


-- ------------------------------------------------------------
-- REQUÊTE 3 — Consommation ressources (CPU / IO / mémoire) — 1h glissante
-- Source : sys.dm_db_resource_stats (granularité 15 s, conservé 1h)
-- ------------------------------------------------------------
SELECT
    end_time,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    avg_memory_usage_percent,
    CASE
        WHEN avg_cpu_percent      > 80 THEN 'ALERTE-CPU'
        WHEN avg_data_io_percent  > 80 THEN 'ALERTE-IO'
        WHEN avg_cpu_percent      > 60 THEN 'ATTENTION-CPU'
        WHEN avg_data_io_percent  > 60 THEN 'ATTENTION-IO'
        ELSE                                'OK'
    END AS severite
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;


-- ------------------------------------------------------------
-- REQUÊTE 4 — Top 10 requêtes les plus coûteuses (CPU cumulé)
-- Source : sys.dm_exec_query_stats + sys.dm_exec_sql_text
-- ------------------------------------------------------------
SELECT TOP 10
    qs.total_worker_time / qs.execution_count / 1000 AS avg_cpu_ms,
    qs.total_elapsed_time / qs.execution_count / 1000 AS avg_elapsed_ms,
    qs.execution_count,
    qs.total_logical_reads / qs.execution_count      AS avg_logical_reads,
    SUBSTRING(qt.text, 1, 300)                       AS query_extrait,
    qs.last_execution_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.total_worker_time DESC;
