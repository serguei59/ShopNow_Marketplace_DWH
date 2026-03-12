# Pipelines batch — SCD2 & Backups

## Périmètre

> **ADF (Azure Data Factory) n'est pas déployé** dans cette implémentation.
> Le volume de données batch (vendeurs quotidiens, stocks horaires) ne justifie pas
> le coût et la complexité d'ADF pour un MVP Marketplace.
>
> Les pipelines batch sont implémentés via **procédures stockées Azure SQL**
> exécutées directement depuis `sqlcmd` ou un scheduler externe.

---

## Pipeline 1 — Intégration vendeurs SCD2 (quotidien)

**Source :** API Marketplace (simulée) → appel `sp_merge_dim_vendor`

```
Déclencheur : quotidien 01h00
      │
      ▼
sp_merge_dim_vendor(@vendor_id, @vendor_name, @commission_rate, ...)
      │
      ├── vendor inconnu     → INSERT version 1 (is_current=1)
      ├── attribut tracké    → UPDATE valid_to + INSERT nouvelle version
      └── email seul         → UPDATE direct (pas de nouvelle version SCD2)
```

Exécution manuelle :
```bash
sqlcmd -S sql-server-rg-e6-sbuasa.database.windows.net \
  -U sqladmin -P '***' -d dwh-shopnow \
  -i sql/scd2/dim_vendor_merge.sql -C
```

---

## Pipeline 2 — Stocks vendeurs (horaire)

**Source :** API stocks Marketplace (simulée) → INSERT `fact_vendor_stock`

```sql
-- Pattern insert-only horodaté
INSERT INTO dbo.fact_vendor_stock
    (vendor_sk, product_id, quantity_available, quantity_reserved, unit_cost)
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

Chaque mise à jour = nouvel enregistrement horodaté (`stock_timestamp DEFAULT SYSUTCDATETIME()`).
Pas de UPDATE — auditabilité complète de l'historique des stocks.

---

## Pipeline 3 — Backup hebdomadaire (BACPAC)

**Script :** [`sql/backups/backup_full.sh`](../../sql/backups/backup_full.sh)

```bash
# Déclencheur : dimanche 02h00 (cron ou Azure Automation)
bash sql/backups/backup_full.sh
# → weekly/dwh-shopnow-YYYY-MM-DD.bacpac (2.4 MB testé le 2026-03-12)
```

---

## Pipeline 4 — Configuration LTR (Long-Term Retention)

**Script :** [`sql/backups/backup_ltr_config.sh`](../../sql/backups/backup_ltr_config.sh)

| Politique | Valeur |
|-----------|--------|
| Rétention hebdomadaire | 4 semaines |
| Rétention mensuelle | 12 mois |
| Rétention annuelle | 5 ans |

---

## Comparaison avec ADF (pour jury)

| Besoin | Solution implémentée | ADF équivalent |
|--------|---------------------|----------------|
| MERGE SCD2 quotidien | `sp_merge_dim_vendor` (procédure SQL) | Pipeline Copy + Mapping Data Flow |
| Stocks horaires | INSERT SQL direct | Pipeline Copy Activity |
| Backup complet | `az sql db export` (BACPAC) | Pipeline avec Azure Function |
| **Justification MVP** | **Volume < 1000 vendeurs/jour → surcoût ADF non justifié** | Approprié à partir de sources multiples hétérogènes |
