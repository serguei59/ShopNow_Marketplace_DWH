# Adaptations SCD2 — Marketplace multi-vendeurs (C17)

---

## Contexte métier

Le pivot de ShopNow vers un modèle Marketplace nécessite d'intégrer des
**vendeurs tiers** dans le DWH. La dimension `dim_vendor` est implémentée
en **SCD Type 2** pour conserver l'historique des changements d'attributs
(commission, statut, région) — requis pour les analyses financières et
contractuelles.

---

## Modèle de données implémenté

| Table | Type | Rôle | Script |
|-------|------|------|--------|
| `dim_vendor` | Dimension SCD2 | Vendeurs avec historique | [`dim_vendor_create.sql`](../../sql/scd2/dim_vendor_create.sql) |
| `fact_vendor_stock` | Table de faits | Stocks par vendeur/produit | [`fact_vendor_stock.sql`](../../sql/scd2/fact_vendor_stock.sql) |
| `dim_product` (enrichi) | Dimension | Rattachement vendeur principal | [`dim_product_update.sql`](../../sql/scd2/dim_product_update.sql) |

### Colonnes SCD2 de dim_vendor

| Colonne | Rôle |
|---------|------|
| `vendor_sk` | Surrogate key — immuable, référencée dans les faits |
| `vendor_id` | Natural key — identifiant source |
| `valid_from` | Début de validité de la version |
| `valid_to` | Fin de validité (NULL = version courante) |
| `is_current` | 1 = version active, 0 = historique |

---

## Procédure MERGE SCD2

La procédure [`sp_merge_dim_vendor`](../../sql/scd2/dim_vendor_merge.sql)
gère automatiquement les trois cas :

| Cas | Déclencheur | Action |
|-----|-------------|--------|
| Nouveau vendeur | `vendor_id` inconnu | INSERT version 1 |
| Changement d'attribut tracké | `commission_rate`, `status`, `country`, `region`, `vendor_name` | Fermeture ancienne version + INSERT nouvelle version |
| Changement mineur | `vendor_email` uniquement | UPDATE sans nouvelle version SCD2 |

---

## Critères C17

| Critère | Artefact | Statut |
|---------|----------|--------|
| Modélisation SCD2 `dim_vendor` | `dim_vendor_create.sql` | [x] Fait |
| Procédure MERGE SCD2 | `dim_vendor_merge.sql` + `sp_merge_dim_vendor` | [x] Fait |
| Nouvelle fact `fact_vendor_stock` | `fact_vendor_stock.sql` + vue `vw_vendor_stock_disponible` | [x] Fait |
| Enrichissement `dim_product` | `dim_product_update.sql` (vendor_id FK) | [x] Fait |
| Documentation modélisation | `docs/06_SCD2/modelisation_SCD2.md` | [x] Fait |
| Documentation ETL | `docs/06_SCD2/adaptations_ETL.md` | [x] Fait |

---

## Choix techniques justifiés

| Besoin | Solution choisie | Alternative écartée | Raison |
|--------|-----------------|---------------------|--------|
| Gestion historique vendeurs | SCD2 (`valid_from/to`, `is_current`) | SCD1 (écrasement) | Traçabilité contractuelle commission requise |
| ETL vendeurs | Procédure stockée `sp_merge_dim_vendor` | ADF + Databricks | Volume batch quotidien ne justifie pas ADF |
| Stocks | `fact_vendor_stock` insert-only | Table de staging | Simplicité + auditabilité horodatée |

---

## Exemple SCD2 en action

```
vendor_sk  vendor_id  vendor_name       commission_rate  valid_from            valid_to              is_current
1          V001       TechGadgets SAS   12.50            2026-03-12 08:00:00   2026-03-12 11:00:00   0
5          V001       TechGadgets SAS   14.00            2026-03-12 11:00:00   NULL                  1
```

Requête pour accéder à la version courante :

```sql
SELECT * FROM dbo.dim_vendor WHERE is_current = 1;
```

Requête pour l'historique complet :

```sql
SELECT vendor_id, commission_rate, valid_from, valid_to, is_current
FROM dbo.dim_vendor WHERE vendor_id = 'V001' ORDER BY valid_from;
```
