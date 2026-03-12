# Exemples de code — Patterns clés

## Pattern SCD2 — Procédure MERGE

```sql
-- sp_merge_dim_vendor (résumé logique)
-- Cas 1 : Nouveau vendeur
IF NOT EXISTS (SELECT 1 FROM dim_vendor WHERE vendor_id = @vendor_id)
BEGIN
    INSERT INTO dim_vendor (vendor_id, vendor_name, commission_rate, valid_from, is_current)
    VALUES (@vendor_id, @vendor_name, @commission_rate, SYSUTCDATETIME(), 1)
END

-- Cas 2 : Changement d'attribut tracké
ELSE IF EXISTS (
    SELECT 1 FROM dim_vendor
    WHERE vendor_id = @vendor_id AND is_current = 1
      AND commission_rate <> @commission_rate  -- ou autre attribut tracké
)
BEGIN
    -- Fermer la version courante
    UPDATE dim_vendor SET valid_to = SYSUTCDATETIME(), is_current = 0
    WHERE vendor_id = @vendor_id AND is_current = 1

    -- Ouvrir une nouvelle version
    INSERT INTO dim_vendor (vendor_id, vendor_name, commission_rate, valid_from, is_current)
    VALUES (@vendor_id, @vendor_name, @commission_rate, SYSUTCDATETIME(), 1)
END

-- Cas 3 : Changement mineur (email uniquement)
ELSE
BEGIN
    UPDATE dim_vendor SET vendor_email = @vendor_email
    WHERE vendor_id = @vendor_id AND is_current = 1
END
```

Voir script complet : [sql/scd2/dim_vendor_merge.sql](../../sql/scd2/dim_vendor_merge.sql)

---

## Pattern monitoring DMV Azure SQL

```sql
-- Détection pipeline silencieux (fact_order)
SELECT
    CASE
        WHEN DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE()) > 10
        THEN 'ALERTE — Aucune commande depuis ' +
             CAST(DATEDIFF(MINUTE, MAX(order_timestamp), GETUTCDATE()) AS NVARCHAR) + ' min'
        ELSE 'OK'
    END AS statut_pipeline
FROM dbo.fact_order;
```

---

## Pattern backup BACPAC

```bash
# Export asynchrone Azure SQL → Blob Storage
az sql db export \
  --admin-password '***' \
  --admin-user sqladmin \
  --storage-key-type StorageAccessKey \
  --storage-key $STORAGE_KEY \
  --storage-uri "https://stshopnowbackup.blob.core.windows.net/sql-backups/weekly/dwh-shopnow-$(date +%F).bacpac" \
  --name dwh-shopnow \
  --resource-group rg-e6-sbuasa \
  --server sql-server-rg-e6-sbuasa
```

---

## Pattern requête historique SCD2

```sql
-- Historique complet des commissions d'un vendeur
SELECT
    vendor_id,
    vendor_name,
    commission_rate,
    valid_from,
    ISNULL(CONVERT(NVARCHAR(20), valid_to), 'en cours') AS valid_to,
    is_current
FROM dbo.dim_vendor
WHERE vendor_id = 'V001'
ORDER BY valid_from;
```

Résultat réel (2026-03-12) :
```
vendor_id  commission_rate  valid_from                   valid_to                     is_current
V001       12.50            2026-03-12 12:40:56.203      2026-03-12 12:41:48.559      0
V001       14.00            2026-03-12 12:41:48.559      en cours                     1
```
