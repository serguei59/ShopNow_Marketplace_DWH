-- ============================================================
-- data_freshness.sql
-- Supervision fraîcheur pipeline — alertes ingestion ratée
-- Projet : DWH ShopNow Marketplace
-- Critère C16 : Journalisation catégorisée, supervision pipeline
-- Base : Azure SQL Database (sql-server-rg-e6-sbuasa / dwh-shopnow)
-- ============================================================


-- ------------------------------------------------------------
-- REQUÊTE 1 — Vue consolidée fraîcheur par table
-- Statut FRAIS / ATTENTION / STALE par table DWH
-- ------------------------------------------------------------
SELECT
    'fact_order'                                          AS table_name,
    MAX(order_timestamp)                                  AS derniere_entree,
    DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE())  AS retard_minutes,
    CASE
        WHEN DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE()) <= 5  THEN 'FRAIS'
        WHEN DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE()) <= 15 THEN 'ATTENTION'
        ELSE                                                                  'STALE'
    END AS statut
FROM dbo.fact_order

UNION ALL

SELECT
    'fact_clickstream',
    MAX(event_timestamp),
    DATEDIFF(MINUTE, MAX(event_timestamp), GETUTCDATE()),
    CASE
        WHEN DATEDIFF(MINUTE, MAX(event_timestamp), GETUTCDATE()) <= 2  THEN 'FRAIS'
        WHEN DATEDIFF(MINUTE, MAX(event_timestamp), GETUTCDATE()) <= 5  THEN 'ATTENTION'
        ELSE                                                                  'STALE'
    END
FROM dbo.fact_clickstream

UNION ALL

SELECT
    'dim_product',
    MAX(created_at),
    DATEDIFF(MINUTE, MAX(created_at), GETUTCDATE()),
    CASE
        WHEN DATEDIFF(MINUTE, MAX(created_at), GETUTCDATE()) <= 60  THEN 'FRAIS'
        WHEN DATEDIFF(MINUTE, MAX(created_at), GETUTCDATE()) <= 360 THEN 'ATTENTION'
        ELSE                                                              'STALE'
    END
FROM dbo.dim_product;


-- ------------------------------------------------------------
-- REQUÊTE 2 — Alerte pipeline orders : 0 commande dans les 15 dernières minutes
-- Déclencheur : pipeline Stream Analytics arrêté silencieusement
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                              AS commandes_15min,
    CASE
        WHEN COUNT(*) = 0 THEN 'ALERTE — pipeline orders interrompu'
        WHEN COUNT(*) < 3 THEN 'ATTENTION — volume anormalement bas'
        ELSE                   'OK'
    END AS statut_pipeline
FROM dbo.fact_order
WHERE order_timestamp >= DATEADD(MINUTE, -15, GETUTCDATE());


-- ------------------------------------------------------------
-- REQUÊTE 3 — Volume journalier J-7 (détection dérive tendancielle)
-- Comparaison jour par jour sur la semaine glissante
-- ------------------------------------------------------------
SELECT
    CAST(order_timestamp AS DATE)  AS jour,
    COUNT(*)                       AS nb_commandes,
    SUM(quantity * unit_price)     AS ca_journalier
FROM dbo.fact_order
WHERE order_timestamp >= DATEADD(DAY, -7, GETUTCDATE())
GROUP BY CAST(order_timestamp AS DATE)
ORDER BY jour DESC;


-- ------------------------------------------------------------
-- REQUÊTE 4 — Détection doublons récents sur fact_clickstream
-- event_id doit être unique — doublon = bug producteur ou re-delivery
-- ------------------------------------------------------------
SELECT
    event_id,
    COUNT(*) AS occurrences,
    MIN(event_timestamp) AS premiere_occurrence,
    MAX(event_timestamp) AS derniere_occurrence
FROM dbo.fact_clickstream
WHERE event_timestamp >= DATEADD(HOUR, -24, GETUTCDATE())
GROUP BY event_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
