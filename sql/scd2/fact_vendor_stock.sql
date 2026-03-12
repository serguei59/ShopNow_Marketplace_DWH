-- =============================================================================
-- fact_vendor_stock.sql — Table de faits stocks vendeurs (Marketplace)
-- Contexte : chaque vendeur gère son propre stock par produit
-- Lien SCD2 : vendor_sk (surrogate key) pointe vers dim_vendor version active
-- Compatible Azure SQL Database
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Création de la table fact_vendor_stock
-- -----------------------------------------------------------------------------
CREATE TABLE dbo.fact_vendor_stock (
    -- Clé primaire
    stock_id            INT IDENTITY(1,1)   NOT NULL,

    -- Clés étrangères
    vendor_sk           INT                 NOT NULL,
    -- FK vers dim_vendor.vendor_sk (surrogate key SCD2 — version active)

    product_id          INT                 NOT NULL,
    -- FK vers dim_product.product_id

    -- Mesures
    quantity_available  INT                 NOT NULL  DEFAULT 0,
    quantity_reserved   INT                 NOT NULL  DEFAULT 0,
    -- reserved = en cours de commande, pas encore expédié

    unit_cost           DECIMAL(10,2)       NULL,
    -- Prix d'achat vendeur (confidentiel)

    -- Horodatage
    stock_timestamp     DATETIME2           NOT NULL  DEFAULT SYSUTCDATETIME(),
    -- Date/heure de la mise à jour du stock

    -- Contraintes
    CONSTRAINT PK_fact_vendor_stock PRIMARY KEY (stock_id),

    CONSTRAINT FK_fact_vendor_stock_vendor
        FOREIGN KEY (vendor_sk)
        REFERENCES dbo.dim_vendor (vendor_sk),

    CONSTRAINT FK_fact_vendor_stock_product
        FOREIGN KEY (product_id)
        REFERENCES dbo.dim_product (product_id),

    CONSTRAINT CHK_quantity_available
        CHECK (quantity_available >= 0),

    CONSTRAINT CHK_quantity_reserved
        CHECK (quantity_reserved >= 0)
);

-- -----------------------------------------------------------------------------
-- 2. Index
-- -----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_fact_vendor_stock_vendor_sk
    ON dbo.fact_vendor_stock (vendor_sk)
    INCLUDE (product_id, quantity_available, stock_timestamp);

CREATE NONCLUSTERED INDEX IX_fact_vendor_stock_product_id
    ON dbo.fact_vendor_stock (product_id)
    INCLUDE (vendor_sk, quantity_available);

-- -----------------------------------------------------------------------------
-- 3. Données de démo — stocks initiaux
-- -----------------------------------------------------------------------------
INSERT INTO dbo.fact_vendor_stock (vendor_sk, product_id, quantity_available, quantity_reserved, unit_cost)
SELECT
    v.vendor_sk,
    p.product_id,
    CAST(RAND(CHECKSUM(NEWID())) * 500 AS INT) + 10  AS quantity_available,
    CAST(RAND(CHECKSUM(NEWID())) * 20  AS INT)       AS quantity_reserved,
    ROUND(RAND(CHECKSUM(NEWID())) * 50 + 5, 2)       AS unit_cost
FROM dbo.dim_vendor  v
CROSS JOIN dbo.dim_product p
WHERE v.is_current = 1
  AND p.product_id IN (
      SELECT TOP 5 product_id FROM dbo.dim_product ORDER BY product_id
  );

-- -----------------------------------------------------------------------------
-- 4. Vue analytique — stock disponible net par vendeur/produit
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW dbo.vw_vendor_stock_disponible AS
SELECT
    v.vendor_id,
    v.vendor_name,
    v.country,
    p.product_id,
    p.name                                              AS product_name,
    p.category,
    s.quantity_available,
    s.quantity_reserved,
    s.quantity_available - s.quantity_reserved          AS stock_net,
    s.stock_timestamp
FROM dbo.fact_vendor_stock s
INNER JOIN dbo.dim_vendor  v ON s.vendor_sk  = v.vendor_sk  AND v.is_current = 1
INNER JOIN dbo.dim_product p ON s.product_id = p.product_id;
GO

-- -----------------------------------------------------------------------------
-- 5. Vérification post-création
-- -----------------------------------------------------------------------------
SELECT TOP 10 * FROM dbo.vw_vendor_stock_disponible ORDER BY vendor_id, product_id;
