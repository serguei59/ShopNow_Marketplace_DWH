-- =============================================================================
-- dim_vendor_merge.sql — Procédure MERGE SCD Type 2 pour dim_vendor
-- Logique :
--   - Nouvel enregistrement (vendor_id inconnu) → INSERT version 1
--   - Changement d'attribut tracké → fermer version courante + INSERT nouvelle
--   - Aucun changement → aucune action
-- Compatible Azure SQL Database
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Procédure stockée sp_merge_dim_vendor
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_merge_dim_vendor
    @vendor_id          NVARCHAR(50),
    @vendor_name        NVARCHAR(200),
    @vendor_email       NVARCHAR(200)   = NULL,
    @country            NVARCHAR(100)   = NULL,
    @region             NVARCHAR(100)   = NULL,
    @status             NVARCHAR(50)    = 'active',
    @commission_rate    DECIMAL(5,2)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @now DATETIME2 = SYSUTCDATETIME();

    -- ------------------------------------------------------------------
    -- Cas 1 : vendor_id inconnu → INSERT première version
    -- ------------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM dbo.dim_vendor WHERE vendor_id = @vendor_id
    )
    BEGIN
        INSERT INTO dbo.dim_vendor (
            vendor_id, vendor_name, vendor_email, country, region,
            status, commission_rate, valid_from, valid_to, is_current
        )
        VALUES (
            @vendor_id, @vendor_name, @vendor_email, @country, @region,
            @status, @commission_rate, @now, NULL, 1
        );
        PRINT 'INSERT — nouveau vendeur : ' + @vendor_id;
        RETURN;
    END

    -- ------------------------------------------------------------------
    -- Cas 2 : vendor_id connu — vérifier si un attribut tracké a changé
    -- Attributs trackés : vendor_name, country, region, status, commission_rate
    -- ------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM dbo.dim_vendor
        WHERE vendor_id   = @vendor_id
          AND is_current  = 1
          AND (
              vendor_name     <> @vendor_name
           OR ISNULL(country,  '')       <> ISNULL(@country,  '')
           OR ISNULL(region,   '')       <> ISNULL(@region,   '')
           OR status          <> @status
           OR ISNULL(commission_rate, -1) <> ISNULL(@commission_rate, -1)
          )
    )
    BEGIN
        -- Étape 2a : fermer la version courante
        UPDATE dbo.dim_vendor
        SET    valid_to   = @now,
               is_current = 0,
               updated_at = @now
        WHERE  vendor_id  = @vendor_id
          AND  is_current = 1;

        -- Étape 2b : insérer la nouvelle version
        INSERT INTO dbo.dim_vendor (
            vendor_id, vendor_name, vendor_email, country, region,
            status, commission_rate, valid_from, valid_to, is_current
        )
        VALUES (
            @vendor_id, @vendor_name, @vendor_email, @country, @region,
            @status, @commission_rate, @now, NULL, 1
        );
        PRINT 'SCD2 — nouvelle version créée pour : ' + @vendor_id;
        RETURN;
    END

    -- ------------------------------------------------------------------
    -- Cas 3 : aucun changement — mise à jour des attributs non trackés seulement
    -- (email peut changer sans créer une nouvelle version SCD2)
    -- ------------------------------------------------------------------
    UPDATE dbo.dim_vendor
    SET    vendor_email = @vendor_email,
           updated_at   = @now
    WHERE  vendor_id    = @vendor_id
      AND  is_current   = 1;

    PRINT 'UPDATE mineur — pas de nouvelle version SCD2 : ' + @vendor_id;
END;
GO

-- -----------------------------------------------------------------------------
-- 2. Test de la procédure
-- -----------------------------------------------------------------------------

-- Test 1 : changement de commission_rate pour V001 (doit créer SCD2)
EXEC dbo.sp_merge_dim_vendor
    @vendor_id       = 'V001',
    @vendor_name     = 'TechGadgets SAS',
    @vendor_email    = 'contact@techgadgets.fr',
    @country         = 'France',
    @region          = 'Île-de-France',
    @status          = 'active',
    @commission_rate = 14.00;  -- changement : 12.50 → 14.00

-- Test 2 : vérifier l'historique SCD2 de V001
SELECT
    vendor_sk,
    vendor_id,
    vendor_name,
    commission_rate,
    valid_from,
    valid_to,
    is_current
FROM dbo.dim_vendor
WHERE vendor_id = 'V001'
ORDER BY valid_from;

-- Test 3 : nouveau vendeur V005
EXEC dbo.sp_merge_dim_vendor
    @vendor_id       = 'V005',
    @vendor_name     = 'ElectroShop BV',
    @vendor_email    = 'info@electroshop.nl',
    @country         = 'Netherlands',
    @region          = 'Noord-Holland',
    @status          = 'active',
    @commission_rate = 9.50;

-- Synthèse finale
SELECT vendor_id, vendor_name, commission_rate, valid_from, valid_to, is_current
FROM dbo.dim_vendor
ORDER BY vendor_id, valid_from;
