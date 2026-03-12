# Cloisonnement multi-vendeur

## Principe

Dans un modèle Marketplace, chaque vendeur ne doit accéder **qu'à ses propres données**.
Le cloisonnement est implémenté en plusieurs couches complémentaires.

## Couches de sécurité implémentées

### Couche 1 — RBAC Azure SQL

Le rôle `Vendor` dans la matrice RBAC a accès uniquement à des **vues filtrées** :

```sql
-- Vue filtrée par vendeur (exemple)
CREATE VIEW dbo.vw_vendor_own_stock AS
SELECT s.*, v.vendor_name
FROM dbo.fact_vendor_stock s
INNER JOIN dbo.dim_vendor v ON s.vendor_sk = v.vendor_sk
WHERE v.vendor_id = USER_NAME()  -- filtre sur l'identité SQL
  AND v.is_current = 1;
```

| Objet | Accès vendeur |
|-------|---------------|
| `dim_vendor` | SELECT WHERE vendor_id = propre ID uniquement |
| `fact_vendor_stock` | Via vue filtrée uniquement |
| `dim_customer` | Aucun accès (PII clients) |
| `fact_order` | Aucun accès direct |
| `fact_clickstream` | Aucun accès (PII) |

### Couche 2 — Firewall SQL Server

Accès réseau restreint par IP (à renforcer en production) :

```bash
# Restreindre à une IP spécifique (exemple)
az sql server firewall-rule create \
  --resource-group rg-e6-sbuasa \
  --server sql-server-rg-e6-sbuasa \
  --name vendor-app \
  --start-ip-address 203.0.113.0 \
  --end-ip-address 203.0.113.255
```

> ⚠️ Situation actuelle : règle `0.0.0.0–255.255.255.255` (dev) — à restreindre en production.

### Couche 3 — Authentification dédiée par vendeur

Chaque vendeur dispose d'un login SQL nominatif avec permissions minimales :

```sql
-- Créer un login vendeur
CREATE LOGIN vendor_v001 WITH PASSWORD = '...';
CREATE USER  vendor_v001 FOR LOGIN vendor_v001;
GRANT SELECT ON dbo.vw_vendor_own_stock TO vendor_v001;
GRANT SELECT ON dbo.vw_vendor_stock_disponible TO vendor_v001;
```

## Matrice d'accès par rôle

| Rôle | dim_vendor | fact_vendor_stock | dim_customer | fact_order |
|------|------------|-------------------|--------------|------------|
| Admin | Tout | Tout | Tout | Tout |
| Data Engineer | Tout | Tout | Lecture | Lecture |
| Data Steward | Lecture | Lecture | Lecture + UPDATE | Lecture |
| MCO | Lecture | Lecture | — | Lecture |
| **Vendor** | **Propre ID** | **Vue filtrée** | **—** | **—** |

Voir matrice complète : [rbac_mapping.md](../../security/rbac/rbac_mapping.md)
