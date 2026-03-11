-- ============================================================
-- pipeline_latency.sql
-- Indicateurs de performance pipeline — monitoring prédictif
-- Projet : DWH ShopNow Marketplace
-- Critère C16 : Indicateurs de service, performance pipeline
-- Base : Azure SQL Database (sql-server-rg-e6-sbuasa / dwh-shopnow)
-- ============================================================


-- ------------------------------------------------------------
-- REQUÊTE 1 — Latence inter-insertions fact_order avec LAG()
-- Mesure l'intervalle moyen entre deux commandes consécutives
-- Détecte les ralentissements du pipeline orders
-- ------------------------------------------------------------
SELECT
    AVG(intervalle_sec)   AS latence_moyenne_sec,
    MIN(intervalle_sec)   AS latence_min_sec,
    MAX(intervalle_sec)   AS latence_max_sec,
    STDEV(intervalle_sec) AS ecart_type_sec,
    COUNT(*)              AS nb_mesures,
    CASE
        WHEN AVG(intervalle_sec) > 300 THEN 'ALERTE — latence > 5 min'
        WHEN AVG(intervalle_sec) > 120 THEN 'ATTENTION — latence > 2 min'
        ELSE                                'OK'
    END AS statut
FROM (
    SELECT
        DATEDIFF(SECOND,
            LAG(order_timestamp) OVER (ORDER BY order_timestamp),
            order_timestamp
        ) AS intervalle_sec
    FROM (
        SELECT TOP 500 order_timestamp
        FROM dbo.fact_order
        ORDER BY order_timestamp DESC
    ) recent
) intervalles
WHERE intervalle_sec IS NOT NULL
  AND intervalle_sec > 0;


-- ------------------------------------------------------------
-- REQUÊTE 2 — Gaps clickstream > 10 secondes avec sévérité
-- Un silence > 60s sur le clickstream signale un arrêt producteur
-- ------------------------------------------------------------
SELECT
    debut_gap,
    fin_gap,
    duree_gap_sec,
    CASE
        WHEN duree_gap_sec > 60 THEN 'ALERTE'
        WHEN duree_gap_sec > 30 THEN 'ATTENTION'
        ELSE                         'INFO'
    END AS severite
FROM (
    SELECT
        LAG(event_timestamp) OVER (ORDER BY event_timestamp) AS debut_gap,
        event_timestamp                                       AS fin_gap,
        DATEDIFF(SECOND,
            LAG(event_timestamp) OVER (ORDER BY event_timestamp),
            event_timestamp
        )                                                     AS duree_gap_sec
    FROM (
        SELECT TOP 1000 event_timestamp
        FROM dbo.fact_clickstream
        ORDER BY event_timestamp DESC
    ) recent
) gaps
WHERE duree_gap_sec > 10
ORDER BY duree_gap_sec DESC;


-- ------------------------------------------------------------
-- REQUÊTE 3 — Volume horaire J-7 vs moyenne même heure
-- Détecte une dégradation progressive avant rupture complète
-- ------------------------------------------------------------
SELECT
    heure,
    jour,
    volume_heure,
    ROUND(AVG(volume_heure) OVER (PARTITION BY heure), 0) AS volume_moyen_meme_heure,
    ROUND(
        100.0 * (volume_heure - AVG(volume_heure) OVER (PARTITION BY heure))
              / NULLIF(AVG(volume_heure) OVER (PARTITION BY heure), 0),
    1)                                                     AS ecart_pct,
    CASE
        WHEN volume_heure < 0.5 * AVG(volume_heure) OVER (PARTITION BY heure)
        THEN 'ALERTE — volume < 50% moyenne'
        WHEN volume_heure < 0.75 * AVG(volume_heure) OVER (PARTITION BY heure)
        THEN 'ATTENTION — volume < 75% moyenne'
        ELSE 'OK'
    END AS statut
FROM (
    SELECT
        DATEPART(HOUR, order_timestamp)  AS heure,
        CAST(order_timestamp AS DATE)    AS jour,
        COUNT(*)                         AS volume_heure
    FROM dbo.fact_order
    WHERE order_timestamp >= DATEADD(DAY, -7, GETUTCDATE())
    GROUP BY DATEPART(HOUR, order_timestamp), CAST(order_timestamp AS DATE)
) volumes
ORDER BY jour DESC, heure;
