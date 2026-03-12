# Stream Analytics — Job asa-shopnow

## Configuration

| Paramètre | Valeur |
|-----------|--------|
| Nom | `asa-shopnow` |
| Streaming Units | 1 |
| Compatibilité | 1.2 |
| Mode démarrage | `JobStartTime` (automatique via Terraform) |
| Statut actuel | `Running` |

## Inputs

| Input | Event Hub | Format | Groupe de consommateurs |
|-------|-----------|--------|------------------------|
| `InputOrders` | `orders` | JSON | `$Default` |
| `InputClickstream` | `clickstream` | JSON | `$Default` |
| `InputProducts` | `products` | JSON | `$Default` |

## Outputs

| Output | Table SQL | Opération |
|--------|-----------|-----------|
| `OutputOrders` | `dbo.fact_order` | INSERT |
| `OutputClickstream` | `dbo.fact_clickstream` | INSERT |
| `OutputProducts` | `dbo.dim_product` | INSERT (upsert via clé) |
| `OutputCustomers` | `dbo.dim_customer` | INSERT (upsert via clé) |

## Requêtes ASA (logique de transformation)

```sql
-- fact_order
SELECT
    order_id,
    product_id,
    customer_id,
    quantity,
    unit_price,
    status,
    order_timestamp
INTO OutputOrders
FROM InputOrders;

-- fact_clickstream
SELECT
    event_id,
    session_id,
    user_id,
    url,
    event_type,
    event_timestamp
INTO OutputClickstream
FROM InputClickstream;

-- dim_product (upsert)
SELECT
    product_id,
    name,
    category
INTO OutputProducts
FROM InputProducts;
```

## Monitoring du job

```sql
-- Vérifier la fraîcheur des données (dernière insertion)
SELECT
    'fact_order'       AS table_name, MAX(order_timestamp)  AS last_event FROM dbo.fact_order
UNION ALL
SELECT
    'fact_clickstream' AS table_name, MAX(event_timestamp)  AS last_event FROM dbo.fact_clickstream
UNION ALL
SELECT
    'dim_product'      AS table_name, MAX(CAST(product_id AS NVARCHAR(50))) AS last_event FROM dbo.dim_product;
```

Vérification statut Azure CLI :
```bash
az stream-analytics job list \
  --resource-group rg-e6-sbuasa \
  --query "[].{name:name, state:jobState}" -o table
```

## Point d'architecture — pourquoi Stream Analytics et pas ADF

| Critère | Stream Analytics | ADF |
|---------|-----------------|-----|
| Latence clickstream (2s) | ✓ Natif | ✗ Batch minimum 15 min |
| Coût MVP | ✓ 1 SU inclus | ✗ Coût par activité |
| Complexité déploiement | ✓ Terraform simple | ✗ ARM templates lourds |
| SCD2 vendeurs | ✗ Non adapté (pas de MERGE) | ✓ Possible mais surdimensionné |

→ Stream Analytics pour le streaming, procédure stockée pour le batch SCD2.
