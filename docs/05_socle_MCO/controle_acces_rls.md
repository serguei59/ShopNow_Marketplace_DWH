# Contrôle d'accès — RLS (Row Level Security)

> **Statut : Bonus — hors périmètre C16/C17**

Le cloisonnement des données par vendeur via RLS Power BI est une évolution
prévue post-certification, non implémentée dans le périmètre actuel.

## Périmètre implémenté (C16)

La gestion des accès actuellement en place repose sur :

- **RBAC Azure SQL** — rôles `db_datareader`, `db_datawriter`, `db_owner`
  → voir [`security/rbac/rbac_mapping.md`](../../security/rbac/rbac_mapping.md)
- **Firewall SQL** — règles IP configurées via Terraform

## Évolution prévue (post-certification)

```dax
-- Exemple DAX pour RLS Power BI multi-vendeurs
[vendor_id] = LOOKUPVALUE(dim_vendor[vendor_id],
    dim_vendor[vendor_email], USERPRINCIPALNAME())
```

Cette règle limiterait chaque vendeur à la vision de ses propres stocks
et commandes dans les dashboards Power BI.
