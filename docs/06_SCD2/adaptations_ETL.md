# Adaptations ETL — Intégration SCD2 Marketplace

## Contexte

L'introduction de `dim_vendor` (SCD2) et `fact_vendor_stock` nécessite
d'adapter le pipeline d'ingestion existant :

```
Avant C17 :  Event Hubs → Stream Analytics → fact_order / fact_clickstream
Après C17 :  Event Hubs → Stream Analytics → fact_order / fact_clickstream
             API vendeurs (batch) → sp_merge_dim_vendor → dim_vendor (SCD2)
             API vendeurs (batch) → fact_vendor_stock
```

## Flux existants (inchangés)

| Flux | Source | Destination | Fréquence |
|------|--------|-------------|-----------|
| Commandes | Event Hub `orders` | `fact_order` | Temps réel (2s) |
| Clickstream | Event Hub `clickstream` | `fact_clickstream` | Temps réel (2s) |
| Produits | Event Hub `products` | `dim_product` | 120s |

## Nouveaux flux C17

| Flux | Source | Destination | Fréquence | Mécanisme |
|------|--------|-------------|-----------|-----------|
| Vendeurs | API Marketplace (batch) | `dim_vendor` | Quotidien | `sp_merge_dim_vendor` (SCD2) |
| Stocks | API Marketplace (batch) | `fact_vendor_stock` | Toutes les heures | INSERT horodaté |

## Logique ETL dim_vendor (SCD2)

La procédure `sp_merge_dim_vendor` gère automatiquement les trois cas :

```
Source (API vendeurs)
        │
        ▼
sp_merge_dim_vendor(@vendor_id, @vendor_name, ...)
        │
        ├── vendor_id inconnu → INSERT version 1 (is_current=1)
        │
        ├── attribut tracké changé → UPDATE version courante (valid_to=now, is_current=0)
        │                            INSERT nouvelle version (valid_from=now, is_current=1)
        │
        └── aucun changement → UPDATE email uniquement (pas de nouvelle version SCD2)
```

## Logique ETL fact_vendor_stock

Les stocks sont des faits ponctuels — chaque mise à jour est un nouvel
enregistrement horodaté (pattern **insert-only**) :

```sql
INSERT INTO dbo.fact_vendor_stock (vendor_sk, product_id, quantity_available, quantity_reserved, unit_cost)
SELECT
    v.vendor_sk,
    @product_id,
    @quantity_available,
    @quantity_reserved,
    @unit_cost
FROM dbo.dim_vendor v
WHERE v.vendor_id  = @vendor_id
  AND v.is_current = 1;
```

## Requête analytique type — stock courant par vendeur

```sql
SELECT
    vendor_id,
    vendor_name,
    product_name,
    quantity_available,
    stock_net,
    stock_timestamp
FROM dbo.vw_vendor_stock_disponible
WHERE stock_net > 0
ORDER BY vendor_id, product_name;
```

## Impact sur les requêtes existantes

Les tables `fact_order`, `fact_clickstream`, `dim_customer` et `dim_product`
ne sont **pas modifiées structurellement** — seule `dim_product` reçoit
une colonne `vendor_id` additionnelle (nullable, non bloquante).

Les requêtes existantes continuent de fonctionner sans modification.

## Séquence de déploiement C17

```bash
# 1. Créer dim_vendor
sqlcmd -S sql-server-rg-e6-sbuasa.database.windows.net \
  -U sqladmin -P 'P@ssw0rd!2024' -d dwh-shopnow \
  -i sql/scd2/dim_vendor_create.sql -C

# 2. Créer la procédure SCD2
sqlcmd -S sql-server-rg-e6-sbuasa.database.windows.net \
  -U sqladmin -P 'P@ssw0rd!2024' -d dwh-shopnow \
  -i sql/scd2/dim_vendor_merge.sql -C

# 3. Créer fact_vendor_stock
sqlcmd -S sql-server-rg-e6-sbuasa.database.windows.net \
  -U sqladmin -P 'P@ssw0rd!2024' -d dwh-shopnow \
  -i sql/scd2/fact_vendor_stock.sql -C

# 4. Enrichir dim_product
sqlcmd -S sql-server-rg-e6-sbuasa.database.windows.net \
  -U sqladmin -P 'P@ssw0rd!2024' -d dwh-shopnow \
  -i sql/scd2/dim_product_update.sql -C
```
