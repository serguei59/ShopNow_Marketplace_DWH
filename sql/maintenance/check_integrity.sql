-- =============================================================================
-- check_integrity.sql — Contrôle d'intégrité DWH ShopNow
-- Vérifie : orphelins FK, nulls critiques, volumétrie, cohérence métier
-- Compatible Azure SQL Database
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Orphelins — clés étrangères non référencées
-- -----------------------------------------------------------------------------
SELECT 'fact_order → dim_customer' AS controle,
       COUNT(*)                    AS nb_orphelins
FROM dbo.fact_order fo
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.dim_customer dc WHERE dc.customer_id = fo.customer_id
)
UNION ALL
SELECT 'fact_order → dim_product',
       COUNT(*)
FROM dbo.fact_order fo
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.dim_product dp WHERE dp.product_id = fo.product_id
);


-- -----------------------------------------------------------------------------
-- 2. Valeurs NULL sur colonnes critiques
-- -----------------------------------------------------------------------------
SELECT 'dim_customer.email NULL'   AS controle, COUNT(*) AS nb FROM dbo.dim_customer WHERE email IS NULL
UNION ALL
SELECT 'dim_customer.name NULL',   COUNT(*) FROM dbo.dim_customer WHERE name IS NULL
UNION ALL
SELECT 'fact_order.unit_price NULL', COUNT(*) FROM dbo.fact_order WHERE unit_price IS NULL
UNION ALL
SELECT 'fact_order.quantity NULL',   COUNT(*) FROM dbo.fact_order WHERE quantity IS NULL
UNION ALL
SELECT 'fact_clickstream.session_id NULL', COUNT(*) FROM dbo.fact_clickstream WHERE session_id IS NULL;


-- -----------------------------------------------------------------------------
-- 3. Volumétrie des tables
-- -----------------------------------------------------------------------------
SELECT
    t.name                                          AS table_name,
    p.rows                                          AS nb_lignes,
    CAST(a.total_pages * 8 / 1024.0 AS DECIMAL(10,2)) AS taille_mo,
    GETUTCDATE()                                    AS checked_at
FROM sys.tables t
INNER JOIN sys.indexes i     ON t.object_id = i.object_id AND i.index_id IN (0,1)
INNER JOIN sys.partitions p  ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.name IN ('dim_customer','dim_product','fact_order','fact_clickstream')
ORDER BY p.rows DESC;


-- -----------------------------------------------------------------------------
-- 4. Score de cohérence global (0–100)
-- -----------------------------------------------------------------------------
DECLARE @orphelins_cmd   INT = (SELECT COUNT(*) FROM dbo.fact_order fo WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_customer dc WHERE dc.customer_id = fo.customer_id));
DECLARE @orphelins_prod  INT = (SELECT COUNT(*) FROM dbo.fact_order fo WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_product  dp WHERE dp.product_id  = fo.product_id));
DECLARE @nulls_email     INT = (SELECT COUNT(*) FROM dbo.dim_customer WHERE email IS NULL);
DECLARE @nulls_prix      INT = (SELECT COUNT(*) FROM dbo.fact_order   WHERE unit_price IS NULL);

DECLARE @score INT = 100
    - (CASE WHEN @orphelins_cmd  > 0 THEN 25 ELSE 0 END)
    - (CASE WHEN @orphelins_prod > 0 THEN 25 ELSE 0 END)
    - (CASE WHEN @nulls_email    > 0 THEN 25 ELSE 0 END)
    - (CASE WHEN @nulls_prix     > 0 THEN 25 ELSE 0 END);

SELECT
    @score                                          AS score_coherence,
    CASE WHEN @score = 100 THEN 'OK'
         WHEN @score >= 75  THEN 'ATTENTION'
         ELSE                    'ALERTE'
    END                                             AS statut,
    GETUTCDATE()                                    AS evaluated_at;
