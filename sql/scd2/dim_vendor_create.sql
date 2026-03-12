-- =============================================================================
-- dim_vendor_create.sql — Dimension vendeurs SCD Type 2
-- Contexte : pivot ShopNow vers Marketplace multi-vendeurs
-- SCD2 : conservation de l'historique des changements d'attributs vendeur
-- Compatible Azure SQL Database
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Création de la table dim_vendor (SCD2)
-- -----------------------------------------------------------------------------
CREATE TABLE dbo.dim_vendor (
    -- Clé de substitution (surrogate key) — immuable
    vendor_sk           INT IDENTITY(1,1)   NOT NULL,

    -- Clé métier (natural key) — identifiant source du vendeur
    vendor_id           NVARCHAR(50)        NOT NULL,

    -- Attributs métier (trackés en SCD2)
    vendor_name         NVARCHAR(200)       NOT NULL,
    vendor_email        NVARCHAR(200)       NULL,
    country             NVARCHAR(100)       NULL,
    region              NVARCHAR(100)       NULL,
    status              NVARCHAR(50)        NOT NULL  DEFAULT 'active',
    -- Valeurs status : active | suspended | closed

    commission_rate     DECIMAL(5,2)        NULL,
    -- Taux de commission en % (ex: 12.50 = 12,5%)

    -- Colonnes SCD2 — gestion de l'historique
    valid_from          DATETIME2           NOT NULL  DEFAULT SYSUTCDATETIME(),
    valid_to            DATETIME2           NULL,
    -- NULL = enregistrement courant ; sinon date de fermeture

    is_current          BIT                 NOT NULL  DEFAULT 1,
    -- 1 = version active, 0 = version historique

    -- Audit
    created_at          DATETIME2           NOT NULL  DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2           NOT NULL  DEFAULT SYSUTCDATETIME(),

    -- Contraintes
    CONSTRAINT PK_dim_vendor PRIMARY KEY (vendor_sk)
);

-- -----------------------------------------------------------------------------
-- 2. Index pour les requêtes fréquentes
-- -----------------------------------------------------------------------------
-- Recherche par clé métier (vendor_id) — jointure depuis fact tables
CREATE NONCLUSTERED INDEX IX_dim_vendor_vendor_id
    ON dbo.dim_vendor (vendor_id)
    INCLUDE (vendor_sk, vendor_name, is_current);

-- Filtre version courante
CREATE NONCLUSTERED INDEX IX_dim_vendor_is_current
    ON dbo.dim_vendor (is_current)
    INCLUDE (vendor_id, vendor_name, country, status);

-- -----------------------------------------------------------------------------
-- 3. Données initiales — vendeurs de démo ShopNow Marketplace
-- -----------------------------------------------------------------------------
INSERT INTO dbo.dim_vendor (
    vendor_id, vendor_name, vendor_email, country, region,
    status, commission_rate, valid_from, valid_to, is_current
)
VALUES
    ('V001', 'TechGadgets SAS',    'contact@techgadgets.fr',  'France',  'Île-de-France', 'active',    12.50, SYSUTCDATETIME(), NULL, 1),
    ('V002', 'ModaStyle GmbH',     'info@modastyle.de',       'Germany', 'Bavaria',       'active',    10.00, SYSUTCDATETIME(), NULL, 1),
    ('V003', 'HomeDecor Ltd',      'sales@homedecor.co.uk',   'UK',      'London',        'active',    11.00, SYSUTCDATETIME(), NULL, 1),
    ('V004', 'SportZone Iberia',   'hello@sportzone.es',      'Spain',   'Catalonia',     'suspended', 15.00, SYSUTCDATETIME(), NULL, 1);

-- -----------------------------------------------------------------------------
-- 4. Vérification post-création
-- -----------------------------------------------------------------------------
SELECT
    vendor_sk,
    vendor_id,
    vendor_name,
    status,
    commission_rate,
    valid_from,
    is_current
FROM dbo.dim_vendor
ORDER BY vendor_sk;
