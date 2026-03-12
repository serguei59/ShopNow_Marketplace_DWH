-- =============================================================================
-- dim_product_update.sql — Enrichissement dim_product pour Marketplace
-- Ajout vendor_id FK → rattache chaque produit à son vendeur principal
-- Contexte : pivot ShopNow vers multi-vendeurs (C17)
-- Compatible Azure SQL Database — ALTER TABLE non destructif
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Ajout de la colonne vendor_id dans dim_product
-- -----------------------------------------------------------------------------
ALTER TABLE dbo.dim_product
ADD vendor_id NVARCHAR(50) NULL;
-- NULL par défaut : compatibilité avec les produits existants sans vendeur assigné

-- -----------------------------------------------------------------------------
-- 2. Mise à jour des produits existants — assignation vendeur par catégorie
-- -----------------------------------------------------------------------------
-- Logique de rattachement initiale basée sur la catégorie produit
UPDATE dbo.dim_product
SET vendor_id = CASE
    WHEN category IN ('Electronics', 'Tech', 'Gadgets')    THEN 'V001'  -- TechGadgets SAS
    WHEN category IN ('Fashion', 'Clothing', 'Accessories') THEN 'V002'  -- ModaStyle GmbH
    WHEN category IN ('Home', 'Decor', 'Furniture')        THEN 'V003'  -- HomeDecor Ltd
    WHEN category IN ('Sports', 'Outdoor', 'Fitness')      THEN 'V004'  -- SportZone Iberia
    ELSE 'V001'  -- vendeur par défaut pour catégories non mappées
END;

-- -----------------------------------------------------------------------------
-- 3. Contrainte FK vers dim_vendor (clé métier vendor_id)
-- Note : on référence vendor_id (natural key) et non vendor_sk (surrogate)
-- car dim_product n'a pas besoin de l'historique SCD2 pour ce rattachement
-- -----------------------------------------------------------------------------
-- Index préalable requis sur dim_vendor.vendor_id pour la FK
CREATE UNIQUE NONCLUSTERED INDEX UX_dim_vendor_vendor_id_current
    ON dbo.dim_vendor (vendor_id)
    WHERE is_current = 1;

-- -----------------------------------------------------------------------------
-- 4. Vérification post-mise à jour
-- -----------------------------------------------------------------------------
SELECT
    p.product_id,
    p.name          AS product_name,
    p.category,
    p.vendor_id,
    v.vendor_name,
    v.country,
    v.status        AS vendor_status
FROM dbo.dim_product p
LEFT JOIN dbo.dim_vendor v
    ON p.vendor_id = v.vendor_id
    AND v.is_current = 1
ORDER BY p.category, p.product_id;

-- Contrôle : produits sans vendeur assigné
SELECT COUNT(*) AS produits_sans_vendeur
FROM dbo.dim_product
WHERE vendor_id IS NULL;

-- Distribution par vendeur
SELECT
    vendor_id,
    COUNT(*) AS nb_produits
FROM dbo.dim_product
GROUP BY vendor_id
ORDER BY nb_produits DESC;
