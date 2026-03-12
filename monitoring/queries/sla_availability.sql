-- ============================================================
-- sla_availability.sql
-- Indicateurs de service basés sur SLA
-- Projet : DWH ShopNow Marketplace
-- Critère C16 : Indicateurs de service basés sur les SLA
-- SLA cibles : disponibilité ≥ 99,9% / latence fact_order ≤ 5min / clickstream ≤ 2min
-- Base : Azure SQL Database (sql-server-rg-e6-sbuasa / dwh-shopnow)
-- ============================================================


-- ------------------------------------------------------------
-- REQUÊTE 1 — Taux de disponibilité par jour sur 30 jours
-- Source : sys.event_log (connexions ok / total)
-- SLA cible : ≥ 99,9 % de connexions réussies par jour
-- ------------------------------------------------------------
SELECT
    CAST(event_time AS DATE)                              AS jour,
    COUNT(*)                                              AS total_connexions,
    SUM(CASE WHEN event_type = 'connection_successful'
             THEN 1 ELSE 0 END)                           AS connexions_ok,
    SUM(CASE WHEN event_type = 'connection_failed'
             THEN 1 ELSE 0 END)                           AS connexions_ko,
    ROUND(
        100.0 * SUM(CASE WHEN event_type = 'connection_successful'
                         THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0),
    2)                                                    AS taux_disponibilite_pct,
    CASE
        WHEN ROUND(100.0 * SUM(CASE WHEN event_type = 'connection_successful'
                                    THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) >= 99.9
        THEN 'SLA OK'
        ELSE 'SLA KO'
    END AS statut_sla
FROM sys.event_log
WHERE event_time >= DATEADD(DAY, -30, GETUTCDATE())
  AND event_type IN ('connection_successful', 'connection_failed')
GROUP BY CAST(event_time AS DATE)
ORDER BY jour DESC;


-- ------------------------------------------------------------
-- REQUÊTE 2 — Fraîcheur temps réel avec étiquettes SLA
-- SLA fact_order : ≤ 5 min | SLA fact_clickstream : ≤ 2 min
-- ------------------------------------------------------------
SELECT
    'fact_order'                                              AS table_name,
    MAX(order_timestamp)                                      AS derniere_entree,
    DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE())      AS retard_minutes,
    5                                                         AS sla_max_minutes,
    CASE
        WHEN DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE()) <= 5
        THEN 'SLA OK' ELSE 'SLA KO'
    END AS statut_sla
FROM dbo.fact_order

UNION ALL

SELECT
    'fact_clickstream',
    MAX(event_timestamp),
    DATEDIFF(MINUTE, MAX(event_timestamp), GETUTCDATE()),
    2,
    CASE
        WHEN DATEDIFF(MINUTE, MAX(event_timestamp), GETUTCDATE()) <= 2
        THEN 'SLA OK' ELSE 'SLA KO'
    END
FROM dbo.fact_clickstream;


-- ------------------------------------------------------------
-- REQUÊTE 3 — Synthèse mensuelle KPI (rapport direction)
-- Vue agrégée mois en cours : volume, disponibilité, incidents
-- ------------------------------------------------------------
SELECT
    YEAR(event_time)                                      AS annee,
    MONTH(event_time)                                     AS mois,
    COUNT(*)                                              AS total_evenements,
    SUM(CASE WHEN event_type = 'connection_successful'
             THEN 1 ELSE 0 END)                           AS connexions_ok,
    SUM(CASE WHEN event_type = 'connection_failed'
             THEN 1 ELSE 0 END)                           AS connexions_ko,
    SUM(CASE WHEN event_type = 'deadlock'
             THEN 1 ELSE 0 END)                           AS deadlocks,
    SUM(CASE WHEN event_type = 'throttling'
             THEN 1 ELSE 0 END)                           AS throttlings,
    ROUND(
        100.0 * SUM(CASE WHEN event_type = 'connection_successful'
                         THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0),
    2)                                                    AS disponibilite_pct
FROM sys.event_log
WHERE event_time >= DATEADD(MONTH, -1, GETUTCDATE())
GROUP BY YEAR(event_time), MONTH(event_time)
ORDER BY annee DESC, mois DESC;

