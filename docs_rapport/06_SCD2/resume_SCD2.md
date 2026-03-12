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

## Tests en conditions réelles — 2026-03-12

### Commande de déploiement
```bash
sqlcmd -S sql-server-rg-e6-sbuasa.database.windows.net \
  -U sqladmin -P '***' -d dwh-shopnow \
  -i sql/scd2/dim_vendor_create.sql -C
# → (4 rows affected) — 4 vendeurs insérés

sqlcmd ... -i sql/scd2/dim_vendor_merge.sql -C
# → SCD2 — nouvelle version créée pour : V001
# → INSERT — nouveau vendeur : V005

sqlcmd ... -i sql/scd2/fact_vendor_stock.sql -C
# → (25 rows affected) — stocks initiaux 5 vendeurs × 5 produits

sqlcmd ... -i sql/scd2/dim_product_update.sql -C
# → (972 rows affected) — produits assignés aux vendeurs
```

### SCD2 en action — V001 commission 12.50 → 14.00

```
vendor_sk  vendor_id  vendor_name      commission_rate  valid_from                   valid_to                     is_current
1          V001       TechGadgets SAS  12.50            2026-03-12 12:40:56.203      2026-03-12 12:41:48.559      0
5          V001       TechGadgets SAS  14.00            2026-03-12 12:41:48.559      NULL                         1
```

Ancienne version fermée (`valid_to` renseigné, `is_current=0`), nouvelle version active (`is_current=1`).

### Résultats dim_product enrichi

| Métrique | Valeur |
|----------|--------|
| Produits total | 972 |
| Produits sans vendeur | **0** |
| V001 TechGadgets (Electronics + défaut) | 587 |
| V002 ModaStyle (Clothing) | 195 |
| V003 HomeDecor (Home) | 190 |

### Vue vw_vendor_stock_disponible

```
vendor_id  vendor_name      product_name                        quantity_available  stock_net
V001       TechGadgets SAS  Persevering stable alliance         85                  80
V001       TechGadgets SAS  Universal actuating Local Area...   495                 482
V002       ModaStyle GmbH   Persevering stable alliance         24                  14
...
(25 lignes — 5 vendeurs actifs × 5 produits)
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
