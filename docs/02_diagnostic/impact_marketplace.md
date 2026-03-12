# Impact du pivot Marketplace sur le DWH

## Évolutions du schéma de données

| Élément | Avant Marketplace | Après Marketplace (C17) |
|---------|------------------|------------------------|
| `dim_vendor` | Inexistant | SCD2 — valid_from/to, is_current, commission_rate |
| `dim_product` | product_id, name, category | + `vendor_id` FK nullable |
| `fact_vendor_stock` | Inexistant | stocks par vendeur/produit, insert-only |
| `fact_order` | Inchangé | Inchangé (vendor visible via dim_product.vendor_id) |
| `fact_clickstream` | Inchangé | Inchangé |

## Évolutions du pipeline d'ingestion

```
Avant C17 :
  ACI Python → Event Hubs → Stream Analytics → fact_order / fact_clickstream / dim_product

Après C17 :
  ACI Python → Event Hubs → Stream Analytics → fact_order / fact_clickstream / dim_product
  API vendeurs (batch quotidien)  → sp_merge_dim_vendor → dim_vendor (SCD2)
  API stocks   (batch horaire)    → INSERT horodaté    → fact_vendor_stock
```

## Évolutions de la gouvernance

| Domaine | Avant | Après |
|---------|-------|-------|
| RGPD | 2 traitements (commandes, clickstream) | + 1 traitement vendeurs tiers |
| RBAC | sqladmin uniquement | 5 rôles (Admin/DE/Steward/MCO/Vendor) |
| Backup | PITR natif Azure (non documenté) | PITR + BACPAC hebdo + LTR 5 ans |
| Monitoring | Aucun | 4 requêtes DMV + 6 règles Azure Monitor |

## Compatibilité ascendante

Le pivot Marketplace est **non destructif** sur l'existant :
- `fact_order` et `fact_clickstream` : **inchangés structurellement**
- `dim_product` : colonne `vendor_id` ajoutée en **nullable** → requêtes existantes non cassées
- Stream Analytics : flux existants **inchangés** — 2 nouveaux flux batch ajoutés en parallèle

Les requêtes analytiques existantes continuent de fonctionner sans modification.
