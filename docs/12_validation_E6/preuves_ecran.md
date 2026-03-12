# Preuves — Tests en conditions réelles

> Les captures d'écran sont remplacées par des **sorties terminal réelles**
> documentées avec timestamps Azure — plus fiables qu'une capture statique.

---

## Preuve 1 — Infrastructure déployée

```bash
az resource list --resource-group rg-e6-sbuasa --query "[].{name:name, type:type}" -o table
# → 21 ressources : Event Hubs, SQL Server, SQL DB, Stream Analytics, ACI ×2, Storage...
```

Statut vérifié le 2026-03-12 :
- Stream Analytics `asa-shopnow` → **Running**
- ACI `aeh-producers` → **Running** (restartCount: 0)

---

## Preuve 2 — Backup complet BACPAC

```bash
bash sql/backups/backup_full.sh
# → weekly/dwh-shopnow-2026-03-12.bacpac
# → Taille : 2.4 MB
# → Stockage : stshopnowbackup / sql-backups/weekly/
```

---

## Preuve 3 — LTR (Long-Term Retention)

```bash
bash sql/backups/backup_ltr_config.sh
# → weeklyRetention: P4W
# → monthlyRetention: P12M
# → yearlyRetention: P5Y
```

---

## Preuve 4 — Intégrité données (check_integrity.sql)

```
Résultats 2026-03-12 :
- Orphelins fact_order → dim_customer : 0
- Orphelins fact_order → dim_product  : 0
- NULL email dim_customer             : 0
- NULL unit_price fact_order          : 3004 ⚠ (anomalie Stream Analytics)
- Score cohérence global              : 75/100 (ATTENTION)
```

---

## Preuve 5 — Maintenance index (index_maintenance.sql)

```
Résultats 2026-03-12 :
- fact_clickstream : fragmentation 99.9% → REBUILD ONLINE → 0.28%
- UPDATE STATISTICS : toutes tables
```

---

## Preuve 6 — SCD2 dim_vendor en action

```
vendor_sk  vendor_id  commission_rate  valid_from                   valid_to                     is_current
1          V001       12.50            2026-03-12 12:40:56.203      2026-03-12 12:41:48.559      0
5          V001       14.00            2026-03-12 12:41:48.559      NULL                         1
```

---

## Preuve 7 — dim_product enrichi

```bash
sqlcmd ... -i sql/scd2/dim_product_update.sql -C
# → (972 rows affected)
# → produits_sans_vendeur : 0
# → V001: 587 / V002: 195 / V003: 190
```

---

## Preuve 8 — fact_vendor_stock + vue analytique

```bash
sqlcmd ... -i sql/scd2/fact_vendor_stock.sql -C
# → (25 rows affected) — 5 vendeurs × 5 produits
# → vw_vendor_stock_disponible : stock_net calculé, jointure SCD2 is_current=1
```
