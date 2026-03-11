-- =============================================================================
-- index_maintenance.sql — Maintenance des index Azure SQL (dwh-shopnow)
-- Fragmentation : REORGANIZE < 30% / REBUILD >= 30%
-- Compatible Azure SQL Database (pas de BACKUP, pas de OFFLINE REBUILD)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Rapport de fragmentation des index
-- -----------------------------------------------------------------------------
SELECT
    OBJECT_SCHEMA_NAME(ips.object_id)          AS schema_name,
    OBJECT_NAME(ips.object_id)                 AS table_name,
    i.name                                     AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE
        WHEN ips.avg_fragmentation_in_percent < 5  THEN 'OK — aucune action'
        WHEN ips.avg_fragmentation_in_percent < 30 THEN 'ATTENTION — REORGANIZE recommandé'
        ELSE                                            'ALERTE — REBUILD requis'
    END AS action_recommandee
FROM sys.dm_db_index_physical_stats(
    DB_ID(),   -- base courante
    NULL,      -- toutes les tables
    NULL,      -- tous les index
    NULL,      -- toutes les partitions
    'LIMITED'  -- mode rapide (DETAILED trop lourd sur S0)
) AS ips
INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
    AND ips.index_id  = i.index_id
WHERE ips.index_id > 0              -- exclure heap (index_id = 0)
  AND ips.page_count > 100          -- ignorer les très petits index
ORDER BY ips.avg_fragmentation_in_percent DESC;


-- -----------------------------------------------------------------------------
-- 2. REORGANIZE — fragmentation entre 5% et 30%
--    (online, non-bloquant, compatible Azure SQL S0)
-- -----------------------------------------------------------------------------
DECLARE @sql_reorg NVARCHAR(MAX) = N'';

SELECT @sql_reorg += N'ALTER INDEX ' + QUOTENAME(i.name)
    + N' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(ips.object_id))
    + N'.' + QUOTENAME(OBJECT_NAME(ips.object_id))
    + N' REORGANIZE;' + CHAR(10)
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
    AND ips.index_id  = i.index_id
WHERE ips.index_id > 0
  AND ips.page_count > 100
  AND ips.avg_fragmentation_in_percent >= 5
  AND ips.avg_fragmentation_in_percent < 30;

IF LEN(@sql_reorg) > 0
BEGIN
    PRINT '-- REORGANIZE en cours --';
    PRINT @sql_reorg;
    EXEC sp_executesql @sql_reorg;
END
ELSE
    PRINT '-- Aucun index à REORGANIZE --';


-- -----------------------------------------------------------------------------
-- 3. REBUILD — fragmentation >= 30%
--    ONLINE = ON requis sur Azure SQL (pas de lock table)
-- -----------------------------------------------------------------------------
DECLARE @sql_rebuild NVARCHAR(MAX) = N'';

SELECT @sql_rebuild += N'ALTER INDEX ' + QUOTENAME(i.name)
    + N' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(ips.object_id))
    + N'.' + QUOTENAME(OBJECT_NAME(ips.object_id))
    + N' REBUILD WITH (ONLINE = ON);' + CHAR(10)
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
    AND ips.index_id  = i.index_id
WHERE ips.index_id > 0
  AND ips.page_count > 100
  AND ips.avg_fragmentation_in_percent >= 30;

IF LEN(@sql_rebuild) > 0
BEGIN
    PRINT '-- REBUILD en cours --';
    PRINT @sql_rebuild;
    EXEC sp_executesql @sql_rebuild;
END
ELSE
    PRINT '-- Aucun index à REBUILD --';


-- -----------------------------------------------------------------------------
-- 4. UPDATE STATISTICS — toutes les tables DWH
-- -----------------------------------------------------------------------------
UPDATE STATISTICS dbo.dim_customer    WITH FULLSCAN;
UPDATE STATISTICS dbo.dim_product     WITH FULLSCAN;
UPDATE STATISTICS dbo.fact_order      WITH FULLSCAN;
UPDATE STATISTICS dbo.fact_clickstream WITH FULLSCAN;

PRINT '-- UPDATE STATISTICS terminé --';


-- -----------------------------------------------------------------------------
-- 5. Synthèse post-maintenance
-- -----------------------------------------------------------------------------
SELECT
    OBJECT_SCHEMA_NAME(ips.object_id)      AS schema_name,
    OBJECT_NAME(ips.object_id)             AS table_name,
    i.name                                 AS index_name,
    ROUND(ips.avg_fragmentation_in_percent, 2) AS fragmentation_pct,
    ips.page_count,
    GETUTCDATE()                           AS checked_at
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
    AND ips.index_id  = i.index_id
WHERE ips.index_id > 0
  AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
